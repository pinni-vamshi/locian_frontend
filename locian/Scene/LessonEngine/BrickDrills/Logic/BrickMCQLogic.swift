import SwiftUI
import Combine

class BrickMCQLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only - no UI strings
    let options: [String]
    let optionPhonetics: [String: String]
    let prompt: String
    let targetLanguage: String
    
    @Published var selectedOption: String?
    @Published var isCorrect: Bool?
    var onComplete: (() -> Void)?
    weak var patternIntroLogic: PatternIntroLogic?  // ✅ Sync: Recap Phase reporting
    weak var lessonDrillLogic: LessonDrillLogic?    // ✅ Sync: Practice Phase (Ghost) reporting
    
    init(state: DrillState, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, lessonDrillLogic: LessonDrillLogic? = nil, onComplete: (() -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.patternIntroLogic = patternIntroLogic
        self.lessonDrillLogic = lessonDrillLogic
        self.onComplete = onComplete
        let targetLanguageCode = engine.lessonData?.target_language ?? "es"
        
        // BRICK MCQ: Meaning (L1) -> Word (L2)
        // This provides a clear "Discovery" flow:
        // "How do I say [English]?" -> Select [Spanish]
        self.prompt = state.drillData.meaning
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: targetLanguageCode).english
        
        // 2. Generate Options
        if let existing = state.mcqOptions {
            self.options = existing
        } else {
            // ✅ Use engine.allBricks to get bricks from ALL groups
            let allBricksData = engine.allBricks
            let allBricks = (allBricksData?.constants ?? []) + 
                           (allBricksData?.variables ?? []) + 
                           (allBricksData?.structural ?? [])
            
            // Meaning (L1) prompt -> Word (L2) options
            let candidates = Array(Set(allBricks.map { $0.word }))
            
            self.options = MCQOptionGenerator.generateNativeOptions(
                targetMeaning: state.drillData.target,
                candidates: candidates,
                validator: NeuralValidator()
            )
        }
        
        // 3. Populate Phonetics
        var phoneticMap: [String: String] = [:]
        let allItems = (engine.allBricks?.constants ?? []) + 
                      (engine.allBricks?.variables ?? []) + 
                      (engine.allBricks?.structural ?? [])
        
        for option in self.options {
            if let match = allItems.first(where: { $0.word == option }) {
                phoneticMap[option] = match.phonetic
            }
        }
        self.optionPhonetics = phoneticMap
        
        print("   🧩 [BrickMCQLogic] Init for brick: \(state.id) | Options: \(self.options)")
    }
    
    var correctOption: String {
        return state.drillData.target
    }
    
    func selectOption(_ option: String) {
        print("   🧩 [BrickMCQLogic] selectOption called with: \(option)")
        
        // ✅ ALWAYS Speak what the user JUST tapped (even if already answered)
        let language = engine.lessonData?.target_language ?? "es-ES"
        AudioManager.shared.speak(text: option, language: language)
        
        guard isCorrect == nil else { 
            print("   🧩 [BrickMCQLogic] selectOption - answer already recorded, replaying audio only")
            return 
        }
        
        selectedOption = option
        validateSelection(option)
    }
    
    private func validateSelection(_ option: String) {
        print("   🧩 [BrickMCQLogic] validateSelection: \(option)")
        let actualTarget = state.drillData.target
        
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        
        let validator = MCQValidator()
        let result = validator.validate(input: option, target: actualTarget, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        
        print("   🧩 [BrickMCQLogic] Validation Result: \(isCorrect)")
        
        // ✅ UI TRIGGER - Update local state to show green/red card backgrounds
        self.isCorrect = isCorrect
        
        // ✅ UNIFIED REPORTING - Notify the active parent manager
        patternIntroLogic?.markBrickAnswered(isCorrect: isCorrect)
        lessonDrillLogic?.markDrillAnswered(isCorrect: isCorrect)
        
        // Update Mastery (Only this brick)
        let brickId = state.id.replacingOccurrences(of: "INT-", with: "")
        let delta = isCorrect ? 0.20 : -0.10
        engine.updateMastery(id: brickId, delta: delta)
    }
    
    func playAudio() {
        let text = state.drillData.target
        let language = engine.lessonData?.target_language ?? "es-ES"
        AudioManager.shared.speak(text: text, language: language)
    }
    
    func continueToNext() {
        print("   🧩 [BrickMCQLogic] continueToNext called")
        if let onComplete = onComplete {
            print("   🧩 [BrickMCQLogic] Calling onComplete closure")
            onComplete()
        } else {
            print("   🧩 [BrickMCQLogic] Calling finishPattern (fallback)")
            engine.orchestrator?.finishPattern()
        }
    }
    
    @ViewBuilder
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, lessonDrillLogic: LessonDrillLogic? = nil, onComplete: (() -> Void)? = nil) -> some View {
        if let introLogic = patternIntroLogic {
            // ✅ Direction A: Pattern Intro (Recap) -> Mini Interaction
            // Hiding Prompt because PatternIntroView Header + Tap Strip already shows Meaning.
            BrickMCQInteraction(drill: state, engine: engine, showPrompt: false, patternIntroLogic: introLogic, onComplete: onComplete)
        } else {
            // ✅ Direction B: Ghost Mode (Practice) -> Full View
            BrickMCQView(state: state, engine: engine, lessonDrillLogic: lessonDrillLogic, onComplete: onComplete)
        }
    }
}
