import Foundation
import NaturalLanguage

/// Validator for typing, dictation, and cloze drills
/// Implements 5-Gate Logic: Exact -> Perfect Semantic -> Adaptive Semantic -> Typo Rescue -> Fail
struct TypingValidator: DrillValidator {
    
    func validate(input: String, target: String, context: ValidationContext) -> ValidationResult {
        let cleanInput = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTarget = target.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // GATE 1: EXACT MATCH
        if cleanInput == cleanTarget {
            return .correct
        }
        
        // Calculate Semantic Similarity
        let langCode = context.locale.language.languageCode?.identifier ?? "en"
        let similarity = EmbeddingService.compare(textA: cleanInput, textB: cleanTarget, languageCode: langCode)
        
        // GATE 2: NEAR-PERFECT SEMANTICS
        let strictThreshold = 1.0 - NeuralConfig.semanticStrictThreshold
        if similarity > strictThreshold {
            return .correct
        }
        
        // GATE 3: ADAPTIVE SEMANTIC MATCH
        // GATE 3: ADAPTIVE SEMANTIC MATCH (V4.1)
        // Use the Semantic Cliff tolerance logic to see if this input is "relevant enough"
        // We simulate a mini-cliff check: If the input's score is within the tolerance window of the target's self-score (1.0), it passes.
        
        let mastery = context.state.id.isEmpty ? 0.0 : context.engine.getBlendedMastery(for: context.state.id)
        
        // Calculate G(M) tolerance
        // Since target is always 1.0, the spread is (1.0 - inputScore).
        // If (1.0 - inputScore) < G(M), then the input is "close enough" to be considered a valid synonym/alternative.
        // G(M) = alpha * delta * mastery -> Delta is effectively 1.0 here vs perfect match
        // Logic: 
        // - Low Mastery (0.0): Tolerance -> 0.0 (Must be exact/perfect semantic)
        // - High Mastery (1.0): Tolerance -> 0.25 (Allows looser synonyms)
        
        let tolerance = 0.25 * mastery 
        let threshold = 1.0 - tolerance
        
        if similarity >= threshold {
            return .meaningCorrect
        }
        
        // GATE 4: TYPO RESCUE
        let distance = ValidationUtils.levenshteinDistance(cleanInput, cleanTarget)
        let maxLength = max(cleanInput.count, cleanTarget.count)
        let normalizedDistance = maxLength > 0 ? Double(distance) / Double(maxLength) : 0.0
        
        if normalizedDistance <= NeuralConfig.typoTolerance {
            return .meaningCorrect
        }
        
        // GATE 5: FAIL
        return .wrong
    }
}
