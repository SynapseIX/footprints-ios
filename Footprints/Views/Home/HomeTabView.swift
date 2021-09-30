//
//  HomeTabView.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/30/21.
//

import SwiftUI

enum HomeTabType: String {
    case home
}

struct HomeTabView: View {
    @State private var selectedTab: HomeTabType = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Welcome to Footprints")
                .tabItem {
                    Image(systemName: "house")
                        .font(.system(size: 24))
                        .tag(HomeTabType.home)
                }
                .tag(HomeTabType.home)
        }
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
