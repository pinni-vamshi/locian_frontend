//
//  DiscoverMomentsModels.swift
//  locian
//
//  Models for Discover Moments Endpoint (minimal demo shape)
//

import Foundation

// MARK: - Grammar (discover-moments wire; mirrors backend `demo_response.json`)

/// Native vs target contrast lines for a catalogued rule.
struct GrammarRuleContrast: Codable, Hashable, Sendable {
    let native_form: String?
    let target_form: String?
}

/// One entry in `grammar_rule_catalog` (keyed by rule id in JSON).
struct GrammarRuleCatalogEntry: Codable, Hashable, Sendable {
    let label: String?
    let explain: String?
    let contrast: GrammarRuleContrast?
    let category: String?
}

// MARK: - Grammar bricks (current wire; `demo_response.json` → `grammar_bricks`)

/// Q/A chunk embedded in a grammar brick's `pattern_json`.
struct GrammarBridgeChunkPayload: Codable, Hashable, Sendable {
    let native: String?
    let target: String?
}

struct GrammarBrickContrastPayload: Codable, Hashable, Sendable {
    let native_linguistic: String?
    let target_linguistic: String?
}

/// `pattern_json` for rows in `grammar_bricks` (shape differs from vocab-brick ops).
struct PatternGrammarBrickPatternJson: Codable, Hashable, Sendable {
    let kind: String?
    let rule_id: String?
    let question: GrammarBridgeChunkPayload?
    let reply: GrammarBridgeChunkPayload?
    let contrast: GrammarBrickContrastPayload?
}

/// One grammar teaching row — same field family as vocab bricks, plus `rule_id`.
struct PatternGrammarBrick: Codable, Hashable, Sendable {
    let rule_id: String
    let native: String?
    let target: String?
    let base: String?
    let base_native: String?
    let base_transliteration: String?
    let target_transliteration: String?
    let base_kind: String?
    let form_kind: String?
    let pattern: String?
    let why: String?
    let pattern_json: PatternGrammarBrickPatternJson?
    let why_json: WhyJson?
}

/// Legacy index anchors (older payloads). Prefer `grammar_bricks`.
struct PatternGrammarRule: Codable, Hashable, Sendable {
    let rule_id: String
    let q_anchor_index: Int
    let a_brick_index: Int
}

/// Echo of cleaned request fields from `/api/learning/discover-moments` for client-side filtering.
struct DiscoverMomentsDiscoverMeta: Codable, Hashable, Sendable {
    let user_language: String?
    let target_language: String?
    let latitude: Double?
    let longitude: Double?
    let date: String?
    let time: String?
    let hour: Double?
    let ts: String?
}

// MARK: - Request
struct DiscoverMomentsRequest: Codable {
    let session_token: String?
    let latitude: Double
    let longitude: Double
    let date: String
    let time: String
    let velocity: String?
    let weather: String?
    let places: [DiscoverPlaceInput]?
    let output_volume: Double?
    let headphones_connected: Bool?
    let audio_db: Double?
    let light_level: Double?
    let altitude: Double?
    let wifi_info: [String: String]?
    let explicit_request: String?
    let image_base64: String?
    let user_language: String?
    let target_language: String?
}

struct DiscoverPlaceInput: Codable {
    let name: String
    let category: String
    let place_latitude: Double?
    let place_longitude: Double?

    init(name: String, category: String, place_latitude: Double? = nil, place_longitude: Double? = nil) {
        self.name = name
        self.category = category
        self.place_latitude = place_latitude
        self.place_longitude = place_longitude
    }
}

// MARK: - Response
struct DiscoverMomentsResponse: Decodable {
    let success: Bool?
    /// Optional global catalog; same keys as backend `grammar_rule_catalog`.
    let grammar_rule_catalog: [String: GrammarRuleCatalogEntry]?
    let places: [DiscoverPlacePayload]?
    /// Server echo after cleaning (languages, time, coordinates).
    let discover_meta: DiscoverMomentsDiscoverMeta?

