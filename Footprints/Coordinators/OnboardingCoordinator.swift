//
//  OnboardingCoordinator.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/24/21.
//

import UIKit

class OnboardingCoordinator: Coordinator {
    weak var parent: MainCoordinator?
    var navigationController: UINavigationController
    var children = [Coordinator]()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let welcomeViewController = WelcomeViewController.instantiate()
        welcomeViewController.coordinator = self
        navigationController.pushViewController(welcomeViewController, animated: false)
    }
}

