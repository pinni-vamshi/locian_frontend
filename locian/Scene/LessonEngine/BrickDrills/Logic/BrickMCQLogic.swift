import SwiftUI
import Combine

class BrickMCQLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only - no UI strings
    let options: [String]
    let prompt: String
    let targetLanguage: String
    
    @Published var selectedOption: String?
    @Published var isCorrect: Bool?
    
    var onComplete: (() -> Void)?
    weak var patternIntroLogic: PatternIntroLogic?  // ✅ NEW: Reference to notify pattern intro
    
    init(state: DrillState, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil) {
        self.state = state
        self.engine = engine
        self.patternIntroLogic = patternIntroLogic
        let targetLanguageCode = engine.lessonData?.target_language ?? "es"
        
        // BRICK MCQ: Meaning (L1) -> Word (L2)
        // This provides a clear "Discovery" flow:
        // "How do I say [English]?" -> Select [Spanish]
        self.prompt = state.drillData.meaning
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: targetLanguageCode).english
        
        // 2. Generate Options
        if let existing = state.mcqOptions {
            self.options = existing
        } else {
            // ✅ Use engine.allBricks to get bricks from ALL groups
            let allBricksData = engine.allBricks
            let allBricks = (allBricksData?.constants ?? []) + 
                           (allBricksData?.variables ?? []) + 
                           (allBricksData?.structural ?? [])
            
            // Meaning (L1) prompt -> Word (L2) options
            let candidates = Array(Set(allBricks.map { $0.word }))
            
            self.options = MCQOptionGenerator.generateNativeOptions(
                targetMeaning: state.drillData.target,
                candidates: candidates,
                validator: NeuralValidator()
            )
        }
    }
    
    var correctOption: String {
        return state.drillData.target
    }
    
    func selectOption(_ option: String) {
        guard isCorrect == nil else { return }
        
        // Speak what the user JUST tapped
        let language = engine.lessonData?.target_language ?? "es-ES"
        AudioManager.shared.speak(text: option, language: language)
        
        selectedOption = option
        validateSelection(option)
    }
    
    private func validateSelection(_ option: String) {
        let actualTarget = state.drillData.target
        
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        
        let validator = MCQValidator()
        let result = validator.validate(input: option, target: actualTarget, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        
        // ✅ PUBLISH TO VIEW - This triggers UI updates (colors, continue button)
        self.isCorrect = isCorrect
        
        // ✅ NOTIFY PATTERN INTRO - Tell parent view to show continue button
        patternIntroLogic?.markBrickAnswered(isCorrect: isCorrect)
        
        // Update Mastery (Only this brick)
        let brickId = state.id.replacingOccurrences(of: "INT-", with: "")
        let delta = isCorrect ? 0.20 : -0.10
        engine.updateMastery(id: brickId, delta: delta)
    }
    
    func playAudio() {
        let text = state.drillData.target
        let language = engine.lessonData?.target_language ?? "es-ES"
        AudioManager.shared.speak(text: text, language: language)
    }
    
    func continueToNext() {
        if let onComplete = onComplete {
            onComplete()
        } else {
            engine.orchestrator?.finishPattern()
        }
    }
    
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, onComplete: (() -> Void)? = nil) -> some View {
        let logic = BrickMCQLogic(state: state, engine: engine)
        logic.onComplete = onComplete
        return BrickMCQView(logic: logic)
    }
}
