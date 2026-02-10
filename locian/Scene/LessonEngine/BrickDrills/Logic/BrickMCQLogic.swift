import SwiftUI
import Combine

class BrickMCQLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only - no UI strings
    let options: [String]
    let prompt: String
    let targetLanguage: String
    
    @Published var selectedOption: String?
    @Published var isCorrect: Bool?
    
    var onComplete: (() -> Void)?
    init(state: DrillState, engine: LessonEngine) {
        self.state = state
        self.engine = engine
        let targetLanguageCode = engine.lessonData?.target_language ?? "es"
        
        // BRICK MCQ: Meaning (L1) -> Word (L2)
        // This provides a clear "Discovery" flow:
        // "How do I say [English]?" -> Select [Spanish]
        self.prompt = state.drillData.meaning
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: targetLanguageCode).english
        
        // 2. Generate Options
        if let existing = state.mcqOptions {
            self.options = existing
            print("   🧱 [BrickMCQ] Loaded \(existing.count) options from State Cache.")
        } else {
            print("   🧱 [BrickMCQ] Mode: L1->L2 | Generating options...")
            
            // Collect ALL bricks from ALL groups to ensure a rich distractor pool
            var allBricks: [BrickItem] = []
            
            // 1. Check legacy top-level bricks
            if let legacyBricks = engine.lessonData?.bricks {
                allBricks += (legacyBricks.constants ?? [])
                allBricks += (legacyBricks.variables ?? [])
                allBricks += (legacyBricks.structural ?? [])
            }
            
            // 2. Check all "LEGO" groups (The primary source)
            // Includes structural (Ins/Instrumental) group bricks as requested
            for group in engine.groups {
                if let bricks = group.bricks {
                    allBricks += (bricks.constants ?? [])
                    allBricks += (bricks.variables ?? [])
                    allBricks += (bricks.structural ?? [])
                }
            }
            
            // Meaning (L1) prompt -> Word (L2) options
            let candidates = Array(Set(allBricks.map { $0.word }))
            print("   🧱 [BrickMCQ] Distractor pool gathered: \(candidates.count) distinct words (Includes Ins groups).")
            
            self.options = MCQOptionGenerator.generateOptions(
                target: state.drillData.target,
                candidates: candidates,
                targetLanguage: targetLanguageCode,
                validator: NeuralValidator()
            )
            print("   🧱 [BrickMCQ] Generated \(self.options.count) options (Target: \(state.drillData.target)).")
        }
        
        // 3. Pre-Validation Check
        // 3. Pre-Validation Check
         // State restoration removed as engine no longer tracks activeState

    }
    
    var correctOption: String {
        return state.drillData.target
    }
    
    func selectOption(_ option: String) {
        guard isCorrect == nil else { return }
        print("   👉 [BrickMCQ] User selected: \(option)")
        
        // Speak what the user JUST tapped
        // Speak what the user JUST tapped
        let language = engine.lessonData?.target_language ?? "es-ES"
        AudioManager.shared.speak(text: option, language: language)
        
        selectedOption = option
        validateSelection(option)
    }
    
    private func validateSelection(_ option: String) {
        let actualTarget = state.drillData.target
        
        print("      - Validating selection [Brick MCQ] (L2-Target)...")
        
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        
        let validator = MCQValidator()
        let result = validator.validate(input: option, target: actualTarget, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        
        // Update Mastery (Only this brick)
        let brickId = state.id.replacingOccurrences(of: "INT-", with: "")
        let delta = isCorrect ? 0.20 : -0.10
        engine.updateMastery(id: brickId, delta: delta)
        
        // UI Effects
        // UI Effects - Handled by Engine state update
        // UI Effects
        // UI Effects - Handled by Engine state update
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
            print("   ⚠️ [BrickMCQ] No completion callback provided. Flow stalled.")
        }
    }
    
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, onComplete: (() -> Void)? = nil) -> some View {
        let logic = BrickMCQLogic(state: state, engine: engine)
        logic.onComplete = onComplete
        return BrickMCQView(logic: logic)
    }
}
