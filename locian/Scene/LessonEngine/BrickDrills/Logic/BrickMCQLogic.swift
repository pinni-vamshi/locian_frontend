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
    var onComplete: ((Bool) -> Void)?
    weak var patternIntroLogic: PatternIntroLogic? 
    weak var practiceLogic: PatternPracticeLogic?
    weak var ghostLogic: GhostModeLogic?
    
    init(state: DrillState, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.patternIntroLogic = patternIntroLogic
        self.practiceLogic = practiceLogic
        self.ghostLogic = ghostLogic
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
        patternIntroLogic?.markBrickAnswered(isCorrect: isCorrect, input: option)
        practiceLogic?.markDrillAnswered(isCorrect: isCorrect)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrect)
        
        // Update Mastery (Only this brick)
        let brickId = state.id.replacingOccurrences(of: "INT-", with: "")
            .replacingOccurrences(of: "PRACTICE-MISTAKE-", with: "")
            .replacingOccurrences(of: "GHOST-", with: "")
        
        let delta = isCorrect ? 0.10 : -0.05
        engine.updateMastery(id: brickId, delta: delta)
        
        // ✅ Localized Feedback
        playFeedback(isCorrect: isCorrect)
    }
    
    // MARK: - 🎙️ Voice Assets (Decentralized)
    
    // 1. Full Context
    private static let fullIntroVoices = [
        "Select the correct meaning for \"%@\" in %@.",
        "Which translation matches \"%@\" in %@?",
        "Match the meaning of \"%@\" in %@.",
        "Pick the correct way to say %@ in %@",
        "How do we say %@ in %@"
    ]
    
    private static let correctVoices = [
        "You are right! \"%@\" in %@ is \"%@\"",
        "Exactly. \"%@\" in %@ translates to \"%@\"",
        "Spot on. In %@, \"%@\" matches \"%@\"",
        "That's correct. We say \"%@\" for \"%@\" in %@",
        "Perfect match. \"%@\" in %@ is \"%@\""
    ]
    
    // 3. Concise Feedback
    private static let wrongVoices = [
        "Actually, \"%@\" in %@ is \"%@\"",
        "The translation for \"%@\" in %@ is \"%@\"",
        "Note the %@ word for \"%@\" is \"%@\"",
        "The match for %@ in %@ is \"%@\"",
        "Factual correction: \"%@\" in %@ is \"%@\""
    ]
    
    private static var introIndex = 0
    
    static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ [BrickMCQ] Using Voice Override: '\(override)'")
            AudioManager.shared.speak(segments: [.init(text: override, language: drill.voiceLanguage ?? "en-US")])
            return
        }
        
        guard !drill.suppressIntroAudio else { return }
        
        let languageCode = engine.lessonData?.target_language ?? "es"
        let languageName = TargetLanguageMapping.shared.getDisplayNames(for: languageCode).english
        let meaning = drill.drillData.meaning
        
        // Sequential Iteration (1-by-1)
        let index = introIndex % fullIntroVoices.count
        let template = fullIntroVoices[index]
        introIndex += 1
        
        // Simple Interpolation
        var text = template.replacingOccurrences(of: "%@", with: meaning, range: template.range(of: "%@"))
        text = text.replacingOccurrences(of: "%@", with: languageName)
        
        AudioManager.shared.speak(segments: [.init(text: text, language: "en-US")])
    }
    
    private func playFeedback(isCorrect: Bool) {
        let answer = state.drillData.target
        let meaning = state.drillData.meaning
        let targetLang = targetLanguage
        
        let template = isCorrect ? 
            (BrickMCQLogic.correctVoices.randomElement() ?? "Correct! \"%@\" in %@ is \"%@\"") :
            (BrickMCQLogic.wrongVoices.randomElement() ?? "Actually, \"%@\" in %@ is \"%@\"")
        
        // Use robust interpolation for first N-1 placeholders
        var textToSpeak = template.replacingOccurrences(of: "%@", with: meaning, range: template.range(of: "%@"))
        if let langRange = textToSpeak.range(of: "%@") {
            textToSpeak = textToSpeak.replacingOccurrences(of: "%@", with: targetLang, range: langRange)
        }
        
        let finalComponents = textToSpeak.components(separatedBy: "\"%@\"")
        let langCode = self.engine.lessonData?.target_language ?? "es-ES"
        
        if finalComponents.count >= 2 {
            AudioManager.shared.speak(segments: [
                .init(text: finalComponents[0], language: "en-US"),
                .init(text: answer, language: langCode)
            ])
        } else {
            AudioManager.shared.speak(segments: [
                .init(text: isCorrect ? "Correct! " : "Actually, it is ", language: "en-US"),
                .init(text: answer, language: langCode)
            ])
        }
    }
    
    func playAudio() {
        let text = state.drillData.target
        let language = engine.lessonData?.target_language ?? "es-ES"
        AudioManager.shared.speak(segments: [.init(text: text, language: language)])
    }
    
    func continueToNext() {
        print("   🧩 [BrickMCQLogic] continueToNext called")
        onComplete?(isCorrect ?? true)
    }
    
    @ViewBuilder
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) -> some View {
        if let introLogic = patternIntroLogic {
            // ✅ Direction A: Pattern Intro (Recap) -> Mini Interaction
            // Hiding Prompt because PatternIntroView Header + Tap Strip already shows Meaning.
            BrickMCQInteraction(drill: state, engine: engine, showPrompt: false, patternIntroLogic: introLogic, onComplete: onComplete)
                .onAppear {
                    // 🔊 Trigger Drill-Specific Intro with Context + Language
                    BrickMCQLogic.playIntro(drill: state, engine: engine, mode: mode)
                }
        } else {
            // ✅ Direction B: Ghost Mode (Practice) -> Full View
            BrickMCQView(state: state, engine: engine, patternIntroLogic: patternIntroLogic, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
                .onAppear {
                     // 🔊 Trigger Drill specific intro for Ghost Mode too?
                     // User said "MCQ starting point... should be different".
                     // For now, let's enable it here too.
                     BrickMCQLogic.playIntro(drill: state, engine: engine, mode: mode)
                }
        }
    }
}

