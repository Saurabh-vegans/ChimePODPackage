//
//  DeviceManager.swift
//  ChimePOC
//
//  Created by Luigi Villa on 14/10/21.
//

import UIKit
import AmazonChimeSDK
import AmazonChimeSDKMedia

/// Use this class to manage your devices and get devices lists
public class DeviceManager: NSObject {
    // The device controller from the session
    private var meetingSession: DefaultMeetingSession?
    
    /// the selected video device, the default value is the active camera of the DefaultDeviceController
    private var selectedVideoDevice: MediaDevice?
    
    /// the selected audio device, the default value is the active audio device of the DefaultDeviceController
    private var selectedAudioDevice: MediaDevice?
    
    public var audioDevices: [MediaDevice] {
        get{
            return meetingSession?.audioVideo.listAudioDevices() ?? []
        }
    }
    
    public var videoDevices: [MediaDevice] = MediaDevice.listVideoDevices().reversed()
    
    public init(session: DefaultMeetingSession) {
        super.init()
       
        meetingSession = session
        setDefaultDevices()
    }
    
    public func setDefaultDevices()
    {
        selectedVideoDevice = meetingSession?.audioVideo.getActiveCamera()
        selectedAudioDevice = meetingSession?.audioVideo.getActiveAudioDevice()
    }
    
    public func getCurrentVideoDevice()->MediaDevice?
    {
        return selectedVideoDevice
    }
    
    public func getCurrentAudioDevice()->MediaDevice?
    {
        return selectedAudioDevice
    }
    
    public func setCurrentVideoDevice(deviceIndex: Int)->MediaDevice?
    {
        selectedVideoDevice = videoDevices[deviceIndex]
        return selectedVideoDevice
    }
    
    public func setCurrentAudioDevice(deviceIndex: Int)->MediaDevice?
    {
        selectedAudioDevice = audioDevices[deviceIndex]
        return selectedAudioDevice
    }
    
    public func setCurrentVideoDevice(device: MediaDevice)->Int?
    {
        guard let index = videoDevices.firstIndex(where: { actual in
            return device.type == actual.type
        }) else { return nil }
                                                       
        selectedVideoDevice = videoDevices[index]
        
        return index
    }
    
    public func setCurrentAudioDevice(device: MediaDevice)->Int?
    {
        guard let index = audioDevices.firstIndex(where: { actual in
            return device.type == actual.type
        }) else { return nil }
                                                       
        selectedAudioDevice = audioDevices[index]
        
        return index
    }
    
}
