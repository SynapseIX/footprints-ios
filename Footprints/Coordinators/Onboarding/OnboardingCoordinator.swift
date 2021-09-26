//
//  OnboardingCoordinator.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/24/21.
//

import UIKit



class OnboardingCoordinator: Coordinator {
    static let onboardingCompletedKey = "onboardingCompletedKey"
    
    var navigationController: UINavigationController
    
    weak var parent: MainCoordinator?
    var children = [CoordinatorKeys: Coordinator]()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let welcomeCoordinator = WelcomeCoordinator(navigationController: navigationController,
                                                    navigationStyle: .push,
                                                    removeCoordinatorWith: removeChild)
        welcomeCoordinator.parent = self
        addChild(coordinator: welcomeCoordinator, with: .welcomeCoordinator)
        welcomeCoordinator.start()
    }
}

