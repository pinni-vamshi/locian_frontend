//
//  AnimatedReadyToStartView.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI

struct AnimatedReadyToStartView: View {
    @ObservedObject var appState: AppStateManager
    @State private var planeScale: CGFloat = 0.8
    @State private var planeOpacity: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Static plane in the middle with pulsing animation
            Image(systemName: "paperplane.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
                .scaleEffect(planeScale * pulseScale)
                .opacity(planeOpacity)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            startAnimation()
            startPulseAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 0.6)) {
            planeScale = 1.0
            planeOpacity = 1.0
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
    }
}

#Preview {
    AnimatedReadyToStartView(appState: AppStateManager())
        .background(Color.black)
        .preferredColorScheme(.dark)
}
