//
//  GeometricButtons.swift
//  locian
//
//  Created for Locian
//

import SwiftUI

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Upward pointing triangle
        // Top Center
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        // Bottom Right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Bottom Left
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Close
        path.closeSubpath()
        return path
    }
}

// MARK: - Tactile Triangle Button
// MARK: - Tactile Triangle Button
struct TriangleButton: View {
    let action: () -> Void
    let color: Color
    let size: CGFloat
    var iconName: String? = nil
    var shadowColor: Color = .white
    var iconColor: Color = .white
    
    // Shadow offset constant
    let shadowOffset: CGFloat = 4
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Triangle()
                    .fill(color)
                
                if let icon = iconName {
                    Image(systemName: icon)
                        .font(.system(size: size * 0.25, weight: .bold))
                        .foregroundColor(iconColor)
                        .offset(y: size * 0.15)
                }
            }
            .frame(width: size, height: size * 0.866)
        }
        .buttonStyle(TriangleButtonStyle(
            shadowColor: shadowColor,
            shadowOffset: shadowOffset,
            size: size
        ))
    }
}

// MARK: - Triangle Button Style (Primitive for Instant Response)
struct TriangleButtonStyle: PrimitiveButtonStyle {
    var shadowColor: Color
    var shadowOffset: CGFloat
    var size: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        TriangleButtonContent(configuration: configuration, style: self)
    }
}

private struct TriangleButtonContent: View {
    let configuration: PrimitiveButtonStyle.Configuration
    let style: TriangleButtonStyle
    
    @State private var isPressed = false
    @State private var dragCancelled = false
    
    var body: some View {
        ZStack {
            // 1. The Shadow (Static - Outside the Button)
            Triangle()
                .fill(style.shadowColor)
                .frame(width: style.size, height: style.size * 0.866)
                .offset(x: style.shadowOffset, y: style.shadowOffset)
            
            // 2. The Interactive Button (Top Layer - Moves on Press)
            configuration.label
                .offset(
                    x: isPressed ? style.shadowOffset : 0,
                    y: isPressed ? style.shadowOffset : 0
                )
        }
        .contentShape(Triangle()) // Ensure hit area is the triangle
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    if dragCancelled { return }
                    
                    let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                    
                    // Swipe cancellation
                    if distance > 20 {
                        if isPressed {
                            withAnimation(.easeOut(duration: 0.05)) {
                                isPressed = false
                            }
                        }
                        dragCancelled = true
                        return
                    }
                    
                    // Instant press
                    if !isPressed {
                        withAnimation(.easeOut(duration: 0.05)) {
                            isPressed = true
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.prepare()
                            generator.impactOccurred()
                        }
                    }
                }
                .onEnded { value in
                    defer { dragCancelled = false }
                    
                    if isPressed {
                        withAnimation(.easeOut(duration: 0.05)) {
                            isPressed = false
                        }
                        
                        // Action
                        configuration.trigger()
                    }
                }
        )
    }
}

// MARK: - Custom Button Style for "Drop/Press" Effect
struct TactileTriangleStyle: ButtonStyle {
    let offset: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // When pressed: Move content DOWN-RIGHT to "cover" the shadow
            .offset(
                x: configuration.isPressed ? offset : 0,
                y: configuration.isPressed ? offset : 0
            )
            // Optional: Slight scale or brightness change
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
