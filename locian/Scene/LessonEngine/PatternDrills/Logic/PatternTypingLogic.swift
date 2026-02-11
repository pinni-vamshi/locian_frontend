import SwiftUI
import Combine

class PatternTypingLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let targetLanguage: String
    
    @Published var userInput: String = ""
    @Published var isCorrect: Bool?
    
    weak var lessonDrillLogic: LessonDrillLogic? // ✅ Wrapper Reference
    
    init(state: DrillState, engine: LessonEngine, lessonDrillLogic: LessonDrillLogic? = nil) {
        self.state = state
        self.engine = engine
        self.lessonDrillLogic = lessonDrillLogic
        self.prompt = state.drillData.meaning
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        // Restore State logic removed
        // if engine.activeState?.id == state.id ...
    }
    
    var hasInput: Bool {
        !userInput.isEmpty
    }
    
    func checkAnswer() {
        guard isCorrect == nil && !userInput.isEmpty else { return }
        
        // Save input to session for persistence
        // Save input to session for persistence
        // engine.activeInput = userInput // Removed
        
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        
        // 1. Validate the FULL Pattern using Typing Validator
        let validator = TypingValidator()
        let result = validator.validate(input: userInput, target: state.drillData.target, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)

        
        // 2. Perform Granular Analysis (The Ripple Effect)
        // ✅ NOW USING GROUP-SPECIFIC BRICKS ONLY
        let brickMatches = ContentAnalyzer.findRelevantBricks(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: engine.activeGroupBricks,
            targetLanguage: engine.lessonData?.target_language ?? "es"
        )
        let bricks = MasteryFilterService.resolveBricks(ids: Set(brickMatches), from: engine.activeGroupBricks)
        
        let rippleResults = GranularAnalyzer.analyze(
            input: userInput,
            target: state.drillData.target,
            requiredBricks: Array(bricks),
            type: .typing,
            context: context
        )
        
        // 3. Update Mastery Directly in Engine
        let delta = isCorrect ? 0.30 : -0.15
        engine.updateMastery(id: state.id, delta: delta)
        
        // Ripple Effect on Bricks
        for res in rippleResults {
            let brickDelta = res.isCorrect ? 0.10 : -0.05
            engine.updateMastery(id: res.brickId, delta: brickDelta)
        }
        
        // 4. Trigger UI Side Effects
        self.isCorrect = isCorrect
        playAudio()
        
        // ✅ Notify Wrapper
        lessonDrillLogic?.markDrillAnswered(isCorrect: isCorrect)
    }
    
    func playAudio() {
        let text = state.drillData.target
        let language = engine.lessonData?.target_language ?? "es-ES"
        AudioManager.shared.speak(text: text, language: language)
    }
    
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, lessonDrillLogic: LessonDrillLogic? = nil) -> some View {
        // View now owns the logic creation via StateObject
        return PatternTypingView(state: state, engine: engine, lessonDrillLogic: lessonDrillLogic)
    }
}
