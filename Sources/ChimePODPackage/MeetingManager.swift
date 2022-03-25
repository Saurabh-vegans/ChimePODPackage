//
//  MeetingManager.swift
//  ChimePOC
//
//  Created by Luigi Villa on 18/10/21.
//

import UIKit
import AmazonChimeSDK

public enum CameraPosition: Int
{
    case front = 0
    case rear
}

enum UserPreference
{
	case active
	case inactive
}

public enum MeetingInputOutputDeviceStatus {
	case active
	case inactive
	case paused
}

public enum MeetingFailStatus {
	case undefined
	case authenticationRejected
}

public enum MeetingManagerMode {
    case development
    case production
}


public protocol MeetingManagerDelegate {
	func agentDidDisconnect() -> Void
	func agentDidConnect() -> Void
	func agentDidToggleCamera(status: MeetingInputOutputDeviceStatus) -> Void
	func agentDidToggleMicrophone(status: MeetingInputOutputDeviceStatus) -> Void
	func meetingFailWithStatus(status: MeetingFailStatus) -> Void
}

/// This class manages the entire meeting cycle
public class MeetingManager: NSObject, ActiveSpeakerObserver, VideoTileObserver, RealtimeObserver, AudioVideoObserver, MetricsObserver, DeviceChangeObserver, EventAnalyticsObserver
{
    var currentLocalVideoSink: DefaultVideoRenderView?
    
    /// The meeting presenter object, set it to your presentarion view controller
    public weak var meetingPresenter: MeetingPresenter? {
        didSet{
            if let presenter = meetingPresenter
            {
                if currentLocalVideoSink != nil
                {
                    currentCamera?.removeVideoSink(sink: currentLocalVideoSink!)
                }

                currentLocalVideoSink = presenter.videoView
                currentCamera?.device = currentMeetingSession?.audioVideo.getActiveCamera()
                currentCamera?.addVideoSink(sink: currentLocalVideoSink!)
                currentCamera?.start()
            }
        }
    }
    
    /// we have only a meeting session at a time
    public var currentMeetingSession: DefaultMeetingSession?
    
    /// Used to handle devices
    private var deviceManager: DeviceManager?
    
    ///  The current camera used to capture video, by default is the front camera
    private var currentCameraPosition: CameraPosition = .front
    
    /// the current camera
    private var currentCamera: DefaultCameraCaptureSource?
    
    /// keep the status of the mic
    var isMicActive: Bool = true
    
    /// keep the status of the cam
    var isCamActive: Bool = true
    
    /// keep the status of the mic set by the user
    var userMicPreference: UserPreference = .active
    
    /// keep the status of the cam set by the user
    var userCamPreference: UserPreference = .active
    
    public var camActive:Bool {
        get{
            return userCamPreference == .active
        }
    }
    
    public var micActive:Bool {
        get{
            return userMicPreference == .active
        }
    }
    
    /// The current meeting session configuration
    public var meetingSessionConfig: MeetingSessionConfiguration?
    {
        didSet{
            if let meetingSessionConfig = meetingSessionConfig {
                currentMeetingSession = DefaultMeetingSession(configuration: meetingSessionConfig, logger: logger)
                
                if let presenter = meetingPresenter {
                    currentCamera?.device = currentMeetingSession?.audioVideo.getActiveCamera()
                    currentCamera?.addVideoSink(sink: presenter.videoView!)
                    currentLocalVideoSink = presenter.videoView!
                    currentCamera?.start()
                    
                    isCamActive = true
                }
            }
            else {
                currentLocalVideoSink = nil
            }
        }
    }
	
	/// For customize events handling in in UI
	public var delegate: MeetingManagerDelegate?
    
    /// Chime logger
    private let logger = ConsoleLogger(name: "MeetingManager")
    
