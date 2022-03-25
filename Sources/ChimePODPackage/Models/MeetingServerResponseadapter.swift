//
//  MeetingServerResponseadapter.swift
//  
//
//  Created by Luigi Villa on 12/11/21.
//

import Foundation

/// This class is used to translate the meeting server response into our internal data structure, this avoids refactoring the whole app if the server response changes.
class MeetingServerResponseadapter: NSObject
{
    class func createInternalMeetingResponse(serverResponse: MeetingServerResponse)->InternalMeetingServerResponse?
    {
        let mediaPlacement = InternalResponseMediaPlacement(audioHostURL: serverResponse.meeting?.mediaPlacement?.audioHostURL,
                                                            screenSharingURL: serverResponse.meeting?.mediaPlacement?.screenSharingURL,
                                                            screenDataURL: serverResponse.meeting?.mediaPlacement?.screenDataURL,
                                                            signalingURL: serverResponse.meeting?.mediaPlacement?.signalingURL,
                                                            audioFallbackURL: serverResponse.meeting?.mediaPlacement?.audioFallbackURL,
                                                            eventIngestionURL: serverResponse.meeting?.mediaPlacement?.eventIngestionURL,
                                                            screenViewingURL: serverResponse.meeting?.mediaPlacement?.screenViewingURL,
                                                            turnControlURL: serverResponse.meeting?.mediaPlacement?.turnControlURL)
        
        let meeeting = InternalResponseMeeting(meetingID: serverResponse.meeting?.meetingID,
                                               externalMeetingID: serverResponse.meeting?.externalMeetingID,
                                               mediaRegion: serverResponse.meeting?.mediaRegion,
                                               mediaPlacement: mediaPlacement)
        
        let attendee = ResponseAttendee(joinToken: serverResponse.attendee?.joinToken, externalUserID: serverResponse.attendee?.externalUserID, attendeeID: serverResponse.attendee?.attendeeID)
        
        let attendeeResponse = InternalResponseAttendee(attendee: attendee)
        
        let toRet = InternalMeetingServerResponse(meeting: meeeting, attendee: attendeeResponse)
        
        return toRet
    }
}
