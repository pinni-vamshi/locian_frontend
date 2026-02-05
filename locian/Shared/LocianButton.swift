//
//  LocianButton.swift
//  locian
//
//  Created by Component Refactor on 2025-12-24.
//

import SwiftUI

/// A reusable button style that implements a solid "pop" effect.
/// The button looks like a rectangle with a solid shadow.
/// On tap, the button moves down-right to cover the shadow, simulating a physical press.
/// Using PrimitiveButtonStyle to ensure instant touch response.
struct LocianButtonStyle: PrimitiveButtonStyle {
    var backgroundColor: Color = .black
    var foregroundColor: Color = .white
    var shadowColor: Color = .black
    var shadowOffset: CGFloat = 3.0
    var borderWidth: CGFloat = 1.0
    var borderColor: Color = .white
    var contentPadding: CGFloat? = nil
    var fullWidth: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        LocianButtonContent(configuration: configuration, style: self)
    }
}

private struct LocianButtonContent: View {
    let configuration: PrimitiveButtonStyle.Configuration
    let style: LocianButtonStyle
    
    @Environment(\.isEnabled) private var isEnabled
    @State private var isPressed = false
    @State private var dragCancelled = false
    
    var body: some View {
        ZStack {
            // 1. Shadow Layer (Sized by invisible content)
            configuration.label
                .padding(style.contentPadding ?? 16)
                .frame(maxWidth: style.fullWidth ? .infinity : nil)
                .hidden()
                .background(
                    Rectangle()
                        .fill(style.shadowColor)
                )
                .offset(x: style.shadowOffset, y: style.shadowOffset)
            
            // 2. Top Layer (The actual button face)
            configuration.label
                .padding(style.contentPadding ?? 16)
                .frame(maxWidth: style.fullWidth ? .infinity : nil)
                .background(
                    Rectangle()
                        .fill(style.backgroundColor)
                        .overlay(
                            style.borderWidth > 0 ?
                                AnyView(Rectangle().stroke(style.borderColor, lineWidth: style.borderWidth)) :
                                AnyView(EmptyView())
                        )
                )
                .foregroundColor(style.foregroundColor)
                .offset(
                    x: isPressed ? style.shadowOffset : 0,
                    y: isPressed ? style.shadowOffset : 0
                )
        }
        .contentShape(Rectangle())
        .gesture(
            isEnabled ? 
            AnyGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        if dragCancelled { return }
                        let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                        if distance > 20 {
                            if isPressed {
                                withAnimation(.easeOut(duration: 0.05)) {
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
                                HapticFeedback.buttonPress()
                            }
                        }
                    }
                    .onEnded { value in
                        defer { dragCancelled = false }
                        if isPressed {
                            withAnimation(.easeOut(duration: 0.05)) {
                                isPressed = false
                                HapticFeedback.buttonRelease()
                            }
                            configuration.trigger()
                        }
                    }
            ) : AnyGesture(DragGesture(minimumDistance: 0).onChanged { _ in }.onEnded { _ in })
        )
    }
}

/// A wrapper view that applies the LocianButtonStyle.
struct LocianButton<Label: View>: View {
    let action: () -> Void
    var backgroundColor: Color = .black
    var foregroundColor: Color = .white
    var shadowColor: Color = .black
    var shadowOffset: CGFloat = 3.0
    var borderWidth: CGFloat = 1.0
    var borderColor: Color = .white
    var contentPadding: CGFloat? = nil
    var fullWidth: Bool = false
    let label: Label
    
    init(
        action: @escaping () -> Void,
        backgroundColor: Color = .black,
        foregroundColor: Color = .white,
        shadowColor: Color = .black,
        shadowOffset: CGFloat = 3.0,
        borderWidth: CGFloat = 1.0,
        borderColor: Color = .white,
        contentPadding: CGFloat? = nil,
        fullWidth: Bool = false,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.shadowColor = shadowColor
        self.shadowOffset = shadowOffset
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.contentPadding = contentPadding
        self.fullWidth = fullWidth
        self.label = label()
    }
    
    var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(LocianButtonStyle(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            shadowColor: shadowColor,
            shadowOffset: shadowOffset,
            borderWidth: borderWidth,
            borderColor: borderColor,
            contentPadding: contentPadding,
            fullWidth: fullWidth
        ))
    }
}

struct LocianButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 50) {
            Button("Solid Button") {
                print("Primitive Clicked")
            }
            .buttonStyle(LocianButtonStyle(
                backgroundColor: .yellow,
                shadowColor: .black,
                shadowOffset: 6
            ))
            .frame(width: 200, height: 60)
            
            LocianButton(action: { print("Locian Clicked") }) {
                Text(LocalizationManager.shared.string(.startLearningLabel))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}

// MARK: - View Modifiers for Pop Style
extension View {
    /// Applies the Locian "pop" shadow effect to any view.
    /// This is useful for labels of Menus or other non-button interactive elements
    /// that should share the same aesthetic.
    func locianPopStyle(shadowColor: Color, backgroundColor: Color = .black, shadowOffset: CGFloat = 3.0, borderWidth: CGFloat = 1.0, borderColor: Color = .white) -> some View {
        ZStack {
            // 1. Shadow Layer
            self
                .hidden()
                .background(Rectangle().fill(shadowColor))
                .offset(x: shadowOffset, y: shadowOffset)
            
            // 2. Top Layer
            self
                .background(
                    Rectangle()
                        .fill(backgroundColor)
                        .overlay(
                            Rectangle()
                                .stroke(borderColor, lineWidth: borderWidth)
                        )
                )
        }
    }
}
