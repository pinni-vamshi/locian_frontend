//
//  ButtonAnimationModifier.swift
//  locian
//
//  Created for centralized button animations
//

import SwiftUI

// MARK: - Centralized Button Animation Configuration
struct ButtonAnimationConfig {
    static let springResponse: Double = 0.4      // Smoother response (increased from 0.25)
    static let springDamping: Double = 0.55     // Slightly more prominent bounce (reduced from 0.6 to 0.55)
    static let pressScale: CGFloat = 0.75        // Scale down on press (more prominent)
    static let pressScaleUp: CGFloat = 1.5       // Scale up on press (for circle buttons) - more prominent pop
    static let releaseDuration: Double = 0.1     // Quicker release
    static let radialExpansion: CGFloat = 1.15   // Radial expansion factor for wiggle effect (expanding/shrinking)
}

// MARK: - Button Press Animation Modifier
struct ButtonPressAnimation: ViewModifier {
    @State private var isPressed: Bool = false
    @State private var initialLocation: CGPoint? = nil
    @State private var hasTriggeredPressHaptic: Bool = false
    @State private var hasTriggeredReleaseHaptic: Bool = false
    @State private var gestureStartTime: Date? = nil
    @State private var lastHapticTime: Date? = nil // Debounce haptic feedback
    @State private var isGestureActive: Bool = false // Track if gesture is actually active
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? ButtonAnimationConfig.pressScale : 1.0)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // CRITICAL: Only process if this is a REAL touch event
                        // Check that startLocation is valid (not zero/negative, which indicates view update)
                        guard value.startLocation.x > 0 && value.startLocation.y > 0 else {
                            return // Invalid start location - likely a view update, not a touch
                        }
                        
                        // On tap (first touch) - TRIGGER PRESS HAPTIC
                        if initialLocation == nil {
                            // CRITICAL: Only trigger if this is a real user touch
                            // Check that the gesture actually started (has valid start location and time)
                            let now = Date()
                            gestureStartTime = now
                            initialLocation = value.location
                            isGestureActive = true
                            
                            // Trigger haptic on press (first touch) - but only if not dragging
                            let timeSinceLastHaptic = lastHapticTime.map { Date().timeIntervalSince($0) } ?? 1.0
                            if timeSinceLastHaptic > 0.1 {
                                HapticFeedback.buttonPress()
                                hasTriggeredPressHaptic = true
                                lastHapticTime = Date()
                            }
                            
                            // Scale down with spring animation on tap
                            withAnimation(
                                .spring(
                                    response: ButtonAnimationConfig.springResponse,
                                    dampingFraction: ButtonAnimationConfig.springDamping
                                )
                            ) {
                                isPressed = true
                            }
                        } else {
                            // Check if user is scrolling (movement > 5 points)
                            let delta = CGPoint(
                                x: abs(value.location.x - (initialLocation?.x ?? 0)),
                                y: abs(value.location.y - (initialLocation?.y ?? 0))
                            )
                            
                            // If dragging, release press to allow scrolling and cancel haptics
                            if delta.x > 5 || delta.y > 5 {
                                if isPressed {
                                    withAnimation(
                                        .spring(
                                            response: ButtonAnimationConfig.springResponse,
                                            dampingFraction: ButtonAnimationConfig.springDamping
                                        )
                                    ) {
                                        isPressed = false
                                    }
                                }
                                // Mark that this was a drag, so we don't trigger release haptic
                                hasTriggeredPressHaptic = false
                            }
                        }
                    }
                    .onEnded { value in
                        // Check that gesture actually started (has start time and location) AND was active
                        guard let startTime = gestureStartTime,
                              let startLocation = initialLocation,
                              isGestureActive else {
                            // Not a real gesture - just reset state
                            initialLocation = nil
                            gestureStartTime = nil
                            hasTriggeredPressHaptic = false
                            hasTriggeredReleaseHaptic = false
                            isGestureActive = false
                            if isPressed {
                                withAnimation {
                                    isPressed = false
                                }
                            }
                            return
                        }
                        
                        // Calculate total movement during gesture
                        let totalMovement = sqrt(
                            pow(value.location.x - startLocation.x, 2) +
                            pow(value.location.y - startLocation.y, 2)
                        )
                        
                        // Check gesture duration - real taps are usually < 300ms
                        let gestureDuration = Date().timeIntervalSince(startTime)
                        
                        // CRITICAL: If ANY drag detected (movement > 5 points), COMPLETELY SKIP RELEASE HAPTIC
                        // Only trigger release haptic if this was a QUICK TAP with NO DRAG:
                        // - Short duration (< 300ms)
                        // - Minimal movement (< 5 points) - STRICT threshold to detect any drag
                        // - Press haptic was triggered (not a drag)
                        let timeSinceLastHaptic = lastHapticTime.map { Date().timeIntervalSince($0) } ?? 1.0
                        let isQuickTap = gestureDuration < 0.3 && totalMovement < 5.0 && hasTriggeredPressHaptic
                        
                        // ONLY trigger release haptic if confirmed tap (NO DRAG detected)
                        if isQuickTap && timeSinceLastHaptic > 0.1 {
                            // This was an actual button click - trigger release haptic
                            HapticFeedback.buttonRelease()
                            lastHapticTime = Date()
                        }
                        // If drag detected (totalMovement >= 5.0), NO RELEASE HAPTIC - completely skipped
                        
                        // Always release the press animation
                        if isPressed {
                            withAnimation(
                                .spring(
                                    response: ButtonAnimationConfig.springResponse,
                                    dampingFraction: ButtonAnimationConfig.springDamping
                                )
                            ) {
                                isPressed = false
                            }
                        }
                        
                        // Reset state
                        initialLocation = nil
                        gestureStartTime = nil
                        hasTriggeredPressHaptic = false
                        hasTriggeredReleaseHaptic = false
                        isGestureActive = false
                    }
            )
    }
}

