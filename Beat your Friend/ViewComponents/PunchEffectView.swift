//
//  PunchEffectView.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/15.
//

import SwiftUI

struct PunchEffectView: View {
    let direction: PunchDirection
    let alignment: Alignment
    let isEnemy: Bool
    
    var body: some View {
        VStack {
            // Punch fist
            Image(.fist)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(direction.degree))
                .foregroundColor(isEnemy ? .red : .green)
            
            // Strength indicator
            Text(String(format: "%.0f", direction.strength))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isEnemy ? .red : .green)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 5)
        )
        .scaleEffect(1.2)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: direction)
    }
}

#Preview {
    PunchEffectView(direction: .up(strength: 100), alignment: .top, isEnemy: false)
}
