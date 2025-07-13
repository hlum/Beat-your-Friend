//
//  BrowsingView.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/11.
//

import SwiftUI

struct BrowsingView: View {
    @EnvironmentObject var mpcManager: MPCManager
    var body: some View {
        VStack {
            Button("Start Hotspot") {
                mpcManager.setupServices()
                mpcManager.startAdvertising()
                mpcManager.startBrowsing()
            }
            if mpcManager.connectedPeers.isEmpty {
                List(mpcManager.availablePeers, id: \.self) { peer in
                    HStack {
                        Text(peer.displayName)
                        Spacer()
                        Button {
                            mpcManager.invitePeer(peer)
                        } label: {
                            Text("招待する")
                                .foregroundStyle(.white)
                                .font(.headline)
                                .padding()
                                .frame(width: 150, height: 40)
                                .background(.blue)
                                .cornerRadius(10)
                        }

                    }
                    .padding()
                }
            } else {
                ConnectedPeerView()
                    .environmentObject(mpcManager)
            }
        }
        .navigationTitle("近くのプレイヤー")
    }
}

#Preview {
    NavigationStack {
        BrowsingView()
            .environmentObject(MPCManager())
    }
}
