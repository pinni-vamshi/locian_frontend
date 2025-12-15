//
//  BrainAwarenessView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

struct BrainAwarenessView: View {
    @State private var pulseScale: CGFloat = 1.0
    @State private var ring1Scale: CGFloat = 1.0
    @State private var ring2Scale: CGFloat = 1.0
    @State private var ring3Scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Ring 1 (Outer) - 200px
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 200, height: 200)
                .scaleEffect(ring1Scale)
                .opacity(0.6)
            
            // Ring 1 Icons (Outer ring) - Triangular positions
            Image(systemName: "airplane")
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.7))
                .offset(y: -100) // Top of ring 1
                .scaleEffect(ring1Scale)
                .opacity(0.6)
            
            Image(systemName: "car")
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.7))
                .offset(x: 87, y: 50) // Bottom right of ring 1
                .scaleEffect(ring1Scale)
                .opacity(0.6)
            
            Image(systemName: "house")
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.7))
                .offset(x: -87, y: 50) // Bottom left of ring 1
                .scaleEffect(ring1Scale)
                .opacity(0.6)
            
            // Ring 2 (Middle) - 160px
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                .frame(width: 160, height: 160)
                .scaleEffect(ring2Scale)
                .opacity(0.4)
            
            // Ring 2 Icons (Middle ring) - Time, Weather, Temperature
            Image(systemName: "clock")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.6))
                .offset(y: -80) // Top of ring 2
                .rotationEffect(.degrees(45)) // Rotate 45 degrees
                .scaleEffect(ring2Scale)
                .opacity(0.4)
            
            Image(systemName: "cloud.sun")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.6))
                .offset(x: 69, y: 40) // Bottom right of ring 2
                .rotationEffect(.degrees(45)) // Rotate 45 degrees
                .scaleEffect(ring2Scale)
                .opacity(0.4)
            
            Image(systemName: "thermometer")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.6))
                .offset(x: -69, y: 40) // Bottom left of ring 2
                .rotationEffect(.degrees(45)) // Rotate 45 degrees
                .scaleEffect(ring2Scale)
                .opacity(0.4)
            
            // Ring 3 (Inner) - 120px
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 2)
                .frame(width: 120, height: 120)
                .scaleEffect(ring3Scale)
                .opacity(0.3)
            
            // Central brain icon
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .scaleEffect(pulseScale)
        }
        .onAppear {
            startPulseAnimation()
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.2
        }
        
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            ring1Scale = 1.3
        }
        
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.3)) {
            ring2Scale = 1.2
        }
        
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(0.6)) {
            ring3Scale = 1.1
        }
    }
}

#Preview {
    BrainAwarenessView()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
