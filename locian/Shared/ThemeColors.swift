//
//  ThemeColors.swift
//  locian
//
//  Centralized theme color definitions
//

import SwiftUI

struct ThemeColors {
    // Centralized theme color definitions - single source of truth
    
    // Global Aesthetic Colors (Cyberpunk / Brand)
    static let primaryAccent = Color(red: 0.0, green: 1.0, blue: 1.0) // #00FFFF (Cyan)
    static let secondaryAccent = Color(red: 1.0, green: 0.1, blue: 0.4) // #FF1966 (Pink)
    static let neonGreen = Color(hex: "#35F21C")
    static let neonCyan = Color(red: 0.0, green: 0.8, blue: 1.0)
    static let neonYellow = Color(red: 1.0, green: 0.9, blue: 0.0)
    static let neonPurple = Color(red: 0.6, green: 0.4, blue: 1.0)
    static let neonOrange = Color(red: 1.0, green: 0.6, blue: 0.4)
    static let neonRed = Color(red: 1.0, green: 0.2, blue: 0.2)
    static let successMint = Color(red: 0, green: 1, blue: 0.5)
    
    // Grayscale / Surface Colors
    static let graphiteBlack = Color(hex: "#1C1C1C")
    static let graphiteGrey = Color(hex: "#2C2C2C")
    static let darkSurface = Color(white: 0.1)
    static let textGray = Color(white: 0.6)
    static let midGrey = Color(red: 0.7, green: 0.7, blue: 0.7)
    
    // Semantic Colors
    static let success = Color.green
    static let error = Color.red
    
    static func getColor(for themeName: String) -> Color {
        switch themeName {
        case "Neon Fuchsia":
            return Color(hex: "#D80073")
        case "Neon Green":
            return Color(hex: "#35F21C")
        case "Electric Indigo":
            return Color(hex: "#5D00FF")
        case "Graphite Black":
            return graphiteBlack
        // Legacy support / Default
        default:
            return neonGreen // Default to Neon Green
        }
    }
    
    // Get all theme colors with their names (for SettingsView)
    static func themeColors(languageManager: LanguageManager) -> [(name: String, localizedName: String, color: Color)] {
        [
            ("Neon Fuchsia", languageManager.settings.neonFuchsia, Color(hex: "#D80073")),
            ("Neon Green", languageManager.settings.neonGreen, Color(hex: "#35F21C")),
            ("Electric Indigo", languageManager.settings.electricIndigo, Color(hex: "#5D00FF")),
            ("Graphite Black", languageManager.settings.graphiteBlack, graphiteBlack)
        ]
    }
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
