import Foundation

// MARK: - List Target Languages Request
struct ListTargetLanguagesRequest: Codable {
    let session_token: String
}

// MARK: - List Target Languages Response
struct ListTargetLanguagesResponse: Codable {
    let success: Bool
    let message: String
    let data: ListTargetLanguagesData?
    let error: String?
    let error_code: String?
    let request_id: String?
    let timestamp: String?
}

// MARK: - List Target Languages Data
struct ListTargetLanguagesData: Codable {
    let native_language: String?  // Can be null if not set
    let target_languages: [TargetLanguage]
}

// MARK: - Target Language
struct TargetLanguage: Codable, Identifiable {
    let target_language: String
    let is_default: Bool
    let user_level: String
    var practice_dates: [String]
    let native_language: String?  // Stored within each target language
    let added_date: String?       // ISO 8601 datetime string
    let last_practiced: String?   // ISO 8601 datetime string or null
    let current_streak: Int?      // Current consecutive days of practice
    let longest_streak: Int?      // Longest consecutive days of practice
    let total_practice_days: Int? // Total number of practice days
    
    var id: String {
        target_language
    }
}

// MARK: - Available Language Pairs Data (for backward compatibility)
struct AvailableLanguagePairsData: Codable {
    let language_pairs: [LanguagePair]
}

// MARK: - Available Language Pairs Request (for backward compatibility)
struct AvailableLanguagePairsRequest: Codable {
    let session_token: String
}

// MARK: - Available Language Pairs Response (for backward compatibility)
struct AvailableLanguagePairsResponse: Codable {
    let success: Bool
    let message: String
    let data: AvailableLanguagePairsData?
    let error: String?
    let error_code: String?
    let request_id: String
    let timestamp: String?
}

// MARK: - Language Pair (for backward compatibility with existing code)
struct LanguagePair: Codable, Identifiable, Equatable {
    let native_language: String
    let target_language: String
    let is_default: Bool
    let user_level: String
    var practice_dates: [String]
    
    var id: String {
        "\(native_language)-\(target_language)"
    }
    
    // Memberwise initializer
    init(native_language: String, target_language: String, is_default: Bool, user_level: String, practice_dates: [String]) {
        self.native_language = native_language
        self.target_language = target_language
        self.is_default = is_default
        self.user_level = user_level
        self.practice_dates = practice_dates
    }
    
    // Convert from TargetLanguage with native_language
    init(native_language: String, targetLanguage: TargetLanguage) {
        // Use native_language from TargetLanguage if available, otherwise use the provided one
        self.native_language = targetLanguage.native_language ?? native_language
        self.target_language = targetLanguage.target_language
        self.is_default = targetLanguage.is_default
        self.user_level = targetLanguage.user_level
        self.practice_dates = targetLanguage.practice_dates
    }
}