    var recommendations: [PlaceRecommendation] {
        // Resolve target language once for the importance pass.
        let targetLang = AppStateManager.shared
            .userLanguagePairs
            .first(where: { $0.is_default })?
            .target_language ?? "es"

        return (places ?? []).map { place in
            let patterns = (place.sentences ?? []).enumerated().map { idx, item -> RecommendationPattern in
                // 1. Build the bricks for this sentence.
                let rawBricks = (item.bricks ?? []).map { $0.asBrickItem }

                // 2. Compute per-brick importance ONCE per sentence
                //    (fused POS × semantic-centrality from `BrickImportanceService`).
                //    Falls back to 1.0 when scoring is unavailable so the cliff
                //    filter still has a defined input.
                let scoreMap: [String: Double] = {
                    guard let sentence = item.target, !sentence.isEmpty,
                          !rawBricks.isEmpty else { return [:] }
                    return BrickImportanceService.scoreMap(
                        sentence: sentence,
                        bricks: rawBricks,
                        languageCode: targetLang
                    )
                }()
                let scoredBricks: [RecommendationBrickItem] = rawBricks.map { b in
                    var copy = b
                    copy.importance = scoreMap[b.id]
                    return copy
                }

                // 3. Same pass for the Locian question's brick breakdown so
                //    the question line gets the same tappable / importance
                //    treatment as the user reply.
                let rawQBricks = (item.locian_question_bricks ?? []).map { $0.asBrickItem }
                let qScoreMap: [String: Double] = {
                    guard let qSentence = item.locian_question, !qSentence.isEmpty,
                          !rawQBricks.isEmpty else { return [:] }
                    return BrickImportanceService.scoreMap(
                        sentence: qSentence,
                        bricks: rawQBricks,
                        languageCode: targetLang
                    )
                }()
                let scoredQBricks: [RecommendationBrickItem] = rawQBricks.map { b in
                    var copy = b
                    copy.importance = qScoreMap[b.id]
                    return copy
                }

                return RecommendationPattern(
                    id: "p_\(place.place_id ?? "context")_\(idx + 1)",
                    topic_id: "context",
                    native_pattern: item.native,
                    target_pattern: item.target,
                    phonetic: nil,
                    transliteration: item.transliteration,
                    status: "done",
                    bricks: RecommendationBricks.grouped(from: scoredBricks),
                    applied_case: nil,
                    locian_question: item.locian_question,
                    locian_question_native: item.locian_question_native,
                    locian_question_transliteration: item.locian_question_transliteration,
                    locian_question_bricks: scoredQBricks.isEmpty ? nil : scoredQBricks,
                    grammar_rules: item.grammar_rules,
                    grammar_bricks: item.grammar_bricks
                )
            }
            return PlaceRecommendation(
                place_id: place.place_id ?? "context",
                name: place.place_id?.capitalized ?? "Context",
                confidence: 1.0,
                grounding: nil,
                patterns: patterns,
                grammarRuleCatalog: grammar_rule_catalog
            )
        }
    }
}

// MARK: - Runtime Models (used by Learn tab)
struct PlaceRecommendation: Identifiable {
    var id: String { place_id }
    let place_id: String
    let name: String?
    let confidence: Double
    let grounding: String?
    var patterns: [RecommendationPattern]?
    /// Copied from the discover response root for this hydration session.
    var grammarRuleCatalog: [String: GrammarRuleCatalogEntry]?

    init(
        place_id: String,
        name: String?,
        confidence: Double,
        grounding: String?,
        patterns: [RecommendationPattern]?,
        grammarRuleCatalog: [String: GrammarRuleCatalogEntry]? = nil
    ) {
        self.place_id = place_id
        self.name = name
        self.confidence = confidence
        self.grounding = grounding
        self.patterns = patterns
        self.grammarRuleCatalog = grammarRuleCatalog
    }
}

struct RecommendationPattern: Identifiable {
    let id: String?
    let topic_id: String?
    let native_pattern: String?
    let target_pattern: String?
    let phonetic: String?
    let transliteration: String?
    let status: String?
    var bricks: RecommendationBricks?
    let applied_case: RecommendationAppliedCase?
    let locian_question: String?
    let locian_question_native: String?
    let locian_question_transliteration: String?
    /// Brick breakdown of `locian_question` — same shape as the user-reply
    /// `bricks`, but for the question Locian asks. Drives the same tappable /
    /// underlined word treatment in Learn Preview.
    var locian_question_bricks: [RecommendationBrickItem]?
    /// Legacy grammar links (brick indices). Prefer `grammar_bricks`.
    var grammar_rules: [PatternGrammarRule]?
    /// Rich grammar rows from `grammar_bricks` on the wire.
    var grammar_bricks: [PatternGrammarBrick]?

