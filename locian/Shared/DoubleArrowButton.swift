//
//  DoubleArrowButton.swift
//  locian
//
//  A dynamic button with two arrows where the first arrow
//  slides towards the second fixed arrow to trigger an action.
//  Supports dynamic directions (up, down, left, right) and colors.
//

import SwiftUI
import UIKit

struct DoubleArrowButton: View {
    
    enum Direction {
        case up, down, left, right
        
        var iconName: String {
            switch self {
            case .up: return "chevron.up"
            case .down: return "chevron.down"
            case .left: return "chevron.left"
            case .right: return "chevron.right"
            }
        }
        
        var axis: Axis.Set {
            switch self {
            case .up, .down: return .vertical
            default: return .horizontal
            }
        }
    }
    
    // Configuration
    let direction: Direction
    var hasSquareBackground: Bool = false
    var hasMixedSquareBackground: Bool = false
    
    // Configurable colors
    var arrow1Color: Color = .white
    var arrow2Color: Color? = nil
    
    var size: CGFloat = 24
    var spacing: CGFloat = -4
    var action: () -> Void
    
    // State
    @State private var isPressed: Bool = false
    @State private var dragCancelled: Bool = false
    
    // Initializer for simple single color use
    init(direction: Direction, color: Color, size: CGFloat = 24, spacing: CGFloat = -4, hasSquareBackground: Bool = false, hasMixedSquareBackground: Bool = false, action: @escaping () -> Void) {
        self.direction = direction
        self.arrow1Color = color.opacity(0.5)
        self.arrow2Color = color
        self.size = size
        self.spacing = spacing
        self.hasSquareBackground = hasSquareBackground
        self.hasMixedSquareBackground = hasMixedSquareBackground
        self.action = action
    }
    
    // Initializer for dual color use
    init(direction: Direction, arrow1: Color, arrow2: Color, size: CGFloat = 24, spacing: CGFloat = -4, hasSquareBackground: Bool = false, hasMixedSquareBackground: Bool = false, action: @escaping () -> Void) {
        self.direction = direction
        self.arrow1Color = arrow1
        self.arrow2Color = arrow2
        self.size = size
        self.spacing = spacing
        self.hasSquareBackground = hasSquareBackground
        self.hasMixedSquareBackground = hasMixedSquareBackground
        self.action = action
    }
    
    var body: some View {
        ZStack {
             // Extended Touch Area
             if direction.axis == .vertical {
                 Color.white.opacity(0.001)
                     .frame(width: size * 4, height: size * 3)
             } else {
                 Color.white.opacity(0.001)
                     .frame(width: size * 3, height: size * 4)
             }
             
             // The Double Arrow Content
             layoutContent
                 .font(.system(size: size, weight: .bold)) // Bolder for background mode
        }
        // Gesture Logic
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if dragCancelled { return }
                    let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                    if distance > 30 {
                         if isPressed {
                             withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                 isPressed = false
                                 HapticFeedback.buttonRelease()
                             }
                         }
                         dragCancelled = true
                         return
                    }
                    if !isPressed {
                        withAnimation(.easeOut(duration: 0.05)) {
                            isPressed = true
                        }
                        HapticFeedback.buttonPress()
                    }
                }
                .onEnded { value in
                    defer { dragCancelled = false }
                    if isPressed {
                        HapticFeedback.buttonRelease()
                        action()
                        withAnimation(.easeOut(duration: 0.1)) {
                            isPressed = false
                        }
                    }
                }
        )
    }
    
    // MARK: - Subviews
    
    private func arrowBox(image: String, color: Color, opacity: Double, scale: CGFloat = 1.0, isMovable: Bool = false) -> some View {
        ZStack {
            if hasSquareBackground || (hasMixedSquareBackground && isMovable) {
                Rectangle()
                    .fill(color.opacity(0.1))
                    .frame(width: size * 1.4, height: size * 1.4)
                    .cornerRadius(2)
            }
            
            Image(systemName: image)
                .foregroundColor(color)
                .opacity(opacity)
                .scaleEffect(scale)
        }
    }
    
    // The arrow that moves (FIRST ARROW)
    private var movableArrow: some View {
        let moveDistance: CGFloat = isPressed ? 4 : 0
        
        return arrowBox(
            image: direction.iconName,
            color: arrow1Color,
            opacity: isPressed ? 1.0 : 0.6,
            isMovable: true
        )
        .offset(
            x: direction == .right ? moveDistance : (direction == .left ? -moveDistance : 0),
            y: direction == .down ? moveDistance : (direction == .up ? -moveDistance : 0)
        )
    }
    
    // The fixed target arrow (SECOND ARROW)
    private var fixedArrow: some View {
        arrowBox(
            image: direction.iconName,
            color: arrow2Color ?? arrow1Color,
            opacity: 1.0,
            scale: isPressed ? 1.1 : 1.0
        )
    }
    
    // Layout builder respects direction flow
    @ViewBuilder
    private var layoutContent: some View {
        switch direction {
        case .right:
            // [Movable] -> [Fixed]
            HStack(spacing: spacing) { movableArrow; fixedArrow }
        case .left:
            // [Fixed] <- [Movable] (Row is [Fixed, Movable])
            HStack(spacing: spacing) { fixedArrow; movableArrow }
        case .down:
            // [Movable]
            //    v
            // [Fixed]
            VStack(spacing: spacing) { movableArrow; fixedArrow }
        case .up:
            // [Fixed]
            //    ^
            // [Movable]
            VStack(spacing: spacing) { fixedArrow; movableArrow }
        }
    }
}
