//
//  MeetingMainCoordinator.swift
//  
//
//  Created by Luigi Da Ros on 03/11/21.
//

import Foundation
import UIKit

public protocol MeetingMainCoordinatorDelegate {
	func onMeetingSessionEnded()
}


public final class MeetingMainCoordinator: NSObject, Coordinator {
	
	var navigationController: UINavigationController
	
	var parent: Coordinator?
	
	var startController: UIViewController?
	
	var lastControllerPreviousFlow: UIViewController?
	
	var onCompleted: ((Coordinator) -> ())?
	
	var childCoordinators = [Coordinator]()
	
	/// The app window
	private var window: UIWindow
	
	/// Main coordinator shared instance
	static var shared: MeetingMainCoordinator!
	
	var delegate: MeetingMainCoordinatorDelegate?
	private var meetingId: String?
	
	public init(window: UIWindow,
				navigation: UINavigationController?,
				meetingId: String?,
				delegate: MeetingMainCoordinatorDelegate) {
		self.navigationController = navigation ?? UINavigationController()
		self.meetingId = meetingId
		self.delegate = delegate
		self.window = window
	}
	
	public func start() {
		MeetingMainCoordinator.shared = self
		MeetingUIManager.configurePackageUI()
		
		let vc = MeetingVideoPreviewViewController(coordinator: self)
		vc.meetingId = meetingId
		self.navigationController.viewControllers = [vc]
		self.navigationController.delegate = self
		self.window.rootViewController = navigationController
	}

	func removeAllCoordinators() {
		self.childCoordinators.removeAll()
		self.navigationController.delegate = self
	}
	
	func showSettings(withDelegate delegate: MeetingSettingsViewControllerDelegate) {
		let vc = MeetingSettingsViewController(delegate: delegate)
		navigationController.present(vc, animated: true)
	}
	
	func showVideoCall(meetingManager: MeetingManager) {
		let vc = MeetingViewController(meetingManager: meetingManager)
		vc.meetingManager = meetingManager
		navigationController.pushViewController(vc, animated: true)
	}

		
}

extension MeetingMainCoordinator: UINavigationControllerDelegate {
	
	public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		
		return nil
	}
	
}
