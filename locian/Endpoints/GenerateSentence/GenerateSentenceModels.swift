//
//  GenerateSentenceModels.swift
//  locian
//
//  Models for Generate Sentence Endpoint
//

import Foundation

// MARK: - Request Model

struct GenerateSentenceRequest: Codable, Sendable {
    let moment_id: String
    let user_language: String
    let target_language: String
    let latitude: Double
    let longitude: Double
    let time: String
}



// MARK: - Response Models

struct GenerateSentenceResponse: Codable, Sendable {
    let success: Bool
    var data: GenerateSentenceData?
    let error: String?
    
    // Custom decoder to handle nested "data.data" structure from API
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.success = try container.decode(Bool.self, forKey: .success)
        self.error = try container.decodeIfPresent(String.self, forKey: .error)
        
        // Direct Decoding (No extended nesting)
        if let directData = try? container.decodeIfPresent(GenerateSentenceData.self, forKey: .data) {
             print("🔍 [GetPatternLesson] Decoding: Path DIRECT succeeded.")
             self.data = directData
        } else {
             // Fallback for "data.data" if API reverts
             if let outerData = try? container.decodeIfPresent(OuterDataWrapper.self, forKey: .data) {
                 print("🔍 [GetPatternLesson] Decoding: Path NESTED (data.data) succeeded.")
                 self.data = outerData.data
             } else {
                 print("❌ [GetPatternLesson] Decoding: Both DIRECT and NESTED paths failed.")
                 self.data = nil
             }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case success, data, error
    }
    
    // Wrapper to decode the outer "data" object which contains another "data" object
    private struct OuterDataWrapper: Codable {
        let data: GenerateSentenceData?
    }
}

// MARK: - Legacy Data Model Support
// These fields are optional so the backend does not need to send them.
// They are kept here purely because the Lesson Engine UI logic relies on their presence (even if nil).
struct GenerateSentenceData: Codable, Sendable {
    let target_language: String?
    let user_language: String?
    let place_name: String?
    let micro_situation: String?
    let conversation_context: String?
    
    // Captured from Inner Data Object
    let lesson_id: String?
    let moment_label: String?
    let sentence: String?
    let native_sentence: String?
    
    // NEW LEGO Structure
    var groups: [LessonGroup]?
    
    // Legacy support (to be phased out if possible, but kept for safety)
    var bricks: BricksData?
    var patterns: [PatternData]?
}

struct LessonGroup: Codable, Identifiable, Sendable {
    let group_id: String
    var id: String { group_id }
    
    var patterns: [PatternData]?

    var bricks: BricksData?
}

struct SentenceItem: Codable, Sendable {
    let sentence: String
    let translation: String
    let difficulty: String?
    let keywords: [String]?
}

// MARK: - Lesson Engine Shared Models

struct BrickItem: Codable, Identifiable, Sendable {
    let id: String?
    let word: String
    let meaning: String
    let phonetic: String?
    let type: String?
    
    var safeID: String { id ?? word }
    
    // Semantic Vector (Filled by Logic Layer)
    var vector: [Double]?
}

struct BricksData: Codable, Sendable {
    var constants: [BrickItem]?
    var variables: [BrickItem]?
    var structural: [BrickItem]?
}

struct PatternData: Codable, Identifiable, Sendable {
    let id: String
    let target: String
    let meaning: String
    let phonetic: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case target
        case meaning
        case phonetic
        case vector
        case mastery
    }
    
    // Semantic Vector (Filled by Logic Layer)
    var vector: [Double]?
    var mastery: Int?
}

struct DrillItem: Codable, Sendable {
    let target: String
    let meaning: String
    let phonetic: String?
}
