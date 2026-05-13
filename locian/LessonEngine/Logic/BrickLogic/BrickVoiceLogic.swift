import SwiftUI
import Combine

class BrickVoiceLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let targetLanguage: String
    
    @Published var isCorrect: Bool?
    @Published var practiceLogic: PatternPracticeLogic?
    @Published var ghostLogic: GhostModeLogic?
    @Published var isAudioPlaying: Bool = false
    
    var onComplete: ((Bool) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    // Local Speech Recognizer (or Shared Singleton)
    // Since we removed SessionManager, we use the shared instance directly or pass it in.
    // For now, let's assume we use the global SpeechRecognizer or one attached to Engine.
    private let speechRecognizer = SpeechRecognizer.shared 
    
    init(state: DrillState, engine: LessonEngine, onComplete: ((Bool) -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.onComplete = onComplete
        self.prompt = state.drillData.target
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        // speechRecognizer.reset() // ❌ REMOVED: Breaks singleton during re-renders
        
        speechRecognizer.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                if let self = self {
                    let hasText = !self.speechRecognizer.recognizedText.isEmpty
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
    
    // Voice state exposed to view
    var isStarting: Bool {
        return speechRecognizer.isStarting
    }
    
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
        print("🎙️ [BrickVoiceLogic] triggerSpeechRecognition() called. isRecording: \(speechRecognizer.isRecording)")
        
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        } else {
            SpeechRecognizer.shared.ensureVoiceAccess { granted in
                guard granted else { return }
                
                // Sync Locale to Target Language before starting
                let targetLang = self.engine.lessonData?.target_language ?? "en"
                let locale = TargetLanguageMapping.shared.getLocale(for: targetLang)
                self.speechRecognizer.setLocale(locale)
                
                do {
                    try self.speechRecognizer.startRecording()
                } catch {
                    print("❌ [BrickVoiceLogic] Failed to start recording: \(error.localizedDescription)")
                }
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

        practiceLogic?.isAnswered = false
        practiceLogic?.isCorrect = false
        
        ghostLogic?.isAnswered = false
        ghostLogic?.isCorrect = false
    }
    
    func checkAnswer() {
        guard isCorrect == nil else { return }
        
        // Capture text BEFORE stopping to avoid race condition
        // (stopRecording dispatches async, so text could change after the call)
        let input = speechRecognizer.recognizedText
        
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        }
        print("🚨 [BrickVoiceLogic] checkAnswer() TRIGGERED")
        print("   🎤 Spoken Input: '\(input)'")
        print("   🎯 Target Word: '\(state.drillData.target)'")
        
        print("🔍 [BrickVoiceLogic] Building ValidationContext for '\(state.id)'")
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        print("   ✅ Context Created. Starting Validator...")
        
        // Bricks always match Foreign Word
        let validator = VoiceValidator()
        let result = validator.validate(input: input, target: state.drillData.target, context: context)
        let isCorrectResult = (result == .correct || result == .meaningCorrect)
        
        // Update Mastery (Only this brick)
        let brickId = state.id.replacingOccurrences(of: "INT-", with: "")
            .replacingOccurrences(of: "PRACTICE-MISTAKE-", with: "")
            .replacingOccurrences(of: "GHOST-", with: "")
            

        if isCorrectResult {
            engine.updateMastery(id: brickId, delta: 0.15)
        } else {
            engine.updateMastery(id: brickId, delta: -0.05)
        }
        
        // UI Effects
        self.isCorrect = isCorrectResult
        
        practiceLogic?.markDrillAnswered(isCorrect: isCorrectResult)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrectResult)
        // Keep voice flow silent on CHECK to avoid duplicate replay.
    }
    
    // MARK: - 🎙️ Voice Assets (Decentralized)
    
    // MARK: - 🎙️ Voice Assets (Decentralized)
    
    // 1. Full Context
    
    
    
    
    // 3. Concise Feedback
    
    
    private static var introIndex = 0
    
    static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        print("🔊 [BrickVoiceLogic] playIntro() called for Mode: \(mode). Drill ID: \(drill.id)")
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ Skipping Voice Override text (TTS Disabled): '\(override)'")
        }
    }
    
    private func playFeedback(isCorrect: Bool) {
        // No-op: post-check replay removed.
    }
    
    func playAudio() {
        let text = state.drillData.target
        let voiceData = state.drillData.voice_data
        
        print("🔊 [BrickVoiceLogic] playAudio() TRIGGERED")
        print("   🆔 ID: \(state.id)")
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
            id: state.id,
            completion: completion
        )
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
    
    @ViewBuilder
    static func view(
        for state: DrillState,
        mode: DrillMode,
        engine: LessonEngine,
        practiceLogic: PatternPracticeLogic? = nil,
        ghostLogic: GhostModeLogic? = nil,
        onComplete: ((Bool) -> Void)? = nil
    ) -> some View {
        BrickVoiceView(
            state: state,
            engine: engine,
            practiceLogic: practiceLogic,
            ghostLogic: ghostLogic,
            onComplete: onComplete
        )
        .onAppear {
            BrickVoiceLogic.playIntro(drill: state, engine: engine, mode: mode)
        }
    }
}