    /// This is the "mode" in which the app is running, it is used because the call to the service /deleteAttendee for now must be done only in development
    private(set) var mode: MeetingManagerMode = .development
    
    
    /// Constructor
    /// - Parameter mode: the mode in whick the app is running
    public init(mode: MeetingManagerMode = .development) {
        super.init()
        
        // Add the background notification listener
        NotificationCenter.default.addObserver(forName: UIScene.willDeactivateNotification, object: self, queue: nil) { notification in
//            self.stopVideo()
        }
        
        self.mode = mode
        currentCamera = DefaultCameraCaptureSource(logger: logger)
    }
    // MARK: - Session start and stop
    public func startSession()
    {
        do
        {
            try currentMeetingSession?.audioVideo.start()
            
            // Set the audio device to the one choosen by the user
            if let audioDev = deviceManager?.getCurrentAudioDevice() {
                currentMeetingSession?.audioVideo.chooseAudioDevice(mediaDevice: audioDev)
            }
        }
        catch
        {
            VeganLogger.err("Error starting meeting session \(error)")
        }
    }
    
    public func stopSession()
    {
        currentMeetingSession?.audioVideo.stop()
        
        // This is only for development, in case the server side implementation will be approved it will be called in production too
        if mode == .development, let attendeeId = MeetingDataManager.shared().getClientAttendeeInfo()?.attendee?.attendeeID {
            makeAttendeeLeftTheMeetingCall(attendeeIds: [attendeeId])
        }
    }
    
    /// Request the camera and micophone permission, this function is blocking
    /// - Parameter completion: the completion callback, if both the permissions are granted the parameter is true
    public func checkAVPermissions(completion: @escaping (Bool) -> Void)
    {
        PermissionManager.shared().requestAVPermissions(completion: { granted in
            completion(granted)
        })
    }
    
    // MARK: - Start and stop local video
    public func stopLocalVideo()->Bool
    {
        userCamPreference = .inactive
        
        if let session = currentMeetingSession
        {
            session.audioVideo.stopLocalVideo()
            isCamActive = false
            
            return true
        }
        
        return false
    }
    
    public func startLocalVideo()->Bool
    {
        userCamPreference = .active
        
        if let session = currentMeetingSession
        {
            do
            {
                try session.audioVideo.startLocalVideo()
                
                if let videoView = currentLocalVideoSink, meetingPresenter?.isTest == true
                {
                    currentCamera?.device = currentMeetingSession?.audioVideo.getActiveCamera()
                    currentCamera?.addVideoSink(sink: videoView)
                    currentCamera?.start()
                }
                
                isCamActive = true
                return true
            }
            catch
            {
                VeganLogger.err("Error starting local video \(error)")
                isCamActive = false
                return false
            }
        }
        
        return false
    }
    
    public func toggleVideo()->Bool
    {
        if isCamActive
        {
            return stopLocalVideo()
        }
        else
        {
            return startLocalVideo()
        }
    }
    
    // MARK: - Start and stop local audio
    public func stopLocalAudio()->Bool
    {
        userMicPreference = .inactive
        
        if let session = currentMeetingSession
        {
            if session.audioVideo.realtimeLocalMute()
            {
                isMicActive = false
                return true
            }
            
            return false
        }
        
        return false
    }
    
    public func startLocalAudio()->Bool
    {
        userMicPreference = .active
        
        if let session = currentMeetingSession
        {
            if session.audioVideo.realtimeLocalUnmute()
            {
                isMicActive = true
                return true
            }
        }
        
        return false
    }
    
    public func toggleAudio()->Bool
    {
        if userMicPreference == .active
        {
            return stopLocalAudio()
        }
        else
        {
            return startLocalAudio()
        }
    }
    
    /// Restore the audio device to the selected one
    public func restoreLocalAudioDevice()
    {
        if let session = currentMeetingSession,
           let sessionDevice = session.audioVideo.getActiveAudioDevice(),
           let managerDevice = deviceManager?.getCurrentAudioDevice()
        {
            if sessionDevice.type != managerDevice.type
            {
                session.audioVideo.chooseAudioDevice(mediaDevice: managerDevice)
            }
            
            if !session.audioVideo.realtimeIsVoiceFocusEnabled()
            {
                if !session.audioVideo.realtimeSetVoiceFocusEnabled(enabled: true)
                {
                    VeganLogger.err("realtimeSetVoiceFocusEnabled failed to set")
                }
            }
        }
    }
    
