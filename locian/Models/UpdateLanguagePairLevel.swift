import Foundation

// MARK: - Update Language Pair Level Request
struct UpdateLanguagePairLevelRequest: Codable {
    let session_token: String
    let native_language: String
    let target_language: String
    let new_level: String
}

// MARK: - Update Language Pair Level Response
struct UpdateLanguagePairLevelResponse: Codable {
    let success: Bool
    let data: UpdateLanguagePairLevelData?
    let message: String?
    let error: String?
    let error_code: String?
    let request_id: String?
    let timestamp: String?
}

// MARK: - Update Language Pair Level Data
struct UpdateLanguagePairLevelData: Codable {
    let native_language: String
    let target_language: String
    let new_level: String
}

