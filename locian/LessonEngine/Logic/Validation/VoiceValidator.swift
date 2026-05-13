import Foundation

/// Validator for speaking and verbal drills
/// Uses fuzzy matching with a configurable tolerance for transcriptions
struct VoiceValidator: DrillValidator {
    
    // Configurable tolerance for speech matching (e.g. 0.35 means 35% char difference allowed)
    let tolerance: Double = 0.35
    
    func validate(input: String, target: String, context: ValidationContext) -> ValidationResult {
        let cleanInput = normalizeForSpeech(input)
        let cleanTarget = normalizeForSpeech(target)
        
        // Exact Match shortcut
        if cleanInput == cleanTarget {
            return .correct
        }
        
        // Word-level overlap check (speech errors are word-level, not character-level)
        let inputWords = cleanInput.components(separatedBy: " ").filter { !$0.isEmpty }
        let targetWords = cleanTarget.components(separatedBy: " ").filter { !$0.isEmpty }
        
        if !targetWords.isEmpty {
            let matchCount = targetWords.filter { targetWord in
                inputWords.contains { inputWord in
                    // Allow minor per-word fuzziness (1 edit per word)
                    ValidationUtils.levenshteinDistance(inputWord, targetWord) <= max(1, targetWord.count / 4)
                }
            }.count
            
            let wordOverlap = Double(matchCount) / Double(targetWords.count)
            if wordOverlap >= 0.75 {
                print("🔍 [VoiceValidator] Word overlap PASS: \(matchCount)/\(targetWords.count) words matched (\(String(format: "%.0f", wordOverlap * 100))%)")
                return .correct
            }
        }
        
        // Character-level fuzzy match as fallback (for single words / short targets)
        let distance = ValidationUtils.levenshteinDistance(cleanInput, cleanTarget)
        let threshold = Int(Double(cleanTarget.count) * tolerance)
        
        let isMatch = distance <= threshold
        print("🔍 [VoiceValidator] Input: '\(cleanInput)' | Target: '\(cleanTarget)' | Result: \(isMatch ? "CORRECT" : "WRONG") (Distance: \(distance), Threshold: \(threshold))")
        
        return isMatch ? .correct : .wrong
    }
    
    /// Normalize text for speech comparison:
    /// - Lowercase, trim whitespace
    /// - Strip punctuation
    /// - Fold diacritics (é→e, ñ→n) for comparison tolerance
    /// - Normalize Unicode (NFC)
    private func normalizeForSpeech(_ text: String) -> String {
        var result = text
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .precomposedStringWithCanonicalMapping // Unicode NFC normalization
        
        // Strip punctuation (speech recognizers often add/omit these)
        result = result.components(separatedBy: .punctuationCharacters).joined()
        
        // Collapse multiple spaces
        result = result.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        // Fold diacritics for tolerance (café → cafe)
        result = result.folding(options: .diacriticInsensitive, locale: nil)
        
        return result
    }
}
