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
        ZStack {
            VStack {
                
                playerIcon(for: mpcManager.connectedPeers.first?.displayName, isPlayer: false)
                    .overlay(alignment: mpcManager.enemyPunchDirection?.overlayPlacement ?? .bottom) {
                        if let enemyPunchDirection = mpcManager.enemyPunchDirection {
                            punch(to: enemyPunchDirection)
                        }
                    }
                
                if !vm.gameOver {
                    timeOutTimer
                }
                
                
                playerIcon(for: mpcManager.peerID.displayName, isPlayer: true)
                    .overlay(alignment: vm.punchDirection?.overlayPlacement ?? .bottom) {
                        if let punchDirection = vm.punchDirection {
                            punch(to: punchDirection)
                        }
                    }
                    .overlay {
                        coolDownView
                    }

            }
            .padding()
            .onAppear {
                // Update the ViewModel's MPCManager reference with the correct one from environment
                vm.updateMPCManager(mpcManager)
                vm.startAccelerometer()
            }
            
            
            if vm.gameOver {
                Text("Game Over")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.red)
            }
        }
    }
    
    private var timeOutTimer: some View {
        HStack {
            Image(systemName: "timer")
            Text(String(format: "%.0f", vm.timeOutProgress))
        }
        .font(.system(size: 40))
        .foregroundStyle(.red)
    }
    
    @ViewBuilder
    private var coolDownView: some View {
        if vm.isInCooldown {
            ZStack {
                Color.gray.opacity(0.7)
                VStack {
                    ProgressView()
                    HStack {
                        Text(String(format: "%.0f", vm.cooldownProgress) + "秒")
                            .font(.system(size: 100))
                            .bold()
                            .foregroundStyle(.red)
                    }
                }
                .transition(.scale)
            }
            .cornerRadius(500)
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
        .frame(width: 270, height: 300)
    }
    
    private func punch(to direction: PunchDirection) -> some View {
        VStack {
            Image(.fist)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(direction.degree))
            Text(String(format: "%.0f", direction.strength))
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
