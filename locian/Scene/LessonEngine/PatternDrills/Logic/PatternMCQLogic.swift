import SwiftUI
import Combine

class PatternMCQLogic: ObservableObject {
    let state: DrillState
    let session: LessonSessionManager
    
    // Data only
    let prompt: String
    let options: [String]
    let targetLanguage: String
    
    @Published var selectedOption: String?
    @Published var isCorrect: Bool?
    
    init(state: DrillState, session: LessonSessionManager) {
        self.state = state
        self.session = session
        self.prompt = state.drillData.target
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: session.lessonData?.target_language ?? "en").english
        
        // SELF-HEALING: Generate options if missing
        if let existing = state.mcqOptions, !existing.isEmpty {
            self.options = existing
        } else {
            print("      - [PatternMCQLogic] Self-healing: Generating options...")
            let candidates = session.engine.rawPatterns.map { $0.meaning }
            self.options = MCQOptionGenerator.generateNativeOptions(
                targetMeaning: state.drillData.meaning,
                candidates: candidates,
                validator: session.neuralValidator
            )
        }
        
        print("   🧬 [PatternMCQLogic] Initialized for \(state.id)")
        print("      - Target: \(state.drillData.target)")
        print("      - Meaning: \(state.drillData.meaning)")
        print("      - Final Options: \(self.options)")
        
        // 4. Pre-Validation Check (If session says we already answered this state)
        if session.activeState?.id == state.id, let result = session.lastAnswerCorrect {
             print("      - Restoring previous answer state: \(result)")
             self.isCorrect = result
             self.selectedOption = state.drillData.target 
        }
    }
    
    func selectOption(_ option: String) {
        print("   👉 [PatternMCQLogic] User selected: \(option)")
        guard isCorrect == nil else { 
            print("      - Ignoring select (Already answered)")
            return 
        }
        selectedOption = option
        validateSelection(option)
    }
    
    private func validateSelection(_ option: String) {
        print("      - Validating selection [Pattern MCQ]...")
        
        let context = ValidationContext(
            state: state,
            locale: session.targetLocale,
            session: session,
            neuralEngine: session.neuralValidator
        )
        
        // 1. Validate the FULL Pattern using the specific MCQ Validator
        let validator = MCQValidator()
        let result = validator.validate(input: option, target: state.drillData.meaning, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        
        // 2. Perform Granular Analysis (The Ripple Effect)
        // We find which bricks are in this pattern and evaluate them based on the user's choice
        let brickMatches = ContentAnalyzer.findRelevantBricks(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: session.lessonData?.bricks,
            targetLanguage: session.lessonData?.target_language ?? "es"
        )
        let bricks = MasteryFilterService.resolveBricks(ids: Set(brickMatches), from: session.lessonData?.bricks)
        
        let rippleResults = GranularAnalyzer.analyze(
            input: option,
            target: state.drillData.meaning,
            requiredBricks: Array(bricks),
            type: .multipleChoice,
            context: context
        )
        
        // 3. Update Mastery Directly in Engine
        let delta = isCorrect ? 0.20 : -0.10
        session.engine.updateMastery(id: state.id, delta: delta, reason: "[Pattern MCQ]")
        
        // Ripple Effect on Bricks
        for res in rippleResults {
            let brickDelta = res.isCorrect ? 0.10 : -0.05
            session.engine.updateMastery(id: res.brickId, delta: brickDelta, reason: "[Ripple: MCQ]")
        }
        
        // 4. Trigger UI Side Effects in Session
        session.handleValidationResult(isCorrect: isCorrect, targetContent: state.drillData.target)
        self.isCorrect = isCorrect
    }
    
    func continueToNext() {
        session.continueToNext()
    }
    
    static func view(for state: DrillState, mode: DrillMode, session: LessonSessionManager) -> some View {
        let logic = PatternMCQLogic(state: state, session: session)
        return PatternMCQView(logic: logic)
    }
}