// MARK: - Circle Button Press Animation (Scale Up with Radial Wiggle)
struct CircleButtonPressAnimation: ViewModifier {
    @State private var isPressed: Bool = false
    @State private var initialLocation: CGPoint? = nil
    @State private var expansionPhase: CGFloat = 1.0
    @State private var hasTriggeredPressHaptic: Bool = false
    @State private var hasTriggeredReleaseHaptic: Bool = false
    @State private var gestureStartTime: Date? = nil
    @State private var lastHapticTime: Date? = nil // Debounce haptic feedback
    @State private var isGestureActive: Bool = false // Track if gesture is actually active
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? ButtonAnimationConfig.pressScaleUp * expansionPhase : 1.0)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // CRITICAL: Only process if this is a REAL touch event
                        // Check that startLocation is valid (not zero/negative, which indicates view update)
                        guard value.startLocation.x > 0 && value.startLocation.y > 0 else {
                            return // Invalid start location - likely a view update, not a touch
                        }
                        
                        // On tap (first touch) - TRIGGER PRESS HAPTIC
                        if initialLocation == nil {
                            // CRITICAL: Only trigger if this is a real user touch
                            // Check that the gesture actually started (has valid start location and time)
                            let now = Date()
                            gestureStartTime = now
                            initialLocation = value.location
                            isGestureActive = true
                            
                            // Trigger haptic on press (first touch) - but only if not dragging
                            let timeSinceLastHaptic = lastHapticTime.map { Date().timeIntervalSince($0) } ?? 1.0
                            if timeSinceLastHaptic > 0.1 {
                                HapticFeedback.buttonPress()
                                hasTriggeredPressHaptic = true
                                lastHapticTime = Date()
                            }
                            
                            // Scale up with spring animation on tap (more prominent)
                            withAnimation(
                                .spring(
                                    response: ButtonAnimationConfig.springResponse,
                                    dampingFraction: ButtonAnimationConfig.springDamping
                                )
                            ) {
                                isPressed = true
                            }
                        } else {
                            // Check if user is scrolling (movement > 5 points)
                            let delta = CGPoint(
                                x: abs(value.location.x - (initialLocation?.x ?? 0)),
                                y: abs(value.location.y - (initialLocation?.y ?? 0))
                            )
                            
                            // If dragging, release press to allow scrolling and cancel haptics
                            if delta.x > 5 || delta.y > 5 {
                                if isPressed {
                                    withAnimation(
                                        .spring(
                                            response: ButtonAnimationConfig.springResponse,
                                            dampingFraction: ButtonAnimationConfig.springDamping
                                        )
                                    ) {
                                        isPressed = false
                                        expansionPhase = 1.0
                                    }
                                }
                                // Mark that this was a drag, so we don't trigger release haptic
                                hasTriggeredPressHaptic = false
                            }
                        }
                    }
                    .onEnded { value in
                        // Check that gesture actually started (has start time and location) AND was active
                        guard let startTime = gestureStartTime,
                              let startLocation = initialLocation,
                              isGestureActive else {
                            // Not a real gesture - just reset state
                            initialLocation = nil
                            gestureStartTime = nil
                            hasTriggeredPressHaptic = false
                            hasTriggeredReleaseHaptic = false
                            isGestureActive = false
                            if isPressed {
                                withAnimation {
                                    isPressed = false
                                    expansionPhase = 1.0
                                }
                            }
                            return
                        }
                        
                        // Calculate total movement during gesture
                        let totalMovement = sqrt(
                            pow(value.location.x - startLocation.x, 2) +
                            pow(value.location.y - startLocation.y, 2)
                        )
                        
                        // Check gesture duration - real taps are usually < 300ms
                        let gestureDuration = Date().timeIntervalSince(startTime)
                        
                        // CRITICAL: If ANY drag detected (movement > 5 points), COMPLETELY SKIP RELEASE HAPTIC
                        // Only trigger release haptic if this was a QUICK TAP with NO DRAG:
                        // - Short duration (< 300ms)
                        // - Minimal movement (< 5 points) - STRICT threshold to detect any drag
                        // - Press haptic was triggered (not a drag)
                        let timeSinceLastHaptic = lastHapticTime.map { Date().timeIntervalSince($0) } ?? 1.0
                        let isQuickTap = gestureDuration < 0.3 && totalMovement < 5.0 && hasTriggeredPressHaptic
                        
                        // ONLY trigger release haptic if confirmed tap (NO DRAG detected)
                        if isQuickTap && timeSinceLastHaptic > 0.1 {
                            // This was an actual button click - trigger release haptic
                            HapticFeedback.buttonRelease()
                            lastHapticTime = Date()
                        }
                        // If drag detected (totalMovement >= 5.0), NO RELEASE HAPTIC - completely skipped
                        
                        // Always release the press animation
                        if isPressed {
                            withAnimation(
                                .spring(
                                    response: ButtonAnimationConfig.springResponse,
                                    dampingFraction: ButtonAnimationConfig.springDamping
                                )
                            ) {
                                isPressed = false
                                expansionPhase = 1.0
                            }
                        }
                        
                        // Reset state
                        initialLocation = nil
                        gestureStartTime = nil
                        hasTriggeredPressHaptic = false
                        hasTriggeredReleaseHaptic = false
                        isGestureActive = false
                    }
            )
    }
}

// MARK: - Extension for Easy Application
extension View {
    func buttonPressAnimation() -> some View {
        modifier(ButtonPressAnimation())
    }
    
    func circleButtonPressAnimation() -> some View {
        modifier(CircleButtonPressAnimation())
    }
}

