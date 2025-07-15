//
//  GameOverOverlay.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/15.
//
import SwiftUI

struct GameOverOverlay: View {
    let result: GameResult?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Result icon
                Image(systemName: resultIcon)
                    .font(.system(size: 100))
                    .foregroundColor(resultColor)
                
                // Result text
                Text(resultText)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Subtitle
                Text(resultSubtitle)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(40)
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

        }
        .transition(.scale.combined(with: .opacity))
    }
    
    private var resultIcon: String {
        switch result {
        case .win: return "crown.fill"
        case .lose: return "xmark.circle.fill"
        case .tie: return "equal.circle.fill"
        case .none: return "questionmark.circle.fill"
        }
    }
    
    private var resultColor: Color {
        switch result {
        case .win: return .yellow
        case .lose: return .red
        case .tie: return .blue
        case .none: return .gray
        }
    }
    
    private var resultText: String {
        switch result {
        case .win: return "VICTORY!"
        case .lose: return "DEFEAT"
        case .tie: return "TIE GAME"
        case .none: return "GAME OVER"
        }
    }
    
    private var resultSubtitle: String {
        switch result {
        case .win: return "You are the champion! 🎉"
        case .lose: return "Better luck next time! 💪"
        case .tie: return "Evenly matched! 🤝"
        case .none: return "Game ended"
        }
    }
}

#Preview {
    GameOverOverlay(result: .win)
}
