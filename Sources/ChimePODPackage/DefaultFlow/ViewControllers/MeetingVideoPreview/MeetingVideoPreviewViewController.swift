//
//  MeetingVideoPreviewViewController.swift
//  
//
//  Created by Luigi Da Ros on 03/11/21.
//

import UIKit
import AmazonChimeSDK

class MeetingVideoPreviewViewController: UIViewController, MeetingPresenter {
	var videoView: DefaultVideoRenderView?
	var remoteVideoView: DefaultVideoRenderView?
	
	// IMPORTANT: for the preview mode set isTest to true
	var isTest: Bool = true
		
	@IBOutlet weak var previewView: DefaultVideoRenderView!
	@IBOutlet weak var continueButton: UIButton!

	@IBOutlet weak var errorView: UIView?
	@IBOutlet weak var errorTitle: UILabel?
	@IBOutlet weak var errorMessage: UILabel?
	@IBOutlet weak var micButton: UIButton!
	@IBOutlet weak var camButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!

	var meetingManager: MeetingManager?
	private var coordinator: MeetingMainCoordinator
	
	var meetingId: String? {
		didSet{
			if isViewLoaded {
				self.initSession()
			}
		}
	}

	let logger = ConsoleLogger(name: "MeetingVideoPreviewViewController")
	var defaultCamera: DefaultCameraCaptureSource?
	
	init(coordinator: MeetingMainCoordinator) {
		self.coordinator = coordinator
		super.init(nibName: "MeetingVideoPreviewViewController", bundle: Bundle.module)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		videoView = previewView
		continueButton.isEnabled = false
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.errorView?.isHidden = true
		self.showErrorView(show: false)
		navigationController?.isNavigationBarHidden = true
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
			self.initSession()
		}
	}
	
	private func initSession() {
		if meetingManager != nil {
			return
		}
		meetingManager = MeetingManager()
		meetingManager?.checkAVPermissions {[weak self] granted in
			
			if !granted {
				DispatchQueue.main.async {
					self?.meetingManager = nil
					self?.showErrorView(title: "Hello,\nWelcome!",
										message: "You need to give camera and microphone permission before start.")
					
					let alert = UIAlertController(title: "Warning", message: "You need to give camera and microphone permission before start.", preferredStyle: .alert)
					let okAction = UIAlertAction(title: "Ok", style: .cancel)
					let settingsAction = UIAlertAction(title: "Settings", style: .default) { act in
						guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
							return
						}

						if UIApplication.shared.canOpenURL(settingsUrl) {
							UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
								
							})
						}
					}

					alert.addAction(okAction)
					alert.addAction(settingsAction)

					self?.present(alert, animated: true, completion: nil)
				}
				return
			}
			
			self?.showErrorView(show: false)
			
			guard let id = self?.meetingId else {
				self?.showErrorView()
				return
			}
			
			// Create the body request
			self?.meetingManager?.joinMeeting(userName: "", meetingId: id) {[weak self] result in
				switch result
				{
				case .success(_):
					DispatchQueue.main.async {
						self?.meetingManager?.meetingPresenter = self
						self?.continueButton.isEnabled = true
					}
				case .failure(let error):
						VeganLogger.err(error)
					DispatchQueue.main.async {
						self?.meetingManager = nil
						self?.showErrorView(message: nil)
					}
				}
			}

		}

	}
	
	private func showErrorView(title: String = "Sorry", message: String? = nil, show: Bool = true) {
		
		self.errorTitle?.text = title
		self.errorMessage?.text = message ?? "We are encontering some errors."
		self.errorView?.isHidden = !show
		
	}
	
	// MARK: - Navigation
	
	@IBAction func settingsTapped(_ sender: Any) {
		MeetingMainCoordinator.shared.showSettings(withDelegate: self)
	}
	
	@IBAction func joinTapped(_ sender: Any) {
		guard let meetingManager = meetingManager  else { return }
		MeetingMainCoordinator.shared.showVideoCall(meetingManager: meetingManager)
	}

	@IBAction func camTapped(_ sender: Any) {
		guard let meetingManager = meetingManager  else {
			initSession()
			return
		}
		
		_ = meetingManager.toggleVideo()
		
		camButton.isSelected = !meetingManager.camActive
		videoView?.isHidden = !meetingManager.camActive
	}
	
	@IBAction func micTapped(_ sender: Any)
	{
		guard let meetingManager = meetingManager  else {
			initSession()
			return
		}
		
		_ = meetingManager.toggleAudio()
		
		micButton.isSelected = !meetingManager.micActive
	}
	
}

// MARK: - SettingsViewControllerDelegate
extension MeetingVideoPreviewViewController: MeetingSettingsViewControllerDelegate {
	
	func setCurrentAudioDevice(index: Int) {
		meetingManager?.setCurrentAudioDevice(deviceIndex: index)
	}
	
	func setCurrentVideoDevice(index: Int) {
		meetingManager?.setCurrentVideoDevice(deviceNumber: index)
	}
	
}
