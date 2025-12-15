//
//  LanguageManager.swift
//  locian
//
//  Created for app language management
//

import Foundation
import Combine

enum AppLanguage: String, CaseIterable, Codable {
    case english = "English"
    case japanese = "Japanese"
    case hindi = "Hindi"
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
        case .english: return "en"
        case .japanese: return "ja"
        case .hindi: return "hi"
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
        case .english: return "English"
        case .japanese: return "日本語"
        case .hindi: return "हिन्दी"
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
    
    var displayName: String {
        return "\(self.rawValue) / \(self.nativeScript)"
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
        // Load saved language or default to English
        if let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            self.currentLanguage = .english
        }
        loadStrings()
    }
    
    private func loadStrings() {
        switch currentLanguage {
        case .english:
            strings = EnglishStrings()
        case .japanese:
            strings = JapaneseStrings()
        case .hindi:
            strings = HindiStrings()
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
        // Notify observers that strings have changed
        objectWillChange.send()
    }
    
    func getString(_ key: String) -> String {
        return strings.getString(key)
    }
    
    // Convenience accessors
    var quiz: QuizStrings { strings.quiz }
    var settings: SettingsStrings { strings.settings }
    var vocabulary: VocabularyStrings { strings.vocabulary }
    var scene: SceneStrings { strings.scene }
    var login: LoginStrings { strings.login }
    var onboarding: OnboardingStrings { strings.onboarding }
    var common: CommonStrings { strings.common }
}

