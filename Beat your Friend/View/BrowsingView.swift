//
//  BrowsingView.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/11.
//

import SwiftUI

struct BrowsingView: View {
    @AppStorage("DisplayName") private var displayName = ""
    @EnvironmentObject var mpcManager: MPCManager
    
    @State private var isSearching: Bool = false
    var body: some View {
        NavigationView {
            VStack {
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .environmentObject(mpcManager)
                }
            }
            .navigationTitle("近くのプレイヤー")
            .overlay(alignment: .bottomTrailing, content: {
                Button {
                    isSearching.toggle()
                    mpcManager.setDisplayName(displayName)
                    mpcManager.startAllServices()
                } label: {
                    VStack(spacing: 0){
                        if #available(iOS 17.0, *) {
                            Image(systemName: "shareplay")
                                .symbolEffect(.variableColor, options: .speed(0.1), value: isSearching)
                                .symbolRenderingMode(.palette)
                                .tint(isSearching ? .green : .gray)
                                .font(.title)
                        } else {
                            Image(systemName: "shareplay")
                                .font(.title3)
                                .tint(isSearching ? .green : .gray)
                        }
                        Text("Search")
                            .font(.caption)
                            .foregroundStyle(.black)
                    }
                    .padding(1)
                    .frame(width: 80, height: 80)
                    .background(Color.white)
                    .cornerRadius(100)
                    .shadow(color: .gray, radius: 5, x: 0, y: 10)
                    .padding()
                }
            })
        }
    }
}

#Preview {
    NavigationStack {
        BrowsingView()
            .environmentObject(MPCManager())
    }
}
