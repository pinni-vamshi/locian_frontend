import Foundation
import NaturalLanguage

/// Validator for typing, dictation, and cloze drills
/// Implements 5-Gate Logic: Exact -> Perfect Semantic -> Adaptive Semantic -> Typo Rescue -> Fail
struct TypingValidator: DrillValidator {
    
    func validate(input: String, target: String, context: ValidationContext) -> ValidationResult {
        print("\n🔬 [TypingValidator] Starting 5-Gate Validation Sequence:")
        print("   -> Raw Input: '\(input)'")
        print("   -> Target: '\(target)'")
        
        let cleanInput = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTarget = target.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("   -> Step 1: Pre-Processing Comparison:")
        print("      - Clean Input: '\(cleanInput)'")
        print("      - Clean Target: '\(cleanTarget)'")
        
        // GATE 1: EXACT MATCH
        print("   🚪 [Gate 1] Checking Exact Match...")
        if cleanInput == cleanTarget {
            print("   ✅ [Gate 1] PASSED: Identical strings.")
            return .correct
        } else {
            print("   ❌ [Gate 1] FAILED: Content mismatch.")
            // DEBUG: Log Hex to catch invisible chars
            let inputHex = cleanInput.data(using: .utf8)?.map { String(format: "%02x", $0) }.joined() ?? ""
            let targetHex = cleanTarget.data(using: .utf8)?.map { String(format: "%02x", $0) }.joined() ?? ""
            print("      🔍 [Hex Dump] Input: [\(inputHex)] | Target: [\(targetHex)]")
        }
        
        // Calculate Semantic Similarity
        let langCode = context.locale.language.languageCode?.identifier ?? "en"
        print("   🌍 [TypingValidator] Semantic Engine: Language set to '\(langCode)'")
        
        let similarity = EmbeddingService.compare(textA: cleanInput, textB: cleanTarget, languageCode: langCode)
        print("   📏 [TypingValidator] Scored Similarity: \(String(format: "%.4f", similarity))")
        
        // GATE 2: NEAR-PERFECT SEMANTICS
        let strictThreshold = 1.0 - NeuralConfig.semanticStrictThreshold
        print("   🚪 [Gate 2] Checking Near-Perfect Semantic Threshold (\(String(format: "%.3f", strictThreshold)))...")
        if similarity > strictThreshold {
            print("   ✅ [Gate 2] PASSED: High-Confidence Semantic Match.")
            return .correct
        }
        print("   ❌ [Gate 2] FAILED: Confidence below threshold.")
        
        // GATE 3: ADAPTIVE SEMANTIC MATCH
        let threshold = MasteryFilterService.calculateThreshold(
            text: cleanTarget,
            mastery: context.state.id.isEmpty ? 0.0 : context.engine.getBlendedMastery(for: context.state.id),
            languageCode: langCode
        )
        
        print("   🚪 [Gate 3] Checking Adaptive Semantic Threshold (\(String(format: "%.3f", threshold)))...")
        if similarity >= threshold {
            print("   ✅ [Gate 3] PASSED (Meaning Match): \(String(format: "%.3f", similarity)) >= \(String(format: "%.2f", threshold))")
            return .meaningCorrect
        }
        print("   ❌ [Gate 3] FAILED: Semantic distance too large.")
        
        // GATE 4: TYPO RESCUE
        print("   🚪 [Gate 4] Checking Levenshtein/Typo Tolerance...")
        let distance = ValidationUtils.levenshteinDistance(cleanInput, cleanTarget)
        let maxLength = max(cleanInput.count, cleanTarget.count)
        let normalizedDistance = maxLength > 0 ? Double(distance) / Double(maxLength) : 0.0
        
        print("      - Raw Distance: \(distance)")
        print("      - Normalized: \(String(format: "%.2f", normalizedDistance))")
        print("      - Tolerance Limit: \(NeuralConfig.typoTolerance)")
        
        if normalizedDistance <= NeuralConfig.typoTolerance {
            print("   ✅ [Gate 4] PASSED: Rescue via Typo Tolerance.")
            return .meaningCorrect
        }
        print("   ❌ [Gate 4] FAILED: Character mutations excessive.")
        
        // GATE 5: FAIL
        print("   🚪 [Gate 5] TOTAL FAILURE: Exhausted all rescue attempts.")
        return .wrong
    }
}
