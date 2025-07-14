//
//  Beat_your_FriendApp.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/11.
//

import SwiftUI

@main
struct Beat_your_FriendApp: App {
    @StateObject private var mpcManager: MPCManager = .init()
    var body: some Scene {
        WindowGroup {
            NavigationView {
                GlobalInvitationAlertView {
                    MainTabView()
                        .environmentObject(mpcManager)
                }
                .environmentObject(mpcManager)
            }
        }
    }
}
