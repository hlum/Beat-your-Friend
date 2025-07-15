//
//  TimerView.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/15.
//
import SwiftUI

struct TimerView: View {
    @Binding var timeRemaining: Double
    
    var body: some View {
        VStack {
            Image(systemName: "timer")
                .font(.title2)
            Text(String(format: "%.0f", timeRemaining))
                .font(.title2)
                .fontWeight(.bold)
        }
        .foregroundColor(timeRemaining <= 2 ? .red : .orange)
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
        .scaleEffect(timeRemaining <= 2 ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: timeRemaining)
//        .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true),value: timeRemaining <= 2)
    }
}

#Preview {
    TimerView(timeRemaining: .constant(10))
}
