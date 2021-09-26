//
//  Coordinator.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/24/21.
//

import UIKit

typealias RemoveChildCallback = (Coordinator) -> ()

enum CoordinatorKeys: String {
    case mainCoordinator
    case onboardingCoordinator
    case welcomeCoordinator
}

enum NavigationStyle {
    case present
    case push
}

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var children: [CoordinatorKeys: Coordinator] { get set }
    
    func start()
    func addChild(coordinator: Coordinator, with key: CoordinatorKeys)
    func removeChild(coordinator: Coordinator)
}

//MARK: - Default implementation of add/remove child methods

extension Coordinator {
    func addChild(coordinator: Coordinator, with key: CoordinatorKeys) {
        children[key] = coordinator
    }
    
    func removeChild(coordinator: Coordinator) {
        children = children.filter { $0.value !== coordinator }
    }
}

//MARK: - Navigation helper

extension Coordinator {
    func navigate(to viewController: UIViewController, with navigationStyle: NavigationStyle, animated: Bool = true) {
        switch navigationStyle {
        case .present:
            navigationController.present(viewController, animated: animated, completion: nil)
        case .push:
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}

