import Foundation

/// Dynamic full-catalog mapping for Target Languages.
/// This file seamlessly replaces the hardcoded list with API-driven updates from /api/system/languages/available.
class TargetLanguageMapping {
    static let shared = TargetLanguageMapping()
    private init() {}
    
    // The master catalog retrieved from the backend
    private var combinations: [LanguageCombination] = []
    
    // In-memory cache for fast O(1) speech/display Name lookups across all known languages
    private var unifiedNames: [String: (english: String, native: String)] = [:]
    
    // The master list of all possible target codes (Used as fallback or superset queries)
    var availableCodes: [String] {
        return Array(unifiedNames.keys)
    }
    
    // MARK: - Integration
    
    /// Hydrate the mapping table from backend combos
    func update(with catalog: [LanguageCombination]) {
         self.combinations = catalog
         
         var newMap: [String: (english: String, native: String)] = [:]
         for combo in catalog {
             for target in combo.targets {
                 // Even if a target exists in multiple native combos (like spanish), its display name is identical
                 let code = target.code.lowercased()
                 newMap[code] = (target.english_name, target.native_name)
             }
         }
         
         self.unifiedNames = newMap
    }
    
    // MARK: - Dynamic Accessors
    
    /// Returns specifically the available target combinations for a given native code
    func getAvailableCodes(for nativeCode: String) -> [String] {
        let normalizedNative = nativeCode.lowercased()
        
        // Find the native combo exactly
        if let combo = combinations.first(where: { $0.native.code.lowercased() == normalizedNative }) {
            return combo.targets.map { $0.code.lowercased() }
        }
        
        print("⚠️ [TargetLanguageMapping] No dynamic targets found for native language: \(nativeCode). Returning fallback.")
        return []
    }
    
    // MARK: - Universal Accessors
    
    func getDisplayNames(for code: String) -> (english: String, native: String) {
        let normalized = code.lowercased()
        return unifiedNames[normalized] ?? (normalized.uppercased(), normalized.uppercased())
    }
    
    func normalizeAndValidate(_ input: String, forNativeCode nativeCode: String? = nil) -> String? {
        let normalized = input.lowercased()
        
        // Context-aware validation (Strict) mapping to the user's specific native language combos
        if let nativeRaw = nativeCode, let safeCombo = combinations.first(where: { $0.native.code.lowercased() == nativeRaw.lowercased() }) {
            
            // 1. Direct code check in the strict targets subset
            if safeCombo.targets.contains(where: { $0.code.lowercased() == normalized }) {
                return normalized
            }
            
            // 2. Name lookup in the strict targets subset
            for target in safeCombo.targets {
                if target.english_name.lowercased() == normalized || target.native_name.lowercased() == normalized {
                    return target.code.lowercased()
                }
            }
            return nil
        }
        
        // Global Fallback Validation (Permissive) - Used mostly for legacy code or phonetic maps
        if unifiedNames.keys.contains(normalized) { return normalized }
        
        for (code, nameTuple) in unifiedNames {
            if nameTuple.english.lowercased() == normalized || nameTuple.native.lowercased() == normalized {
                return code
            }
        }
        
        return nil
    }
    
    // Helper to get Locale for speech recognition and validation.
    // SFSpeechRecognizer requires full locale identifiers (e.g. "es-ES") not bare codes ("es").
    func getLocale(for code: String) -> Locale {
        let normalized = code.lowercased()
        
        // Map bare language codes to full locale identifiers for SFSpeechRecognizer
        let speechLocaleMap: [String: String] = [
            "en": "en-US",
            "es": "es-ES",
            "fr": "fr-FR",
            "de": "de-DE",
            "ja": "ja-JP",
            "ko": "ko-KR",
            "zh": "zh-CN",
            "ru": "ru-RU",
            "hi": "hi-IN",
            "te": "te-IN",
            "ta": "ta-IN",
            "ml": "ml-IN",
            "pt": "pt-BR",
            "it": "it-IT",
            "ar": "ar-SA",
            "tr": "tr-TR",
            "nl": "nl-NL",
            "pl": "pl-PL",
            "th": "th-TH",
            "vi": "vi-VN",
            "id": "id-ID",
        ]
        
        // Use mapped identifier if available, otherwise pass through as-is
        let identifier = speechLocaleMap[normalized] ?? code
        return Locale(identifier: identifier)
    }
}
