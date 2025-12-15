//
//  HapticFeedback.swift
//  locian
//
//  Created for centralized haptic feedback
//

import UIKit

// MARK: - Centralized Haptic Feedback Helper
struct HapticFeedback {
    // Light impact - for subtle button presses
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // Medium impact - for standard button presses (default)
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // Heavy impact - for important actions
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // Selection feedback - for selection changes (pickers, toggles)
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // Success notification - for successful actions
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // Warning notification - for warnings
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    // Error notification - for errors
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // Button press and release - double haptic for button interactions
    // Call this on press (when button is first touched) and on release (when button is released)
    static func buttonPress() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func buttonRelease() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

