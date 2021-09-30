//
//  OnboardingCard.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/29/21.
//

import SwiftUI

enum CardType: String {
    case welcome
    case camera
    case location
    case mic
    case done
}

struct OnboardingCard: View {
    @State private var isAnimating = false
    
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let imageName: String
    let buttonTitle: LocalizedStringKey
    let buttonAction: (() -> Void)?
    let backgroundGradientColors: [Color]
    
    init(title: LocalizedStringKey,
         message: LocalizedStringKey,
         imageName: String,
         buttonTitle: LocalizedStringKey,
         buttonAction: (() -> Void)? = nil,
         backgroundGradientColors: [Color]) {
        
        self.title = title
        self.message = message
        self.imageName = imageName
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        self.backgroundGradientColors = backgroundGradientColors
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24.0) {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .shadow(color: .black.opacity(0.75), radius: 8, x: 6, y: 8)
                        .padding(.top, 32.0)
                        .scaleEffect(isAnimating ? 1.0 : 0.1)
                    Text(title)
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.15), radius: 2, x: 2, y: 2)
                    Text(message)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16.0)
                        .frame(maxWidth: 480.0)
                    NextButton(title: buttonTitle,
                               action: buttonAction)
                        .padding(.top, 24.0)
                        .padding(.bottom, 24.0)
                }
                .padding(16.0)
            }
        }
        .frame(minWidth: 0.0,
               maxWidth: .infinity,
               minHeight: 0.0,
               maxHeight: .infinity,
               alignment: .center)
        .background(LinearGradient(gradient: Gradient(colors: backgroundGradientColors),
                                   startPoint: .top,
                                   endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
        .gesture(DragGesture())
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

struct OnboardingCard_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCard(title: "WelcomeToFootprints",
                       message: "WelcomeMessage",
                       imageName: "chest",
                       buttonTitle: "LetsGetStarted",
                       backgroundGradientColors: [Color("ColorBlueberryLight"), Color("ColorBlueberryDark")])
            .previewLayout(.fixed(width: 320, height: 640))
    }
}
