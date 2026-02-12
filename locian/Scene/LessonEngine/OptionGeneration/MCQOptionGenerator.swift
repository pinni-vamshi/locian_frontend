//
//  MCQOptionGenerator.swift
//  locian
//
//  Logic for generating multiple-choice distractors.
//

import Foundation
import NaturalLanguage

class MCQOptionGenerator {
    
    // MARK: - Helpers
    
    /// Calculate Levenshtein Edit Distance between two strings
    private static func levenshtein(_ s1: String, _ s2: String) -> Double {
        let empty = [Int](repeating: 0, count: s2.count + 1)
        var last = [Int](0...s2.count)
        
        for (i, char1) in s1.enumerated() {
            var cur = [i + 1] + empty.dropFirst()
            for (j, char2) in s2.enumerated() {
                cur[j + 1] = char1 == char2 ? last[j] : min(last[j], last[j + 1], cur[j]) + 1
            }
            last = cur
        }
        return Double(last.last ?? 0)
    }

    struct MCQConfig {
        static let penaltyNoVector = 1.5
    }

    /// Generate L2 distractor options for a target (L2) answer
    static func generateOptions(target: String, candidates: [String], targetLanguage: String, validator: NeuralValidator? = nil) -> [String] {
        var opts = Set<String>()
        opts.insert(target)
        
        let targetText = target
        
        // 1. Sort Candidates (Semantic > Spelling > Random)
        var allCandidates = candidates.shuffled() // Default random
        var similarityMap: [String: Double] = [:]

        // Check A:
        if validator == nil {
        }
        
        // Use centralized semantic logic from ContentAnalyzer
        if let validator = validator {
             for c in candidates {
                 // Use similarity directly (1.0 = identical, 0.0 = unrelated)
                 let sim = SemanticMatcher.calculatePairSimilarity(target: targetText, candidate: c, validator: validator)
                 similarityMap[c] = sim
             }
        } else {
            // Fallback: Use Levenshtein (Spelling Distance)
            for c in candidates {
                // Normalize by length matches roughly (0-large)
                // For Levenshtein, lower is better, so we invert it to match similarity semantics
                let dist = levenshtein(c, targetText)
                let maxLen = Double(max(c.count, targetText.count))
                similarityMap[c] = maxLen > 0 ? 1.0 - (dist / maxLen) : 0.0
            }
        }
        
        // Apply Sort: DESCENDING (Highest Similarity = Best Distractors)
        if !similarityMap.isEmpty {
            allCandidates = candidates.sorted {
                return (similarityMap[$0] ?? 0.0) > (similarityMap[$1] ?? 0.0)
            }
        }
        
        // 2. Selection Strategy (Mid-Range Distractors):
        // Safety Fallback: Only skip top matches if we have enough candidates (>= 8).
        // Otherwise, use the top matches to guarantee 4 options.
        
        let useMidRange = allCandidates.count >= 8
        
        let topTier = useMidRange 
            ? Array(allCandidates.dropFirst(3).prefix(20))
            : Array(allCandidates.prefix(20))
            
        let bottomTier = useMidRange
            ? Array(allCandidates.dropFirst(23)).shuffled()
            : Array(allCandidates.dropFirst(20)).shuffled()
        
        // Pass 1: Semantic Match (From Top 20)
        for candidate in topTier {
            if opts.count >= 4 { break }
            if candidate == targetText { continue }
            
            opts.insert(candidate)
        }
        
        // Pass 2: Fallback (Relaxed Type) - From Top 20
        if opts.count < 4 {
            for candidate in topTier {
                if opts.count >= 4 { break }
                if !opts.contains(candidate) && candidate != targetText {
                    opts.insert(candidate)
                }
            }
        }
        
        // Pass 3: Random Fill (If Top 20 wasn't enough)
        if opts.count < 4 {
             for candidate in bottomTier {
                 if opts.count >= 4 { break }
                 if !opts.contains(candidate) && candidate != targetText {
                     opts.insert(candidate)
                 }
             }
        }
        
        let finalOpts = Array(opts.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }).shuffled()
        return finalOpts
    }
    
    /// Generate Native (L1) options for a Target (L2) audio/text
    static func generateNativeOptions(targetMeaning: String, candidates: [String], validator: NeuralValidator? = nil) -> [String] {
        var opts = Set<String>()
        opts.insert(targetMeaning)
        
        let targetMean = targetMeaning
        
        // 1. Sort Candidates
        var allCandidates = candidates.shuffled() // Default random
        var similarityMap: [String: Double] = [:]
        
        // Check A:
        if validator == nil {
        }
        
        // Use centralized semantic logic from ContentAnalyzer
        // Even for Native, the logic (Containment + Embedding) is valid.
        if let validator = validator {
            for c in candidates {
                // Use similarity directly (no conversion)
                let sim = SemanticMatcher.calculatePairSimilarity(target: targetMean, candidate: c, validator: validator)
                similarityMap[c] = sim
            }
        } else {
            // Fallback: Use EmbeddingService for English directly
             let embedCode = "en"
             
             for c in candidates {
                 if let v1 = EmbeddingService.getVector(for: targetMeaning, languageCode: embedCode),
                    let v2 = EmbeddingService.getVector(for: c, languageCode: embedCode) {
                     similarityMap[c] = EmbeddingService.cosineSimilarity(v1: v1, v2: v2)
                 } else {
                     // Spelling fallback if embedding fails
                     let dist = levenshtein(c, targetMeaning)
                     let maxLen = Double(max(c.count, targetMeaning.count))
                     similarityMap[c] = maxLen > 0 ? 1.0 - (dist / maxLen) : 0.0
                 }
             }
        }
        
        // Apply Sort: DESCENDING (Highest Similarity = Best Distractors)
        if !similarityMap.isEmpty {
            allCandidates = candidates.sorted {
                return (similarityMap[$0] ?? 0.0) > (similarityMap[$1] ?? 0.0)
            }
        }
        
        // 2. Selection Strategy (Mid-Range Distractors):
        // Safety Fallback: Only skip top matches if we have enough candidates (>= 8).
        // Otherwise, use the top matches to guarantee 4 options.
        
        let useMidRange = allCandidates.count >= 8
        
        let topTier = useMidRange 
            ? Array(allCandidates.dropFirst(3).prefix(20))
            : Array(allCandidates.prefix(20))
            
        let bottomTier = useMidRange
            ? Array(allCandidates.dropFirst(23)).shuffled()
            : Array(allCandidates.dropFirst(20)).shuffled()
        
        // Pass 1: Semantic Match (From Top 20)
        for candidate in topTier {
            if opts.count >= 4 { break }
            if candidate == targetMean { continue }
            
            opts.insert(candidate)
        }

        // Pass 2: Fallback (Relaxed Type) - From Top 20
        if opts.count < 4 {
            for candidate in topTier {
                if opts.count >= 4 { break }
                if !opts.contains(candidate) && candidate != targetMean {
                    opts.insert(candidate)
                }
            }
        }
        
        // Pass 3: Random Fill
        if opts.count < 4 {
             for candidate in bottomTier {
                 if opts.count >= 4 { break }
                 if !opts.contains(candidate) && candidate != targetMean {
                     opts.insert(candidate)
                 }
             }
        }
        
        let finalOpts = Array(opts.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }).shuffled()
        return finalOpts
    }
}
