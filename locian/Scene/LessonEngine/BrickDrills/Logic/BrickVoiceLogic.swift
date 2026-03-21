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
                // ✅ Sync Input State across potential parents for Footer Button
                if let self = self {
                    let hasText = !self.speechRecognizer.recognizedText.isEmpty
                    self.patternIntroLogic?.currentBrickHasInput = hasText
                    self.practiceLogic?.hasInput = hasText
                    self.ghostLogic?.hasInput = hasText
                }
            }
            .store(in: &cancellables)
    }
    
    func bindToParent() {
        // ✅ Bridge Actions to whichever parent is active
        let checkAction: () -> Void = { [weak self] in self?.checkAnswer() }
        let clearAction: () -> Void = { [weak self] in self?.clearInput() }
        
        patternIntroLogic?.requestCheckAnswer = checkAction
        patternIntroLogic?.requestClearInput = clearAction
        
        practiceLogic?.requestCheckAnswer = checkAction
        practiceLogic?.requestClearInput = clearAction
        
        ghostLogic?.requestCheckAnswer = checkAction
        ghostLogic?.requestClearInput = clearAction

        // Sync initial state
        let hasText = !recognizedText.isEmpty
        patternIntroLogic?.currentBrickHasInput = hasText
        practiceLogic?.hasInput = hasText
        ghostLogic?.hasInput = hasText
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
            SpeechRecognizer.shared.ensureVoiceAccess { granted in
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
        
        practiceLogic?.isAnswered = false
        practiceLogic?.isCorrect = false
        
        ghostLogic?.isAnswered = false
        ghostLogic?.isCorrect = false
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
    
    
    
    
    // 3. Concise Feedback
    
    
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
