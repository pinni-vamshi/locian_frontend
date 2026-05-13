import Foundation

// MARK: - Get Target Languages Request
struct GetTargetLanguagesRequest: Codable {
    let session_token: String
    let action: String?
    let target_language: String?
    let native_language: String?
    
    // Initializer with defaults for optional values
    init(session_token: String, action: String? = nil, target_language: String? = nil, native_language: String? = nil) {
        self.session_token = session_token
        self.action = action
        self.target_language = target_language
        self.native_language = native_language
    }
}

// MARK: - Get Target Languages Response
// MARK: - Get Target Languages Response
struct GetTargetLanguagesResponse: Codable {
    let success: Bool?
    let message: String?
    let data: GetTargetLanguagesData?
    let target_languages: [TargetLanguage]? // Flat structure support
    let count: Int?
    let error: String?
    let error_code: String?
    let request_id: String?
    let timestamp: String?
    
    // Custom coding keys to handle both structures if needed, or just flat
    enum CodingKeys: String, CodingKey {
        case success, message, data, target_languages, count, error, error_code, request_id, timestamp
    }
}

// MARK: - Get Target Languages Data
struct GetTargetLanguagesData: Codable {
    let target_languages: [TargetLanguage]
}

// MARK: - Target Language (Server representation)
struct TargetLanguage: Codable {
    let target_language: String
    let native_language: String?
    let is_default: Bool
    let user_level: String
    let practice_dates: [String]
    let recent_activity: [String: [PracticeActivityItem]]?
}

// MARK: - Practice Activity Item
struct PracticeActivityItem: Codable {
    let pattern_id: String
    let place_id: String
    let place_name: String
    let sentence: String
    let words: [String]
    let user_time: String
    let timestamp: String
    let target_language: String
}

// MARK: - Language Pair (Local representation)
struct LanguagePair: Codable, Identifiable {
    var id: String { "\(native_language)_\(target_language)" }
    let native_language: String
    let target_language: String
    let is_default: Bool
    let user_level: String
    var practice_dates: [String]
    var recent_activity: [String: [PracticeActivityItem]]?
    
    // Computed names for UI (baked into the model)
    var targetEnglishName: String { TargetLanguageMapping.shared.getDisplayNames(for: target_language).english }
    var targetNativeName: String { TargetLanguageMapping.shared.getDisplayNames(for: target_language).native }
    var nativeEnglishName: String { NativeLanguageMapping.shared.getDisplayNames(for: native_language).english }
}

