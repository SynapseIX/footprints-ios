//
//  LocationPermissionsCoordinator.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/26/21.
//

import UIKit

class LocationPermissionsCoordinator: NSObject, Coordinator {
    var navigationController: UINavigationController
    
    weak var parent: OnboardingCoordinator?
    var children = [CoordinatorKeys: Coordinator]()
    
    private var navigationStyle: NavigationStyle
    private var removeChildCallback: RemoveChildCallback
    
    init(navigationController: UINavigationController, navigationStyle: NavigationStyle, removeCoordinatorWith removeChildCallback: @escaping RemoveChildCallback) {
        self.navigationController = navigationController
        self.navigationStyle = navigationStyle
        self.removeChildCallback = removeChildCallback
    }
    
    func start() {
        navigationController.delegate = self
        
        let viewController = LocationPermissionsViewController.instantiate()
        viewController.coordinator = self
        navigate(to: viewController, with: .push)
    }
}

// MARK: - UINavigationControllerDelegate

extension LocationPermissionsCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // Process child coordinators once view controllers are popped out of navigation controller
        guard let viewController = navigationController.transitionCoordinator?.viewController(forKey: .from), !navigationController.viewControllers.contains(viewController) else {
            return
        }
        
        if viewController is LocationPermissionsViewController {
            removeChildCallback(self)
        }
    }
}
