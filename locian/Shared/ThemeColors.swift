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
    
    static func getColor(for themeName: String) -> Color {
        switch themeName {
        case "Neon Fuchsia":
            return Color(hex: "#D80073")
        case "Neon Green":
            return Color(hex: "#35F21C")
        case "Electric Indigo":
            return Color(hex: "#5D00FF")
        case "Graphite Black":
            return Color(hex: "#1C1C1C")
        // Legacy support / Default
        default:
            return Color(hex: "#35F21C") // Default to Neon Green
        }
    }
    
    // Get all theme colors with their names (for SettingsView)
    static func themeColors(languageManager: LanguageManager) -> [(name: String, localizedName: String, color: Color)] {
        [
            ("Neon Fuchsia", languageManager.settings.neonFuchsia, Color(hex: "#D80073")),
            ("Neon Green", languageManager.settings.neonGreen, Color(hex: "#35F21C")),
            ("Electric Indigo", languageManager.settings.electricIndigo, Color(hex: "#5D00FF")),
            ("Graphite Black", languageManager.settings.graphiteBlack, Color(hex: "#1C1C1C"))
        ]
    }
}
