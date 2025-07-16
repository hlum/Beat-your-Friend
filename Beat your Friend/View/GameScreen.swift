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
    @State private var gameMessage: String = "Ready to Fight!"
    @State private var showGameMessage: Bool = false
    
    init() {
        // Create a temporary MPCManager for initialization
        // The actual MPCManager will be injected via environmentObject
        let tempMPCManager = MPCManager()
        _vm = StateObject(wrappedValue: GameScreenViewModel(mpcManager: tempMPCManager))
    }
    
    var body: some View {
        GeometryReader { geometry in
            
                VStack(spacing: 0) {
                    // Top Status Bar
                    statusBar
                        .padding(.top, 10)
                    
                    // Enemy Section
                    VStack(spacing: 10) {
                        // Enemy Health Bar
                        healthBar(health: mpcManager.enemyHealth, isPlayer: false)
                        
                        // Enemy Player
                        playerIcon(for: mpcManager.connectedPeers.first?.displayName, isPlayer: false)
                    }
                    .padding(.leading, 60)
                    
                    Spacer()
                    
                    if let enemyPunchDirection = mpcManager.enemyPunchDirection {
                        punch(to: enemyPunchDirection)
                    }
                    
                    if let playerPunchDirection = vm.punchDirection {
                        punch(to: playerPunchDirection)
                    }
                    
                    Spacer()
                    
                    
                    // Player Section
                    HStack {
                        VStack(spacing: 10) {
                            // Player
                            playerIcon(for: mpcManager.peerID.displayName, isPlayer: true)
                     
                            
                            // Player Health Bar
                            healthBar(health: vm.playerHealth, isPlayer: true)
                        }
                        
                        Text(String(format: "%.0f", vm.timeOutProgress))
                            .font(.title)
                            .bold()
                            .foregroundStyle(.red)
                            .padding(.trailing, 60)
                        if vm.isInTimeout {
                        }
                    }
                    
                    // Cooldown Indicator
                    if vm.isInCooldown {
                        cooldownIndicator
                            .padding(.bottom, 20)
                    }
                    
                    Spacer()
                }
                .background(
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [.black.opacity(0.9), .red.opacity(0.3), .black.opacity(0.9)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    // Game Message
                    if showGameMessage {
                        Text(gameMessage)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(15)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .onAppear {
            // Update the ViewModel's MPCManager reference with the correct one from environment
            vm.updateMPCManager(mpcManager)
            vm.startAccelerometer()
            vm.setupListenerToEnemyPunch()
            vm.setupListenerToPlayerHealth()
            showWelcomeMessage()
        }
        .onChange(of: vm.punchDirection) { newValue in
            if newValue != nil {
                showPunchMessage()
            }
        }
        .onChange(of: mpcManager.enemyPunchDirection) { newValue in
            if newValue != nil {
                showEnemyPunchMessage()
            }
        }
    }
    
    private func playerIcon(for name: String?, isPlayer: Bool) -> some View {
        VStack(spacing: 10) {
            Text(name ?? "Unknown")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)

            ZStack {
                // Glow effect
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [isPlayer ? .blue.opacity(0.6) : .red.opacity(0.6), .clear]),
                        center: .center,
                        startRadius: 30,
                        endRadius: 80
                    ))
                    .frame(width: 100, height: 100)
                
                // Character background
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(isPlayer ? Color.blue : Color.red, lineWidth: 3)
                    )
                
                // Character image
                Image(isPlayer ? .player : .enemy)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
        }
        .frame(width: 200, height: 150)
    }
    
    private func punch(to direction: PunchDirection) -> some View {
        HStack {
            Image(.fist)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .rotationEffect(.degrees(direction.degree))
            
            Text(String(format: "%.0f", direction.strength))
                .font(.title2)
                .bold()
                .foregroundColor(.red)
        }
    }
    
    // MARK: - UI Components
    
    private var statusBar: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Motion: \(vm.isMotionActive ? "Active" : "Inactive")")
                    .font(.caption)
                    .foregroundColor(.white)
                Text("Strength: \(String(format: "%.1f", vm.punchStrength))")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Connection")
                    .font(.caption)
                    .foregroundColor(.white)
                Text(mpcManager.connectionState == .connected ? "Connected" : "Disconnected")
                    .font(.caption)
                    .foregroundColor(mpcManager.connectionState == .connected ? .green : .red)
            }
        }
        .padding(.horizontal)
    }
    
    private func healthBar(health: Double, isPlayer: Bool) -> some View {
        VStack(spacing: 5) {
            Text(isPlayer ? "Your Health" : "Enemy Health")
                .font(.caption)
                .foregroundColor(.white)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 20)
                        .cornerRadius(10)
                    
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: health > 50 ? [.green, .yellow] : [.yellow, .red]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * (health / 100), height: 20)
                        .cornerRadius(10)
                        .animation(.easeInOut(duration: 0.3), value: health)
                }
            }
            .frame(height: 20)
            
            Text("\(Int(health))%")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(.horizontal)
    }
    
    private var cooldownIndicator: some View {
        VStack(spacing: 5) {
            Text("Cooldown")
                .font(.caption)
                .foregroundColor(.white)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: geometry.size.width * vm.cooldownProgress, height: 8)
                        .cornerRadius(4)
                        .animation(.linear(duration: 0.05), value: vm.cooldownProgress)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Game Messages
    
    private func showWelcomeMessage() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showGameMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showGameMessage = false
            }
        }
    }
    
    private func showPunchMessage() {
        gameMessage = "You Punched!"
        withAnimation(.easeInOut(duration: 0.3)) {
            showGameMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showGameMessage = false
            }
        }
    }
    
    private func showEnemyPunchMessage() {
        gameMessage = "Enemy Punched!"
        withAnimation(.easeInOut(duration: 0.3)) {
            showGameMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showGameMessage = false
            }
        }
    }
}

#Preview {
    NavigationView {
        GameScreen()
            .environmentObject(MPCManager())
    }
}
