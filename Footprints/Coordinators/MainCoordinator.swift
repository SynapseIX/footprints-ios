//
//  MainCoordinator.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/24/21.
//

import UIKit

class MainCoordinator: Coordinator {    
    var navigationController: UINavigationController
    var children = [CoordinatorKeys: Coordinator]()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)
        
        if UserDefaults.standard.hasCompletedOnboarding {
            // TODO: navigate home
        }
        else {
            let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
            onboardingCoordinator.parent = self
            addChild(coordinator: onboardingCoordinator, with: .onboardingCoordinator)
            onboardingCoordinator.start()
        }
    }
}

