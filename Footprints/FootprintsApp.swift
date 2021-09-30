//
//  FootprintsApp.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/28/21.
//

import SwiftUI

@main
struct FootprintsApp: App {
    @AppStorage(hasCompletedOnboardingKey)
    var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                HomeTabView()
                    .transition(.scale)
            }
            else {
                OnboardingView()
            }
        }
    }
}
