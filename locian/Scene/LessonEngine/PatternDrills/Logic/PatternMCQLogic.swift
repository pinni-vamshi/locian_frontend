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
    
    init(state: DrillState, engine: LessonEngine) {
        self.state = state
        self.engine = engine
        self.prompt = state.drillData.target
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        // SELF-HEALING: Generate options if missing
        if let existing = state.mcqOptions, !existing.isEmpty {
            self.options = existing
        } else {
            print("      - [PatternMCQLogic] Self-healing: Generating options...")
            let candidates = engine.rawPatterns.map { $0.meaning }
            self.options = MCQOptionGenerator.generateNativeOptions(
                targetMeaning: state.drillData.meaning,
                candidates: candidates,
                validator: NeuralValidator()
            )
        }
        
        print("   🧬 [PatternMCQLogic] Initialized for \(state.id)")
        print("      - Target: \(state.drillData.target)")
        print("      - Meaning: \(state.drillData.meaning)")
        print("      - Final Options: \(self.options)")
        
        // 4. Pre-Validation Check
         // State restoration removed

    }
    
    func selectOption(_ option: String) {
        print("   👉 [PatternMCQLogic] User selected: \(option)")
        guard isCorrect == nil else { 
            print("      - Ignoring select (Already answered)")
            return 
        }
        
        // Speak the option (English meaning)
        AudioManager.shared.speak(text: option, language: "en-US")
        
        selectedOption = option
        validateSelection(option)
    }
    
    private func validateSelection(_ option: String) {
        print("      - Validating selection [Pattern MCQ]...")
        
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
        let brickMatches = ContentAnalyzer.findRelevantBricks(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: engine.lessonData?.bricks,
            targetLanguage: engine.lessonData?.target_language ?? "es"
        )
        let bricks = MasteryFilterService.resolveBricks(ids: Set(brickMatches), from: engine.lessonData?.bricks)
        
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
    }
    
    func playAudio() {
        let text = state.drillData.target
        let language = engine.lessonData?.target_language ?? "es-ES"
        AudioManager.shared.speak(text: text, language: language)
    }
    
    func continueToNext() {
        engine.orchestrator?.finishPattern()
    }
    
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine) -> some View {
        let logic = PatternMCQLogic(state: state, engine: engine)
        return PatternMCQView(logic: logic)
    }
}
