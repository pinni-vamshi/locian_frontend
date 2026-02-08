import SwiftUI
import Combine

class BrickTypingLogic: ObservableObject {
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
        self.prompt = state.drillData.meaning
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: session.lessonData?.target_language ?? "en").english
        
        // Restore State if session already has result
        if session.activeState?.id == state.id, let result = session.lastAnswerCorrect {
             self.isCorrect = result
             self.userInput = session.activeInput
             print("   ⌨️ [BrickTyping] Restored State: '\(userInput)' (Correct: \(result))")
        }
        
        print("   ⌨️ [BrickTyping] Init (Prompt: '\(prompt)', Target: '\(state.drillData.target)')")
    }
    
    var hasInput: Bool {
        !userInput.isEmpty
    }
    
    func checkAnswer() {
        guard isCorrect == nil && !userInput.isEmpty else { return }
        print("   👉 [BrickTyping] Checking answer: '\(userInput)'")
        print("      - Validating typing [Brick Typing]...")
        
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
        session.engine.updateMastery(id: brickId, delta: delta, reason: "[Brick Typing]")
        
        // UI Effects
        session.handleValidationResult(isCorrect: isCorrect, targetContent: state.drillData.target, isMeaningCorrect: isMeaningCorrect)
        self.isCorrect = isCorrect
    }
    
    func continueToNext() {
        session.continueToNext()
    }
    
    static func view(for state: DrillState, mode: DrillMode, session: LessonSessionManager) -> some View {
        let logic = BrickTypingLogic(state: state, session: session)
        return BrickTypingView(logic: logic)
    }
}
