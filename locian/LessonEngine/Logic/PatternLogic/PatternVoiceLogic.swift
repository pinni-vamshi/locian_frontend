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
    var isAnswered: Bool { isCorrect != nil }
    @Published var practiceLogic: PatternPracticeLogic?
    @Published var ghostLogic: GhostModeLogic?
    private var cancellables = Set<AnyCancellable>()
    
    // Local Speech Recognizer (or Shared Singleton)
    private let speechRecognizer = SpeechRecognizer.shared 
    
    var onComplete: ((Bool) -> Void)? // ✅ Direct closure reference
    
    init(state: DrillState, engine: LessonEngine, onComplete: ((Bool) -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.onComplete = onComplete
        self.prompt = state.drillData.meaning
        self.phonetic = state.drillData.phonetic
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        // BRIDGE: Notify View when speech recognizer updates
        // speechRecognizer.reset() // ❌ REMOVED: Blocks start-up on re-render
        speechRecognizer.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                if let self = self {
                    let hasText = !self.recognizedText.isEmpty
                    self.practiceLogic?.hasInput = hasText
                    self.ghostLogic?.hasInput = hasText
                }
            }
            .store(in: &cancellables)
    }
    
    func bindToParent(practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil) {
        self.practiceLogic = practiceLogic
        self.ghostLogic = ghostLogic

        let has = self.hasInput
        if let practice = practiceLogic {
            practice.requestCheckAnswer = { [weak self] in self?.checkAnswer() }
            practice.requestClearInput = { [weak self] in self?.clearInput() }
            practice.hasInput = has
        }
        if let ghost = ghostLogic {
            ghost.requestCheckAnswer = { [weak self] in self?.checkAnswer() }
            ghost.requestClearInput = { [weak self] in self?.clearInput() }
            ghost.hasInput = has
        }
    }
    
    func clearInput() {
        speechRecognizer.reset()
        self.isCorrect = nil

        practiceLogic?.isAnswered = false
        practiceLogic?.isCorrect = false
        
        ghostLogic?.isAnswered = false
        ghostLogic?.isCorrect = false
    }
    
    // MARK: - Speech Recognition Props
    var isStarting: Bool { speechRecognizer.isStarting }
    var isRecording: Bool { speechRecognizer.isRecording }
    var recognizedText: String { speechRecognizer.recognizedText }
    var hasInput: Bool { !recognizedText.isEmpty }
    
    func triggerSpeechRecognition() {
        if isRecording {
            speechRecognizer.stopRecording()
        } else {
            SpeechRecognizer.shared.ensureVoiceAccess { granted in
                guard granted else { return }
                
                // Sync Locale to Target Language
                let targetLang = self.engine.lessonData?.target_language ?? "en"
                let locale = TargetLanguageMapping.shared.getLocale(for: targetLang)
                self.speechRecognizer.setLocale(locale)
                
                do {
                    try self.speechRecognizer.startRecording()
                } catch {
                    print("❌ [PatternVoiceLogic] Failed to start recording: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func checkAnswer() {
        print("🚨 [PatternVoiceLogic] checkAnswer() TRIGGERED")
        guard isCorrect == nil else { return }
        
        // Capture text BEFORE stopping to avoid race condition
        // (stopRecording dispatches async, so text could change after the call)
        let input = speechRecognizer.recognizedText
        
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        }
        print("🎤 [VoiceLogic] Validating Spoken Text: '\(input)' against Target: '\(state.drillData.target)'")

        // 1. Validate the FULL Pattern using Voice Validator
        print("🔍 [VoiceLogic] Building ValidationContext for '\(state.patternId)'")
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        print("   ✅ Context Created. Starting Validator...")
        
        // 1. Validate the FULL Pattern using Voice Validator
        let validator = VoiceValidator()
        let result = validator.validate(input: input, target: state.drillData.target, context: context)
        print("✅ [VoiceLogic] Validation Result: \(result)")
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

        if isCorrectResult {
            engine.updateMastery(id: state.patternId, delta: 0.20)
        } else {
            engine.updateMastery(id: state.patternId, delta: -0.05)
        }
        
        // 3.5 ✅ PATTERN COMPLETION TRIGGER (Competitive Decay Loop)
        // If correct and the final score is now >= 0.85, trigger the completion endpoint for architectural persistence.
        if isCorrectResult && engine.getBlendedMastery(for: state.patternId) >= 0.85 {
            CompletePatternLogic.shared.reportCompletion(patternId: state.patternId, engine: engine)
        }
        
        // 4. Trigger UI Side Effects
        self.isCorrect = isCorrectResult
        
        practiceLogic?.markDrillAnswered(isCorrect: isCorrectResult)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrectResult)
    }
    
    deinit {
        // No-op: speechRecognizer is a shared singleton.
        // Purging it here causes infinite loops during SwiftUI re-renders.
    }
    
    func continueToNext() {
        AudioManager.shared.stop()
        speechRecognizer.reset() // ✅ CLEAR STATE BEFORE TRANSITION
        onComplete?(isCorrect ?? true)
    }
    
    func playAudio() {
        let text = state.drillData.target
        let voiceData = state.drillData.voice_data
        
        print("🔊 [PatternVoiceLogic] playAudio() TRIGGERED")
        print("   🆔 ID: \(state.patternId)")
        print("   📑 Text: \(text)")
        print("   📦 Data Length: \(voiceData?.count ?? 0)")
        
        self.isAudioPlaying = true
        self.practiceLogic?.isAudioPlaying = true
        self.ghostLogic?.isAudioPlaying = true

        let completion = { [weak self] in
            DispatchQueue.main.async {
                self?.isAudioPlaying = false
                self?.practiceLogic?.isAudioPlaying = false
                self?.ghostLogic?.isAudioPlaying = false
            }
        }
        
        AudioManager.shared.playVoiceFromBackendIfAvailable(
            relativePath: voiceData,
            id: state.patternId,
            completion: completion
        )
    }
    
    // MARK: - 🎙️ Voice Assets
    
    
    
    
    
    
    
    private static var introIndex = 0
    
    static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        print("🔊 [PatternVoiceLogic] playIntro() called for Mode: \(mode)")
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ Skipping Voice Override text (TTS Disabled): '\(override)'")
        }
    }
    
    private func playFeedback(isCorrect: Bool) {
        // No-op: post-check replay removed.
    }
    
    @ViewBuilder
    static func view(
        for state: DrillState,
        mode: DrillMode,
        engine: LessonEngine,
        practiceLogic: PatternPracticeLogic? = nil,
        ghostLogic: GhostModeLogic? = nil,
        onComplete: ((Bool) -> Void)? = nil
    ) -> some View {
        PatternDictationView(
            state: state, 
            engine: engine, 
            practiceLogic: practiceLogic, 
            ghostLogic: ghostLogic, 
            onComplete: onComplete
        )
            .onAppear {
                PatternVoiceLogic.playIntro(drill: state, engine: engine, mode: mode)
            }
    }
}
