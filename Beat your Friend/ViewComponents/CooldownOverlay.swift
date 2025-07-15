//
//  CooldownOverlay.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/15.
//
import SwiftUI

struct CooldownOverlay: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                
                Text("\(Int(progress))s")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top)
            }
        }
        .frame(width: 150, height: 150)
        .clipShape(Circle())
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    CooldownOverlay(progress: 10)
}
