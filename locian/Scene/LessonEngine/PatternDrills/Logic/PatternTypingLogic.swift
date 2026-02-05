import SwiftUI
import Combine

class PatternTypingLogic: ObservableObject {
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
        }
    }
    
    var hasInput: Bool {
        !userInput.isEmpty
    }
    
    func checkAnswer() {
        guard isCorrect == nil && !userInput.isEmpty else { return }
        print("      - Validating typing [Pattern Typing]...")
        
        // Save input to session for persistence
        session.activeInput = userInput
        
        let context = ValidationContext(
            state: state,
            locale: session.targetLocale,
            session: session,
            neuralEngine: session.neuralValidator
        )
        
        // 1. Validate the FULL Pattern using Typing Validator
        let validator = TypingValidator()
        let result = validator.validate(input: userInput, target: state.drillData.target, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        let isMeaningCorrect = (result == .meaningCorrect)
        
        // 2. Perform Granular Analysis (The Ripple Effect)
        let brickMatches = ContentAnalyzer.findRelevantBricks(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: session.lessonData?.bricks,
            targetLanguage: session.lessonData?.target_language ?? "es"
        )
        let bricks = MasteryFilterService.resolveBricks(ids: Set(brickMatches), from: session.lessonData?.bricks)
        
        let rippleResults = GranularAnalyzer.analyze(
            input: userInput,
            target: state.drillData.target,
            requiredBricks: Array(bricks),
            type: .typing,
            context: context
        )
        
        // 3. Update Mastery Directly in Engine
        let delta = isCorrect ? 0.30 : -0.15
        session.engine.updateMastery(id: state.id, delta: delta, reason: "[Pattern Typing]")
        
        // Ripple Effect on Bricks
        for res in rippleResults {
            let brickDelta = res.isCorrect ? 0.10 : -0.05
            session.engine.updateMastery(id: res.brickId, delta: brickDelta, reason: "[Ripple: Typing]")
        }
        
        // 4. Trigger UI Side Effects in Session
        session.handleValidationResult(isCorrect: isCorrect, targetContent: state.drillData.target, isMeaningCorrect: isMeaningCorrect)
        self.isCorrect = isCorrect
    }
    
    func continueToNext() {
        session.continueToNext()
    }
    
    static func view(for state: DrillState, mode: DrillMode, session: LessonSessionManager) -> some View {
        return PatternTypingView(state: state, session: session)
    }
}
