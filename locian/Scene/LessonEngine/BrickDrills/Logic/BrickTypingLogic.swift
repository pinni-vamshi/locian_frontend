import SwiftUI
import Combine

class BrickTypingLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let targetLanguage: String
    
    @Published var userInput: String = "" {
        didSet {
            // Sync input state to parent for Footer Button
            patternIntroLogic?.currentBrickHasInput = !userInput.isEmpty
        }
    }
    @Published var isCorrect: Bool?
    var onComplete: ((Bool) -> Void)?
    weak var patternIntroLogic: PatternIntroLogic?  // ✅ Sync: Recap Phase reporting
    weak var practiceLogic: PatternPracticeLogic?   // ✅ Sync: Practice Phase reporting
    weak var ghostLogic: GhostModeLogic?            // ✅ Sync: Ghost Mode reporting
    
    init(state: DrillState, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.patternIntroLogic = patternIntroLogic
        self.practiceLogic = practiceLogic
        self.ghostLogic = ghostLogic
        self.onComplete = onComplete
        self.prompt = state.drillData.meaning
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
    }
    
    func bindToParent() {
        // ✅ Bridge Actions to Parent (if present)
        patternIntroLogic?.requestCheckAnswer = { [weak self] in
            self?.checkAnswer()
        }
        patternIntroLogic?.requestClearInput = { [weak self] in
            self?.clearInput()
        }
        
        // Sync initial state
        patternIntroLogic?.currentBrickHasInput = !userInput.isEmpty
    }
    
    var hasInput: Bool {
        !userInput.isEmpty
    }
    
    func clearInput() {
        print("🧹 [BrickTypingLogic] Clearing input")
        self.userInput = ""
        self.isCorrect = nil
        
        // Sync with parents
        patternIntroLogic?.currentBrickAnswered = false
        patternIntroLogic?.currentBrickCorrect = false
    }
    
    func checkAnswer() {
        guard isCorrect == nil && !userInput.isEmpty else { return }
        
        // Save input to session for persistence
        // engine.activeInput = userInput // Removed
        
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        
        // Bricks always match Foreign Word
        let validator = TypingValidator()
        let result = validator.validate(input: userInput, target: state.drillData.target, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        
        // Update Mastery (Only this brick)
        let brickId = state.id.replacingOccurrences(of: "INT-", with: "")
            .replacingOccurrences(of: "PRACTICE-MISTAKE-", with: "")
            .replacingOccurrences(of: "GHOST-", with: "")
            
        let delta = isCorrect ? 0.10 : -0.05
        engine.updateMastery(id: brickId, delta: delta)
        
        // UI Effects
        self.isCorrect = isCorrect
        
        // ✅ UNIFIED REPORTING - Notify the active parent manager
        patternIntroLogic?.markBrickAnswered(isCorrect: isCorrect, input: userInput)
        practiceLogic?.markDrillAnswered(isCorrect: isCorrect)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrect)
        
        // ✅ Localized Feedback
        playFeedback(isCorrect: isCorrect)
        
        if isCorrect {
            playAudio()
        }
    }
    
    // MARK: - 🎙️ Voice Assets (Decentralized)
    
    // MARK: - 🎙️ Voice Assets (Decentralized)
    
    // 1. Full Context
    
    
    
    
    
    
    private static var introIndex = 0
    
    static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ Using Voice Override: '\(override)'")
            AudioManager.shared.speak(segments: [.init(text: override, language: drill.voiceLanguage ?? "en-US")])
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
        AudioManager.shared.speak(segments: [.init(text: text, language: language)])
    }
    
    func continueToNext() {
        onComplete?(isCorrect ?? true)
    }
    
    @ViewBuilder
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) -> some View {
        if let introLogic = patternIntroLogic {
            // ✅ Direction A: Pattern Intro (Recap) -> Mini Interaction
            // Hiding Prompt because PatternIntroView Header + Tap Strip already shows Meaning.
            BrickTypingInteraction(drill: state, engine: engine, showPrompt: false, patternIntroLogic: introLogic, onComplete: onComplete)
                .onAppear {
                    BrickTypingLogic.playIntro(drill: state, engine: engine, mode: mode)
                }
        } else {
            // ✅ Direction B: Ghost Mode (Practice) -> Full View
            BrickTypingView(state: state, engine: engine, patternIntroLogic: patternIntroLogic, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
                .onAppear {
                    BrickTypingLogic.playIntro(drill: state, engine: engine, mode: mode)
                }
        }
    }
}
