//
//  ScoreView.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/15.
//
import SwiftUI

struct ScoreView: View {
    let score: Int
    let color: Color
    let label: String
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text("\(score)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
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

    }
}


#Preview {
    ZStack {
        Color.black
        ScoreView(score: 10, color: .red, label: "Enemy")
    }
}
