import SwiftUI
import Combine

class PatternMCQLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let phonetic: String?
    let options: [String]
    let targetLanguage: String
    
    @Published var selectedOption: String?
    @Published var isCorrect: Bool?
    @Published var isAudioPlaying: Bool = false
    var isAnswered: Bool { isCorrect != nil }
    @Published var practiceLogic: PatternPracticeLogic?
    @Published var ghostLogic: GhostModeLogic?
    private var optionTargetVoiceDataByMeaning: [String: (id: String, data: String)] = [:]
    
    var onComplete: ((Bool) -> Void)?
    
    init(state: DrillState, engine: LessonEngine, onComplete: ((Bool) -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.onComplete = onComplete
        self.prompt = state.drillData.target
        self.phonetic = state.drillData.phonetic
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        // Options are now in TARGET language (L2). Always regenerate so we don't
        // accidentally reuse native-language options cached in `state.mcqOptions`.
        let candidates = engine.allPatterns.map { $0.target }
        self.options = MCQOptionGenerator.generateOptions(
            target: state.drillData.target,
            candidates: candidates,
            targetLanguage: engine.lessonData?.target_language ?? "en",
            validator: NeuralValidator()
        )

        // Build lookup so each tapped target-language option can play its own voice.
        // Keyed by `target` now (was `meaning`) since options carry target strings.
        var voiceLookup: [String: (id: String, data: String)] = [:]
        if let ownVoice = state.drillData.voice_data, !ownVoice.isEmpty {
            voiceLookup[state.drillData.target] = (state.patternId, ownVoice)
        }
        for pattern in engine.allPatterns {
            guard !voiceLookup.keys.contains(pattern.target) else { continue }
            if let data = pattern.voice_data, !data.isEmpty {
                voiceLookup[pattern.target] = (pattern.id, data)
            }
        }
        self.optionTargetVoiceDataByMeaning = voiceLookup
        
        // 4. Pre-Validation Check
         // State restoration removed

    }
    
    func selectOption(_ option: String) {
        guard isCorrect == nil else { 
            return 
        }
        
        playTappedOptionTargetAudio(for: option)
        selectedOption = option
        
        // Notify parents of input
        practiceLogic?.hasInput = true
        ghostLogic?.hasInput = true
    }

    private func playTappedOptionTargetAudio(for optionMeaning: String) {
        AudioManager.shared.stop()
        isAudioPlaying = true
        let tuple = optionTargetVoiceDataByMeaning[optionMeaning]
        let path = tuple?.data.trimmingCharacters(in: .whitespacesAndNewlines)
        let id = tuple?.id ?? state.patternId
        AudioManager.shared.playVoiceFromBackendIfAvailable(
            relativePath: (path?.isEmpty == false) ? path : nil,
            id: id
        ) { [weak self] in
            DispatchQueue.main.async {
                self?.isAudioPlaying = false
            }
        }
    }
    func bindToParent(practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil) {
        self.practiceLogic = practiceLogic
        self.ghostLogic = ghostLogic

        let has = self.hasInput
        if let practice = practiceLogic {
            practice.requestCheckAnswer = { [weak self] in self?.checkAnswer() }
            practice.requestClearInput = { [weak self] in self?.clearInput() }
            practice.hasInput = has
        }
        if let ghost = ghostLogic {
            ghost.requestCheckAnswer = { [weak self] in self?.checkAnswer() }
            ghost.requestClearInput = { [weak self] in self?.clearInput() }
            ghost.hasInput = has
        }
    }
    
    var hasInput: Bool {
        selectedOption != nil
    }
    
    func clearInput() {
        print("🧹 [PatternMCQLogic] Clearing input")
        self.selectedOption = nil
        self.isCorrect = nil

        practiceLogic?.isAnswered = false
        practiceLogic?.isCorrect = false
        
        ghostLogic?.isAnswered = false
        ghostLogic?.isCorrect = false
    }

    func checkAnswer() {
        guard let option = selectedOption, isCorrect == nil else { return }
        validateSelection(option)
    }
    
    private func validateSelection(_ option: String) {
        
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        
        // 1. Validate the FULL Pattern using the specific MCQ Validator.
        //    Options are now target-language strings, so validate against `target`.
        let validator = MCQValidator()
        let result = validator.validate(input: option, target: state.drillData.target, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        
        // 2. Perform Autonomous Granular Analysis (The Ripple Effect)
        // This directly updates brick mastery in the engine (+0.10 / -0.05)
        GranularAnalyzer.processGranularMastery(
            engine: engine,
            target: state.drillData.target,
            meaning: state.drillData.meaning,
            userInput: option,
            type: .multipleChoice,
            context: context
        )
        
        // Update Mastery (Only this pattern)
        // REDUCED DELTA: 0.15 (Gradual progression)

        if isCorrect {
            engine.updateMastery(id: state.patternId, delta: 0.20)
        } else {
            engine.updateMastery(id: state.patternId, delta: -0.05)
        }
        
        // 4. Trigger UI Side Effects
        self.isCorrect = isCorrect
        
        practiceLogic?.markDrillAnswered(isCorrect: isCorrect)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrect)
        // Keep MCQ audio on option tap only; avoid duplicate replay on CHECK.
        
        // Match standard behavior: Play target audio on correct
        // REMOVED per user request to avoid redundancy (Feedback already speaks it)
        // ✅ Notify Wrapper
    }
    
    func continueToNext() {
        AudioManager.shared.stop()
        onComplete?(isCorrect ?? true)
    }
    
    // MARK: - 🎙️ Voice Assets (Decentralized)
    
    // 1. Full Context
    
    

    
    
    // 3. Concise Feedback
    
    
    static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ Skipping Voice Override text (TTS Disabled): '\(override)'")
        }
    }
    
    private func playFeedback(isCorrect: Bool) {
        // No-op: post-check replay removed.
    }
    
    func playAudio() {
        let voiceData = state.drillData.voice_data
        
        self.isAudioPlaying = true
        AudioManager.shared.playVoiceFromBackendIfAvailable(
            relativePath: voiceData,
            id: state.patternId
        ) { [weak self] in
            DispatchQueue.main.async {
                self?.isAudioPlaying = false
            }
        }
    }
    
    @ViewBuilder
    static func view(
        for state: DrillState,
        mode: DrillMode,
        engine: LessonEngine,
        practiceLogic: PatternPracticeLogic? = nil,
        ghostLogic: GhostModeLogic? = nil,
        onComplete: ((Bool) -> Void)? = nil
    ) -> some View {
        PatternMCQView(
            state: state, 
            engine: engine, 
            practiceLogic: practiceLogic, 
            ghostLogic: ghostLogic, 
            onComplete: onComplete
        )
            .onAppear {
                PatternMCQLogic.playIntro(drill: state, engine: engine, mode: mode)
            }
    }
}
