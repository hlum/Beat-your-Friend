//
//  GameScreen.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/14.
//

import SwiftUI
import Foundation
import CoreMotion
import Combine




struct GameScreen: View {
    @StateObject private var vm: GameScreenViewModel
    @EnvironmentObject private var mpcManager: MPCManager

    
    
    init() {
        // Create a temporary MPCManager for initialization
        // The actual MPCManager will be injected via environmentObject
        let tempMPCManager = MPCManager()
        _vm = StateObject(wrappedValue: GameScreenViewModel(mpcManager: tempMPCManager))
    }
    
    var body: some View {
        VStack {
            Text("\(vm.isMotionActive ? "Active" : "Inactive")")
            Text("\(vm.punchStrength)")
            Text("\(vm.getMotionStatus())")
                .lineLimit(nil)
            Text("\(vm.punchDirection?.strength ?? 0)")
                .lineLimit(nil)

            ProgressView(value: vm.cooldownProgress)
                .progressViewStyle(.linear)
            
            
            playerIcon(for: mpcManager.connectedPeers.first?.displayName, isPlayer: false)
                .overlay(alignment: mpcManager.enemyPunchDirection?.overlayPlacement ?? .bottom) {
                    if let enemyPunchDirection = mpcManager.enemyPunchDirection {
                        punch(to: enemyPunchDirection)
                    }
                }
            
            
            playerIcon(for: mpcManager.peerID.displayName, isPlayer: true)
                .overlay(alignment: vm.punchDirection?.overlayPlacement ?? .bottom) {
                    if let punchDirection = vm.punchDirection {
                        punch(to: punchDirection)
                    }
                }
        }
        .padding()
        .onAppear {
            // Update the ViewModel's MPCManager reference with the correct one from environment
            vm.updateMPCManager(mpcManager)
            vm.startAccelerometer()
        }
    }
    
    private func playerIcon(for name: String?, isPlayer: Bool) -> some View {
        VStack {
            Text(name ?? "Unknown")
                .font(.headline)

            Image(isPlayer ? .player : .enemy)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
        }
        .frame(width: 270, height: 270)
        
    }
    
    private func punch(to direction: PunchDirection) -> some View {
        VStack {
            Image(.fist)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(direction.degree))
            Text(String(format: "%.1f", direction.strength))
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
