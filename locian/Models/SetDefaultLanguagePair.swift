import Foundation

// MARK: - Set Default Language Pair Request
struct SetDefaultLanguagePairRequest: Codable {
    let session_token: String
    let native_language: String
    let target_language: String
}

// MARK: - Set Default Language Pair Response
struct SetDefaultLanguagePairResponse: Codable {
    let success: Bool
    let data: SetDefaultLanguagePairData?
    let message: String?
    let error: String?
    let error_code: String?
    let request_id: String?
    let timestamp: String?
}

// MARK: - Set Default Language Pair Data
struct SetDefaultLanguagePairData: Codable {
    let native_language: String
    let target_language: String
    let is_default: Bool
}

