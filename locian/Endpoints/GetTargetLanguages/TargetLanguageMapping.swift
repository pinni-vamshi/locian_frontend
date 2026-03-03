import Foundation

/// Full-catalog mapping for Target Languages.
/// This file handles the identification and normalization of languages the user is learning.
class TargetLanguageMapping {
    static let shared = TargetLanguageMapping()
    private init() {}
    
    // Full learning catalog
    let availableCodes = ["en", "es", "fr", "ja", "de", "ko", "it", "zh", "pt", "ru", "nl", "ar", "tr"]
    
    private let names: [String: (english: String, native: String)] = [
        "en": ("English", "English"),
        "es": ("Spanish", "Español"),
        "fr": ("French", "Français"),
        "ja": ("Japanese", "日本語"),
        "de": ("German", "Deutsch"),
        "ko": ("Korean", "한국어"),
        "it": ("Italian", "Italiano"),
        "zh": ("Chinese", "中文"),
        "pt": ("Portuguese", "Português"),
        "ru": ("Russian", "Русский"),
        "nl": ("Dutch", "Nederlands"),
        "ar": ("Arabic", "العربية"),
        "tr": ("Turkish", "Türkçe")
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