    // MARK: - Start and stop local audio
    public func startAudio()->Bool
    {
        if userMicPreference == .active, let session = currentMeetingSession
        {
            return session.audioVideo.realtimeLocalUnmute()
        }
        
        return false
    }
    
    public func stopAudio()->Bool
    {
        if let session = currentMeetingSession, userMicPreference == .inactive
        {
            return session.audioVideo.realtimeLocalMute()
        }
        
        return false
    }
    
    // MARK: - Device handling
    public func getCurrentVideoDevice()->MediaDevice?
    {
        return currentMeetingSession?.audioVideo.getActiveCamera()
    }
    
    public func getCurrentAudioDevice()->MediaDevice?
    {
        return currentMeetingSession?.audioVideo.getActiveAudioDevice()
    }
    
    public func switchCamera()
    {
        currentMeetingSession?.audioVideo.switchCamera()
    }
    
    /// Switch from front and rear camera and vice versa
    /// - Parameter deviceNumber: the device number, 0 = front camera
    public func setCurrentVideoDevice(deviceNumber: Int)
    {
        if let device = deviceManager?.setCurrentVideoDevice(deviceIndex: deviceNumber)
        {
            if currentMeetingSession?.audioVideo.getActiveCamera()?.type != device.type
            {
                currentMeetingSession?.audioVideo.switchCamera()
            }
        }
        
        guard let previewView = currentLocalVideoSink else { return }
        
        currentCamera?.removeVideoSink(sink: previewView)
        currentCamera?.device = currentMeetingSession?.audioVideo.getActiveCamera()
        currentCamera?.addVideoSink(sink: previewView)
    }
    
    public func setCurrentAudioDevice(deviceIndex: Int)
    {
        if let device = deviceManager?.setCurrentAudioDevice(deviceIndex: deviceIndex)
        {
            if currentMeetingSession?.audioVideo.getActiveAudioDevice()?.type != device.type
            {
                currentMeetingSession?.audioVideo.chooseAudioDevice(mediaDevice: device)
            }
        }
    }
    
    public func getVideoDeviceList()->[MediaDevice]?
    {
        return deviceManager?.videoDevices
    }
    
    public func getAudioDeviceList()->[MediaDevice]?
    {
        return deviceManager?.audioDevices
    }
    
    /// Set the default audio device to the built in speaker
    private func setAudioDeviceToBuiltinSpeaker() {
        if let session = currentMeetingSession {
            let devices = session.audioVideo.listAudioDevices()
            var selectedDevice:MediaDevice?
            
            if let bluetoothDevice = devices.first(where: { $0.type == MediaDeviceType.audioBluetooth}) {
                selectedDevice = bluetoothDevice
            }
            else if let wiredDevice = devices.first(where: { $0.type == MediaDeviceType.audioWiredHeadset}) {
                selectedDevice = wiredDevice
            }
            else if let wiredDevice = devices.first(where: { $0.type == MediaDeviceType.audioBuiltInSpeaker || $0.label == "Build-in Speaker"}) {
                selectedDevice = wiredDevice
            }
            else if let firstDevice = devices.first {
                selectedDevice = firstDevice
            }
            
            if let theSelectedDevice = selectedDevice {
                currentMeetingSession?.audioVideo.chooseAudioDevice(mediaDevice: theSelectedDevice)
                _ = deviceManager?.setCurrentAudioDevice(device: theSelectedDevice)
            }
        }
    }
    
    // MARK: - meetings methods
    
