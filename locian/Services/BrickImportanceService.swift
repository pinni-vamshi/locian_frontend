//
//  BrickImportanceService.swift
//  locian
//
//  Per-brick importance scoring for a generated sentence.
//
//  Replaces the binary 1.0 score that `ContentAnalyzer` currently emits for
//  any lexically-present brick with a real teach-weight in [0, 1] that the
//  semantic-cliff filter can rank against.
//
//  Two signals fused per brick:
//    1. POS weight  — from Apple's built-in `NLTagger` (.lexicalClass).
//                     Content tags (noun/verb/adjective/adverb/numeral) →
//                     high weight. Function tags (determiner/preposition/
//                     pronoun/conjunction/particle/auxiliary) → low weight.
//    2. Centrality  — cosine(brick_embedding, sentence_embedding) via the
//                     existing `EmbeddingService`, then min-max normalized
//                     across this sentence's brick set so the most-on-topic
//                     word ≈ 1.0 and the least ≈ 0.0.
//
//  Fusion:
//      importance = (posWeight ^ alpha) * (centrality ^ beta)
//                   clipped to [floor, 1.0]
//
//  Output:
//      [BrickImportance] / [String: Double]
//
//  Location: locian/Services/BrickImportanceService.swift
//

import Foundation
import NaturalLanguage

// MARK: - Result types

struct BrickImportance {
    let id: String
    let importance: Double      // final fused score, in [floor, 1.0]
    let pos: String             // NLTag rawValue or heuristic tag
    let posWeight: Double       // raw POS weight in [0, 1]
    let centrality: Double?     // sentence-normalized cosine, [0, 1] or nil
}

/// Minimal brick shape the service needs. A protocol so call sites can pass
/// `BrickItem`, `RecommendationBrickItem`, or anything else that exposes the
/// two fields without copying.
protocol BrickImportanceInput {
    var id: String { get }
    var word: String { get }       // target-language surface form
    var meaning: String { get }    // native fallback if `word` is empty
}

// MARK: - Service

enum BrickImportanceService {

    // MARK: POS weight table (NLTag.lexicalClass rawValues)

    /// Teachability weight per POS tag. Content tags ≈ 1.0; function tags
    /// ≈ 0.15–0.35. Unknown tags fall back to `defaultPOSWeight`.
    private static let posWeights: [String: Double] = [
        // Content
        NLTag.noun.rawValue:        1.00,
        NLTag.verb.rawValue:        1.00,
        NLTag.adjective.rawValue:   0.90,
        NLTag.adverb.rawValue:      0.75,
        NLTag.number.rawValue:      0.70,
        NLTag.idiom.rawValue:       0.95,
        NLTag.otherWord.rawValue:   0.60,
        // Function / glue
        NLTag.pronoun.rawValue:     0.35,
        NLTag.determiner.rawValue:  0.15,
        NLTag.preposition.rawValue: 0.20,
        NLTag.conjunction.rawValue: 0.15,
        NLTag.particle.rawValue:    0.20,
        NLTag.interjection.rawValue: 0.40,
        NLTag.classifier.rawValue:  0.30,
        // Punctuation / whitespace (only the two that are actual lexical-class
        // tags; `NLTag.otherPunctuation`/`sentenceTerminator`/quote/paren cases
        // share rawValues with the lexical-class scheme and would crash a
        // dictionary literal with "duplicate keys").
        NLTag.punctuation.rawValue: 0.05,
        NLTag.whitespace.rawValue:  0.00,
    ]
    private static let defaultPOSWeight: Double = 0.50

    // MARK: Per-language function-word fallback (used when NLTagger gives nothing useful)

