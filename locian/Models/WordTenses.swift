import Foundation

// MARK: - Word Tenses Request
struct WordTensesRequest: Codable {
    let session_token: String
    let word: String
    let user_language: String
    let target_language: String
}

// MARK: - Word Tenses Response
struct WordTensesResponse: Codable {
    let success: Bool
    let message: String?
    let data: WordTensesData?
    let error: String?
    let error_code: String?
    let timestamp: String
    let request_id: String?
}

// MARK: - Word Tenses Data
struct WordTensesData: Codable {
    let tenses: [String: TenseDetail]
}

// MARK: - Tense Detail
struct TenseDetail: Codable {
    let user: String
    let target: String
    let transliteration: String
}

// MARK: - Word Tense Item (for display)
struct WordTenseItem: Identifiable {
    let id = UUID()
    let tenseName: String
    let userForm: String
    let targetTranslation: String
    let transliteration: String
}

