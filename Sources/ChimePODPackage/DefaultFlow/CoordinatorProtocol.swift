//
//  Coordinator.swift
//  
//
//  Created by Luigi Da Ros on 03/11/21.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
	var childCoordinators: [Coordinator] { get set }
	var navigationController: UINavigationController { get set }
	var parent: Coordinator? {get set}
	var startController: UIViewController? {get set}
	var lastControllerPreviousFlow: UIViewController? {get set}
	func start()
	
	func addChild(coordinator: Coordinator)
	func removeChild(coordinator: Coordinator)
}

extension Coordinator {
	func addChild(coordinator: Coordinator) {
		childCoordinators.append(coordinator)
	}
	
	func removeChild(coordinator: Coordinator) {
		childCoordinators = childCoordinators.filter {
			$0 !== coordinator
		}
	}
	
}

extension Coordinator {
	func forceComplete(animated: Bool = true) {
		if let controller = self.lastControllerPreviousFlow {
			self.navigationController.popToViewController(controller, animated: animated)
		} else {
			self.navigationController.popToRootViewController(animated: animated)
		}
		
	}
	
	func configure(startController: UIViewController) {
		self.startController = startController
		self.lastControllerPreviousFlow = findLastControllerOfPreviousFlow()
	}
	
	func findLastControllerOfPreviousFlow() -> UIViewController? {
		var controller: UIViewController?
		var i = navigationController.viewControllers.count - 1
		for _ in 0..<navigationController.viewControllers.count {
			let actualController = navigationController.viewControllers[i]
			if actualController == startController && i > 0 {
				controller = navigationController.viewControllers[i-1]
				break
			}
			i -= 1
		}
		
		if let controller = controller {
			return controller
		} else {
			return navigationController.viewControllers.first
		}
	}
	
	func findNewStartController(controllers: [UIViewController]) -> UIViewController? {
		var newStartController: UIViewController? = nil
		let lastFlowVc = self.lastControllerPreviousFlow
		for i in 0..<controllers.count {
			if controllers[i] == lastFlowVc, i + 1 < controllers.count {
				newStartController = controllers[i+1]
				break
			}
		}
		return newStartController
	}
}
