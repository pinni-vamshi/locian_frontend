import Foundation

// MARK: - Generate Quiz
struct QuizGenerateRequest: Codable {
    let session_token: String
    let scene: String
    let time: String?
    let vocabulary_session_id: String?
    let categories: [QuizCategory]
}

struct QuizCategory: Codable {
    let category_name: String
    let clicked: Bool?
    let words: [QuizWord]
}

struct QuizWord: Codable {
    let native_text: String
    let target_text: String
    let transliteration: String
    let clicked: Bool
    let is_correct: Bool?
    let attempts: Int?
}

struct QuizGenerateResponse: Codable {
    // Wrapped format fields
    let success: Bool?
    let message: String?
    let data: QuizData?
    let timestamp: String?
    let request_id: String?
    
    // Direct format fields (if API returns quiz data at root level instead of in "data")
    let quiz_session_id: String?
    let questions: [String: QuizQuestion]?
    
    // Computed property for backward compatibility
    var status: String {
        (success ?? true) ? "success" : "error"
    }
}

struct QuizData: Codable {
    let quiz_session_id: String
    let questions: [String: QuizQuestion]
}

enum QuizQuestion: Codable {
    case multiple_choice(QuizMultipleChoice)
    case fill_blank(QuizFillBlank)
    case ordering(QuizOrdering)

    private enum CodingKeys: String, CodingKey { case type }
    private enum Kind: String, Codable { case multiple_choice, fill_blank, ordering }

    init(from decoder: Decoder) throws {
        let root = try decoder.singleValueContainer()
        let dict = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try dict.decode(Kind.self, forKey: .type)
        switch kind {
        case .multiple_choice:
            self = .multiple_choice(try root.decode(QuizMultipleChoice.self))
        case .fill_blank:
            self = .fill_blank(try root.decode(QuizFillBlank.self))
        case .ordering:
            self = .ordering(try root.decode(QuizOrdering.self))
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .multiple_choice(let v):
            try v.encode(to: encoder)
        case .fill_blank(let v):
            try v.encode(to: encoder)
        case .ordering(let v):
            try v.encode(to: encoder)
        }
    }
}

struct QuizMultipleChoice: Codable {
    let type: String // "multiple_choice"
    let prompt_native: String?
    let prompt_target: String?
    let options_native: [String]? // API can return native options
    let options_target: [String]?  // API can return target options
    let options_transliteration: [String]?
    let answer_native: String?     // API can return native answer (legacy)
    let answer_target: String?     // API can return target answer (legacy)
    let answer_transliteration: String? // Legacy
    let answer_index: Int?         // New format: index of correct answer (0, 1, 2, or 3)
    let is_attempted: Bool?
    let is_correct: Bool?
    let time_taken: Double?
    
    // Computed properties for backward compatibility
    var effectiveOptions: [String] {
        options_target ?? options_native ?? []
    }
    
    // Legacy computed property - returns answer string if available
    var effectiveAnswer: String {
        if let index = answer_index, index < effectiveOptions.count {
            return effectiveOptions[index]
        }
        return answer_target ?? answer_native ?? ""
    }
    
    // Get correct answer index (new format) or -1 if not available
    var correctAnswerIndex: Int? {
        if let index = answer_index {
            return index
        }
        // Fallback: try to find index by matching answer string (legacy support)
        if let answer = answer_target ?? answer_native {
            return effectiveOptions.firstIndex(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() })
        }
        return nil
    }
}

struct QuizFillBlank: Codable {
    let type: String // "fill_blank"
    let template: String
    let options: [String]
    let answers: [String]
    let is_attempted: Bool?
    let is_correct: Bool?
    let time_taken: Double?
}

struct QuizOrdering: Codable {
    let type: String // "ordering"
    let prompt_native: String?
    let tokens_target: [String]
    let tokens_transliteration: [String]?
    let answer_token_order: [Int]
    let is_attempted: Bool?
    let is_correct: Bool?
    let time_taken: Double?
}

// MARK: - Update Question
struct QuizUpdateRequest: Codable {
    let session_token: String
    let quiz_session_id: String
    let question_id: String
    let updates: QuizQuestionUpdates
}

struct QuizQuestionUpdates: Codable {
    let is_attempted: Bool?
    let is_correct: Bool?
    let time_taken: Double?
}

struct QuizUpdateResponse: Codable {
    let success: Bool
    let message: String?
    let data: QuizUpdateData?
    let timestamp: String?
    let request_id: String?
    
    // Computed property for backward compatibility
    var status: String {
        success ? "success" : "error"
    }
}

struct QuizUpdateData: Codable {
    let quiz_session_id: String?
    let question_id: String?
    let updated_fields: [String]
}


