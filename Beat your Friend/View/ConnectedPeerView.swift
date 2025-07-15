//
//  ConnectedPeerView.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/12.
//


import SwiftUI

struct ConnectedPeerView: View {
    @EnvironmentObject var mpcManager: MPCManager

    var body: some View {
        if let connectedPeer = mpcManager.connectedPeers.first {
            VStack {
                HStack(spacing: 16) {
                    // Avatar
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.blue)
                        .frame(width: 50, height: 50)

                    // Peer Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("接続済みのプレイヤー")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text(connectedPeer.displayName)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    // Connection Status
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                        Text("オンライン")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                                
                Button {
                    mpcManager.disconnect()
                } label: {
                    Text("切断する")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(.red)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }

            }
            .padding()
            .background(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

        } else {
            EmptyView()
        }
    }
}

#Preview {
    ConnectedPeerView()
        .environmentObject(MPCManager())
}
