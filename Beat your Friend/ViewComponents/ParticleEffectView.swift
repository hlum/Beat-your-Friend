//
//  ParticleEffectView.swift
//  Beat your Friend
//
//  Created by cmStudent on 2025/07/15.
//

import SwiftUI

struct ParticleEffectView: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles, id: \.id) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
    }
    
    private func createParticles(in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        for _ in 0..<20 {
            let particle = Particle(
                position: center,
                color: [.red, .orange, .yellow, .white].randomElement() ?? .white,
                size: Double.random(in: 2...8),
                opacity: Double.random(in: 0.5...1.0)
            )
            particles.append(particle)
        }
        
        // Animate particles
        withAnimation(.easeOut(duration: 0.5)) {
            for i in particles.indices {
                let angle = Double.random(in: 0...2 * .pi)
                let distance = Double.random(in: 30...80)
                particles[i].position.x += cos(angle) * distance
                particles[i].position.y += sin(angle) * distance
                particles[i].opacity = 0
            }
        }
        
        // Remove particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            particles.removeAll()
        }
    }
}

struct Particle {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: Double
    var opacity: Double
}

#Preview {
    ParticleEffectView()
        .frame(width: 500, height: 600)
}
