import Foundation
import NaturalLanguage

/// Validator for typing, dictation, and cloze drills
/// Implements 5-Gate Logic: Exact -> Perfect Semantic -> Adaptive Semantic -> Typo Rescue -> Fail
struct TypingValidator: DrillValidator {
    
    func validate(input: String, target: String, context: ValidationContext) -> ValidationResult {
        let cleanInput = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTarget = target.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("   🔍 [LessonFlow] [Validator] Comparing Input: '\(cleanInput)' vs Target: '\(cleanTarget)'")
        
        // GATE 1: EXACT MATCH
        if cleanInput == cleanTarget {
            print("   ✅ [LessonFlow] [Typing] Gate 1: Exact Match")
            return .correct
        } else {
            // DEBUG: Log Hex to catch invisible chars
            let inputHex = cleanInput.data(using: .utf8)?.map { String(format: "%02x", $0) }.joined() ?? ""
            let targetHex = cleanTarget.data(using: .utf8)?.map { String(format: "%02x", $0) }.joined() ?? ""
            print("   🔍 [Validator] Mismatch Hex -> Input: [\(inputHex)] | Target: [\(targetHex)]")
        }
        
        // Calculate Semantic Similarity
        var similarity = 0.0
        print("   📏 [Validator] Input: '\(cleanInput)' (\(cleanInput.count) chars) | Target: '\(cleanTarget)' (\(cleanTarget.count) chars)")
        
        // Use Centralized Embedding Service
        let langCode = context.locale.language.languageCode?.identifier ?? "en"
        print("   🌍 [Validator] Using Language Code: \(langCode)")
        similarity = EmbeddingService.compare(textA: cleanInput, textB: cleanTarget, languageCode: langCode)
        
        if similarity > 0 {
            print("   📏 [LessonFlow] [Typing] Semantic Similarity: \(String(format: "%.4f", similarity))")
        }
        
        // GATE 2: NEAR-PERFECT SEMANTICS
        let strictThreshold = 1.0 - NeuralConfig.semanticStrictThreshold
        if similarity > strictThreshold {
            print("   ✅ [LessonFlow] [Typing] Gate 2: Near-Perfect Semantics (\(String(format: "%.3f", similarity)))")
            return .correct
        }
        
        // GATE 3: ADAPTIVE SEMANTIC MATCH
        // Use centralized threshold logic (formulaic) instead of bucketed buckets
        let threshold = MasteryFilterService.calculateThreshold(
            text: cleanTarget,
            mastery: context.state.id.isEmpty ? 0.0 : context.session.engine.getBlendedMastery(for: context.state.id),
            languageCode: langCode
        )
        
        if similarity >= threshold {
            print("   🟠 [LessonFlow] [Typing] Gate 3: Meaning Correct (\(String(format: "%.3f", similarity)) >= \(String(format: "%.2f", threshold)))")
            return .meaningCorrect
        }
        
        // GATE 4: TYPO RESCUE
        let distance = ValidationUtils.levenshteinDistance(cleanInput, cleanTarget)
        let maxLength = max(cleanInput.count, cleanTarget.count)
        let normalizedDistance = maxLength > 0 ? Double(distance) / Double(maxLength) : 0.0
        print("   📏 [Validator] Levenshtein Dist: \(distance) (Norm: \(String(format: "%.2f", normalizedDistance)))")
        
        if normalizedDistance <= NeuralConfig.typoTolerance {
            print("   🟠 [Gate 4: Typo] Match Found! (Norm-Dist: \(String(format: "%.2f", normalizedDistance)) <= Tolerance: \(NeuralConfig.typoTolerance))")
            return .meaningCorrect
        }
        
        // GATE 5: FAIL
        print("   ❌ [LessonFlow] [Typing] Gate 5: Wrong")
        return .wrong
    }
}
