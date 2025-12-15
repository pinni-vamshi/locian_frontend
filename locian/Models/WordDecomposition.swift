import Foundation

// MARK: - Word Decomposition Request
struct WordDecompositionRequest: Codable {
    let session_token: String
    let word: String
    let target_language: String
    let user_language: String?
}

// MARK: - Word Decomposition Response
struct WordDecompositionResponse: Codable {
    let success: Bool
    let message: String?
    let data: WordDecompositionData?
    let error: String?
    let error_code: String?
    let timestamp: String
    let request_id: String?
}

// MARK: - Word Decomposition Data
struct WordDecompositionData: Codable {
    let original_word: String
    let blocks: [DecompositionBlock]
}

// MARK: - Decomposition Block
struct DecompositionBlock: Codable {
    let script: String
    let consonant: String
    let consonant_transliteration: String
    let vowel: String
    let vowel_transliteration: String
    let has_vowel: Bool
}

// MARK: - Word Decomposition Item (for display)
struct WordDecompositionDisplayItem: Identifiable {
    let id = UUID()
    let block: String
    let components: String
    let description: String
}

