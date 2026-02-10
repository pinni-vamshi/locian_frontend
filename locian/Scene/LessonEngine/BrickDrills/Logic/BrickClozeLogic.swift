import SwiftUI
import Combine

class BrickClozeLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let targetLanguage: String
    
    @Published var userInput: String = ""
    @Published var isCorrect: Bool?
    
    var onComplete: (() -> Void)?
    
    init(state: DrillState, engine: LessonEngine) {
        self.state = state
        self.engine = engine
        
        // Generate Cloze Prompt: "Es mi _______"
        // If context exists, mask the target word. Otherwise fallback to meaning (Typing style).
        if let context = state.contextSentence, !context.isEmpty {
            let target = state.drillData.target
            // Case-insensitive replacement
            let masked = context.replacingOccurrences(of: target, with: "_______", options: .caseInsensitive)
            self.prompt = masked
            print("   🧩 [BrickCloze] Mode: Context Masking")
            print("      - Original: '\(context)'")
            print("      - Masked:   '\(masked)'")
        } else {
            self.prompt = state.drillData.meaning // Fallback
            print("   🧩 [BrickCloze] Mode: Meaning Fallback (No Context Available)")
        }
        
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        // Restore State if engine already has result (Fix for button resetting)
        // Restore State logic removed as engine no longer tracks activeState history here
         // This should be handled by the Orchestrator or a local state manager in the future if needed.
    }
    
    var hasInput: Bool {
        !userInput.isEmpty
    }
    
    func checkAnswer() {
        guard isCorrect == nil && !userInput.isEmpty else { return }
        print("   👉 [BrickCloze] Checking answer: '\(userInput)'")
        print("      - Validating cloze [Brick Cloze]...")
        
        // Save input to session for persistence
        // Save input if needed (skipped for now as we removed session.activeInput)
        
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        
        // Bricks always match Foreign Word
        let validator = TypingValidator()
        let result = validator.validate(input: userInput, target: state.drillData.target, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)

        
        // Update Mastery (Only this brick)
        let brickId = state.id.replacingOccurrences(of: "INT-", with: "")
        let delta = isCorrect ? 0.30 : -0.15
        engine.updateMastery(id: brickId, delta: delta)
        
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
        let logic = BrickClozeLogic(state: state, engine: engine)
        return BrickClozeView(logic: logic)
    }
}
