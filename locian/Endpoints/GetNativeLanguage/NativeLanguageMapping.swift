import Foundation

/// Dictionary-only mapping for Native Languages.
/// This file handles the identification and display of languages the user speaks.
/// It dynamically syncs with /api/system/languages/available
class NativeLanguageMapping {
    static let shared = NativeLanguageMapping()
    private init() {}
    
    // Supported native language codes dynamically loaded
    var availableCodes: [String] {
        return Array(names.keys)
    }
    
    private var names: [String: (english: String, native: String)] = [:]
    
    // MARK: - Integration
    
    func update(with catalog: [LanguageCombination]) {
        var newMap: [String: (english: String, native: String)] = [:]
        for combo in catalog {
            let code = combo.native.code.lowercased()
            newMap[code] = (combo.native.english_name, combo.native.native_name)
        }
        self.names = newMap
    }
    
    // MARK: - Accessors
    
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
        if names.keys.contains(cleanName) { return cleanName }
        
        // Reverse search
        for (code, (englishName, nativeName)) in names {
            if englishName.lowercased() == cleanName || nativeName.lowercased() == cleanName {
                return code
            }
        }
        return nil
    }
}
