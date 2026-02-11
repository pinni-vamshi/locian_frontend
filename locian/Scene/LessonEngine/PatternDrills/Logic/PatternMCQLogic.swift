import SwiftUI
import Combine

class PatternMCQLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let options: [String]
    let targetLanguage: String
    
    @Published var selectedOption: String?
    @Published var isCorrect: Bool?
    
    weak var lessonDrillLogic: LessonDrillLogic?
    
    init(state: DrillState, engine: LessonEngine, lessonDrillLogic: LessonDrillLogic? = nil) {
        self.state = state
        self.engine = engine
        self.lessonDrillLogic = lessonDrillLogic
        self.prompt = state.drillData.target
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        // SELF-HEALING: Generate options if missing
        if let existing = state.mcqOptions, !existing.isEmpty {
            self.options = existing
        } else {
            let candidates = engine.allPatterns.map { $0.meaning }  // ✅ Use ALL groups
            self.options = MCQOptionGenerator.generateNativeOptions(
                targetMeaning: state.drillData.meaning,
                candidates: candidates,
                validator: NeuralValidator()
            )
        }
        
        // 4. Pre-Validation Check
         // State restoration removed

    }
    
    func selectOption(_ option: String) {
        guard isCorrect == nil else { 
            return 
        }
        
        // Speak the option (English meaning)
        AudioManager.shared.speak(text: option, language: "en-US")
        
        selectedOption = option
        validateSelection(option)
    }
    
    private func validateSelection(_ option: String) {
        
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        
        // 1. Validate the FULL Pattern using the specific MCQ Validator
        let validator = MCQValidator()
        let result = validator.validate(input: option, target: state.drillData.meaning, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        
        // 2. Perform Granular Analysis (The Ripple Effect)
        // We find which bricks are in this pattern and evaluate them based on the user's choice
        // ✅ NOW USING GROUP-SPECIFIC BRICKS ONLY
        let brickMatches = ContentAnalyzer.findRelevantBricks(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: engine.activeGroupBricks,
            targetLanguage: engine.lessonData?.target_language ?? "es"
        )
        let bricks = MasteryFilterService.resolveBricks(ids: Set(brickMatches), from: engine.activeGroupBricks)
        
        let rippleResults = GranularAnalyzer.analyze(
            input: option,
            target: state.drillData.meaning,
            requiredBricks: Array(bricks),
            type: .multipleChoice,
            context: context
        )
        
        // 3. Update Mastery Directly in Engine
        let delta = isCorrect ? 0.20 : -0.10
        engine.updateMastery(id: state.id, delta: delta)
        
        // Ripple Effect on Bricks
        for res in rippleResults {
            let brickDelta = res.isCorrect ? 0.10 : -0.05
            engine.updateMastery(id: res.brickId, delta: brickDelta)
        }
        
        // 4. Trigger UI Side Effects
        self.isCorrect = isCorrect
        
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
        return PatternMCQView(state: state, engine: engine, lessonDrillLogic: lessonDrillLogic)
    }
}
