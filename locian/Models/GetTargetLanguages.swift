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

