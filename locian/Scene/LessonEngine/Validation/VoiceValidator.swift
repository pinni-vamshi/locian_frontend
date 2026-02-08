import Foundation

/// Validator for speaking and verbal drills
/// Uses fuzzy matching with a configurable tolerance for transcriptions
struct VoiceValidator: DrillValidator {
    
    // Configurable tolerance for speech matching (e.g. 0.3 means 30% char difference allowed)
    let tolerance: Double = 0.3
    
    func validate(input: String, target: String, context: ValidationContext) -> ValidationResult {
        let cleanInput = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTarget = target.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("\n🎙️ [VoiceValidator] Analyzing Transcription:")
        print("   -> Transcript: '\(cleanInput)'")
        print("   -> Expected: '\(cleanTarget)'")
        
        // Exact Match shortcut
        if cleanInput == cleanTarget {
            print("   ✅ [Voice] Perfect Match.")
            return .correct
        }
        
        // Fuzzy match with Levenshtein distance
        let distance = ValidationUtils.levenshteinDistance(cleanInput, cleanTarget)
        let threshold = Int(Double(cleanTarget.count) * tolerance)
        
        print("   -> Step 1: Fuzzy Matching Logic")
        print("      - Levenshtein Distance: \(distance)")
        print("      - Allowance (Tolerated Error): \(threshold) chars (\(Int(tolerance*100))%)")
        
        if distance <= threshold {
            print("   ✅ [Voice] PASSED: Match within tolerance limits.")
            return .correct
        } else {
            print("   ❌ [Voice] FAILED: Too many phonetic/literal deviations.")
            return .wrong
        }
    }
}
