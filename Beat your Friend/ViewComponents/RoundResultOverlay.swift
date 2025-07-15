//
//  RoundResultOverlay.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/15.
//
import SwiftUI

struct RoundResultOverlay: View {
    let result: TurnResult?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Result icon
                Image(systemName: resultIcon)
                    .font(.system(size: 80))
                    .foregroundColor(resultColor)
                
                // Result text
                Text(resultText)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
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
        case .blocked: return "shield.fill"
        case .hit: return "bolt.fill"
        case .missed: return "xmark.circle.fill"
        case .tie: return "equal.circle.fill"
        case .none: return "questionmark.circle.fill"
        }
    }
    
    private var resultColor: Color {
        switch result {
        case .blocked: return .green
        case .hit: return .red
        case .missed: return .orange
        case .tie: return .yellow
        case .none: return .gray
        }
    }
    
    private var resultText: String {
        switch result {
        case .blocked: return "GREAT BLOCK!\nYou scored!"
        case .hit: return "Got HIT!\nThey scored!"
        case .missed: return "MISSED!\nEnemy scored!"
        case .tie: return "TIE!\nSame strength!"
        case .none: return "Processing..."
        }
    }
}


#Preview {
    RoundResultOverlay(result: .blocked)
}
