import Foundation

/// Full-catalog mapping for Target Languages.
/// This file handles the identification and normalization of languages the user is learning.
class TargetLanguageMapping {
    static let shared = TargetLanguageMapping()
    private init() {}
    
    // Full learning catalog
    let availableCodes = ["en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko", "ar", "tr", "pl", "nl", "sv", "no", "da", "fi", "el", "he", "ta", "ml"]
    
    private let names: [String: (english: String, native: String)] = [
        "en": ("English", "English"),
        "es": ("Spanish", "Español"),
        "fr": ("French", "Français"),
        "de": ("German", "Deutsch"),
        "it": ("Italian", "Italiano"),
        "pt": ("Portuguese", "Português"),
        "ru": ("Russian", "Русский"),
        "zh": ("Chinese", "中文"),
        "ja": ("Japanese", "日本語"),
        "ko": ("Korean", "한국어"),
        "ar": ("Arabic", "العربية"),
        "tr": ("Turkish", "Türkçe"),
        "pl": ("Polish", "Polski"),
        "nl": ("Dutch", "Nederlands"),
        "sv": ("Swedish", "Svenska"),
        "no": ("Norwegian", "Norsk"),
        "da": ("Danish", "Dansk"),
        "fi": ("Finnish", "Suomi"),
        "el": ("Greek", "Ελληνικά"),
        "he": ("Hebrew", "עברית"),
        "ta": ("Tamil", "தமிழ்"),
        "ml": ("Malayalam", "മലയാളം")
    ]
    
    func getDisplayNames(for code: String) -> (english: String, native: String) {
        let normalized = code.lowercased()
        return names[normalized] ?? (normalized.uppercased(), normalized.uppercased())
    }
    
    func normalizeAndValidate(_ input: String) -> String? {
        // 1. Direct code check
        let normalized = input.lowercased()
        if availableCodes.contains(normalized) { return normalized }
        
        // 2. Name lookup
        for (code, nameTuple) in names {
            if nameTuple.english.lowercased() == normalized || nameTuple.native.lowercased() == normalized {
                return code
            }
        }
        return nil
    }
    
    // Helper to get Locale for speech/validation
    func getLocale(for code: String) -> Locale {
        return Locale(identifier: code)
    }
}
