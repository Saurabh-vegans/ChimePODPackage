//
//  MeetingDataManager.swift
//  ChimePOC
//
//  Created by Luigi Da Ros on 29/09/21.
//

import Foundation
import AmazonChimeSDK

class MeetingDataManager {
    
    static private var sharedInstance: MeetingDataManager?
    
    static func shared() -> MeetingDataManager {
        if sharedInstance == nil {
            sharedInstance = MeetingDataManager()
        }
        return sharedInstance!
    }
	
	private var joinMeetingResponse: InternalMeetingServerResponse?
	private var eventsBuffer = [MeetingEvent]()

    func requestMeetingData(body: RestoreMeetingRequestBody,
                     completionHandler: ((MeetingSessionConfiguration?, ServerErr?) -> Void)?)
    {
        NetworkManager.shared().globalJoinMeeting(body: body) { result in
            
            switch result {
                
				case .success(let response):
					guard let joinMeetingResponse = response else {
						completionHandler?(nil,ServerErr.unmanagedError)
						return
					}
					
                self.joinMeetingResponse =  MeetingServerResponseadapter.createInternalMeetingResponse(serverResponse: joinMeetingResponse)
					
					guard let meetingResp = self.getCreateMeetingResponse(),
						  let attendeeResp = self.getCreateAttendeeResponse()
					else {
						completionHandler?(nil,ServerErr.unmanagedError)
						return
					}
					
					completionHandler?(MeetingSessionConfiguration(createMeetingResponse: meetingResp,
                                                              createAttendeeResponse: attendeeResp,
                                                              urlRewriter: self.urlRewriter), nil)
                
				case .failure(let error):
					completionHandler?(nil,error)
                
            }
        }
    }
    
    public func requestE2EVideoTest(base64: String,
                     completionHandler: ((ServerErr?) -> Void)?)
    {
        NetworkManager.shared().requestE2EVideoTest(base64: base64) { error in
            // We only log the error
            if let error = error {
                VeganLogger.err("Error requesting E2E video test: \(error.localizedDescription)")
            }
        }
    }
    
    func sendMeetingLeftData(body: AttendeeLeftMeetingBody,
                     completionHandler: ((ServerErr?) -> Void)?) {
        NetworkManager.shared().globalLeftMeeting(body: body) { result in
            
            switch result {
                case .success(let response):
                    guard let _ = response else {
                        completionHandler?(ServerErr.unmanagedError)
                        return
                    }
                completionHandler?(nil)
                case .failure(let error):
                    completionHandler?(error)
                
            }
        }
    }
	
    
    /// Return the local attendee informations
    /// - Returns: the local attendee informations
	func getClientAttendeeInfo() -> InternalResponseAttendee? {
        return self.joinMeetingResponse?.localAttendee
	}
	
    
    /// To use for check if the attendee is the local attendee
    /// - Parameter attendee: the attendee data from server
    /// - Returns: true if the attendee is the local one
	func isClientAttendee(_ attendee: AttendeeInfo) -> Bool {
        let clientId = self.joinMeetingResponse?.localAttendee?.attendee?.attendeeID
		return clientId != nil && attendee.attendeeId == clientId
	}
    
    /// To use for check if the attendee is the agent
    /// - Parameter attendee: the attendee data from server
    /// - Returns: true if the attendee is the agent
	func isAgentAttendee(_ attendee: AttendeeInfo) -> Bool {
        let clientId = self.joinMeetingResponse?.localAttendee?.attendee?.attendeeID
		return clientId != nil && attendee.attendeeId != clientId
	}
    
    /// To use for check if the attendee is the local attendee
    /// - Parameter attendee: the attendee ID
    /// - Returns: true if the attendee is the local one
	func isClientAttendee(_ attendeeId: String) -> Bool {
        let clientId = self.joinMeetingResponse?.localAttendee?.attendee?.attendeeID
		return attendeeId == clientId
	}
    
