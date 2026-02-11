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
    var onComplete: (() -> Void)?
    weak var patternIntroLogic: PatternIntroLogic?  // ✅ NEW: Reference to notify pattern intro
    private var cancellables = Set<AnyCancellable>()
    
    // Local Speech Recognizer (or Shared Singleton)
    // Since we removed SessionManager, we use the shared instance directly or pass it in.
    // For now, let's assume we use the global SpeechRecognizer or one attached to Engine.
    private let speechRecognizer = SpeechRecognizer.shared 
    
    init(state: DrillState, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil) {
        self.state = state
        self.engine = engine
        self.patternIntroLogic = patternIntroLogic
        self.prompt = state.drillData.target
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        // BRIDGE: Notify View when speech recognizer updates
        speechRecognizer.reset()
        speechRecognizer.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
    
    // Voice state exposed to view
    var isRecording: Bool {
        speechRecognizer.isRecording
    }
    
    var recognizedText: String {
        speechRecognizer.recognizedText
    }
    
    var hasInput: Bool {
        !recognizedText.isEmpty
    }
    
    func triggerSpeechRecognition() {
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
        let delta = isCorrect ? 0.40 : -0.20
        engine.updateMastery(id: brickId, delta: delta)
        
        // UI Effects
        self.isCorrect = isCorrect
        
        // ✅ NOTIFY PATTERN INTRO - Tell parent view to show continue button
        patternIntroLogic?.markBrickAnswered(isCorrect: isCorrect)
        
        playAudio()
    }
    
    func playAudio() {
        let text = state.drillData.target
        let language = engine.lessonData?.target_language ?? "es-ES"
        
        self.isAudioPlaying = true
        self.patternIntroLogic?.isAudioPlaying = true
        AudioManager.shared.speak(text: text, language: language) { [weak self] in
            DispatchQueue.main.async {
                self?.isAudioPlaying = false
                self?.patternIntroLogic?.isAudioPlaying = false
            }
        }
    }
    
    deinit {
        speechRecognizer.stopRecording()
    }
    
    func continueToNext() {
        if let onComplete = onComplete {
            onComplete()
        } else {
            engine.orchestrator?.finishPattern()
        }
    }
    
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, onComplete: (() -> Void)? = nil) -> some View {
        let logic = BrickVoiceLogic(state: state, engine: engine)
        logic.onComplete = onComplete
        return BrickVoiceView(logic: logic)
    }
}
