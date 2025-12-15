import Foundation

// MARK: - Available Language Pairs Request
struct AvailableLanguagePairsRequest: Codable {
    let session_token: String
}

// MARK: - Available Language Pairs Response
struct AvailableLanguagePairsResponse: Codable {
    let success: Bool
    let message: String
    let data: AvailableLanguagePairsData?
    let error: String?
    let error_code: String?
    let request_id: String
    let timestamp: String?
}

// MARK: - Available Language Pairs Data
struct AvailableLanguagePairsData: Codable {
    let language_pairs: [LanguagePair]
}

// MARK: - Language Pair (Essential Data Only)
struct LanguagePair: Codable, Identifiable {
    let native_language: String
    let target_language: String
    let is_default: Bool
    let user_level: String
    
    var id: String {
        "\(native_language)-\(target_language)"
    }
}
