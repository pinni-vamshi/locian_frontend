import Foundation

// MARK: - Delete Language Pair Request
struct DeleteLanguagePairRequest: Codable {
    let session_token: String
    let native_language: String
    let target_language: String
}

// MARK: - Delete Language Pair Response
struct DeleteLanguagePairResponse: Codable {
    let success: Bool
    let data: DeleteLanguagePairData?
    let message: String?
    let error: String?
    let error_code: String?
    let request_id: String?
    let timestamp: String?
}

// MARK: - Delete Language Pair Data
struct DeleteLanguagePairData: Codable {
    let data_source: String
    let deleted_pair: DeletedPair
}

// MARK: - Deleted Pair
struct DeletedPair: Codable {
    let native_language: String
    let target_language: String
}

