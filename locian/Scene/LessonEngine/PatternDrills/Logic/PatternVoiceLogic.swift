import SwiftUI
import Combine

class PatternVoiceLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let targetLanguage: String
    
    @Published var isCorrect: Bool?
    @Published var isAudioPlaying: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    // Local Speech Recognizer (or Shared Singleton)
    private let speechRecognizer = SpeechRecognizer.shared 
    
    weak var lessonDrillLogic: LessonDrillLogic? // ✅ Wrapper Reference
    
    init(state: DrillState, engine: LessonEngine, lessonDrillLogic: LessonDrillLogic? = nil) {
        self.state = state
        self.engine = engine
        self.lessonDrillLogic = lessonDrillLogic
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
        
        // 1. Validate the FULL Pattern using Voice Validator
        let validator = VoiceValidator()
        let result = validator.validate(input: input, target: state.drillData.target, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        
        // 2. Perform Granular Analysis (The Ripple Effect)
        // ✅ NOW USING GROUP-SPECIFIC BRICKS ONLY
        let brickMatches = ContentAnalyzer.findRelevantBricks(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: engine.activeGroupBricks,
            targetLanguage: engine.lessonData?.target_language ?? "es"
        )
        let bricks = MasteryFilterService.resolveBricks(ids: Set(brickMatches), from: engine.activeGroupBricks)
        
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
        
        // ✅ Notify Wrapper
        lessonDrillLogic?.markDrillAnswered(isCorrect: isCorrect)
    }
    
    func playAudio() {
        let text = state.drillData.target
        let language = engine.lessonData?.target_language ?? "es-ES"
        
        self.isAudioPlaying = true
        self.lessonDrillLogic?.isAudioPlaying = true
        AudioManager.shared.speak(text: text, language: language) { [weak self] in
            DispatchQueue.main.async {
                self?.isAudioPlaying = false
                self?.lessonDrillLogic?.isAudioPlaying = false
            }
        }
    }
    
    deinit {
        speechRecognizer.stopRecording()
    }
    
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, lessonDrillLogic: LessonDrillLogic? = nil) -> some View {
        // View now owns the logic creation via StateObject
        return PatternDictationView(state: state, engine: engine, lessonDrillLogic: lessonDrillLogic)
    }
}
