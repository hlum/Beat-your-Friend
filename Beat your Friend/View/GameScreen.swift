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
    @State private var showGameStart = false
    @State private var animatePunch = false
    @State private var shakeOffset: CGFloat = 0
    
    init() {
        let tempMPCManager = MPCManager()
        _vm = StateObject(wrappedValue: GameScreenViewModel(mpcManager: tempMPCManager))
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.2),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Main game content
            VStack(spacing: 0) {
                // Top HUD
                gameHUD
                
                Spacer()
                
                // Enemy section
                enemySection
                
                Spacer()
                
                // VS indicator
                vsIndicator
                
                Spacer()
                
                // Player section
                playerSection
                
                Spacer()
                
                // Bottom controls
                bottomControls
            }
            .padding()
            
            // Overlays
            gameStateOverlay
            
            // Particle effects
            if animatePunch {
                ParticleEffectView()
                    .allowsHitTesting(false)
            }
        }
        .offset(x: shakeOffset)
        .onAppear {
            vm.updateMPCManager(mpcManager)
            vm.startAccelerometer()
        }
        .onChange(of: vm.punchDirection) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                animatePunch = true
            }
            
            // Shake effect on punch
            withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                shakeOffset = 10
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animatePunch = false
                shakeOffset = 0
            }
        }
    }
    
    // MARK: - Game HUD
    private var gameHUD: some View {
        HStack {
            // Round indicator
            VStack {
                Text("ROUND")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text("\(vm.currentRound)/3")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    // Fill layer
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(Color.white.opacity(0.1)) // fill

                    // Stroke layer
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                }
            )

            Spacer()
            
            // Score display
            HStack(spacing: 20) {
                ScoreView(score: vm.playerScore, color: .green, label: "YOU")
                
                Text("-")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.5))
                
                ScoreView(score: vm.enemyScore, color: .red, label: "ENEMY")
            }
            
            Spacer()

            // Timer
            if vm.timeOutProgress > 0 && vm.gameState != .gameOver {
                TimerView(timeRemaining: $vm.timeOutProgress)
            }
        }
    }
    
    // MARK: - Enemy Section
    private var enemySection: some View {
        VStack(spacing: 15) {
            // Enemy name
            Text(mpcManager.connectedPeers.first?.displayName ?? "Enemy")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.red)
            
            // Enemy character with punch overlay
            ZStack {
                CharacterView(
                    isPlayer: false,
                    isActive: vm.gameState == .enemyTurn,
                    punchDirection: mpcManager.enemyPunchDirection
                )
                
                // Enemy punch effect
                if let enemyPunch = mpcManager.enemyPunchDirection {
                    PunchEffectView(
                        direction: enemyPunch,
                        alignment: enemyPunch.overlayPlacement,
                        isEnemy: true
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .scaleEffect(vm.gameState == .enemyTurn ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: vm.gameState)
        }
    }
    
    // MARK: - VS Indicator
    private var vsIndicator: some View {
        HStack {
            Rectangle()
                .fill(LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(height: 1)
            
            Text("VS")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 60, height: 60)
                )
            
            Rectangle()
                .fill(LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(height: 1)
        }
    }
    
    // MARK: - Player Section
    private var playerSection: some View {
        VStack(spacing: 15) {
            // Player character with punch overlay
            ZStack {
                CharacterView(
                    isPlayer: true,
                    isActive: vm.gameState == .myTurn,
                    punchDirection: vm.punchDirection
                )
                
                // Player punch effect
                if let playerPunch = vm.punchDirection {
                    PunchEffectView(
                        direction: playerPunch,
                        alignment: playerPunch.overlayPlacement,
                        isEnemy: false
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Cooldown overlay
                if vm.isInCooldown {
                    CooldownOverlay(progress: vm.cooldownProgress)
                }
            }
            .scaleEffect(vm.gameState == .myTurn ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: vm.gameState)
            
            // Player name
            Text(mpcManager.peerID.displayName)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
    }
    
    // MARK: - Bottom Controls
    private var bottomControls: some View {
        VStack(spacing: 15) {
            // Game status message
            Text(vm.getGameStatusMessage())
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    ZStack {
                        // Fill layer
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color.white.opacity(0.1)) // fill

                        // Stroke layer
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    }
                )

            
            // Action buttons
            HStack(spacing: 20) {
                if vm.gameState == .waiting {
                    ActionButton(
                        title: "START GAME",
                        color: .green,
                        icon: "play.fill"
                    ) {
                        vm.startGame()
                    }
                }
                
                if vm.showResetButton {
                    ActionButton(
                        title: "RESET",
                        color: .blue,
                        icon: "arrow.clockwise"
                    ) {
                        vm.resetGame()
                    }
                }
            }
        }
    }
    
    // MARK: - Game State Overlay
    @ViewBuilder
    private var gameStateOverlay: some View {

        if vm.gameState == .roundResult {
            RoundResultOverlay(result: vm.turnResult)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        vm.gameState = .waiting
                    }
                }
        }
        
        if vm.gameState == .gameOver {
            GameOverOverlay(result: vm.gameResult)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        vm.gameState = .waiting
                        vm.showResetButton = true
                    }
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
