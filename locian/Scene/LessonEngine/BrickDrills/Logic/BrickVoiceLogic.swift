import SwiftUI
import Combine

class BrickVoiceLogic: ObservableObject {
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
            print("   🎤 [BrickVoice] Stopping recording...")
            session.speechRecognizer.stopRecording()
        } else {
            print("   🎤 [BrickVoice] Starting recording...")
            try? session.speechRecognizer.startRecording()
        }
    }
    
    func checkAnswer() {
        guard isCorrect == nil else { return }
        let input = session.speechRecognizer.recognizedText
        print("   👉 [BrickVoice] Checking speech: '\(input)'")
        print("      - Validating voice [Brick Voice]...")
        
        let context = ValidationContext(
            state: state,
            locale: session.targetLocale,
            session: session,
            neuralEngine: session.neuralValidator
        )
        
        // Bricks always match Foreign Word
        let validator = VoiceValidator()
        let result = validator.validate(input: input, target: state.drillData.target, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        
        // Update Mastery (Only this brick)
        let brickId = state.id.replacingOccurrences(of: "INT-", with: "")
        let delta = isCorrect ? 0.40 : -0.20
        session.engine.updateMastery(id: brickId, delta: delta, reason: "[Brick Voice]")
        
        // UI Effects
        session.handleValidationResult(isCorrect: isCorrect, targetContent: state.drillData.target)
        self.isCorrect = isCorrect
    }
    
    func continueToNext() {
        session.continueToNext()
    }
    
    static func view(for state: DrillState, mode: DrillMode, session: LessonSessionManager) -> some View {
        let logic = BrickVoiceLogic(state: state, session: session)
        return BrickVoiceView(logic: logic)
    }
}
