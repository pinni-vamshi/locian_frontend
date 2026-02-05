import SwiftUI
import Combine

class BrickMCQLogic: ObservableObject {
    let state: DrillState
    let session: LessonSessionManager
    
    // Data only - no UI strings
    let options: [String]
    let prompt: String
    let targetLanguage: String
    
    @Published var selectedOption: String?
    @Published var isCorrect: Bool?
    
    init(state: DrillState, session: LessonSessionManager) {
        self.state = state
        self.session = session
        let targetLanguageCode = session.lessonData?.target_language ?? "es"
        
        // BRICK MCQ: Meaning (L1) -> Word (L2)
        // This provides a clear "Discovery" flow:
        // "How do I say [English]?" -> Select [Spanish]
        self.prompt = state.drillData.meaning
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: targetLanguageCode).english
        
        // 2. Generate Options
        if let existing = state.mcqOptions {
            self.options = existing
        } else {
            print("   🧱 [BrickMCQLogic] Mode: L1->L2 | Generating options...")
            
            let allBricks = (session.lessonData?.bricks?.constants ?? []) + 
                           (session.lessonData?.bricks?.variables ?? []) + 
                           (session.lessonData?.bricks?.structural ?? [])
            
            // Meaning (L1) prompt -> Word (L2) options
            let candidates = Array(Set(allBricks.map { $0.word }))
            self.options = MCQOptionGenerator.generateOptions(
                target: state.drillData.target,
                candidates: candidates,
                targetLanguage: targetLanguageCode,
                validator: session.neuralValidator
            )
        }
        
        // 3. Pre-Validation Check
        if session.activeState?.id == state.id, let result = session.lastAnswerCorrect {
             self.isCorrect = result
             self.selectedOption = state.drillData.target
        }
    }
    
    var correctOption: String {
        return state.drillData.target
    }
    
    func selectOption(_ option: String) {
        guard isCorrect == nil else { return }
        print("   👉 [BrickMCQ] User selected: \(option)")
        selectedOption = option
        validateSelection(option)
    }
    
    private func validateSelection(_ option: String) {
        let actualTarget = state.drillData.target
        
        print("      - Validating selection [Brick MCQ] (L2-Target)...")
        
        let context = ValidationContext(
            state: state,
            locale: session.targetLocale,
            session: session,
            neuralEngine: session.neuralValidator
        )
        
        let validator = MCQValidator()
        let result = validator.validate(input: option, target: actualTarget, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        
        // Update Mastery (Only this brick)
        let brickId = state.id.replacingOccurrences(of: "INT-", with: "")
        let delta = isCorrect ? 0.20 : -0.10
        session.engine.updateMastery(id: brickId, delta: delta, reason: "[Brick MCQ]")
        
        // UI Effects
        session.handleValidationResult(isCorrect: isCorrect, targetContent: state.drillData.target)
        self.isCorrect = isCorrect
    }
    
    func continueToNext() {
        session.continueToNext()
    }
    
    static func view(for state: DrillState, mode: DrillMode, session: LessonSessionManager) -> some View {
        let logic = BrickMCQLogic(state: state, session: session)
        return BrickMCQView(logic: logic)
    }
}
