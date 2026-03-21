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
            SpeechRecognizer.shared.ensureVoiceAccess { granted in
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
        
        // 3.5 ✅ PATTERN COMPLETION TRIGGER (Competitive Decay Loop)
        // If correct and the final score is now >= 0.85, trigger the completion endpoint for architectural persistence.
        if isCorrectResult && engine.getBlendedMastery(for: state.patternId) >= 0.85 {
            CompletePatternLogic.shared.reportCompletion(patternId: state.patternId, engine: engine)
        }
        
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
        self.patternIntroLogic?.isAudioPlaying = true
        self.practiceLogic?.isAudioPlaying = true
        self.ghostLogic?.isAudioPlaying = true
        
        AudioManager.shared.speak(text: text, language: language) { [weak self] in
            DispatchQueue.main.async {
                self?.isAudioPlaying = false
                self?.patternIntroLogic?.isAudioPlaying = false
                self?.practiceLogic?.isAudioPlaying = false
                self?.ghostLogic?.isAudioPlaying = false
            }
        }
    }
    
    // MARK: - 🎙️ Voice Assets
    
    
    
    
    
    
    
    private static var introIndex = 0
    
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
