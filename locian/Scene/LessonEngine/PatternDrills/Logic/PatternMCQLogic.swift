import SwiftUI
import Combine

class PatternMCQLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let phonetic: String?
    let options: [String]
    let targetLanguage: String
    
    @Published var selectedOption: String?
    @Published var isCorrect: Bool?
    var isAnswered: Bool { isCorrect != nil }
    
    var onComplete: ((Bool) -> Void)?
    weak var patternIntroLogic: PatternIntroLogic?
    weak var practiceLogic: PatternPracticeLogic?
    weak var ghostLogic: GhostModeLogic?
    
    init(state: DrillState, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.patternIntroLogic = patternIntroLogic
        self.practiceLogic = practiceLogic
        self.ghostLogic = ghostLogic
        self.onComplete = onComplete
        self.prompt = state.drillData.target
        self.phonetic = state.drillData.phonetic
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
        // ✅ CRITICAL: Do NOT speak the native language (English) meaning
        // AudioManager.shared.speak(text: option, language: "en-US")
        
        guard isCorrect == nil else { 
            return 
        }
        
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
        
        // 2. Perform Autonomous Granular Analysis (The Ripple Effect)
        // This directly updates brick mastery in the engine (+0.10 / -0.05)
        GranularAnalyzer.processGranularMastery(
            engine: engine,
            target: state.drillData.target,
            meaning: state.drillData.meaning,
            userInput: option,
            type: .multipleChoice,
            context: context
        )
        
        // Update Mastery (Only this pattern)
        // REDUCED DELTA: 0.15 (Gradual progression)
        let delta = isCorrect ? 0.15 : -0.05
        engine.updateMastery(id: state.patternId, delta: delta)
        
        // 4. Trigger UI Side Effects
        self.isCorrect = isCorrect
        
        // ✅ Localized Feedback
        playFeedback(isCorrect: isCorrect)
        
        // Match standard behavior: Play target audio on correct
        // REMOVED per user request to avoid redundancy (Feedback already speaks it)
        /*
        if isCorrect {
            playAudio()
        }
        */
        
        // ✅ Notify Wrapper
        patternIntroLogic?.markBrickAnswered(isCorrect: isCorrect, input: option)
        practiceLogic?.markDrillAnswered(isCorrect: isCorrect)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrect)
    }
    
    func continueToNext() {
        onComplete?(isCorrect ?? true)
    }
    
    // MARK: - 🎙️ Voice Assets (Decentralized)
    
    // 1. Full Context
    
    

    
    
    // 3. Concise Feedback
    
    
    static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ Using Voice Override: '\(override)'")
            AudioManager.shared.speak(text: override, language: drill.voiceLanguage ?? "en-US")
        }
    }
    
    private func playFeedback(isCorrect: Bool) {
        if isCorrect {
            playAudio()
        }
    }
    
    func playAudio() {
        let text = state.drillData.target
        let language = engine.lessonData?.target_language ?? "es-ES"
        AudioManager.shared.speak(text: text, language: language)
    }
    
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) -> some View {
        // View now owns the logic creation via StateObject
        return PatternMCQView(state: state, engine: engine, patternIntroLogic: patternIntroLogic, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
            .onAppear {
                PatternMCQLogic.playIntro(drill: state, engine: engine, mode: mode)
            }
    }
}
