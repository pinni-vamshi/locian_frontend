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
    private static let fullIntroVoices = [
        "Type the word for \"%@\" in %@.",
        "How do you spell \"%@\" using %@?",
        "Write the %@ translation for \"%@\".",
        "What is the %@ word for \"%@\"?",
        "Keyboard practice: \"%@\" in %@."
    ]
    
    private static let correctVoices = [
        "You are right! \"%@\" in %@ is \"%@\"",
        "Exactly. \"%@\" in %@ translates to \"%@\"",
        "Spot on. In %@, \"%@\" matches \"%@\"",
        "That's correct. We say \"%@\" for \"%@\" in %@",
        "Perfect match. \"%@\" in %@ is \"%@\""
    ]
    
    private static let wrongVoices = [
        "Actually, \"%@\" in %@ is \"%@\"",
        "The correct word for \"%@\" in %@ is \"%@\"",
        "Note the %@ translation for \"%@\": \"%@\"",
        "In %@, \"%@\" is actually \"%@\"",
        "Actually, we say \"%@\" in %@ for \"%@\""
    ]
    
    private static var introIndex = 0
    
    static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ [BrickTyping] Using Voice Override: '\(override)'")
            AudioManager.shared.speak(segments: [.init(text: override, language: drill.voiceLanguage ?? "en-US")])
            return
        }
        
        guard !drill.suppressIntroAudio else { return }
        
        let languageCode = engine.lessonData?.target_language ?? "es"
        let languageName = TargetLanguageMapping.shared.getDisplayNames(for: languageCode).english
        let meaning = drill.drillData.meaning
        
        // Sequential Iteration (1-by-1)
        let index = introIndex % fullIntroVoices.count
        let template = fullIntroVoices[index]
        introIndex += 1
        
        // Simple Interpolation
        var text = template.replacingOccurrences(of: "%@", with: meaning, range: template.range(of: "%@"))
        text = text.replacingOccurrences(of: "%@", with: languageName)
        
        AudioManager.shared.speak(segments: [.init(text: text, language: "en-US")])
    }
    
    private func playFeedback(isCorrect: Bool) {
        let answer = state.drillData.target
        let meaning = state.drillData.meaning
        let targetLang = targetLanguage
        
        let template = isCorrect ? 
            (BrickTypingLogic.correctVoices.randomElement() ?? "Correct! \"%@\" in %@ is \"%@\"") :
            (BrickTypingLogic.wrongVoices.randomElement() ?? "Actually, \"%@\" in %@ is \"%@\"")
        
        // Split at potential target placeholder
        var textToSpeak = template.replacingOccurrences(of: "%@", with: meaning, range: template.range(of: "%@"))
        if let langRange = textToSpeak.range(of: "%@") {
            textToSpeak = textToSpeak.replacingOccurrences(of: "%@", with: targetLang, range: langRange)
        }
        
        // Final split at target placeholder
        let finalComponents = textToSpeak.components(separatedBy: "\"%@\"")
        
        let langCode = self.engine.lessonData?.target_language ?? "es-ES"
        
        if finalComponents.count >= 2 {
            AudioManager.shared.speak(segments: [
                .init(text: finalComponents[0], language: "en-US"),
                .init(text: answer, language: langCode)
            ])
        } else {
            AudioManager.shared.speak(segments: [
                .init(text: isCorrect ? "That's correct. " : "Actually, it is ", language: "en-US"),
                .init(text: answer, language: langCode)
            ])
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
