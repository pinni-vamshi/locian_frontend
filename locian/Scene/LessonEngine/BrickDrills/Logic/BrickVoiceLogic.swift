import SwiftUI
import Combine

class BrickVoiceLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let targetLanguage: String
    
    @Published var isCorrect: Bool?
    var onComplete: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    // Local Speech Recognizer (or Shared Singleton)
    // Since we removed SessionManager, we use the shared instance directly or pass it in.
    // For now, let's assume we use the global SpeechRecognizer or one attached to Engine.
    private let speechRecognizer = SpeechRecognizer.shared 
    
    init(state: DrillState, engine: LessonEngine) {
        self.state = state
        self.engine = engine
        self.prompt = state.drillData.target
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        // BRIDGE: Notify View when speech recognizer updates
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
            print("   🎤 [BrickVoice] STOPPING recording. Finalizing transcript...")
            speechRecognizer.stopRecording()
        } else {
            print("   🎤 [BrickVoice] Requesting MIC access via Autonomous Service...")
            PermissionsService.shared.ensureVoiceAccess { granted in
                guard granted else { 
                    print("   🚫 [BrickVoice] Access DENIED. Alert handled by Service.")
                    return 
                }
                
                print("   🎤 [BrickVoice] Access GRANTED. STARTING recording...")
                print("      - Target: '\(self.state.drillData.target)'")
                // Use default locale if not set in engine (TODO: Move targetLocale to Engine)
                try? self.speechRecognizer.startRecording()
            }
        }
    }
    
    func checkAnswer() {
        guard isCorrect == nil else { return }
        let input = speechRecognizer.recognizedText
        print("   👉 [BrickVoice] Checking speech: '\(input)'")
        print("      - Validating voice [Brick Voice]...")
        
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
        // UI Effects
        self.isCorrect = isCorrect
        playAudio()
    }
    
    func playAudio() {
        let text = state.drillData.target
        let language = engine.lessonData?.target_language ?? "es-ES"
        AudioManager.shared.speak(text: text, language: language)
    }
    
    func continueToNext() {
        onComplete?()
    }
    
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine) -> some View {
        let logic = BrickVoiceLogic(state: state, engine: engine)
        return BrickVoiceView(logic: logic)
    }
}
