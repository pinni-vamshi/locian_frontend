import Foundation

/// Validator for sentence builders and granular pattern analysis
/// Determines which required bricks were successfully used by the user.
struct BuilderValidator: DrillValidator {
    
    func validate(input: String, target: String, context: ValidationContext) -> ValidationResult {
        // Sentence Builder usually has an exact match requirement for the pattern result,
        // but it provides granular feedback for bricks.
        
        // 1. Exact Match check for the overall pattern
        let cleanInput = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTarget = target.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanInput == cleanTarget {
            return .correct
        }
        
        // 2. Semantic Match check for the overall pattern using TypingValidator
        if context.neuralEngine != nil {
            let typingValidation = TypingValidator().validate(input: input, target: target, context: context)
            return typingValidation
        }
        
        return .wrong
    }
}