    /// Join a meeting given the meeting ID and the user name
    /// - Parameters:
    ///   - userName: the nickname to use for the meeting
    ///   - meetingId: the meeting ID
    ///   - completion: a callback with a Result paramenter which can contain the meeting session or an error
    public func joinMeeting(userName: String, meetingId: String, completion: @escaping (Result<DefaultMeetingSession, ServerErr>)->())
    {
        // Create the body request
        let body = RestoreMeetingRequestBody(videoUID: meetingId)
        
        // Make the request
        MeetingDataManager.shared().requestMeetingData(body: body) { meetingConfig, error in
            if let error = error
            {
                completion(.failure(error))
            }
            else if let meetingConfig = meetingConfig
            {
                // The call had a positive result, create the meeting
                self.meetingSessionConfig = meetingConfig
                
                // Setup the video and audio facade observer
                self.setupAudioVideoFacadeObservers()

                self.deviceManager = DeviceManager(session: self.currentMeetingSession!)
                self.setAudioDeviceToBuiltinSpeaker()
                
                completion(.success(self.currentMeetingSession!))
            }
        }
    }
    
    public func makeE2EApiTestCall(base64: String, completion: @escaping (ServerErr?)->())
    {   // Make the request
        MeetingDataManager.shared().requestE2EVideoTest(base64: base64) { error in
            completion(error)
        }
    }
    
    private func makeAttendeeLeftTheMeetingCall(attendeeIds: [String]) {
        // Create the body request
        guard let meetingId = meetingSessionConfig?.meetingId else { return }
        
        DispatchQueue.concurrentPerform(iterations: attendeeIds.count) { idCounter in
            let attendeeId = attendeeIds[idCounter]
            let body = AttendeeLeftMeetingBody(meetingID: meetingId, attendeeID: attendeeId)
            
            // Make the request
            MeetingDataManager.shared().sendMeetingLeftData(body: body) { error in
                if let error = error {
                    VeganLogger.err("Error sending left meeting data \(error.localizedDescription)")
                }
            }
        }
    }
    
    public func bindParticipantVideo(renderView: VideoRenderView)
    {
        currentMeetingSession?.audioVideo.bindVideoView(videoView: renderView, tileId: 0)
    }
    
    // MARK: - Observers setup
    private func setupAudioVideoFacadeObservers()
    {
        let audioVideo = currentMeetingSession!.audioVideo
        audioVideo.addVideoTileObserver(observer: self)
        audioVideo.addRealtimeObserver(observer: self)
        audioVideo.addAudioVideoObserver(observer: self)
        audioVideo.addMetricsObserver(observer: self)
        audioVideo.addDeviceChangeObserver(observer: self)
        audioVideo.addActiveSpeakerObserver(policy: DefaultActiveSpeakerPolicy(),
                                            observer: self)
        audioVideo.addEventAnalyticsObserver(observer: self)
    }

    private func removeAudioVideoFacadeObservers()
    {
        let audioVideo = currentMeetingSession!.audioVideo
        audioVideo.removeVideoTileObserver(observer: self)
        audioVideo.removeRealtimeObserver(observer: self)
        audioVideo.removeAudioVideoObserver(observer: self)
        audioVideo.removeMetricsObserver(observer: self)
        audioVideo.removeDeviceChangeObserver(observer: self)
        audioVideo.removeActiveSpeakerObserver(observer: self)
        audioVideo.removeRealtimeDataMessageObserverFromTopic(topic: "chat")
        audioVideo.removeEventAnalyticsObserver(observer: self)
    }
    
    // MARK: - ActiveSpeakerObserver protocol
    public var observerId: String = "fakeObserverId"
    public func activeSpeakerDidDetect(attendeeInfo: [AttendeeInfo]) {
    }
    
    // MARK: - VideoTileObserver protocol
    public func videoTileDidAdd(tileState: VideoTileState) {
		VeganLogger.log(tileState)

        if let remoteView = meetingPresenter?.remoteVideoView, !tileState.isLocalTile
        {
            currentMeetingSession?.audioVideo.bindVideoView(videoView: remoteView, tileId: tileState.tileId)
        }
        else if let localView = meetingPresenter?.videoView, tileState.isLocalTile
        {
            currentMeetingSession?.audioVideo.bindVideoView(videoView: localView, tileId: tileState.tileId)
        }
		
		if MeetingDataManager.shared().isAgentAttendee(tileState.attendeeId) {
			self.delegate?.agentDidToggleCamera(status: .active)
		}
    }
    
