import Foundation

// MARK: - Category Event Update Request
struct PracticeCategoryEventUpdateRequest: Codable {
    let place_name: String
    let session_id: String
    let session_token: String?
    let category: String
    let updates: VocabularyEventUpdates
}

// MARK: - Word Event Update Request
struct PracticeWordEventUpdateRequest: Codable {
    let place_name: String
    let session_id: String
    let session_token: String?
    let category: String
    let word: String
    let updates: VocabularyEventUpdates
}


