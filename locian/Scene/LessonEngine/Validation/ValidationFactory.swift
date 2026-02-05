import Foundation

/// Factory to provide the appropriate validator for each drill type
struct ValidationFactory {
    
    static func validator(for type: DrillType) -> DrillValidator {
        switch type {
        case .multipleChoice, .listenAndTranslate:
            return MCQValidator()
            
        case .typing, .dictation, .cloze, .reorder:
            return TypingValidator()
            
        case .speaking:
            return VoiceValidator()
            
        case .vocabMatch:
            return BuilderValidator()
            
        case .masteryCheck, .vocabIntro:
            // Minimal validators for non-complex modes
            return MCQValidator()
        }
    }
}
