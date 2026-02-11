//
//  GranularAnalyzer.swift
//  locian
//
//  Unified logic for analyzing which bricks were used correctly in a pattern response.
//

import Foundation

struct GranularAnalyzer {
    
    /// Analyzes a response to determine which bricks were used correctly
    static func analyze(
        input: String,
        target: String,
        requiredBricks: [BrickItem],
        type: DrillType,
        context: ValidationContext
    ) -> [BrickAnalysisResult] {
        
        let responseTokens = GranularAnalyzerCore.parseTextTokens(input)
        let validator = ValidationFactory.validator(for: type)
        var results: [BrickAnalysisResult] = []
        
        for brick in requiredBricks {
            // DYNAMIC TARGET: For MCQs, the response is in English (Meaning). 
            // For others (Speaking/Typing), it's in the Target Language (Word).
            let isMeaningBase = (type == .multipleChoice || type == .vocabMatch)
            let primaryTarget = isMeaningBase ? brick.meaning.lowercased() : brick.word.lowercased()
            let secondaryTarget = isMeaningBase ? brick.word.lowercased() : brick.meaning.lowercased()
            
            // 1. Find the best match in the user's response tokens
            let match = GranularAnalyzerCore.findBestSemanticMatch(
                brickWord: primaryTarget,
                responseTokens: responseTokens,
                validator: context.neuralEngine,
                threshold: 0.65 
            )
            
            // 2. Double check against secondary target (just in case of mixed input or builder modes)
            let secondaryMatch = GranularAnalyzerCore.findBestSemanticMatch(
                brickWord: secondaryTarget,
                responseTokens: responseTokens,
                validator: context.neuralEngine,
                threshold: 0.65
            )
            
            let bestMatch = (match.similarity >= secondaryMatch.similarity) ? match : secondaryMatch
            let bestTarget = (match.similarity >= secondaryMatch.similarity) ? primaryTarget : secondaryTarget
            
            // 3. Delegate to the ACTUAL mode-specific validator for the final verdict
            let result = validator.validate(
                input: bestMatch.matchedToken,
                target: bestTarget,
                context: context
            )
            
            let isCorrect = (result == .correct || result == .meaningCorrect)
            
            results.append(BrickAnalysisResult(
                brickId: brick.id ?? brick.word,
                word: brick.word,
                isCorrect: isCorrect,
                similarity: bestMatch.similarity,
                masteryChange: isCorrect ? 1.0 : 0.0 
            ))
        }
        
        return results
    }
}
