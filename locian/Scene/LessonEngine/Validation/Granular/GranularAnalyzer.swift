//
//  GranularAnalyzer.swift
//  locian
//
//  Unified logic for analyzing which bricks were used correctly in a pattern response.
//

import Foundation

struct GranularAnalyzer {
    /// 🛡️ POSITION-BASED RIPPLE EFFECT: Centralized mastery updates for bricks within a pattern.
    /// This uses the "Anchor Model" to accurately map user input to specific brick positions in the solution.
    static func processGranularMastery(
        engine: LessonEngine,
        target: String,
        meaning: String,
        userInput: String,
        type: DrillType,
        context: ValidationContext
    ) {
        // 1. Identify which bricks belong to this pattern solution
        let brickMatches = ContentAnalyzer.findRelevantBricks(
            in: target,
            meaning: meaning,
            bricks: engine.activeGroupBricks,
            targetLanguage: engine.lessonData?.target_language ?? "es"
        )
        let bricks = MasteryFilterService.resolveBricks(ids: Set(brickMatches), from: engine.activeGroupBricks)
        
        // 2. The Anchor: Tokenize the official Solution and the User Input
        // We check against 'target' for foreign modes and 'meaning' for MCQ
        let solutionText = (type == .multipleChoice || type == .vocabMatch) ? meaning : target
        let solutionTokens = parseTextTokens(solutionText)
        let inputTokens = parseTextTokens(userInput)
        
        // 3. The Map: Find where each brick sits in the Solution Anchor
        for brick in bricks {
            let brickSearchTerm = (type == .multipleChoice || type == .vocabMatch) ? brick.meaning : brick.word
            
            // Find the index of this brick in the solution tokens (handles duplicates)
            // Note: In a professional implementation, we'd map whole sentences, 
            // but for this ripple effect, we find the "Best Anchor" match.
            var bestAnchorToken = ""
            var maxSim: Double = 0.0
            
            for sToken in solutionTokens {
                let sim = SemanticMatcher.calculatePairSimilarity(
                    target: brickSearchTerm.lowercased(),
                    candidate: sToken.lowercased(),
                    validator: context.neuralEngine,
                    silent: true
                )
                if sim > maxSim {
                    maxSim = sim
                    bestAnchorToken = sToken
                }
            }
            
            // 4. Verify: Now check if the user's input matches that SPECIFIC anchor word
            var userSim: Double = 0.0
            for iToken in inputTokens {
                let sim = SemanticMatcher.calculatePairSimilarity(
                    target: bestAnchorToken.lowercased(),
                    candidate: iToken.lowercased(),
                    validator: context.neuralEngine,
                    silent: true
                )
                if sim > userSim {
                    userSim = sim
                }
            }
            
            // Verdict: Strictly check against the Anchor token with 0.65 similarity (Thematic Vibe)
            let isCorrect = userSim >= 0.65
            
            // 5. Direct Engine Connection: +10% success / -5% failure
            let delta = isCorrect ? 0.10 : -0.05
            engine.updateMastery(id: brick.id, delta: delta)
            
            print("⚓ Anchor Analysis [\(brick.word)]: \(isCorrect ? "✅ +0.10" : "❌ -0.05") (Anchor: '\(bestAnchorToken)' -> User Match: \(String(format: "%.2f", userSim)))")
        }
    }
    
    // MARK: - Internal Utilities (Merged from Core)
    
    static func parseTextTokens(_ text: String) -> [String] {
        let cleaned = text.lowercased()
        return cleaned
            .components(separatedBy: .punctuationCharacters).joined()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
    }
}
