//
//  PermissionManager.swift
//  ChimePOC
//
//  Created by Luigi Da Ros on 28/09/21.
//

import Foundation
import AVFoundation
import Combine

/// Singleton class to handle the camera and microphone usage permissions
class PermissionManager {
    /// The shared instance
    private static var sharedInstance: PermissionManager?
    
    @Published var videoPermissions: AVAuthorizationStatus?
    @Published var audioPermissions: AVAudioSession.RecordPermission?
    var cancelBag: Set<AnyCancellable> = []
    
    /// Call this method to access the singleton PermissionManager object
    static func shared() -> PermissionManager {
        if sharedInstance == nil {
            sharedInstance = PermissionManager()
        }
        sharedInstance?.requestVideoPermission()
        sharedInstance?.requestAudioPermission()
        return sharedInstance!
    }
    
    
    /// Request the camera user permission
    /// - Parameter completion: the completion callback, the bool parameter is true if the permission is granted
    private func requestVideoPermission() {
        let videoPermissions = AVCaptureDevice.authorizationStatus(for: .video)
        if videoPermissions == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authorized in
                VeganLogger.log("Video permission granted: \(authorized)")
                self?.videoPermissions = AVCaptureDevice.authorizationStatus(for: .video)
            }
        } else {
            self.videoPermissions = AVCaptureDevice.authorizationStatus(for: .video)
        }
    }
    
    
    /// Request the microphone usage user permission
    /// - Parameter completion: the completion callback, the bool parameter is true if the permission is granted
    func requestAudioPermission() {
        let audioPermissions = AVAudioSession.sharedInstance().recordPermission
        if audioPermissions == .undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                VeganLogger.log("Audio permission granted: \(granted)")
                self?.configureAudioSession()
                self?.audioPermissions = AVAudioSession.sharedInstance().recordPermission
            }
        }else {
            self.configureAudioSession()
            self.audioPermissions = AVAudioSession.sharedInstance().recordPermission
        }
    }
    
    
    /// Request both camera and microphone usage permissions, this method blocks until the user granted or denied the permissions
    /// - Parameter completion: the completion callback, the bool parameter is true if both the permissions are granted
    func requestAVPermissions(completion: @escaping (Bool) -> Void) {
        
        Publishers.CombineLatest(self.$videoPermissions,
                                 self.$audioPermissions)
            .receive(on: DispatchQueue.main)
            .filter({ $0.0 != nil && $0.1 != nil })
            .sink { pubs in
                completion( pubs.0 == .authorized && pubs.1 == .granted)
            }.store(in: &cancelBag)
    }
    
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord,
                                         options: [.allowBluetooth, .duckOthers])
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setMode(.videoChat)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
        } catch {
            VeganLogger.err("Error configuring AVAudioSession: \(error.localizedDescription)")
        }
    }
}
