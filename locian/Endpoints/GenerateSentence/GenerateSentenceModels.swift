//
//  GenerateSentenceModels.swift
//  locian
//
//  Models for Generate Sentence Endpoint
//

import Foundation

// MARK: - Request Model

struct GenerateSentenceRequest: Codable, Sendable {
    let target_language: String
    let user_language: String
    let place_name: String
    let micro_situation: String
    let user_intent: String?
    let profession: String?
    let level: String?
    
    let time: String?
    let date: String?
    
    let nearby_places: [NearbyPlaceData]?
    let previous_places: [String]?
    let future_places: [String]?
    let bypass_cache: Bool?
}



// MARK: - Response Models

struct GenerateSentenceResponse: Codable, Sendable {
    let success: Bool
    let lesson_id: String?
    let moment_label: String?
    let message: String?
    var data: GenerateSentenceData?
    let error: String?
}

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
