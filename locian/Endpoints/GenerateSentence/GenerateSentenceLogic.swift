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
    
    // Voice Support
    var voice_url: String?
    var voice_data: String?
    /// From discover response `grammar_rule_catalog`; one map per lesson load.
    var grammar_rule_catalog: [String: GrammarRuleCatalogEntry]? = nil
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
    var voice_url: String?
    var voice_data: String?
    var vector: [Double]?
    var mastery: Int?

    // Rich morphology fields (from Discover Moments brick payload). All optional —
    // populated only for bricks that ship with structured pattern data.
    var base: String?
    var base_native: String?
    var base_kind: String?
    var form_kind: String?
    var pattern: String?
    var why: String?
    var sibling_targets: [String]?

    /// Per-brick teach-weight in [0, 1] — fused POS × semantic-centrality
    /// score from `BrickImportanceService`, computed once per sentence in
    /// `hydrateFromV3`. Consumed by `ContentAnalyzer` (replaces the
    /// hard-coded 1.0) and surfaced in Learn Preview UI.
    var importance: Double?

    // ConversationBridgeView graph fields — populated from Discover Moments payload.
    var isAnchor: Bool = false
    var expansionBefore: BrickExpansion?
    var expansionAfter: BrickExpansion?

    // Rich brick fields mirrored from RecommendationBrickItem for bridge graph rendering.
    var nativeBrick: String?
    var targetBrick: String?
    var baseKind: String? { base_kind }
    var formKind: String? { form_kind }
    var patternJson: PatternJson?
    var whyJson: WhyJson?
}

struct PatternData: Codable, Sendable, Identifiable {
    var id: String
    let target: String
    let meaning: String
    let phonetic: String?
    var voice_url: String?
    var voice_data: String?
    var vector: [Double]?
    var mastery: Int?

    // The Locian-side prompt that opens this turn. Optional — populated from
    // the Discover Moments payload when available.
    var locian_question: String?
    var locian_question_native: String?
    var locian_question_transliteration: String?
    /// Anchors for grammar bridge UI — legacy index form from discover `grammar_rules`.
    var grammar_rules: [PatternGrammarRule]? = nil
    /// Rich grammar rows from discover `grammar_bricks` (preferred).
    var grammar_bricks: [PatternGrammarBrick]? = nil
}

@MainActor
class GenerateSentenceLogic {
    static let shared = GenerateSentenceLogic()
    
    private init() {}
    