    private static let functionWords: [String: Set<String>] = [
        "en": ["the","a","an","of","to","in","on","at","for","by","with","from","as",
               "is","are","was","were","be","been","being","am","do","does","did",
               "have","has","had","and","or","but","if","then","so","that","this",
               "these","those","i","you","he","she","it","we","they","me","him",
               "her","us","them","my","your","his","its","our","their","not","no","yes"],
        "es": ["el","la","los","las","un","una","unos","unas","de","del","a","al","en",
               "por","para","con","sin","y","o","u","pero","que","si","no","se","lo",
               "le","les","me","te","nos","os","es","son","soy","eres","está","están",
               "ser","estar","yo","tú","él","ella","usted","nosotros","vosotros",
               "ellos","ellas","ustedes","mi","tu","su"],
        "fr": ["le","la","les","un","une","des","de","du","à","au","aux","en","dans",
               "sur","pour","par","avec","sans","et","ou","mais","que","qui","se","ne",
               "pas","non","oui","je","tu","il","elle","nous","vous","ils","elles",
               "mon","ton","son","est","sont","suis","être","avoir","ai","as","a","ont"],
        "de": ["der","die","das","den","dem","des","ein","eine","einen","einer","und",
               "oder","aber","ist","sind","war","waren","bin","bist","sein","haben",
               "hat","habe","in","an","auf","mit","von","zu","für","bei","nicht",
               "kein","ich","du","er","sie","es","wir","ihr"],
        "it": ["il","lo","la","i","gli","le","un","uno","una","di","a","da","in","su",
               "per","con","tra","fra","e","o","ma","che","se","non","è","sono","sei",
               "essere","ho","hai","ha","io","tu","lui","lei","noi","voi","loro"],
        "pt": ["o","a","os","as","um","uma","uns","umas","de","do","da","dos","das",
               "em","no","na","nos","nas","para","por","com","sem","e","ou","mas",
               "que","se","não","é","são","ser","estar","eu","tu","ele","ela","nós",
               "vocês","eles","elas"],
    ]

    // MARK: - Public API

    /// Score every brick against the sentence it appears in.
    ///
    /// - Parameters:
    ///   - sentence: The target-language sentence the bricks belong to.
    ///   - bricks: Bricks to score (id + word + meaning).
    ///   - languageCode: ISO code of `sentence` ("en", "es", …).
    ///   - alpha, beta: Exponents on POS / centrality factors.
    ///   - floor: Minimum returned importance (keeps cliff-filter math safe).
    static func score<B: BrickImportanceInput>(
        sentence: String,
        bricks: [B],
        languageCode: String,
        alpha: Double = 1.0,
        beta:  Double = 1.0,
        floor: Double = 0.05
    ) -> [BrickImportance] {
        guard !bricks.isEmpty else { return [] }

        // 1. POS pass over the whole sentence — single NLTagger walk.
        let sentencePOS = posMap(for: sentence, languageCode: languageCode)

        // 2. Sentence embedding (one call).
        let sentenceVec = EmbeddingService.getVector(for: sentence, languageCode: languageCode)

        // 3. Per-brick: POS lookup + brick embedding + cosine.
        var rawCentralities: [Double?] = []
        var posTags: [String] = []
        var posWeightsArr: [Double] = []

        for brick in bricks {
            let surface = brick.word.isEmpty ? brick.meaning : brick.word
            let tag = posFor(word: surface, sentencePOS: sentencePOS, languageCode: languageCode)
            posTags.append(tag)
            posWeightsArr.append(posWeights[tag] ?? defaultPOSWeight)

            if let sVec = sentenceVec,
               let bVec = EmbeddingService.getVector(for: surface, languageCode: languageCode) {
                rawCentralities.append(EmbeddingService.cosineSimilarity(v1: bVec, v2: sVec))
            } else {
                rawCentralities.append(nil)
            }
        }

        // 4. Min-max normalize centralities across this sentence's bricks.
        let normCentralities = normalize(rawCentralities)

        // 5. Fuse.
        var out: [BrickImportance] = []
        out.reserveCapacity(bricks.count)
        for (i, brick) in bricks.enumerated() {
            let pw = posWeightsArr[i]
            let cent = normCentralities[i]
            let importance: Double
            if let c = cent {
                importance = max(floor, min(1.0, pow(pw, alpha) * pow(c, beta)))
            } else {
                // No embedding signal → POS alone carries the score.
                importance = max(floor, min(1.0, pw))
            }
            out.append(BrickImportance(
                id: brick.id,
                importance: importance,
                pos: posTags[i],
                posWeight: pw,
                centrality: cent
            ))
        }
        return out
    }

