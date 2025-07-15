//
//  GlobalInvitationAlertView.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/12.
//


import SwiftUI

struct GlobalInvitationAlertView<Content: View>: View {
    @EnvironmentObject var mpcManager: MPCManager

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .alert("接続リクエスト", isPresented: $mpcManager.showInvitationPrompt, actions: {
                Button("許可する") {
                    if let invitation = mpcManager.pendingInvitation {
                        invitation.handler(true, mpcManager.session)
                        mpcManager.pendingInvitation = nil
                    }
                }
                Button("拒否", role: .cancel) {
                    if let invitation = mpcManager.pendingInvitation {
                        invitation.handler(false, nil)
                        mpcManager.pendingInvitation = nil
                    }
                }
            }, message: {
                if let peerID = mpcManager.pendingInvitation?.peerID {
                    Text("\(peerID.displayName) が接続しようとしています")
                } else {
                    Text("接続リクエストがあります")
                }
            })
    }
}
