import Foundation

/// Validator for multiple-choice and selection-based drills (Pure Flow)
struct MCQValidator: DrillValidator {
    func validate(input: String, target: String, context: ValidationContext) -> ValidationResult {
        let cleanInput = input.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let cleanTarget = target.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let cleanMeaning = context.state.drillData.meaning.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if cleanInput == cleanTarget {
            return .correct
        } else if cleanInput == cleanMeaning {
            return .correct
        } else {
            return .wrong
        }
    }
}
