//
//  BreathingAnimationModifier.swift
//  locian
//
//  Created by AI Assistant
//

import SwiftUI

struct BreathingAnimationModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    
    let minScale: CGFloat = 0.95
    let maxScale: CGFloat = 1.05
    let duration: Double = 1.5
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                // More prominent pulsating animation
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    scale = maxScale
                }
            }
    }
}

extension View {
    func breathingAnimation() -> some View {
        modifier(BreathingAnimationModifier())
    }
    
    // Conditional modifier helper
    func modifier<T: ViewModifier>(_ modifier: T, condition: Bool) -> some View {
        Group {
            if condition {
                self.modifier(modifier)
            } else {
                self
            }
        }
    }
}

