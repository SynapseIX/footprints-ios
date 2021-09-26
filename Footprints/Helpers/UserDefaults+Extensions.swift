//
//  UserDefaults+Extensions.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/25/21.
//

import Foundation

extension UserDefaults {
    // Onboarding
    var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: OnboardingCoordinator.onboardingCompletedKey)
        }
        set {
            UserDefaults.standard.set(true, forKey: OnboardingCoordinator.onboardingCompletedKey)
        }
    }
}

