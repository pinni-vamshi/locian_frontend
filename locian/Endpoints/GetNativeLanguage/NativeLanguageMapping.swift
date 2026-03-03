import Foundation

/// Dictionary-only mapping for Native Languages.
/// This file handles the identification and display of languages the user speaks.
class NativeLanguageMapping {
    static let shared = NativeLanguageMapping()
    private init() {}
    
    // Supported native language codes
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
        return getCode(for: input)
    }
    
    /// Helper: Reverse lookup to find code from name (e.g., "Spanish" -> "es")
    func getCode(for name: String) -> String? {
        let cleanName = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // Check if input is already a valid code
        if availableCodes.contains(cleanName) { return cleanName }
        
        // Reverse search
        for (code, (englishName, nativeName)) in names {
            if englishName.lowercased() == cleanName || nativeName.lowercased() == cleanName {
                return code
            }
        }
        return nil // Default fallback should be handled by caller
    }
}
