//
//  LanguageManager.swift
//  locian
//
//  Created for app language management
//

import Foundation
import Combine

enum AppLanguage: String, CaseIterable, Codable {
    case system = "System"
    case english = "English"
    case japanese = "Japanese"
    case telugu = "Telugu"
    case tamil = "Tamil"
    case french = "French"
    case german = "German"
    case spanish = "Spanish"
    case chinese = "Chinese"
    case korean = "Korean"
    case russian = "Russian"
    case malayalam = "Malayalam"
    
    var code: String {
        switch self {
        case .system: return "system"
        case .english: return "en"
        case .japanese: return "ja"
        case .telugu: return "te"
        case .tamil: return "ta"
        case .french: return "fr"
        case .german: return "de"
        case .spanish: return "es"
        case .chinese: return "zh"
        case .korean: return "ko"
        case .russian: return "ru"
        case .malayalam: return "ml"
        }
    }
    
    var nativeScript: String {
        switch self {
        case .system: return "🌐 System"
        case .english: return "English"
        case .japanese: return "日本語"
        case .telugu: return "తెలుగు"
        case .tamil: return "தமிழ்"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .spanish: return "Español"
        case .chinese: return "中文"
        case .korean: return "한국어"
        case .russian: return "Русский"
        case .malayalam: return "മലയാളം"
        }
    }
    
    var englishName: String {
        switch self {
        case .system: return "System Language"
        case .english: return "English"
        case .japanese: return "Japanese"
        case .telugu: return "Telugu"
        case .tamil: return "Tamil"
        case .french: return "French"
        case .german: return "German"
        case .spanish: return "Spanish"
        case .chinese: return "Chinese"
        case .korean: return "Korean"
        case .russian: return "Russian"
        case .malayalam: return "Malayalam"
        }
    }
    
    var displayName: String {
        if self == .system {
            let detected = AppLanguage.detectSystemLanguage()
            return "System Language / \(detected.nativeScript)"
        }
        return "\(englishName) / \(nativeScript)"
    }
    
    static func fromCode(_ code: String) -> AppLanguage? {
        switch code.lowercased() {
        case "system": return .system
        case "en": return .english
        case "ja": return .japanese
        case "te": return .telugu
        case "ta": return .tamil
        case "fr": return .french
        case "de": return .german
        case "es": return .spanish
        case "zh": return .chinese
        case "ko": return .korean
        case "ru": return .russian
        case "ml": return .malayalam
        default: return nil
        }
    }
    
    /// Detect the device's system language and return the closest matching AppLanguage
    static func detectSystemLanguage() -> AppLanguage {
        // Get the user's preferred language from device settings
        let preferredLanguages = Locale.preferredLanguages
        
        if let firstLanguage = preferredLanguages.first {
            // Extract the language code (e.g., "en-US" -> "en")
            let languageCode = String(firstLanguage.prefix(2)).lowercased()
            
            // Map to our supported languages
            switch languageCode {
            case "en": return .english
            case "ja": return .japanese
            case "te": return .telugu
            case "ta": return .tamil
            case "fr": return .french
            case "de": return .german
            case "es": return .spanish
            case "zh": return .chinese
            case "ko": return .korean
            case "ru": return .russian
            case "ml": return .malayalam
            default: return .english // Fallback to English if not supported
            }
        }
        
        return .english // Default fallback
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
            loadStrings()
        }
    }
    
    private var strings: AppStrings = EnglishStrings()
    
    private init() {
        // Load saved language or default to System Language
        if let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage") {
            if let language = AppLanguage(rawValue: savedLanguage) {
                self.currentLanguage = language
            } else if let languageByCode = AppLanguage.fromCode(savedLanguage) {
                self.currentLanguage = languageByCode
            } else {
                self.currentLanguage = .system // Default to System Language
            }
        } else {
            self.currentLanguage = .system // Default to System Language for new users
        }
        loadStrings()
    }
    
    /// Get the effective language (resolves .system to actual language)
    var effectiveLanguage: AppLanguage {
        if currentLanguage == .system {
            return AppLanguage.detectSystemLanguage()
        }
        return currentLanguage
    }
    
    private func loadStrings() {
        // Use effective language to handle .system case
        let languageToLoad = effectiveLanguage
        
        switch languageToLoad {
        case .system:
            // This shouldn't happen since effectiveLanguage never returns .system
            strings = EnglishStrings()
        case .english:
            strings = EnglishStrings()
        case .japanese:
            strings = JapaneseStrings()
        case .telugu:
            strings = TeluguStrings()
        case .tamil:
            strings = TamilStrings()
        case .french:
            strings = FrenchStrings()
        case .german:
            strings = GermanStrings()
        case .spanish:
            strings = SpanishStrings()
        case .chinese:
            strings = ChineseStrings()
        case .korean:
            strings = KoreanStrings()
        case .russian:
            strings = RussianStrings()
        case .malayalam:
            strings = MalayalamStrings()
        }
        // Notify observers that strings have changed (on main thread)
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func getString(_ key: String) -> String {
        return strings.getString(key)
    }
    
    // Convenience accessors
    var settings: SettingsStrings { strings.settings }
    var login: LoginStrings { strings.login }
    var onboarding: OnboardingStrings { strings.onboarding }
    var progress: ProgressStrings { strings.progress }
    var ui: UIStrings { strings.ui }
    var quiz: QuizStrings { strings.quiz }
    var scene: SceneStrings { strings.scene }
}

