//
//  GenerateSentenceLogic.swift
//  locian
//
//  Logic layer for Generate Sentence Endpoint
//  Parses raw response data
//

import Foundation

// MARK: - Lesson Models
// These models represent the final hydrated "Lesson" format expected by the LessonEngine
// Since the network endpoint was deleted, these live here purely for the local hydration step.

struct GenerateSentenceData: Codable, Sendable {
    let target_language: String?
    let user_language: String?
    let place_name: String?
    let micro_situation: String?
    let conversation_context: String?
    let lesson_id: String?
    let moment_label: String?
    let sentence: String?
    let native_sentence: String?
    
    // New Structure (Groups contain patterns & bricks)
    var groups: [LessonGroup]?
    
    // Legacy support (Flat arrays)
    var bricks: BricksData?
    var patterns: [PatternData]?
}

struct LessonGroup: Codable, Sendable {
    let group_id: String
    var patterns: [PatternData]?
    var bricks: BricksData?
}

struct BricksData: Codable, Sendable {
    var constants: [BrickItem]?
    var variables: [BrickItem]?
    var structural: [BrickItem]?
}

struct BrickItem: Codable, Sendable, Identifiable {
    var id: String
    let word: String
    let meaning: String
    let phonetic: String?
    let type: String?
    var vector: [Double]?
    var mastery: Int?
}

struct PatternData: Codable, Sendable, Identifiable {
    var id: String
    let target: String
    let meaning: String
    let phonetic: String?
    var vector: [Double]?
    var mastery: Int?
}

@MainActor
class GenerateSentenceLogic {
    static let shared = GenerateSentenceLogic()
    
    private init() {}
    
    // MARK: - Centralized Writer
    
    
    /// Update mastery for a specific brick/pattern (called by Lesson Engine)
    func updateMastery(text: String, vector: [Double]?, languageCode: String, mode: String, isCorrect: Bool, currentStep: Int) {
        
        // Memory removal: Skipping persistent update as per user request.
    }
    
    // MARK: - V3 Direct Hydration (Bypass API, feed discovery data straight to Engine)
    
    /// Accepts a PlaceRecommendation from the V3 discovery system and transforms it
    /// into a fully hydrated GenerateSentenceData with vectors and LessonGroups,
    /// ready to pass directly into LessonEngine.initialize().
    func hydrateFromV3(
        recommendation: PlaceRecommendation,
        completion: @escaping (GenerateSentenceData) -> Void
    ) {
        let langCode = AppStateManager.shared.userLanguagePairs.first(where: { $0.is_default })?.target_language ?? "es"
        let userLang = AppStateManager.shared.userLanguagePairs.first(where: { $0.is_default })?.native_language ?? "en"
        
        print("🔗 [GenerateSentenceLogic] hydrateFromV3: Hydrating '\(recommendation.place_id)' with \(recommendation.patterns?.count ?? 0) patterns")
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            var groups: [LessonGroup] = []
            var allPatterns: [PatternData] = []
            
            // Create ONE LessonGroup per RecommendationPattern,
            // each carrying its OWN brick set so ContentAnalyzer word-matching works correctly.
            for (idx, rp) in (recommendation.patterns ?? []).enumerated() {
                // ✅ V3.46: Skip patterns that are missing target or meaning (empty objects from API)
                guard let target = rp.target, let meaning = rp.meaning else {
                    continue
                }
                
                // 1. Convert pattern → PatternData with vector
                let patternVector = EmbeddingService.getVector(for: target, languageCode: langCode)
                let patternData = PatternData(
                    id: "v3-\(recommendation.place_id)-\(idx)",
                    target: target,
                    meaning: meaning,
                    phonetic: rp.phonetic,
                    vector: patternVector,
                    mastery: 0
                )
                allPatterns.append(patternData)
                
                // 2. Convert this pattern's own bricks → BrickItem with vectors
                let constants: [BrickItem] = (rp.bricks?.constants ?? []).map { b in
                    BrickItem(
                        id: b.word,
                        word: b.word,
                        meaning: b.meaning,
                        phonetic: b.phonetic,
                        type: "constant",
                        vector: EmbeddingService.getVector(for: b.word, languageCode: langCode)
                    )
                }
                let variables: [BrickItem] = (rp.bricks?.variables ?? []).map { b in
                    BrickItem(
                        id: b.word,
                        word: b.word,
                        meaning: b.meaning,
                        phonetic: b.phonetic,
                        type: "variable",
                        vector: EmbeddingService.getVector(for: b.word, languageCode: langCode)
                    )
                }
                let structural: [BrickItem] = (rp.bricks?.structural ?? []).map { b in
                    BrickItem(
                        id: b.word,
                        word: b.word,
                        meaning: b.meaning,
                        phonetic: b.phonetic,
                        type: "structural",
                        vector: EmbeddingService.getVector(for: b.word, languageCode: langCode)
                    )
                }
                
                let bricks = BricksData(
                    constants: constants.isEmpty ? nil : constants,
                    variables: variables.isEmpty ? nil : variables,
                    structural: structural.isEmpty ? nil : structural
                )
                
                // 3. One group for this pattern with its own bricks
                let group = LessonGroup(
                    group_id: "v3-\(recommendation.place_id)-\(idx)",
                    patterns: [patternData],
                    bricks: bricks
                )
                groups.append(group)
                
                print("   🧩 Pattern \(idx): '\(target)' | bricks: \(constants.count)c / \(variables.count)v / \(structural.count)s")
            }
            
            // 4. Assemble final GenerateSentenceData
            let lessonData = GenerateSentenceData(
                target_language: langCode,
                user_language: userLang,
                place_name: recommendation.place_id,
                micro_situation: recommendation.grounding,
                conversation_context: nil,
                lesson_id: "v3-\(UUID().uuidString)",
                moment_label: recommendation.place_id,
                sentence: allPatterns.first?.target,
                native_sentence: allPatterns.first?.meaning,
                groups: groups,
                bricks: nil,
                patterns: allPatterns
            )
            
            print("✅ [GenerateSentenceLogic] hydrateFromV3 COMPLETE. \(groups.count) groups, \(allPatterns.count) patterns, all vectorized.")
            
            DispatchQueue.main.async {
                completion(lessonData)
            }
        }
    }
}
