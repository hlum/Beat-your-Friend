//
//  MainTabView.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/13.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var mpcManager: MPCManager
    var body: some View {
        TabView {
            HomeScreen()
                .environmentObject(mpcManager)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            BrowsingView()
                .environmentObject(mpcManager)
                .tabItem {
                    Image(systemName: "shareplay")
                    Text("Profile")
                }
            
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(MPCManager())
    
}
