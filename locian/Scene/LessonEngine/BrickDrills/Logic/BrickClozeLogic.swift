import SwiftUI
import Combine

class BrickClozeLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let targetLanguage: String
    
    // Inline Support
    let sentencePartA: String?
    let sentencePartB: String?
    let isInline: Bool
    
    @Published var userInput: String = ""
    @Published var isCorrect: Bool?
    
    var onComplete: (() -> Void)?
    weak var patternIntroLogic: PatternIntroLogic?  // ✅ NEW: Reference to notify pattern intro
    
    init(state: DrillState, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil) {
        self.state = state
        self.engine = engine
        self.patternIntroLogic = patternIntroLogic
        
        let target = state.drillData.target
        
        if let context = state.contextSentence, !context.isEmpty {
            // Case-insensitive range finding
            if let range = context.range(of: target, options: .caseInsensitive) {
                self.sentencePartA = String(context[..<range.lowerBound])
                self.sentencePartB = String(context[range.upperBound...])
                self.isInline = true
                self.prompt = context.replacingOccurrences(of: target, with: "_______", options: .caseInsensitive)
            } else {
                // Fallback if target not found in context (shouldn't happen with system logic)
                self.sentencePartA = nil
                self.sentencePartB = nil
                self.isInline = false
                self.prompt = context.replacingOccurrences(of: target, with: "_______", options: .caseInsensitive)
            }
        } else {
            self.sentencePartA = nil
            self.sentencePartB = nil
            self.isInline = false
            self.prompt = state.drillData.meaning // Fallback
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
        
        // ✅ NOTIFY PATTERN INTRO - Tell parent view to show continue button
        patternIntroLogic?.markBrickAnswered(isCorrect: isCorrect)
        
        playAudio()
    }
    
    func playAudio() {
        let text = state.drillData.target
        let language = engine.lessonData?.target_language ?? "es-ES"
        AudioManager.shared.speak(text: text, language: language)
    }
    
    func continueToNext() {
        if let onComplete = onComplete {
            onComplete()
        } else {
            engine.orchestrator?.finishPattern()
        }
    }
    
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, onComplete: (() -> Void)? = nil) -> some View {
        let logic = BrickClozeLogic(state: state, engine: engine)
        logic.onComplete = onComplete
        return BrickClozeView(logic: logic)
    }
}
