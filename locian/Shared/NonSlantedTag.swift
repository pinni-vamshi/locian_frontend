//
//  NonSlantedTag.swift
//  locian
//
//  Non-slanted rectangular tag component for HUD-style UI elements
//

import SwiftUI

// MARK: - Non-Slanted Tag View
struct NonSlantedTag: View {
    let text: String
    var font: Font = .system(size: 14, weight: .bold)
    var textColor: Color = .white
    var backgroundColor: Color = .blue
    var horizontalPadding: CGFloat = 14
    var verticalPadding: CGFloat = 6
    var shadowColor: Color = .white
    var shadowOffset: CGSize = CGSize(width: 7, height: 8)
    var showBorder: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        let content = Text(text.uppercased())
            .font(font)
            .foregroundColor(textColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                ZStack {
                    // Shadow layer (offset at bottom)
                    Rectangle()
                        .fill(shadowColor)
                        .offset(x: shadowOffset.width, y: shadowOffset.height)
                    
                    // Main shape (rectangular, zero slant/corners)
                    Rectangle()
                        .fill(backgroundColor)
                        .overlay(
                            showBorder ? Rectangle()
                                .stroke(Color.white, lineWidth: 2) : nil
                        )
                }
            )
        
        if let tapAction = onTap {
            content.onTapGesture {
                tapAction()
            }
        } else {
            content
        }
    }
}

// MARK: - Convenience Initializers
extension NonSlantedTag {
    // Theme-colored version (black top, theme-colored shadow)
    static func themed(text: String, themeColor: Color) -> NonSlantedTag {
        NonSlantedTag(
            text: text,
            backgroundColor: .black,
            shadowColor: themeColor
        )
    }

    // HUD-style version (outlined with fill)
    static func hud(text: String, accentColor: Color, backgroundColor: Color = Color.black.opacity(0.8)) -> some View {
        Text(text.uppercased())
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Rectangle()
                    .stroke(accentColor, lineWidth: 2)
                    .background(
                        Rectangle()
                            .fill(backgroundColor)
                    )
            )
    }
}

// MARK: - Preview (for development)
struct NonSlantedTag_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            NonSlantedTag(text: "CURRENT LOCATION", backgroundColor: .blue)
            NonSlantedTag(text: "ACTIVE MOMENT", backgroundColor: .green)
            NonSlantedTag(text: "NEXT UP", backgroundColor: .orange)
            NonSlantedTag.hud(text: "WARNING", accentColor: .red)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

