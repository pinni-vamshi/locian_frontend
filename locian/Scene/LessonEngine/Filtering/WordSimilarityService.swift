import Foundation
import NaturalLanguage

/// Brick category used to weight importance in the JNS scoring.
enum BrickCategory {
    case variable   // Primary learnable words (verbs, core nouns) — highest boost
    case constant   // Fixed content words — small boost
    case structural // Grammar particles, articles — slight reduction
    
    var multiplier: Double {
        switch self {
        case .variable:   return 1.10
        case .constant:   return 1.05
        case .structural: return 0.90
        }
    }
}

/// Unified service for calculating "Joint Neural Scores" (JNS) for words.
/// Combines Grammatical Importance (Tagging) with Semantic Relevance (Embeddings).
struct WordSimilarityService {
    
    struct Config {
        static let nounVerbMultiplier: Double = 1.5
        static let adjAdverbMultiplier: Double = 1.2
        static let defaultMultiplier: Double = 1.0
    }
    
    /// Calculates a joint score for a word within a sentence context.
    /// - Parameters:
    ///   - word: The brick/word text to score.
    ///   - sentence: The full context sentence.
    ///   - language: The language code (e.g., "es").
    static func calculateJointScore(word: String, sentence: String, language: String) -> Double {
        // 1. Get raw semantic similarity
        let rawSimilarity = EmbeddingService.compare(
            textA: sentence,
            textB: word,
            languageCode: language
        )
        
        // 2. Determine grammatical importance (The Tagging System)
        let tags = TokenTaggerService.tagContent(text: sentence, languageCode: language)
        let multiplier = getImportanceMultiplier(for: word, in: tags)
        
        // 3. Final JNS Formula
        let jointScore = rawSimilarity * multiplier
        
        // Clamp to 1.0 peak
        return min(jointScore, 1.0)
    }
    
    /// Calculates a combined JNS score using BOTH the target language (L2) and native meaning (L1).
    /// Each side uses its own language-specific embeddings and tagging, then averages the result.
    /// A category boost is applied after averaging.
    /// Returns the raw boosted score WITHOUT clamping — normalization happens at the collection site.
    static func calculateDualJointScore(
        word: String,
        sentence: String,
        targetLanguage: String,
        wordMeaning: String,
        meaningContext: String,
        nativeLanguage: String,
        category: BrickCategory = .constant
    ) -> Double {
        // ✅ L2: JNS using target language tagger + embeddings
        let targetJNS = calculateJointScore(word: word, sentence: sentence, language: targetLanguage)
        
        // ✅ L1: JNS using native language tagger + embeddings
        let meaningJNS = calculateJointScore(word: wordMeaning, sentence: meaningContext, language: nativeLanguage)
        
        // ✅ Average: neither language dominates the other
        let average = (targetJNS + meaningJNS) / 2.0
        
        // ✅ Category Boost: amplifies or reduces based on brick importance tier
        let boosted = average * category.multiplier
        
        // ✅ Normalize to [0, 1] by dividing by the max possible boost
        // Max possible = 1.0 (max JNS) × 1.10 (variable boost) = 1.10
        let maxPossibleScore = BrickCategory.variable.multiplier // 1.10
        return min(boosted / maxPossibleScore, 1.0)
    }
    
    /// Determines the weighting multiplier based on the word's Part of Speech.
    private static func getImportanceMultiplier(for word: String, in tags: [String: String]) -> Double {
        let cleanWord = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if TokenTaggerService.isNoun(cleanWord, in: tags) || TokenTaggerService.isVerb(cleanWord, in: tags) {
            return Config.nounVerbMultiplier
        }
        
        if TokenTaggerService.isAdjective(cleanWord, in: tags) || TokenTaggerService.isAdverb(cleanWord, in: tags) {
            return Config.adjAdverbMultiplier
        }
        
        return Config.defaultMultiplier
    }
}
