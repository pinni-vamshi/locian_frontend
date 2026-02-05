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
    let place_name: String
    let user_language: String
    let micro_situation: String
    let profession: String?
    let time: String?
}

// MARK: - Response Models

struct GenerateSentenceResponse: Codable, Sendable {
    let success: Bool
    let message: String?
    let data: GenerateSentenceData?
    let error: String?
}

struct GenerateSentenceData: Codable, Sendable {
    let target_language: String?
    let user_language: String?
    let place_name: String?
    let micro_situation: String?
    let sentences: [SentenceItem]?
    let conversation_context: String?
    let bricks: BricksData?
    let patterns: [PatternData]?
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
}

struct BricksData: Codable, Sendable {
    let constants: [BrickItem]?
    let variables: [BrickItem]?
    let structural: [BrickItem]?
}

struct PatternData: Codable, Identifiable, Sendable {
    let pattern_id: String
    let target: String
    let meaning: String
    let phonetic: String?
    
    var id: String { pattern_id }
}

struct DrillItem: Codable, Sendable {
    let target: String
    let meaning: String
    let phonetic: String?
}