    // MARK: - Centralized Writer
    
    
    /// No-op shim. Mastery is session-local in `LessonEngine.componentMastery`
    /// and is intentionally NOT persisted on device. A backend writer will be
    /// wired here later. Existing callers can remain — this just absorbs them.
    func updateMastery(text: String, vector: [Double]?, languageCode: String, mode: String, isCorrect: Bool, currentStep: Int) {
        // intentionally empty
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
                guard let target = rp.target_pattern, let meaning = rp.native_pattern else {
                    print("⚠️ [hydrateFromV3] '\(recommendation.place_id)' SKIPPING pattern[\(idx)] — target_pattern=\(rp.target_pattern.map { "'\($0)'" } ?? "nil"), native_pattern=\(rp.native_pattern.map { "'\($0)'" } ?? "nil"). Resulting pattern indices will not be contiguous.")
                    continue
                }
                
                // 1. Convert pattern → PatternData with vector
                let patternVector = EmbeddingService.getVector(for: target, languageCode: langCode)
                var patternData = PatternData(
                    id: "v3-\(recommendation.place_id)-\(idx)",
                    target: target,
                    meaning: meaning,
                    phonetic: rp.phonetic,
                    voice_url: nil,
                    voice_data: nil,
                    vector: patternVector,
                    mastery: 0,
                    locian_question: rp.locian_question,
                    locian_question_native: rp.locian_question_native,
                    locian_question_transliteration: rp.locian_question_transliteration
                )
                patternData.grammar_rules = rp.grammar_rules
                patternData.grammar_bricks = rp.grammar_bricks
                allPatterns.append(patternData)
                
                // 2. Convert this pattern's own bricks → BrickItem with vectors
                let constantBricks: [RecommendationBrickItem] = rp.bricks?.constants ?? []
                let constants: [BrickItem] = constantBricks.map { b in
                    let normalizedWord = GenerateSentenceLogic.normalize(b.word)
                    var item = BrickItem(
                        id: normalizedWord,
                        word: normalizedWord,
                        meaning: b.meaning,
                        phonetic: b.phonetic,
                        type: "constant",
                        voice_url: nil,
                        voice_data: nil,
                        vector: EmbeddingService.getVector(for: b.word, languageCode: langCode)
                    )
                    item.base = b.base
                    item.base_native = b.baseNative
                    item.base_kind = b.baseKind
                    item.form_kind = b.formKind
                    item.pattern = b.pattern
                    item.why = b.why
                    item.sibling_targets = b.siblingTargets
                    item.importance = b.importance
                    item.isAnchor = b.isAnchor
                    item.expansionBefore = b.expansionBefore
                    item.expansionAfter = b.expansionAfter
                    item.nativeBrick = b.nativeBrick
                    item.targetBrick = b.targetBrick
                    item.patternJson = b.patternJson
                    item.whyJson = b.whyJson
                    return item
                }
                let variableBricks: [RecommendationBrickItem] = rp.bricks?.variables ?? []
                let variables: [BrickItem] = variableBricks.map { b in
                    let normalizedWord = GenerateSentenceLogic.normalize(b.word)
                    var item = BrickItem(
                        id: normalizedWord,
                        word: normalizedWord,
                        meaning: b.meaning,
                        phonetic: b.phonetic,
                        type: "variable",
                        voice_url: nil,
                        voice_data: nil,
                        vector: EmbeddingService.getVector(for: b.word, languageCode: langCode)
                    )
                    item.base = b.base
                    item.base_native = b.baseNative
                    item.base_kind = b.baseKind
                    item.form_kind = b.formKind
                    item.pattern = b.pattern
                    item.why = b.why
                    item.sibling_targets = b.siblingTargets
                    item.importance = b.importance
                    item.isAnchor = b.isAnchor
                    item.expansionBefore = b.expansionBefore
                    item.expansionAfter = b.expansionAfter
                    item.nativeBrick = b.nativeBrick
                    item.targetBrick = b.targetBrick
                    item.patternJson = b.patternJson
                    item.whyJson = b.whyJson
                    return item
                }
                let structuralBricks: [RecommendationBrickItem] = rp.bricks?.structural ?? []
                let structural: [BrickItem] = structuralBricks.map { b in
                    let normalizedWord = GenerateSentenceLogic.normalize(b.word)
                    var item = BrickItem(
                        id: normalizedWord,
                        word: normalizedWord,
                        meaning: b.meaning,
                        phonetic: b.phonetic,
                        type: "structural",
                        voice_url: nil,
                        voice_data: nil,
                        vector: EmbeddingService.getVector(for: b.word, languageCode: langCode)
                    )
                    item.base = b.base
                    item.base_native = b.baseNative
                    item.base_kind = b.baseKind
                    item.form_kind = b.formKind
                    item.pattern = b.pattern
                    item.why = b.why
                    item.sibling_targets = b.siblingTargets
                    item.importance = b.importance
                    item.isAnchor = b.isAnchor
                    item.expansionBefore = b.expansionBefore
                    item.expansionAfter = b.expansionAfter
                    item.nativeBrick = b.nativeBrick
                    item.targetBrick = b.targetBrick
                    item.patternJson = b.patternJson
                    item.whyJson = b.whyJson
                    return item
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
            var lessonData = GenerateSentenceData(
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
                patterns: allPatterns,
                voice_url: allPatterns.first?.voice_url,
                voice_data: allPatterns.first?.voice_data
            )
            lessonData.grammar_rule_catalog = recommendation.grammarRuleCatalog
            
            print("✅ [GenerateSentenceLogic] hydrateFromV3 COMPLETE. \(groups.count) groups, \(allPatterns.count) patterns, all vectorized.")
            
            DispatchQueue.main.async {
                completion(lessonData)
            }
        }
    }
    
    // MARK: - 🧼 Normalization Helper
    
    /// Normalizes a string for use as a stable ID (lowercase, no punctuation).
    private nonisolated static func normalize(_ text: String) -> String {
        return text.lowercased()
            .trimmingCharacters(in: .punctuationCharacters)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
