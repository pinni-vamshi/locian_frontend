import SwiftUI
import Combine

class BrickClozeLogic: ObservableObject {
    let state: DrillState
    let session: LessonSessionManager
    
    // Data only
    let prompt: String
    let targetLanguage: String
    
    @Published var userInput: String = ""
    @Published var isCorrect: Bool?
    
    init(state: DrillState, session: LessonSessionManager) {
        self.state = state
        self.session = session
        
        // Generate Cloze Prompt: "Es mi _______"
        // If context exists, mask the target word. Otherwise fallback to meaning (Typing style).
        if let context = state.contextSentence, !context.isEmpty {
            let target = state.drillData.target
            // Case-insensitive replacement
            let masked = context.replacingOccurrences(of: target, with: "_______", options: .caseInsensitive)
            self.prompt = masked
            print("   🧩 [BrickCloze] Mode: Context Masking")
            print("      - Original: '\(context)'")
            print("      - Masked:   '\(masked)'")
        } else {
            self.prompt = state.drillData.meaning // Fallback
            print("   🧩 [BrickCloze] Mode: Meaning Fallback (No Context Available)")
        }
        
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: session.lessonData?.target_language ?? "en").english
        
        // Restore State if session already has result (Fix for button resetting)
        if session.activeState?.id == state.id, let result = session.lastAnswerCorrect {
             self.isCorrect = result
             self.userInput = session.activeInput
        }
    }
    
    var hasInput: Bool {
        !userInput.isEmpty
    }
    
    func checkAnswer() {
        guard isCorrect == nil && !userInput.isEmpty else { return }
        print("   👉 [BrickCloze] Checking answer: '\(userInput)'")
        print("      - Validating cloze [Brick Cloze]...")
        
        // Save input to session for persistence
        session.activeInput = userInput
        
        let context = ValidationContext(
            state: state,
            locale: session.targetLocale,
            session: session,
            neuralEngine: session.neuralValidator
        )
        
        // Bricks always match Foreign Word
        let validator = TypingValidator()
        let result = validator.validate(input: userInput, target: state.drillData.target, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        let isMeaningCorrect = (result == .meaningCorrect)
        
        // Update Mastery (Only this brick)
        let brickId = state.id.replacingOccurrences(of: "INT-", with: "")
        let delta = isCorrect ? 0.30 : -0.15
        session.engine.updateMastery(id: brickId, delta: delta, reason: "[Brick Cloze]")
        
        // UI Effects
        session.handleValidationResult(isCorrect: isCorrect, targetContent: state.drillData.target, isMeaningCorrect: isMeaningCorrect)
        self.isCorrect = isCorrect
    }
    
    func continueToNext() {
        session.continueToNext()
    }
    
    static func view(for state: DrillState, mode: DrillMode, session: LessonSessionManager) -> some View {
        let logic = BrickClozeLogic(state: state, session: session)
        return BrickClozeView(logic: logic)
    }
}
