//
//  MainCoordinator.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/24/21.
//

import UIKit

class MainCoordinator: NSObject, Coordinator, UINavigationControllerDelegate {
    var navigationController: UINavigationController
    
    var children = [Coordinator]()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigationController.delegate = self
        navigationController.setNavigationBarHidden(true, animated: false)
        
        // If user hasn't completed onboarding
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        onboardingCoordinator.parent = self
        children.append(onboardingCoordinator)
        onboardingCoordinator.start()
        
        // TODO: navigate home
    }
    
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in children.enumerated() {
            if coordinator === child {
                children.remove(at: index)
                break
            }
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }
        
        // Check if pushing new view controller on top
        if navigationController.viewControllers.contains(fromViewController) {
            return
        }
        
        // Process child coordinators once view controllers are popped out of navigation controller
        
//        if let viewController = fromViewController as? ViewController {
//            childDidFinish(viewController.coordinator)
//        }
    }
}
