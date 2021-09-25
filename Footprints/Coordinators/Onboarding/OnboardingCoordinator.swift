//
//  OnboardingCoordinator.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/24/21.
//

import UIKit

class OnboardingCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    weak var parent: MainCoordinator?
    var children = [Coordinator]()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let welcomeCoordinator = WelcomeCoordinator(navigationController: navigationController)
        welcomeCoordinator.parent = self
        children.append(welcomeCoordinator)
        welcomeCoordinator.start()
    }
}

