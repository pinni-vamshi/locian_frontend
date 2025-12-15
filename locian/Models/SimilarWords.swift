import Foundation

// MARK: - Similar Words Request
struct SimilarWordsRequest: Codable {
    let session_token: String
    let word: String
    let user_language: String
    let target_language: String
}

// MARK: - Similar Words Response
struct SimilarWordsResponse: Codable {
    let success: Bool
    let message: String?
    let data: SimilarWordsData?
    let error: String?
    let error_code: String?
    let timestamp: String
    let request_id: String?
}

// MARK: - Similar Words Data
struct SimilarWordsData: Codable {
    let similar_words: [String: SimilarWordDetail]
}

// MARK: - Similar Word Detail
struct SimilarWordDetail: Codable {
    let translation: String
    let transliteration: String
}

// MARK: - Similar Word Item (for display)
struct SimilarWordItem: Identifiable {
    let id = UUID()
    let nativeWord: String
    let translation: String
    let transliteration: String
}

