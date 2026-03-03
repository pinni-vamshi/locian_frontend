import SwiftUI
import Combine

class PatternVoiceLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let phonetic: String?
    let targetLanguage: String
    
    @Published var isCorrect: Bool?
    @Published var isAudioPlaying: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    // Local Speech Recognizer (or Shared Singleton)
    private let speechRecognizer = SpeechRecognizer.shared 
    
    var onComplete: ((Bool) -> Void)? // ✅ Direct closure reference
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
        self.onComplete = onComplete
        self.prompt = state.drillData.target
        self.phonetic = state.drillData.phonetic
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        // BRIDGE: Notify View when speech recognizer updates
        speechRecognizer.reset()
        speechRecognizer.objectWillChange
            .sink { [weak self] _ in 
                self?.objectWillChange.send()
                // Sync input state for Footer
                if let intro = self?.patternIntroLogic {
                    intro.currentBrickHasInput = !(self?.speechRecognizer.recognizedText.isEmpty ?? true)
                }
            }
            .store(in: &cancellables)
    }
    
    func bindToParent() {
        // ✅ Bridge Actions to Parent (Intro Recap Phase)
        patternIntroLogic?.requestCheckAnswer = { [weak self] in
            self?.checkAnswer()
        }
        
        // Sync initial state
        patternIntroLogic?.currentBrickHasInput = !recognizedText.isEmpty
    }
    
    // MARK: - Speech Recognition Props
    var isRecording: Bool { speechRecognizer.isRecording }
    var recognizedText: String { speechRecognizer.recognizedText }
    var hasInput: Bool { !recognizedText.isEmpty }
    
    func triggerSpeechRecognition() {
        if isRecording {
            speechRecognizer.stopRecording()
        } else {
            PermissionsService.shared.ensureVoiceAccess { granted in
                guard granted else { return }
                try? self.speechRecognizer.startRecording()
            }
        }
    }
    
    func checkAnswer() {
        guard isCorrect == nil else { return }
        
        // LOGIC CORRECT: Stop recording BEFORE checking answer and playing feedback
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
        
        // 1. Validate the FULL Pattern using Voice Validator
        let validator = VoiceValidator()
        let result = validator.validate(input: input, target: state.drillData.target, context: context)
        let isCorrectResult = (result == .correct || result == .meaningCorrect)
        
        // 2. Perform Autonomous Granular Analysis (The Ripple Effect)
        // This directly updates brick mastery in the engine (+0.10 / -0.05)
        GranularAnalyzer.processGranularMastery(
            engine: engine,
            target: state.drillData.target,
            meaning: state.drillData.meaning,
            userInput: input,
            type: .speaking,
            context: context
        )
        
        // 3. Update Mastery Directly in Engine (Only this pattern)
        // REDUCED DELTA: 0.15 (Gradual progression)
        let delta = isCorrectResult ? 0.15 : -0.05
        engine.updateMastery(id: state.patternId, delta: delta)
        
        // 4. Trigger UI Side Effects
        self.isCorrect = isCorrectResult
        
        // ✅ Localized Feedback
        playFeedback(isCorrect: isCorrectResult)
        
        playAudio()
        
        // ✅ Notify Wrapper
        patternIntroLogic?.markBrickAnswered(isCorrect: isCorrectResult, input: input)
        practiceLogic?.markDrillAnswered(isCorrect: isCorrectResult)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrectResult)
    }
    
    func continueToNext() {
        onComplete?(isCorrect ?? true)
    }
    
    func playAudio() {
        let text = state.drillData.target
        let language = engine.lessonData?.target_language ?? "es-ES"
        
        self.isAudioPlaying = true
        AudioManager.shared.speak(segments: [.init(text: text, language: language)]) { [weak self] in
            DispatchQueue.main.async {
                self?.isAudioPlaying = false
            }
        }
    }
    
    // MARK: - 🎙️ Voice Assets
    
    private static let fullIntroVoices = [
        "Say \"%@\" in %@",
        "How do you pronounce the %@ word for \"%@\"?",
        "Speak the word for \"%@\" in %@",
        "Your turn: Say \"%@\" in %@",
        "Let's hear \"%@\" in %@"
    ]
    
    private static let correctVoices = [
        "You are right! \"%@\" in %@ is \"%@\"",
        "Exactly. \"%@\" in %@ translates to \"%@\"",
        "Spot on. In %@, \"%@\" matches \"%@\"",
        "That's correct. We say \"%@\" for \"%@\" in %@",
        "Perfect match. \"%@\" in %@ is \"%@\""
    ]
    
    private static let wrongVoices = [
        "Actually, we say \"%@\"",
        "The correct word is \"%@\"",
        "Note the pronunciation: \"%@\"",
        "Listen to the word: \"%@\"",
        "It sounds like this: \"%@\""
    ]
    
    private static var introIndex = 0
    
    static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        if let override = drill.overrideVoiceInstructions {
            AudioManager.shared.speak(segments: [.init(text: override, language: drill.voiceLanguage ?? "en-US")])
            return
        }
        
        guard !drill.suppressIntroAudio else { return }
        
        let languageCode = engine.lessonData?.target_language ?? "es"
        let languageName = TargetLanguageMapping.shared.getDisplayNames(for: languageCode).english
        let meaning = drill.drillData.meaning
        
        let index = introIndex % fullIntroVoices.count
        let template = fullIntroVoices[index]
        introIndex += 1
        
        var text = template.replacingOccurrences(of: "%@", with: meaning, range: template.range(of: "%@"))
        text = text.replacingOccurrences(of: "%@", with: languageName)
        
        AudioManager.shared.speak(segments: [.init(text: text, language: "en-US")])
    }
    
    private func playFeedback(isCorrect: Bool) {
        // ✅ USER REQUEST: Silence local feedback if practiceLogic is handling the meaningful bilingual feedback
        if let practiceLogic = practiceLogic, practiceLogic.currentIndex == practiceLogic.mistakes.count {
            print("🎙️ [PatternVoice] Silencing local feedback. practiceLogic will handle bilingual confirmation.")
            return
        }
        
        let target = state.drillData.target
        let meaning = state.drillData.meaning
        let targetLang = targetLanguage
        
        let template = isCorrect ? 
            (PatternVoiceLogic.correctVoices.randomElement() ?? "Correct! \"%@\" in %@ is \"%@\"") :
            (PatternVoiceLogic.wrongVoices.randomElement() ?? "Actually, we say \"%@\"")
        
        // Split at potential target placeholder
        var textToSpeak = template.replacingOccurrences(of: "%@", with: meaning, range: template.range(of: "%@"))
        if let langRange = textToSpeak.range(of: "%@") {
            textToSpeak = textToSpeak.replacingOccurrences(of: "%@", with: targetLang, range: langRange)
        }
        
        // Split at the final placeholder
        let finalComponents = textToSpeak.components(separatedBy: "\"%@\"")
        
        let langCode = self.engine.lessonData?.target_language ?? "es-ES"
        
        if finalComponents.count >= 2 {
            AudioManager.shared.speak(segments: [
                .init(text: finalComponents[0], language: "en-US"),
                .init(text: target, language: langCode)
            ])
        } else {
            // Fallback
            AudioManager.shared.speak(segments: [
                .init(text: isCorrect ? "That's correct. " : "Actually, we say ", language: "en-US"),
                .init(text: target, language: langCode)
            ])
        }
    }
    
    deinit {
        speechRecognizer.stopRecording()
    }
    
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) -> some View {
        return PatternDictationView(state: state, engine: engine, patternIntroLogic: patternIntroLogic, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
            .onAppear {
                PatternVoiceLogic.playIntro(drill: state, engine: engine, mode: mode)
            }
    }
}
