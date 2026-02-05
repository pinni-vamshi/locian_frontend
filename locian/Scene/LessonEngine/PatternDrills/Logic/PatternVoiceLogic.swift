import SwiftUI
import Combine

class PatternVoiceLogic: ObservableObject {
    let state: DrillState
    let session: LessonSessionManager
    
    // Data only
    let prompt: String
    let targetLanguage: String
    
    @Published var isCorrect: Bool?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(state: DrillState, session: LessonSessionManager) {
        self.state = state
        self.session = session
        self.prompt = state.drillData.target
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: session.lessonData?.target_language ?? "en").english
        
        // BRIDGE: Notify View when speech recognizer updates
        session.speechRecognizer.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
    
    // Voice state exposed to view
    var isRecording: Bool {
        session.speechRecognizer.isRecording
    }
    
    var recognizedText: String {
        session.speechRecognizer.recognizedText
    }
    
    var hasInput: Bool {
        !recognizedText.isEmpty
    }
    
    func triggerSpeechRecognition() {
        if session.speechRecognizer.isRecording {
            session.speechRecognizer.stopRecording()
        } else {
            try? session.speechRecognizer.startRecording()
        }
    }
    
    func checkAnswer() {
        guard isCorrect == nil else { return }
        print("      - Validating voice [Pattern Voice]...")
        
        let input = session.speechRecognizer.recognizedText
        let context = ValidationContext(
            state: state,
            locale: session.targetLocale,
            session: session,
            neuralEngine: session.neuralValidator
        )
        
        // 1. Validate the FULL Pattern using Voice Validator
        let validator = VoiceValidator()
        let result = validator.validate(input: input, target: state.drillData.target, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        
        // 2. Perform Granular Analysis (The Ripple Effect)
        let brickMatches = ContentAnalyzer.findRelevantBricks(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: session.lessonData?.bricks,
            targetLanguage: session.lessonData?.target_language ?? "es"
        )
        let bricks = MasteryFilterService.resolveBricks(ids: Set(brickMatches), from: session.lessonData?.bricks)
        
        let rippleResults = GranularAnalyzer.analyze(
            input: input,
            target: state.drillData.target,
            requiredBricks: Array(bricks),
            type: .speaking,
            context: context
        )
        
        // 3. Update Mastery Directly in Engine
        let delta = isCorrect ? 0.40 : -0.20
        session.engine.updateMastery(id: state.id, delta: delta, reason: "[Pattern Voice]")
        
        // Ripple Effect on Bricks
        for res in rippleResults {
            let brickDelta = res.isCorrect ? 0.10 : -0.05
            session.engine.updateMastery(id: res.brickId, delta: brickDelta, reason: "[Ripple: Voice]")
        }
        
        // 4. Trigger UI Side Effects in Session
        session.handleValidationResult(isCorrect: isCorrect, targetContent: state.drillData.target)
        self.isCorrect = isCorrect
    }
    
    func continueToNext() {
        session.continueToNext()
    }
    
    func playAudio() {
        session.playStateAudio(state)
    }
    
    static func view(for state: DrillState, mode: DrillMode, session: LessonSessionManager) -> some View {
        let logic = PatternVoiceLogic(state: state, session: session)
        return PatternDictationView(logic: logic)
    }
}
