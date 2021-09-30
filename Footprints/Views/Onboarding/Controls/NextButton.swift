//
//  NextButton.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/29/21.
//

import SwiftUI

struct NextButton: View {
    let title: LocalizedStringKey
    let systemImageName: String?
    let action: (() -> Void)?
    
    init(title: LocalizedStringKey,
         systemImageName: String? = nil,
         action: (() -> Void)? = nil) {
        
        self.title = title
        self.systemImageName = systemImageName
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16.0) {
                Text(title)
                    .foregroundColor(.white)
                
                if let systemImageName = systemImageName {
                    Image(systemName: systemImageName)
                        .imageScale(.large)
                }
            }
            .padding(.horizontal, 16.0)
            .padding(.vertical, 8.0)
            .background(Capsule().strokeBorder(.white, lineWidth: 1.75))
        }
        .accentColor(.white)
    }
}

struct NextButton_Previews: PreviewProvider {
    static var previews: some View {
        NextButton(title: "LetsGetStarted")
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
