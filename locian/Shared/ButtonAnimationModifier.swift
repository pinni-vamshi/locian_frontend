//
//  ButtonAnimationModifier.swift
//  locian
//
//  Simple button press animation
//

import SwiftUI

// MARK: - Simple Button Press Animation
struct ButtonPressAnimation: ViewModifier {
    @State private var isPressed: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                if pressing != isPressed {
                    isPressed = pressing
                    if pressing {
                        HapticFeedback.buttonPress()
                    } else {
                        HapticFeedback.buttonRelease()
                    }
                }
            }) {}
    }
}

// MARK: - View Extensions
extension View {
    func buttonPressAnimation() -> some View {
        modifier(ButtonPressAnimation())
    }
    
    func circleButtonPressAnimation() -> some View {
        modifier(ButtonPressAnimation())
    }
}
