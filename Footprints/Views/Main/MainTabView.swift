//
//  MainTabView.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/30/21.
//

import SwiftUI

enum MainTabType: String {
    case home
}

struct MainTabView: View {
    @State private var selectedTab: MainTabType = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Welcome to Footprints")
                .tabItem {
                    Image(systemName: "house")
                        .font(.system(size: 24))
                        .tag(MainTabType.home)
                }
                .tag(MainTabType.home)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
