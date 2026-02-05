//
//  NoShadowTag.swift
//  locian
//
//  Non-slanted rectangular tag component without shadow effects
//

import SwiftUI

// MARK: - No Shadow Tag View
struct NoShadowTag: View {
    let text: String
    var font: Font = .system(size: 14, weight: .bold)
    var textColor: Color = .white
    var backgroundColor: Color = .blue
    var horizontalPadding: CGFloat = 14
    var verticalPadding: CGFloat = 6

    var body: some View {
        Text(text.uppercased())
            .font(font)
            .foregroundColor(textColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                Rectangle()
                    .fill(backgroundColor)
                    .overlay(
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                    )
            )
    }
}

// MARK: - Convenience Initializers
extension NoShadowTag {
    // Theme-colored version (uses app's selected theme color)
    static func themed(text: String, themeColor: Color) -> NoShadowTag {
        NoShadowTag(
            text: text,
            backgroundColor: themeColor
        )
    }

    // Simple version (just background color, no outline)
    static func simple(text: String, backgroundColor: Color = .blue) -> NoShadowTag {
        NoShadowTag(
            text: text,
            backgroundColor: backgroundColor
        )
    }
}

// MARK: - Preview (for development)
struct NoShadowTag_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            NoShadowTag(text: "CURRENT LOCATION", backgroundColor: .blue)
            NoShadowTag(text: "ACTIVE MOMENT", backgroundColor: .green)
            NoShadowTag(text: "NEXT UP", backgroundColor: .orange)
            NoShadowTag.themed(text: "THEME TAG", themeColor: .purple)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
