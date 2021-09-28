//
//  FootprintsApp.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/28/21.
//

import SwiftUI

@main
struct FootprintsApp: App {
    @AppStorage(needsOnboardingKey)
    var needsOnboarding = true
    
    var body: some Scene {
        WindowGroup {
            if needsOnboarding {
                OnboardingView()
            }
            else {
                Text("Welcome to Footprints")
                    .transition(.scale)
            }
        }
    }
}