    public func videoTileDidRemove(tileState: VideoTileState) {
		VeganLogger.log(tileState)
        currentMeetingSession?.audioVideo.unbindVideoView(tileId: tileState.tileId)
		if MeetingDataManager.shared().isAgentAttendee(tileState.attendeeId) {
			self.delegate?.agentDidToggleCamera(status: .inactive)
		}
    }
    
    public func videoTileDidPause(tileState: VideoTileState) {
		VeganLogger.log(tileState)
		if MeetingDataManager.shared().isAgentAttendee(tileState.attendeeId) {
			self.delegate?.agentDidToggleCamera(status: .paused)
		}
    }
    
    public func videoTileDidResume(tileState: VideoTileState) {
		VeganLogger.log(tileState)
		if MeetingDataManager.shared().isAgentAttendee(tileState.attendeeId) {
			self.delegate?.agentDidToggleCamera(status: .active)
		}
    }
    
    public func videoTileSizeDidChange(tileState: VideoTileState) {
		VeganLogger.log(tileState)
    }
    
    // MARK: - RealtimeObserver protocol
    public func volumeDidChange(volumeUpdates: [VolumeUpdate]) {
		//VeganLogger.log(volumeUpdates)
    }
    
    public func signalStrengthDidChange(signalUpdates: [SignalUpdate]) {
		VeganLogger.log(signalUpdates)
    }
    
    public func attendeesDidJoin(attendeeInfo: [AttendeeInfo]) {
		VeganLogger.log(attendeeInfo)
		if attendeeInfo.first(where: { att in
			MeetingDataManager.shared().isAgentAttendee(att)
		}) != nil {
			delegate?.agentDidConnect()
            restoreLocalAudioDevice()
		}
    }
    
    public func attendeesDidLeave(attendeeInfo: [AttendeeInfo]) {
		VeganLogger.log(attendeeInfo)
		if attendeeInfo.first(where: { att in
			MeetingDataManager.shared().isAgentAttendee(att)
		}) != nil {
			delegate?.agentDidDisconnect()
			MeetingDataManager.shared().sendMeetingEvents()
		}
        
        // If we are in dev we must call the /deleteAttendee endpoint to notify the server we are leaving the session
        // Maybe we should remove this test in the future...
        if mode == .development {
            // because we don't know how many attendees left the meeting we must cycle over attendeeInfo
            let ids = attendeeInfo.map{($0.attendeeId)}
            makeAttendeeLeftTheMeetingCall(attendeeIds: ids)
        }
    }
    
    public func attendeesDidDrop(attendeeInfo: [AttendeeInfo]) {
		VeganLogger.log(attendeeInfo)
    }
    
    public func attendeesDidMute(attendeeInfo: [AttendeeInfo]) {
		VeganLogger.log(attendeeInfo)
		if attendeeInfo.first(where: { att in
			MeetingDataManager.shared().isAgentAttendee(att)
		}) != nil {
			self.delegate?.agentDidToggleMicrophone(status: .inactive)
		}
    }
    
    public func attendeesDidUnmute(attendeeInfo: [AttendeeInfo]) {
		VeganLogger.log(attendeeInfo)
		if attendeeInfo.first(where: { att in
			MeetingDataManager.shared().isAgentAttendee(att)
		}) != nil {
			self.delegate?.agentDidToggleMicrophone(status: .active)
		}
    }

    // MARK: - RealtimeObserver protocol
    public func audioSessionDidStartConnecting(reconnecting: Bool) {
		VeganLogger.log(reconnecting)
	}
    
    public func audioSessionDidStart(reconnecting: Bool) {
        // Because Chime does not support mute and unmute before join the meeting we must implenet here the logic to stop the audio if the user has turned the mic off
		VeganLogger.log(reconnecting)
        
        // Restore the user audio preference
        restoreLocalAudioDevice()
        
        if userMicPreference == .inactive
        {
            _ = stopLocalAudio()
        }
    }
    