    /// Convenience: `{brick_id: importance}` map — the shape the cliff
    /// filter consumes.
    static func scoreMap<B: BrickImportanceInput>(
        sentence: String,
        bricks: [B],
        languageCode: String
    ) -> [String: Double] {
        var map: [String: Double] = [:]
        for item in score(sentence: sentence, bricks: bricks, languageCode: languageCode) {
            map[item.id] = item.importance
        }
        return map
    }

    // MARK: - POS tagging via NLTagger (built-in)

    /// One pass over the sentence → `[lowercasedToken: NLTag.rawValue]`.
    private static func posMap(for sentence: String, languageCode: String) -> [String: String] {
        guard !sentence.isEmpty else { return [:] }
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = sentence
        if !languageCode.isEmpty {
            tagger.setLanguage(NLLanguage(rawValue: normalize(languageCode)), range: sentence.startIndex..<sentence.endIndex)
        }
        var out: [String: String] = [:]
        let opts: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(
            in: sentence.startIndex..<sentence.endIndex,
            unit: .word,
            scheme: .lexicalClass,
            options: opts
        ) { tag, range in
            let token = String(sentence[range]).lowercased()
            if !token.isEmpty, let raw = tag?.rawValue, out[token] == nil {
                out[token] = raw
            }
            return true
        }
        return out
    }

    /// Resolve a brick word's POS — prefer the NLTagger tag from the
    /// sentence; fall back to a head-token lookup, then to a heuristic.
    private static func posFor(
        word: String,
        sentencePOS: [String: String],
        languageCode: String
    ) -> String {
        let key = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return NLTag.otherWord.rawValue }

        if let exact = sentencePOS[key] { return exact }

        // Multi-word lexical units ("to order", "ir a") — try last and first parts.
        let parts = key.split(separator: " ").map(String.init).filter { !$0.isEmpty }
        for cand in (parts.last.map { [$0] } ?? []) + (parts.first.map { [$0] } ?? []) {
            if let hit = sentencePOS[cand] { return hit }
        }

        // Per-language function-word fallback.
        let lang = String(normalize(languageCode).prefix(2)).lowercased()
        if let stop = functionWords[lang], stop.contains(key) {
            return NLTag.determiner.rawValue
        }

        // Last-resort heuristic: long capitalized → proper noun, digits → number,
        // very short → particle, else noun-ish.
        if word.first?.isUppercase == true && key.count > 1 {
            return NLTag.noun.rawValue
        }
        if key.allSatisfy({ $0.isNumber }) {
            return NLTag.number.rawValue
        }
        if key.count <= 2 {
            return NLTag.particle.rawValue
        }
        return NLTag.noun.rawValue
    }

    // MARK: - Helpers

    private static func normalize(_ code: String) -> String {
        if code.lowercased() == "zh" { return "zh-Hans" }
        return code
    }

    /// Min-max scale non-nil values into [0, 1]; preserve nil.
    private static func normalize(_ values: [Double?]) -> [Double?] {
        let present = values.compactMap { $0 }
        guard let lo = present.min(), let hi = present.max() else { return values }
        if hi - lo < 1e-9 {
            return values.map { $0 == nil ? nil : 1.0 }
        }
        return values.map { v in
            guard let v = v else { return nil }
            return (v - lo) / (hi - lo)
        }
    }
}

// MARK: - Convenience conformance for the common brick types

extension BrickItem: BrickImportanceInput {}

extension RecommendationBrickItem: BrickImportanceInput {
    // `id` is already provided by Identifiable; `word` and `meaning` are
    // declared as stored properties on the struct.
}
