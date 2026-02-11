import Foundation

/// Validator for speaking and verbal drills
/// Uses fuzzy matching with a configurable tolerance for transcriptions
struct VoiceValidator: DrillValidator {
    
    // Configurable tolerance for speech matching (e.g. 0.3 means 30% char difference allowed)
    let tolerance: Double = 0.3
    
    func validate(input: String, target: String, context: ValidationContext) -> ValidationResult {
        let cleanInput = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTarget = target.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Exact Match shortcut
        if cleanInput == cleanTarget {
            return .correct
        }
        
        // Fuzzy match with Levenshtein distance
        let distance = ValidationUtils.levenshteinDistance(cleanInput, cleanTarget)
        let threshold = Int(Double(cleanTarget.count) * tolerance)
        
        if distance <= threshold {
            return .correct
        } else {
            return .wrong
        }
    }
}
