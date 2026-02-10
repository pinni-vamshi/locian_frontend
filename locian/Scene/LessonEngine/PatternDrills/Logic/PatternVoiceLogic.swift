import SwiftUI
import Combine

class PatternVoiceLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let targetLanguage: String
    
    @Published var isCorrect: Bool?
    private var cancellables = Set<AnyCancellable>()
    
    // Local Speech Recognizer (or Shared Singleton)
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
                try? self.speechRecognizer.startRecording()
            }
        }
    }
    
    func checkAnswer() {
        guard isCorrect == nil else { return }
        print("      - Validating voice [Pattern Voice]...")
        
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
        let isCorrect = (result == .correct || result == .meaningCorrect)
        
        // 2. Perform Granular Analysis (The Ripple Effect)
        let brickMatches = ContentAnalyzer.findRelevantBricks(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: engine.lessonData?.bricks,
            targetLanguage: engine.lessonData?.target_language ?? "es"
        )
        let bricks = MasteryFilterService.resolveBricks(ids: Set(brickMatches), from: engine.lessonData?.bricks)
        
        let rippleResults = GranularAnalyzer.analyze(
            input: input,
            target: state.drillData.target,
            requiredBricks: Array(bricks),
            type: .speaking,
            context: context
        )
        
        // 3. Update Mastery Directly in Engine
        let delta = isCorrect ? 0.40 : -0.20
        engine.updateMastery(id: state.id, delta: delta)
        
        // Ripple Effect on Bricks
        for res in rippleResults {
            let brickDelta = res.isCorrect ? 0.10 : -0.05
            engine.updateMastery(id: res.brickId, delta: brickDelta)
        }
        
        // 4. Trigger UI Side Effects
        // 4. Trigger UI Side Effects
        self.isCorrect = isCorrect
        playAudio()
    }
    
    func continueToNext() {
        engine.orchestrator?.finishPattern()
    }
    
    func playAudio() {
        let text = state.drillData.target
        let language = engine.lessonData?.target_language ?? "es-ES"
        AudioManager.shared.speak(text: text, language: language)
    }
    
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine) -> some View {
        let logic = PatternVoiceLogic(state: state, engine: engine)
        return PatternDictationView(logic: logic)
    }
}
