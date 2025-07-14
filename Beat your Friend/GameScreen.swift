//
//  GameScreen.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/14.
//

import SwiftUI

struct GameScreen: View {
    @EnvironmentObject private var mpcManager: MPCManager
    @State private var punchDirection: PunchDirection? = .up(strength: 1000)
    var body: some View {
        VStack {
            playerIcon(for: mpcManager.connectedPeers.first?.displayName, isPlayer: false)
                .overlay(alignment: mpcManager.enemyPunchDirection?.overlayPlacement ?? .bottom) {
                    if let punchDirection {
                        punch(to: punchDirection)
                    }
                }
            
            
            playerIcon(for: mpcManager.peerID.displayName, isPlayer: true)
                .overlay(alignment: mpcManager.enemyPunchDirection?.overlayPlacement ?? .bottom) {
                    if let punchDirection {
                        punch(to: punchDirection)
                    }
                }
        }
        .padding()
    }
    
    private func playerIcon(for name: String?, isPlayer: Bool) -> some View {
        VStack {
            Text(name ?? "Unknown")
                .font(.headline)

            Image(isPlayer ? .player : .enemy)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
        .frame(width: 370, height: 370)
        
    }
    
    private func punch(to direction: PunchDirection) -> some View {
        VStack {
            Image(.fist)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(direction.degree))
            Text(String(format: "%.2f", direction.strength))
                .font(.title)
                .bold()
                .foregroundColor(.red)
        }
    }
}

#Preview {
    NavigationView {
        GameScreen()
            .environmentObject(MPCManager())
    }
}
