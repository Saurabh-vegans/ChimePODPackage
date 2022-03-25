//
//  MeetingSettingsViewControllerDelegate.swift
//  
//
//  Created by Luigi Da Ros on 03/11/21.
//

import Foundation

protocol MeetingSettingsViewControllerDelegate: AnyObject {
	var meetingManager: MeetingManager? { get set }
	func setCurrentAudioDevice(index: Int)
	func setCurrentVideoDevice(index: Int)
}
