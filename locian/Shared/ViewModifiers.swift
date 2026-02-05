//
//  ViewModifiers.swift
//  locian
//
//  Created for shared view modifiers
//

import SwiftUI


/// Modifier for fade and scale appearance animation
struct AppearFadeScaleModifier: ViewModifier {
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.95
    
    var initialScale: CGFloat = 0.95
    var animation: Animation = .spring(response: 0.6, dampingFraction: 0.8)
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(animation) {
                    opacity = 1.0
                    scale = 1.0
                }
            }
    }
}

extension View {
    func appearFadeScale(initialScale: CGFloat = 0.95, animation: Animation = .spring(response: 0.6, dampingFraction: 0.8)) -> some View {
        modifier(AppearFadeScaleModifier(initialScale: initialScale, animation: animation))
    }
}

/// Modifier to block back navigation and swipe gestures
struct BlockBackNavigationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .gesture(DragGesture(minimumDistance: 0))
    }
}

extension View {
    func blockBackNavigation() -> some View {
        modifier(BlockBackNavigationModifier())
    }
}


/// Centralized "Hard Shadow" modifier for the Locian retro/neon aesthetic
struct LocianHardShadowModifier: ViewModifier {
    var color: Color
    var offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: 0, x: offset, y: offset)
    }
}

extension View {
    /// Applies a radius-0 "hard" drop shadow with configurable color and offset
    func locianHardShadow(color: Color = .white, offset: CGFloat = 4) -> some View {
        modifier(LocianHardShadowModifier(color: color, offset: offset))
    }
}

