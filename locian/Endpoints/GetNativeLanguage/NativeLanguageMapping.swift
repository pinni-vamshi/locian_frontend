import Foundation

/// Dictionary-only mapping for Native Languages.
/// This file handles the identification and display of languages the user speaks.
class NativeLanguageMapping {
    static let shared = NativeLanguageMapping()
    private init() {}
    
    // Supported native language codes
    let availableCodes = ["en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko", "hi", "te", "ta", "ml", "ar", "tr", "pl", "nl", "sv", "no", "da", "fi", "el", "he"]
    
    private let names: [String: (english: String, native: String)] = [
        "en": ("English", "English"),
        "hi": ("Hindi", "हिन्दी"),
        "te": ("Telugu", "తెలుగు"),
        "ta": ("Tamil", "தமிழ்"),
        "ml": ("Malayalam", "മലയാളം"),
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
        "he": ("Hebrew", "עברית")
    ]
    
    func getDisplayNames(for code: String) -> (english: String, native: String) {
        let normalized = code.lowercased()
        return names[normalized] ?? (normalized.uppercased(), normalized.uppercased())
    }
    
    func normalizeAndValidate(_ input: String) -> String? {
        let code = input.lowercased()
        return availableCodes.contains(code) ? code : nil
    }
}
