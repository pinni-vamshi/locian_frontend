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
            let hasText = !userInput.isEmpty
            practiceLogic?.hasInput = hasText
            ghostLogic?.hasInput = hasText
        }
    }
    @Published var isCorrect: Bool?
    @Published var practiceLogic: PatternPracticeLogic?
    @Published var ghostLogic: GhostModeLogic?
    @Published var isAudioPlaying: Bool = false
    
    var onComplete: ((Bool) -> Void)?
    
    init(state: DrillState, engine: LessonEngine, onComplete: ((Bool) -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.onComplete = onComplete
        self.prompt = state.drillData.meaning
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
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
    
    var hasInput: Bool {
        !userInput.isEmpty
    }
    
    func clearInput() {
        print("🧹 [BrickTypingLogic] Clearing input")
        self.userInput = ""
        self.isCorrect = nil

        practiceLogic?.isAnswered = false
        practiceLogic?.isCorrect = false
        
        ghostLogic?.isAnswered = false
        ghostLogic?.isCorrect = false
    }
    
    func checkAnswer() {
        guard isCorrect == nil && !userInput.isEmpty else { return }
        
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        
        // Bricks always match Foreign Word
        let validator = TypingValidator()
        let result = validator.validate(input: userInput, target: state.drillData.target, context: context)
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
        // Keep typing flow silent on CHECK to avoid duplicate replay.
    }
    
    // MARK: - 🎙️ Voice Assets (Decentralized)
    
    // MARK: - 🎙️ Voice Assets (Decentralized)
    
    // 1. Full Context
    
    
    
    
    
    
    private static var introIndex = 0
    
    static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ Skipping Voice Override text (TTS Disabled): '\(override)'")
        }
    }
    
    private func playFeedback(isCorrect: Bool) {
        // No-op: post-check replay removed.
    }
    
    func playAudio() {
        let voiceData = state.drillData.voice_data

        self.isAudioPlaying = true
        self.practiceLogic?.isAudioPlaying = true
        self.ghostLogic?.isAudioPlaying = true

        AudioManager.shared.playVoiceFromBackendIfAvailable(
            relativePath: voiceData,
            id: state.id
        ) { [weak self] in
            DispatchQueue.main.async {
                self?.isAudioPlaying = false
                self?.practiceLogic?.isAudioPlaying = false
                self?.ghostLogic?.isAudioPlaying = false
            }
        }
    }
    
    func continueToNext() {
        AudioManager.shared.stop()
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
        BrickTypingView(
            state: state,
            engine: engine,
            practiceLogic: practiceLogic,
            ghostLogic: ghostLogic,
            onComplete: onComplete
        )
        .onAppear {
            BrickTypingLogic.playIntro(drill: state, engine: engine, mode: mode)
        }
    }
}
