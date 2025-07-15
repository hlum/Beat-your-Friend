//
//  ActionButton.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/15.
//
import SwiftUI

struct ActionButton: View {
    let title: String
    let color: Color
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(color)
                    .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
            )
        }
        .buttonStyle(PressedButtonStyle())
    }
}

struct PressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

