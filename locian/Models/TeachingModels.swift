//
//  TeachingModels.swift
//  locian
//
//  Data Models for the Teaching API (Generate Sentence).
//  Matches strict JSON Schema provided by backend.
//

import Foundation

// MARK: - Generate Sentence Request
struct GenerateSentenceRequest: Codable {
    let target_language: String
    let place_name: String
    let user_language: String
    let micro_situation: String
    let profession: String?
    let time: String?
}

// MARK: - Generate Sentence Response
struct GenerateSentenceResponse: Codable {
    let success: Bool
    let message: String?
    let data: GenerateSentenceData?
    let error: String?
}

// MARK: - Generate Sentence Data
struct GenerateSentenceData: Codable {
    let success: Bool?
    let lesson_id: String?
    let moment_label: String?
    let target_language: String?
    let user_language: String?
    let sentence: String?
    let native_sentence: String?
    let micro_situation: String?
    let created_at: String?
    
    // Collections
    let patterns: [PatternData]?
    let bricks: BricksData?
}

// MARK: - BRICKS
struct BricksData: Codable {
    let constants: [BrickItem]?
    let variables: [BrickItem]?
    let structural: [BrickItem]?
}

struct BrickItem: Codable {
    let id: String?
    let word: String
    let meaning: String
    let phonetic: String?
    
    // Helper to get ID or fallback
    var safeID: String { id ?? word }
}

// MARK: - PATTERNS
struct PatternData: Codable {
    let pattern_id: String
    let target: String
    let meaning: String
    let phonetic: String?
}

// Internal ENGINE Model (Not API)
struct DrillItem: Codable {
    let target: String
    let meaning: String
    let phonetic: String?
}

// MARK: - SIMILAR WORDS API
struct GetSimilarWordsRequest: Codable {
    let word: String
    let target_language: String
    let user_language: String
    let situation: String?
    let sentence: String?
}

struct GetSimilarWordsResponse: Codable {
    let success: Bool?
    let message: String?
    let data: SimilarWordsData?
    let error: String?
}

struct SimilarWordsData: Codable {
    let original_word: String?
    let similar_words: [SimilarWord]?
}

struct SimilarWord: Codable, Identifiable {
    var id: String { word }
    let word: String
    let meaning: String
    let pronunciation: String?
    let example_sentence: String?
    let example_meaning: String?
}
