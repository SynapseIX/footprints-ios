//
//  OnboardingCoordinator.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/24/21.
//

import UIKit

class OnboardingCoordinator: NSObject, Coordinator {
    static let onboardingCompletedKey = "onboardingCompletedKey"
    
    var navigationController: UINavigationController
    
    weak var parent: AppCoordinator?
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
        
        let viewController = OnboardingViewController.instantiate()
        viewController.coordinator = self
        navigate(to: viewController, with: navigationStyle, animated: false)
    }
    
    func letsGetStartedTapped() {
        // TODO: uncomment once home screen is stubbed
        // UserDefaults.standard.hasCompletedOnboarding = true
        parent?.navigateHome()
    }
}

// MARK: - UINavigationControllerDelegate

extension OnboardingCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let viewController = navigationController.transitionCoordinator?.viewController(forKey: .from), !navigationController.viewControllers.contains(viewController) else {
            return
        }
        
        // Remove child coordinator once view controller is popped
        if viewController is OnboardingViewController {
            removeChildCallback(self)
        }
    }
}

