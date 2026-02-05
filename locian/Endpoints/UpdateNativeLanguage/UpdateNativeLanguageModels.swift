import Foundation

// MARK: - Update Native Language Request
struct UpdateNativeLanguageRequest: Codable {
    let session_token: String
    let new_native_language: String
}

// MARK: - Update Native Language Response
struct UpdateNativeLanguageResponse: Codable {
    let success: Bool
    let message: String?
    let data: UpdateNativeLanguageData?
    let error: String?
    let error_code: String?
    let request_id: String?
    let timestamp: String?
}

// MARK: - Update Native Language Data
struct UpdateNativeLanguageData: Codable {
    let native_language: String
}

