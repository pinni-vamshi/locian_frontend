import Foundation

/// Validator for multiple-choice and selection-based drills (Pure Flow)
struct MCQValidator: DrillValidator {
    func validate(input: String, target: String, context: ValidationContext) -> ValidationResult {
        let cleanInput = input.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let cleanTarget = target.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let cleanMeaning = context.state.drillData.meaning.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        print("\n🔠 [MCQValidator] Comparing Selections:")
        print("   -> Chosen: '\(cleanInput)'")
        print("   -> Target: '\(cleanTarget)'")
        print("   -> Meaning: '\(cleanMeaning)'")
        
        if cleanInput == cleanTarget {
            print("   ✅ [MCQ] Match Found (Target)")
            return .correct
        } else if cleanInput == cleanMeaning {
            print("   ✅ [MCQ] Match Found (Meaning)")
            return .correct
        } else {
            print("   ❌ [MCQ] No match.")
            return .wrong
        }
    }
}
