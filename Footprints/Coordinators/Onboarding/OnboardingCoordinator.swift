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
        let coordinator = WelcomeCoordinator(navigationController: navigationController,
                                                    navigationStyle: .push,
                                                    removeCoordinatorWith: removeChild)
        coordinator.parent = self
        addChild(coordinator: coordinator, with: .welcomeCoordinator)
        coordinator.start()
    }
    
    func navigateToLocationPermissions() {
        let coordinator = LocationPermissionsCoordinator(navigationController: navigationController,
                                                         navigationStyle: .push,
                                                         removeCoordinatorWith: removeChild)
        coordinator.parent = self
        coordinator.locationService = LocationService()
        addChild(coordinator: coordinator, with: .locationPermissionsCoordinator)
        coordinator.start()
    }
}

