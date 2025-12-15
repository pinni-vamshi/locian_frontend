import Foundation

// MARK: - Add Language Pair Request
struct AddLanguagePairRequest: Codable {
    let session_token: String
    let native_language: String
    let target_language: String
}

// MARK: - Add Language Pair Response
struct AddLanguagePairResponse: Codable {
    let success: Bool
    let message: String?
    let data: AddLanguagePairData?
    let error: String?
    let error_code: String?
    let request_id: String?
    let timestamp: String?
}

// MARK: - Add Language Pair Data
struct AddLanguagePairData: Codable {
    let native_language: String
    let target_language: String
    let is_default: Bool
}
