import Foundation

// MARK: - Update Language Level or Native Language Request
struct UpdateLanguageLevelRequest: Codable {
    let session_token: String
    let target_language: String?
    let native_language: String?
    let new_level: String?
    let new_native_language: String?
}

// MARK: - Update Language Level or Native Language Response
struct UpdateLanguageLevelResponse: Codable {
    let success: Bool
    let data: UpdateLanguageLevelData?
    let message: String?
    let error: String?
    let error_code: String?
    let request_id: String?
    let timestamp: String?
}

// MARK: - Update Language Level or Native Language Data
struct UpdateLanguageLevelData: Codable {
    let level: LevelUpdateData?
    let native_language: NativeLanguageUpdateData?
}

struct LevelUpdateData: Codable {
    let native_language: String
    let target_language: String
    let new_level: String
}

struct NativeLanguageUpdateData: Codable {
    let native_language: String
}

// MARK: - Legacy structs for backward compatibility
struct UpdateLanguagePairLevelRequest: Codable {
    let session_token: String
    let native_language: String
    let target_language: String
    let new_level: String
}

struct UpdateLanguagePairLevelResponse: Codable {
    let success: Bool
    let data: UpdateLanguagePairLevelData?
    let message: String?
    let error: String?
    let error_code: String?
    let request_id: String?
    let timestamp: String?
}

struct UpdateLanguagePairLevelData: Codable {
    let native_language: String
    let target_language: String
    let new_level: String
}