    public func audioSessionDidDrop() {
		VeganLogger.log("audioSessionDidDrop")
    }
    
    public func audioSessionDidStopWithStatus(sessionStatus: MeetingSessionStatus) {
		VeganLogger.log(sessionStatus.statusCode)
    }
    
    public func audioSessionDidCancelReconnect() {
		VeganLogger.log("audioSessionDidCancelReconnect")
    }
    
    public func connectionDidRecover() {
		VeganLogger.log("connectionDidRecover")
    }
    
    public func connectionDidBecomePoor() {
		VeganLogger.log("connectionDidBecomePoor")
    }
    
    public func videoSessionDidStartConnecting() {
		VeganLogger.log("videoSessionDidStartConnecting")
    }
    
    public func videoSessionDidStartWithStatus(sessionStatus: MeetingSessionStatus) {
		VeganLogger.log(sessionStatus.statusCode)
        currentMeetingSession?.audioVideo.startRemoteVideo()
    }
    
    public func videoSessionDidStopWithStatus(sessionStatus: MeetingSessionStatus) {
		VeganLogger.log(sessionStatus.statusCode)
    }
    
    public func remoteVideoSourcesDidBecomeAvailable(sources: [RemoteVideoSource]) {
        VeganLogger.log("remoteVideoSourcesDidBecomeAvailable")
    }
    
    public func remoteVideoSourcesDidBecomeUnavailable(sources: [RemoteVideoSource]) {
        VeganLogger.log("remoteVideoSourcesDidBecomeUnavailable")
    }

    // MARK: - MetricsObserver protocol
    public func metricsDidReceive(metrics: [AnyHashable : Any]) {
		//VeganLogger.log(metrics)
    }

    // MARK: - DeviceChangeObserver protocol
    public func audioDeviceDidChange(freshAudioDeviceList: [MediaDevice]) {
		VeganLogger.log(freshAudioDeviceList)
        
        /*
         Check if the new selected audio device corresponds to the one selected by the user
         if the current device is not the selected one then select the user selected device
         */
        
        // Get the new device in use
        guard let session = currentMeetingSession, let newCurrentDevice = session.audioVideo.getActiveAudioDevice() else { return }
        
        if let currentDevice = deviceManager?.getCurrentAudioDevice(), currentDevice.type != newCurrentDevice.type
        {
            // Get the device number for debug
            let deviceNumber = deviceManager?.setCurrentAudioDevice(device: newCurrentDevice)
            if deviceNumber == nil
            {
                VeganLogger.log("Device \(newCurrentDevice) not found in device manager")
            }
        }
    }
    
    // MARK: - EventAnalyticsObserver
    public func eventDidReceive(name: EventName, attributes: [AnyHashable : Any]) {
		VeganLogger.log("eventName: \(name)\nattributes:\(attributes)")

		MeetingDataManager.shared().appendToEventBuffer(name: name,
														attributes: attributes,
														for: currentMeetingSession)
		
		switch name {

			case .meetingFailed:
				if attributes[EventAttributeName.meetingStatus] as? MeetingSessionStatusCode == .audioAuthenticationRejected {
					self.delegate?.meetingFailWithStatus(status: .authenticationRejected)
				} else {
					self.delegate?.meetingFailWithStatus(status: .undefined)
				}
				MeetingDataManager.shared().sendMeetingEvents()

			case .videoInputFailed:
				break
			case .meetingStartRequested:
				break
			case .meetingStartSucceeded:
				break
			case .meetingStartFailed:
				self.delegate?.meetingFailWithStatus(status: .undefined)
				MeetingDataManager.shared().sendMeetingEvents()

			case .meetingEnded:
				MeetingDataManager.shared().sendMeetingEvents()
				break
			case .unknown:
				break
			@unknown default:
				break
		}

	}
}
