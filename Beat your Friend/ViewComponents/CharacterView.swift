//
//  CharacterView.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/15.
//
import SwiftUI

struct CharacterView: View {
    let isPlayer: Bool
    let isActive: Bool
    let punchDirection: PunchDirection?
    
    var body: some View {
        VStack {
            Image(isPlayer ? .player : .enemy)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    isActive ? (isPlayer ? Color.green : .red).opacity(0.3) : .clear,
                                    .clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 80
                            )
                        )
                        .frame(width: 120, height: 120)
                )
                .overlay(
                    Circle()
                        .stroke(
                            isActive ? (isPlayer ? .green : .red) : .clear,
                            lineWidth: 3
                        )
                        .frame(width: 120, height: 120)
                        .opacity(isActive ? 1 : 0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                  value: isActive)
                )
        }
        .frame(width: 150, height: 150)
    }
}


#Preview {
    CharacterView(isPlayer: true, isActive: true, punchDirection: .up(strength: 100))
}