    // To use for check if the attendee is the agent
    /// - Parameter attendee: the attendee ID
    /// - Returns: true if the attendee is the agent
	func isAgentAttendee(_ attendeeId: String) -> Bool {
        let localAttendeeId = self.joinMeetingResponse?.localAttendee?.attendee?.attendeeID
        return attendeeId != localAttendeeId
	}
	
	func sendMeetingEvents() {
		let events = self.eventsBuffer
		self.eventsBuffer = []
		DispatchQueue.global(qos: .utility).async {
			NetworkManager.shared().postMeetingEvents(events: events) { result in
				switch result {
					case .success(_):
						VeganLogger.log("Sended events:\n\(events)")
					case .failure(let err):
						VeganLogger.log("FAILED sending events with error:\n\(err)")
				}
			}
		}
	}
    
	func appendToEventBuffer(name: EventName, attributes: [AnyHashable : Any], for session: DefaultMeetingSession?) {
		
		guard let currentMeetingSession = session else {
			return
		}
		
		var mutableAttributes = attributes
		let meetingHistory = currentMeetingSession.audioVideo.getMeetingHistory()
		mutableAttributes = mutableAttributes.merging(currentMeetingSession.audioVideo.getCommonEventAttributes(),
													  uniquingKeysWith: { (_, newVal) -> Any in
			newVal
		})
		
		switch name {
		case EventName.videoInputFailed,
			 EventName.meetingStartFailed,
			 EventName.meetingFailed:
				mutableAttributes = mutableAttributes.merging([
					EventAttributeName.meetingHistory: meetingHistory
				] as [EventAttributeName: Any], uniquingKeysWith: { (_, newVal) -> Any in
					newVal})
		default:
			// TODO
			break
		}
		
		let meetingEvent: MeetingEvent = [
			"name": "\(name)",
			"attributes": toStringKeyDict(attributes.merging(currentMeetingSession.audioVideo.getCommonEventAttributes(),
															 uniquingKeysWith: { (_, newVal) -> Any in
				newVal
			}))
		]
		
		eventsBuffer.append(meetingEvent)
		
	}
    
	private func toStringKeyDict(_ attributes: [AnyHashable: Any]) -> [String: Any] {
		var jsonDict = [String: Any]()
		attributes.forEach { (key, value) in
			jsonDict[String(describing: key)] = String(describing: value)
		}
		return jsonDict
	}

    private func getCreateMeetingResponse() -> CreateMeetingResponse?
    {
        guard let meeting = joinMeetingResponse?.meeting else { return nil }
        
        let mediaPlacement = MediaPlacement(audioFallbackUrl: meeting.mediaPlacement!.audioFallbackURL!,
                                            audioHostUrl: meeting.mediaPlacement!.audioHostURL!,
                                            signalingUrl: meeting.mediaPlacement!.signalingURL!,
                                            turnControlUrl: meeting.mediaPlacement!.turnControlURL!,
                                            eventIngestionUrl: meeting.mediaPlacement!.eventIngestionURL)
        
        let meetingResp = CreateMeetingResponse(meeting:
                                                    Meeting(
                                                        externalMeetingId: meeting.externalMeetingID!,
                                                        mediaPlacement: mediaPlacement,
                                                        mediaRegion: meeting.mediaRegion!,
                                                        meetingId: meeting.meetingID!
                                                    )
        )
        return meetingResp
    }
    
    private func getCreateAttendeeResponse() -> CreateAttendeeResponse?
    {
        guard let attendee = joinMeetingResponse?.localAttendee?.attendee else { return nil }
        
        let attendeeResp = CreateAttendeeResponse(attendee:
                                                    Attendee(attendeeId: attendee.attendeeID!,
                                                             externalUserId: attendee.externalUserID!,
                                                             joinToken: attendee.joinToken!)
        )
        
        return attendeeResp
    }
    
    private func urlRewriter(url: String) -> String {
        // changing url
        // return url.replacingOccurrences(of: "example.com", with: "my.example.com")
        return url
    }
    
}
