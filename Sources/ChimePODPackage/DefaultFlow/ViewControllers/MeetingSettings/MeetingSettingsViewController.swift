//
//  File.swift
//  
//
//  Created by Luigi Da Ros on 04/11/21.
//

import Foundation
import UIKit
import AVFAudio

class MeetingSettingsViewController: UIViewController {
	
	@IBOutlet weak var wrapper: UIView!
	
	@IBOutlet weak var micLabel: UILabel!
	@IBOutlet weak var camLabel: UILabel!
	
	@IBOutlet weak var camPicker: UIPickerView!
	@IBOutlet weak var micPicker: UIPickerView!
	
	private var delegate: MeetingSettingsViewControllerDelegate
		
	let camPickerDataSource = MeetingSettingsPickerSource()
	let micPickerDataSource = MeetingSettingsPickerSource()
	
	
	init(delegate: MeetingSettingsViewControllerDelegate) {
		self.delegate = delegate
		super.init(nibName: "MeetingSettingsViewController", bundle: Bundle.module)
		self.modalPresentationStyle = .fullScreen
		self.modalTransitionStyle = .crossDissolve
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//Setup gesture recognizer
		let camTap = UITapGestureRecognizer(target: self, action: #selector(self.camLabelTap(_:)))
		camLabel.addGestureRecognizer(camTap)
		camLabel.isUserInteractionEnabled = true
		let micTap = UITapGestureRecognizer(target: self, action: #selector(self.micLabelTap(_:)))
		micLabel.addGestureRecognizer(micTap)
		micLabel.isUserInteractionEnabled = true
		let bgTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissTap(_:)))
		bgTap.delegate = self
		view.addGestureRecognizer(bgTap)
		view.isUserInteractionEnabled = true

		// Setup the initial mic and cam labels value
		camLabel.text = delegate.meetingManager?.currentMeetingSession?.audioVideo.getActiveCamera()?.description
		micLabel.text = delegate.meetingManager?.currentMeetingSession?.audioVideo.getActiveAudioDevice()?.description
		
		camPickerDataSource.devices = delegate.meetingManager?.getVideoDeviceList()
		micPickerDataSource.devices = delegate.meetingManager?.getAudioDeviceList()
		
		camPicker.dataSource = camPickerDataSource
		camPicker.delegate = camPickerDataSource
		camPickerDataSource.delegate = self
		
		micPicker.dataSource = micPickerDataSource
		micPicker.delegate = micPickerDataSource
		micPickerDataSource.delegate = self
		
		camPicker.reloadAllComponents()
		micPicker.reloadAllComponents()
		
		// Set the correct row in the pickers
		if let camIndex = camPickerDataSource.devices?.firstIndex(where: { actual in
			return actual.type == delegate.meetingManager?.getCurrentVideoDevice()?.type
			})
		{
			camPicker.selectRow(camIndex, inComponent: 0, animated: false)
		}
		
		if let micIndex = micPickerDataSource.devices?.firstIndex(where: { actual in
			return actual.type == delegate.meetingManager?.getCurrentAudioDevice()?.type
			})
		{
			micPicker.selectRow(micIndex, inComponent: 0, animated: false)
		}
	}
	
	
	@objc private func micLabelTap(_ sender: Any) {
		UIView.animate(withDuration: 0.2) {
			self.camPicker.isHidden = true
			self.micPicker.isHidden = false
		}
	}
	
	@objc private func camLabelTap(_ sender: Any) {
		UIView.animate(withDuration: 0.2) {
			self.camPicker.isHidden = false
			self.micPicker.isHidden = true
		}
	}
	
	@objc private func dismissTap(_ sender: Any) {
		dismiss(animated: true)
	}
	
}

extension MeetingSettingsViewController: UIGestureRecognizerDelegate {
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool
	{
		guard let touch = event.allTouches?.first, let touchView = touch.view else { return true }
		
		if wrapper.contains(touchView)
		{
			return false
		}
		
		return true
	}
	
}

extension MeetingSettingsViewController: MeetingSettingsPickerSourceDelegate {

	func pickerDidSelectRow(row: Int, sender: MeetingSettingsPickerSource) {
		if sender == camPickerDataSource {
			delegate.setCurrentVideoDevice(index: row)
		} else if sender == micPickerDataSource {
			delegate.setCurrentAudioDevice(index: row)
		}
	}
	
}