    init(
        id: String?,
        topic_id: String?,
        native_pattern: String?,
        target_pattern: String?,
        phonetic: String?,
        transliteration: String? = nil,
        status: String?,
        bricks: RecommendationBricks?,
        applied_case: RecommendationAppliedCase?,
        locian_question: String? = nil,
        locian_question_native: String? = nil,
        locian_question_transliteration: String? = nil,
        locian_question_bricks: [RecommendationBrickItem]? = nil,
        grammar_rules: [PatternGrammarRule]? = nil,
        grammar_bricks: [PatternGrammarBrick]? = nil
    ) {
        self.id = id
        self.topic_id = topic_id
        self.native_pattern = native_pattern
        self.target_pattern = target_pattern
        self.phonetic = phonetic
        self.transliteration = transliteration
        self.status = status
        self.bricks = bricks
        self.applied_case = applied_case
        self.locian_question = locian_question
        self.locian_question_native = locian_question_native
        self.locian_question_transliteration = locian_question_transliteration
        self.locian_question_bricks = locian_question_bricks
        self.grammar_rules = grammar_rules
        self.grammar_bricks = grammar_bricks
    }
}

struct RecommendationAppliedCase {
    let controller: String?
    let controller_meaning: String?
    let tense: String?
    let base: String?
    let target: String?
    let meaning: String?
}

struct RecommendationBricks {
    var constants: [RecommendationBrickItem]?
    var variables: [RecommendationBrickItem]?
    var structural: [RecommendationBrickItem]?

    static func grouped(from items: [RecommendationBrickItem]) -> RecommendationBricks {
        // Demo flow doesn't classify bricks; keep them all in `constants` so
        // LearnTabView.currentBricks gets them in declared order.
        RecommendationBricks(
            constants: items.isEmpty ? nil : items,
            variables: nil,
            structural: nil
        )
    }
}

struct RecommendationBrickItem: Identifiable, Equatable {
    var id: String { brickId ?? word }
    let brickId: String?
    let word: String
    let meaning: String
    let phonetic: String?
    let nativeBrick: String?
    let targetBrick: String?
    let category: String?
    let tense: String?
    let base: String?
    let baseNative: String?
    let baseTransliteration: String?
    let targetTransliteration: String?
    let baseKind: String?
    let formKind: String?
    let pattern: String?
    let why: String?
    let subjectWord: String?
    let siblingTargets: [String]?
    /// Per-brick teach-weight in [0, 1] from `BrickImportanceService`,
    /// computed once per sentence after demo data loads. Mutable so the
    /// score can be patched in after construction.
    var importance: Double?
    var patternJson: PatternJson?
    var whyJson: WhyJson?
    /// True for the one brick in a sentence that is the teaching anchor —
    /// the ConversationBridgeView starts the graph from this node.
    var isAnchor: Bool
    /// What expands to the LEFT of this node in the bridge graph.
    var expansionBefore: BrickExpansion?
    /// What expands to the RIGHT of this node in the bridge graph.
    var expansionAfter: BrickExpansion?

