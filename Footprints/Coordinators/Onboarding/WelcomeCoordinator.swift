//
//  WelcomeCoordinator.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/25/21.
//

import UIKit

class WelcomeCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    weak var parent: OnboardingCoordinator?
    var children = [Coordinator]()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let welcomeViewController = WelcomeViewController.instantiate()
        welcomeViewController.coordinator = self
        navigationController.pushViewController(welcomeViewController, animated: false)
    }
    
    func startButtonTapped() {
        // TODO: implement
        print("startButtonTapped")
    }
}