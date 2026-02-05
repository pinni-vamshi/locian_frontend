import Foundation

// MARK: - Get Native Language Request
// GET mode: send with only session_token
// SET mode: send with session_token AND native_language
struct GetNativeLanguageRequest: Codable {
    let session_token: String
    let native_language: String?  // Optional: if provided, sets the native language
    
    init(session_token: String, native_language: String? = nil) {
        self.session_token = session_token
        self.native_language = native_language
    }
}

// MARK: - Get Native Language Response
struct GetNativeLanguageResponse: Codable {
    let success: Bool
    let message: String?
    let data: GetNativeLanguageData?
    let error: String?
    let error_code: String?
    let request_id: String?
    let timestamp: String?
}

// MARK: - Get Native Language Data
struct GetNativeLanguageData: Codable {
    let native_language: String?  // Can be null if not set
}