    init(
        id: String? = nil,
        word: String,
        meaning: String,
        phonetic: String? = nil,
        nativeBrick: String? = nil,
        targetBrick: String? = nil,
        category: String? = nil,
        tense: String? = nil,
        base: String? = nil,
        baseNative: String? = nil,
        baseTransliteration: String? = nil,
        targetTransliteration: String? = nil,
        baseKind: String? = nil,
        formKind: String? = nil,
        pattern: String? = nil,
        why: String? = nil,
        subjectWord: String? = nil,
        siblingTargets: [String]? = nil,
        importance: Double? = nil,
        isAnchor: Bool = false,
        expansionBefore: BrickExpansion? = nil,
        expansionAfter: BrickExpansion? = nil
    ) {
        self.brickId = id
        self.word = word
        self.meaning = meaning
        self.phonetic = phonetic
        self.nativeBrick = nativeBrick
        self.targetBrick = targetBrick
        self.category = category
        self.tense = tense
        self.base = base
        self.baseNative = baseNative
        self.baseTransliteration = baseTransliteration
        self.targetTransliteration = targetTransliteration
        self.baseKind = baseKind
        self.formKind = formKind
        self.pattern = pattern
        self.why = why
        self.subjectWord = subjectWord
        self.siblingTargets = siblingTargets
        self.importance = importance
        self.isAnchor = isAnchor
        self.expansionBefore = expansionBefore
        self.expansionAfter = expansionAfter
    }
}

// MARK: - Wire Payload (minimal API shape)
//
// Server may also include `pattern_json` and `why_json` (structured mirrors of
// `pattern` and `why`). They are intentionally NOT decoded here — the iOS UI
// only renders the human-readable strings. Codable silently ignores unknown
// keys, so the server can ship the structured forms for future use without
// breaking this client.
// MARK: - Structured pattern / why (graph view)

/// One morphological op in the transformation chain. Shape mirrors the
/// JSON the backend ships (or that the demo data carries).
///
/// `from` letters get a yellow highlight on the LEFT (preceding) node when
/// the op is selected; `to` letters get a pink highlight on the RIGHT
/// (following) node. `label` is the chip text. `result` is the surface
/// form that exists *after* this op fires.
struct PatternOp: Codable, Equatable {
    let kind: String
    let from: String?
    let to: String?
    let label: String
    let result: String?
}

/// Directional expansion hint for the ConversationBridgeView graph.
/// Tells the graph which grammatical role connects to this brick and
/// what label to animate before the adjacent node slides in.
struct BrickExpansion: Codable, Equatable {
    let role: String
    let label: String
}

struct PatternJson: Codable, Equatable {
    let base: String?
    let target: String?
    let ops: [PatternOp]?
}

struct WhyJson: Codable, Equatable {
    let trail: [String]?
}

struct DiscoverPatternBrickPayload: Decodable {
    let native: String?
    let target: String?
    let base: String?
    let base_native: String?
    let base_transliteration: String?
    let target_transliteration: String?
    let base_kind: String?
    let form_kind: String?
    let pattern: String?
    let why: String?
    let sibling_targets: [String]?
    let pattern_json: PatternJson?
    let why_json: WhyJson?
    /// Graph expansion fields — drive the ConversationBridgeView.
    let anchor: Bool?
    let before: BrickExpansion?
    let after: BrickExpansion?

    var asBrickItem: RecommendationBrickItem {
        var item = RecommendationBrickItem(
            id: nil,
            word: target ?? native ?? "",
            meaning: native ?? target ?? "",
            phonetic: nil,
            nativeBrick: native,
            targetBrick: target,
            category: nil,
            tense: nil,
            base: base,
            baseNative: base_native,
            baseTransliteration: base_transliteration,
            targetTransliteration: target_transliteration,
            baseKind: base_kind,
            formKind: form_kind,
            pattern: pattern,
            why: why,
            subjectWord: nil,
            siblingTargets: sibling_targets,
            isAnchor: anchor ?? false,
            expansionBefore: before,
            expansionAfter: after
        )
        item.patternJson = pattern_json
        item.whyJson = why_json
        return item
    }
}

struct DiscoverSentenceItemPayload: Decodable {
    let native: String?
    let target: String?
    let transliteration: String?
    let locian_question: String?
    let locian_question_native: String?
    let locian_question_transliteration: String?
    let bricks: [DiscoverPatternBrickPayload]?
    /// Brick breakdown of the Locian question itself — same brick schema
    /// as `bricks`, used to drive tappable underlined words on the
    /// question line in Learn Preview.
    let locian_question_bricks: [DiscoverPatternBrickPayload]?
    let grammar_rules: [PatternGrammarRule]?
    let grammar_bricks: [PatternGrammarBrick]?
}

struct DiscoverPlacePayload: Decodable {
    let place_id: String?
    let sentences: [DiscoverSentenceItemPayload]?
}
