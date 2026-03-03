import SwiftUI
import Combine

class BrickVoiceLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let targetLanguage: String
    
    @Published var isCorrect: Bool?
    @Published var isAudioPlaying: Bool = false
    var onComplete: ((Bool) -> Void)?
    weak var patternIntroLogic: PatternIntroLogic?  // ✅ Sync: Recap Phase reporting
    weak var practiceLogic: PatternPracticeLogic?   // ✅ Sync: Practice Phase reporting
    weak var ghostLogic: GhostModeLogic?            // ✅ Sync: Ghost Mode reporting
    private var cancellables = Set<AnyCancellable>()
    
    // Local Speech Recognizer (or Shared Singleton)
    // Since we removed SessionManager, we use the shared instance directly or pass it in.
    // For now, let's assume we use the global SpeechRecognizer or one attached to Engine.
    private let speechRecognizer = SpeechRecognizer.shared 
    
    init(state: DrillState, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.patternIntroLogic = patternIntroLogic
        self.practiceLogic = practiceLogic
        self.ghostLogic = ghostLogic
        self.onComplete = onComplete
        self.prompt = state.drillData.target
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        speechRecognizer.reset()
        
        speechRecognizer.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in 
                self?.objectWillChange.send() 
                // ✅ Sync Input State for Footer Button
                if let self = self {
                    self.patternIntroLogic?.currentBrickHasInput = !self.speechRecognizer.recognizedText.isEmpty
                }
            }
            .store(in: &cancellables)
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
        patternIntroLogic?.currentBrickHasInput = !recognizedText.isEmpty
    }
    
    // Voice state exposed to view
    var isRecording: Bool {
        return speechRecognizer.isRecording
    }
    
    var recognizedText: String {
        return speechRecognizer.recognizedText
    }
    
    var hasInput: Bool {
        !recognizedText.isEmpty
    }
    
    func triggerSpeechRecognition() {
        print("🎙️ [BrickVoiceLogic] Starting speech recognition")
        
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        } else {
            PermissionsService.shared.ensureVoiceAccess { granted in
                guard granted else { 
                    return 
                }
                
                // Use default locale if not set in engine (TODO: Move targetLocale to Engine)
                try? self.speechRecognizer.startRecording()
            }
        }
    }
    
    func clearInput() {
        print("🧹 [BrickVoiceLogic] Clearing input")
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        }
        speechRecognizer.reset()
        self.isCorrect = nil
        
        // Sync with parents
        patternIntroLogic?.currentBrickAnswered = false
        patternIntroLogic?.currentBrickCorrect = false
    }
    
    func checkAnswer() {
        guard isCorrect == nil else { return }
        
        // LOGIC CORRECT: Stop recording BEFORE checking answer and playing feedback
        // This prevents the speaker and mic from fighting during validation
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        }
        
        let input = speechRecognizer.recognizedText
        
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        
        // Bricks always match Foreign Word
        let validator = VoiceValidator()
        let result = validator.validate(input: input, target: state.drillData.target, context: context)
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
        patternIntroLogic?.markBrickAnswered(isCorrect: isCorrect, input: input) // FIXED: input var exists
        practiceLogic?.markDrillAnswered(isCorrect: isCorrect)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrect)
        
        // ✅ Localized Feedback
        playFeedback(isCorrect: isCorrect)
        
        playAudio()
    }
    
    // MARK: - 🎙️ Voice Assets (Decentralized)
    
    // MARK: - 🎙️ Voice Assets (Decentralized)
    
    // 1. Full Context
    private static let fullIntroVoices = [
        "Say \"%@\" in %@.",
        "How do you pronounce the %@ word for \"%@\"?",
        "Speak the word for \"%@\" in %@.",
        "Your turn: Say \"%@\" in %@.",
        "Let's hear \"%@\" in %@."
    ]
    
    private static let correctVoices = [
        "You are right! \"%@\" in %@ is \"%@\"",
        "Exactly. \"%@\" in %@ translates to \"%@\"",
        "Spot on. In %@, \"%@\" matches \"%@\"",
        "That's correct. We say \"%@\" for \"%@\" in %@",
        "Perfect match. \"%@\" in %@ is \"%@\""
    ]
    
    // 3. Concise Feedback
    private static let wrongVoices = [
        "Actually, \"%@\" in %@ is \"%@\"",
        "The correct word for \"%@\" in %@ is \"%@\"",
        "Note the %@ pronunciation for \"%@\": \"%@\"",
        "In %@, \"%@\" is actually \"%@\"",
        "Listen carefully: \"%@\" in %@ is \"%@\""
    ]
    
    private static var introIndex = 0
    
    static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ [BrickVoice] Using Voice Override: '\(override)'")
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
            (BrickVoiceLogic.correctVoices.randomElement() ?? "Correct! \"%@\" in %@ is \"%@\"") :
            (BrickVoiceLogic.wrongVoices.randomElement() ?? "Actually, \"%@\" in %@ is \"%@\"")
        
        var textToSpeak = template.replacingOccurrences(of: "%@", with: meaning, range: template.range(of: "%@"))
        if let langRange = textToSpeak.range(of: "%@") {
            textToSpeak = textToSpeak.replacingOccurrences(of: "%@", with: targetLang, range: langRange)
        }
        
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
        
        self.isAudioPlaying = true
        self.patternIntroLogic?.isAudioPlaying = true
        self.practiceLogic?.isAudioPlaying = true
        AudioManager.shared.speak(segments: [.init(text: text, language: language)]) { [weak self] in
            DispatchQueue.main.async {
                self?.isAudioPlaying = false
                self?.patternIntroLogic?.isAudioPlaying = false
                self?.practiceLogic?.isAudioPlaying = false
                self?.ghostLogic?.isAudioPlaying = false
            }
        }
    }
    
    deinit {
        speechRecognizer.stopRecording()
    }
    
    func continueToNext() {
        onComplete?(isCorrect ?? true)
    }
    
    @ViewBuilder
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) -> some View {
        if let introLogic = patternIntroLogic {
            // ✅ Direction A: Pattern Intro (Recap) -> Mini Interaction
            // Hiding Prompt because PatternIntroView Header + Tap Strip already shows Meaning.
            BrickVoiceInteraction(drill: state, engine: engine, showPrompt: false, patternIntroLogic: introLogic, onComplete: onComplete)
                .onAppear {
                    BrickVoiceLogic.playIntro(drill: state, engine: engine, mode: mode)
                }
        } else {
            // ✅ Direction B: Ghost Mode (Practice) -> Full View
            BrickVoiceView(state: state, engine: engine, patternIntroLogic: patternIntroLogic, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
                .onAppear {
                    BrickVoiceLogic.playIntro(drill: state, engine: engine, mode: mode)
                }
        }
    }
}
