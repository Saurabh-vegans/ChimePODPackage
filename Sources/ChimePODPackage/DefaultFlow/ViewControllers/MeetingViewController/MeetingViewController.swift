//
//  MeetingViewController.swift
//  
//
//  Created by Luigi Da Ros on 05/11/21.
//

import Foundation
import UIKit
import AmazonChimeSDK

class MeetingViewController: UIViewController, MeetingPresenter, MeetingManagerDelegate {
	
	var isTest: Bool = false
	var videoView: DefaultVideoRenderView?
	var remoteVideoView: DefaultVideoRenderView?
		
	@IBOutlet weak var localPreviewViewContainer: RoundView!
	@IBOutlet weak var localPreviewView: DefaultVideoRenderView!
	@IBOutlet weak var remotePreviewView: DefaultVideoRenderView!
	@IBOutlet weak var remoteLoadingView: UIView?
	@IBOutlet weak var sessionEndedView: UIView?

	@IBOutlet weak var micButton: UIButton!
	@IBOutlet weak var camButton: UIButton!
	@IBOutlet weak var minimizeButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    
    @IBOutlet weak var messageLabel: UILabel?

	var meetingManager: MeetingManager?
	
	private let effectPlayer = MeetingEffectPlayer()
	private var callEndedFromAgent: Bool = false
	
	init(meetingManager: MeetingManager) {
		self.meetingManager = meetingManager
		super.init(nibName: "MeetingViewController", bundle: Bundle.module)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		videoView = localPreviewView
		remoteVideoView = remotePreviewView
		
		meetingManager?.meetingPresenter = self
		meetingManager?.delegate = self
		
		remoteLoadingView?.isHidden = false
		remoteLoadingView?.isUserInteractionEnabled = false

		sessionEndedView?.isHidden = false
		sessionEndedView?.isUserInteractionEnabled = false
		sessionEndedView?.alpha = 0
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureLanguage()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if let manager = meetingManager
		{
			manager.startSession()
			
			if manager.camActive == true
			{
				camButton.isSelected = !manager.startLocalVideo()
			}
			else
			{
				camButton.isSelected = true
				localPreviewView.isHidden = true
			}
			
			if !manager.micActive
			{
				micButton.isSelected = true
			}
		}
	}
	

	// MARK: - Button actions
	@IBAction func micTapped(_ sender: Any)
	{
		guard let meetingManager = meetingManager  else { return }
		
		let result = meetingManager.toggleAudio()
		
		if result == true
		{
			micButton.isSelected = !meetingManager.micActive
		}
	}
	
	@IBAction func camTapped(_ sender: Any)
	{
		guard let meetingManager = meetingManager  else { return }
		
		let result = meetingManager.toggleVideo()
		
		if result == true
		{
			camButton.isSelected = !meetingManager.camActive
			localPreviewView.isHidden = !meetingManager.camActive
			localPreviewViewContainer.isHidden = !meetingManager.camActive
			minimizeButton.isSelected = !meetingManager.camActive
		}
	}
	
	@IBAction func endCallTapped(_ sender: Any)
	{
		meetingManager?.stopSession()
		
		effectPlayer.playEffect(effect: .endCall)
		
		if callEndedFromAgent {
			//call the delegate
			MeetingMainCoordinator.shared.delegate?.onMeetingSessionEnded()
		} else {
			//restart flow
			MeetingMainCoordinator.shared.start()
		}
		
	}
	
	@IBAction func toggleLocalPreview(_ sender: Any) {
		localPreviewViewContainer.isHidden = !localPreviewViewContainer.isHidden
		minimizeButton.isSelected = !minimizeButton.isSelected
	}
    
    @IBAction func switchCamera(_ sender: Any) {
        meetingManager?.switchCamera()
    }
	
	@IBAction func settingsTapped(_ sender: Any) {
		MeetingMainCoordinator.shared.showSettings(withDelegate: self)
	}
	
		
	// MARK: - MeetingManagerDelegate
	func agentDidDisconnect() {
		UIView.animate(withDuration: 0.6) {
			self.remoteLoadingView?.alpha = 0
			self.sessionEndedView?.alpha = 1
		}
        
        localPreviewViewContainer.isHidden = true
        
        minimizeButton.isSelected = true
        minimizeButton.isHidden = true
        
        camButton.isHidden = true
        micButton.isHidden = true
        settingsButton.isHidden = true
        flipCameraButton.isHidden = true

        effectPlayer.playEffect(effect: .endCall)
        
        callEndedFromAgent = true
	}
	
	func agentDidConnect() {
		UIView.animate(withDuration: 0.6) {
			self.remoteLoadingView?.alpha = 0
			self.sessionEndedView?.alpha = 0
		}
		
		effectPlayer.playEffect(effect: .startCall)
	}

	func agentDidToggleCamera(status: MeetingInputOutputDeviceStatus) {
		if status == .inactive && remoteLoadingView?.alpha != 1 {
			UIView.animate(withDuration: 0.6) {
				self.remoteLoadingView?.alpha = 1
			}
		} else if status == .active && remoteLoadingView?.alpha != 0 {
			UIView.animate(withDuration: 0.6) {
				self.remoteLoadingView?.alpha = 0
			}
		}
	}
	
	func agentDidToggleMicrophone(status: MeetingInputOutputDeviceStatus) {
		//unmanaged for now
	}

	func meetingFailWithStatus(status: MeetingFailStatus) {
		if status == .authenticationRejected {
			UIView.animate(withDuration: 0.6) {
				self.remoteLoadingView?.alpha = 0
				self.sessionEndedView?.alpha = 1
			}
			localPreviewViewContainer.isHidden = true
			minimizeButton.isSelected = true
			minimizeButton.isHidden = true
			camButton.isHidden = true
			micButton.isHidden = true
			settingsButton.isHidden = true
		}
		
		effectPlayer.playEffect(effect: .endCall)
		
		callEndedFromAgent = true
		
	}
}


// MARK: - SettingsViewControllerDelegate
extension MeetingViewController: MeetingSettingsViewControllerDelegate {
	
    func setCurrentAudioDevice(index: Int) {
		meetingManager?.setCurrentAudioDevice(deviceIndex: index)
	}
	
    func setCurrentVideoDevice(index: Int) {
		meetingManager?.setCurrentVideoDevice(deviceNumber: index)
	}

}

extension MeetingViewController
{
    func configureLanguage()
    {
        messageLabel?.text = NSLocalizedString("session_ended", tableName: nil, bundle: .module, value: "Session ended!", comment: "Session ended!")
    }
}
