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
        let threshold = MasteryFilterService.calculateThreshold(
            text: cleanTarget,
            mastery: context.state.id.isEmpty ? 0.0 : context.engine.getBlendedMastery(for: context.state.id),
            languageCode: langCode
        )
        
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
