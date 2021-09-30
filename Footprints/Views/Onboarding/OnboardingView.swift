//
//  OnboardingView.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/28/21.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage(hasCompletedOnboardingKey)
    var hasCompletedOnboarding: Bool?
    
    @State private var selectedPage: CardType = .welcome
    
    var body: some View {
        let action = {
            switch selectedPage {
            case .welcome:
                withAnimation {
                    selectedPage = .location
                }
            case .location:
                withAnimation {
                    selectedPage = .camera
                }
            case .camera:
                withAnimation {
                    selectedPage = .mic
                }
            case .mic:
                withAnimation {
                    selectedPage = .done
                }
            case .done:
                hasCompletedOnboarding = true
            }
        }
        
        TabView(selection: $selectedPage) {
            OnboardingCard(title: "WelcomeToFootprints",
                           message: "WelcomeMessage",
                           imageName: "chest",
                           buttonTitle: "LetsGetStarted",
                           buttonAction: action,
                           backgroundGradientColors: [Color("ColorPomegranateDark"), Color("ColorGrapefruitDark")])
                .tag(CardType.welcome)
            OnboardingCard(title: "GreatPlacesMakeGreatMemories",
                           message: "LocationMessage",
                           imageName: "map",
                           buttonTitle: "AllowLocationAccess",
                           buttonAction: action,
                           backgroundGradientColors: [Color("ColorLimeDark"), Color("ColorPomegranateDark")])
                .tag(CardType.location)
            OnboardingCard(title: "A1000Words",
                           message: "CameraMessage",
                           imageName: "camera",
                           buttonTitle: "AllowCameraAccess",
                           buttonAction: action,
                           backgroundGradientColors: [Color("ColorPlumLight"), Color("ColorBlueberryLight")])
                .tag(CardType.camera)
            OnboardingCard(title: "PhrasesLyricsThoughts",
                           message: "MicMessage",
                           imageName: "mic",
                           buttonTitle: "AllowMicAccess",
                           buttonAction: action,
                           backgroundGradientColors: [Color("ColorLemonLight"), Color("ColorLemonDark")])
                .tag(CardType.mic)
            OnboardingCard(title: "WeAreReady",
                           message: "ReadyMessage",
                           imageName: "checkmark",
                           buttonTitle: "ContinueToFootprints",
                           buttonAction: action,
                           backgroundGradientColors: [Color("ColorStrawberryDark"), Color("ColorStrawberryLight")])
                .tag(CardType.done)
        }
        .tabViewStyle(PageTabViewStyle())
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(.dark)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
