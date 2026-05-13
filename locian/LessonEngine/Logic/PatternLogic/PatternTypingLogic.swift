import SwiftUI
import Combine

class PatternTypingLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine
    
    // Data only
    let prompt: String
    let targetLanguage: String
    
    @Published var userInput: String = "" {
        didSet {
            let hasText = !userInput.isEmpty
            practiceLogic?.hasInput = hasText
            ghostLogic?.hasInput = hasText
        }
    }
    @Published var isCorrect: Bool?
    var isAnswered: Bool { isCorrect != nil }

    // Similar Words Logic
    @Published var activeWord: String?
    @Published var isLoadingSimilar: Bool = false
    @Published var similarWordsCache: [String: SimilarWordsData] = [:]
    @Published var exploreWords: [(word: String, meaning: String, score: Double)] = []
    @Published var searchResults: [SimilarWord] = []
    @Published var selectedExploreWord: String?
    @Published var isSearching: Bool = false
    @Published var validBrickWords: Set<String> = []
    @Published var practiceLogic: PatternPracticeLogic?
    @Published var ghostLogic: GhostModeLogic?
    @Published var isAudioPlaying: Bool = false

    var onComplete: ((Bool) -> Void)? // ✅ Direct closure reference
    var appState: AppStateManager?
    
    init(state: DrillState, engine: LessonEngine, onComplete: ((Bool) -> Void)? = nil) {
        self.state = state
        self.engine = engine
        // We might still receive lessonDrillLogic from legacy callers, but we prefer onComplete.
        // If onComplete is nil, we can't do much, so we rely on the caller to provide it.
        self.onComplete = onComplete
        
        self.prompt = state.drillData.meaning
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        computeValidBricks()
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
    
    func clearInput() {
        self.userInput = ""
        self.isCorrect = nil

        practiceLogic?.isAnswered = false
        practiceLogic?.isCorrect = false
        
        ghostLogic?.isAnswered = false
        ghostLogic?.isCorrect = false
    }
    
    var hasInput: Bool {
        !userInput.isEmpty
    }
    
    func continueToNext() {
        AudioManager.shared.stop()
        onComplete?(isCorrect ?? true)
    }
    
    func checkAnswer() {
        guard isCorrect == nil && !userInput.isEmpty else { return }
        
        // Save input to session for persistence
        // Save input to session for persistence
        // engine.activeInput = userInput // Removed
        
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        
        // 1. Validate the FULL Pattern using Typing Validator
        let validator = TypingValidator()
        let result = validator.validate(input: userInput, target: state.drillData.target, context: context)
        let isCorrectResult = (result == .correct || result == .meaningCorrect)

        
        // 2. Perform Autonomous Granular Analysis (The Ripple Effect)
        // This directly updates brick mastery in the engine (+0.10 / -0.05)
        GranularAnalyzer.processGranularMastery(
            engine: engine,
            target: state.drillData.target,
            meaning: state.drillData.meaning,
            userInput: userInput,
            type: .typing,
            context: context
        )
        
        // 3. Update Mastery Directly in Engine (Only this pattern)
        // REDUCED DELTA: 0.15 (Gradual progression)

        if isCorrectResult {
            engine.updateMastery(id: state.patternId, delta: 0.20)
        } else {
            engine.updateMastery(id: state.patternId, delta: -0.05)
        }
        
        // 4. Trigger UI Side Effects
        self.isCorrect = isCorrectResult
        
        practiceLogic?.markDrillAnswered(isCorrect: isCorrectResult)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrectResult)
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
        self.practiceLogic?.isAudioPlaying = true
        self.ghostLogic?.isAudioPlaying = true

        AudioManager.shared.playVoiceFromBackendIfAvailable(
            relativePath: voiceData,
            id: state.patternId
        ) { [weak self] in
            DispatchQueue.main.async {
                self?.isAudioPlaying = false
                self?.practiceLogic?.isAudioPlaying = false
                self?.ghostLogic?.isAudioPlaying = false
            }
        }
    }
    
    func selectExploreWord(_ word: String) {
        selectedExploreWord = word
        fetchSimilarWords(for: word)
    }
    
    // ...
    
    @ViewBuilder
    static func view(
        for state: DrillState,
        mode: DrillMode,
        engine: LessonEngine,
        practiceLogic: PatternPracticeLogic? = nil,
        ghostLogic: GhostModeLogic? = nil,
        onComplete: ((Bool) -> Void)? = nil
    ) -> some View {
        PatternTypingView(
            state: state, 
            engine: engine, 
            practiceLogic: practiceLogic, 
            ghostLogic: ghostLogic, 
            onComplete: onComplete
        )
            .onAppear {
                PatternTypingLogic.playIntro(drill: state, engine: engine, mode: mode)
            }
    }
    
    func computeValidBricks() {
        let targetCode = engine.lessonData?.target_language ?? "es"
        let nativeCode = engine.lessonData?.user_language ?? "en"

        // ✅ V5.5: Use the new Laser (ContentAnalyzer) directly. 
        // This gives us the final, normalized neural scores for all bricks in the sentence.
        let brickMatches = ContentAnalyzer.findRelevantBricksWithSimilarity(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: engine.activeGroupBricks,
            targetLanguage: targetCode,
            nativeLanguage: nativeCode
        )
        
        let brickIds = brickMatches.map { $0.id }
        
        // Use Group-Specific Bricks to materialize items
        if let groupBricks = engine.activeGroupBricks {
            let allBricks = (groupBricks.constants ?? []) + 
                           (groupBricks.variables ?? []) + 
                           (groupBricks.structural ?? [])
            
            for brickId in brickIds {
                if let brick = allBricks.first(where: { $0.id == brickId }) {
                    validBrickWords.insert(brick.word.lowercased())
                }
            }
            
            // Identify Top 3 Explore Words (Already weighted by the Brain)
            let scoredExplore = brickMatches.compactMap { match -> (String, String, Double)? in
                if let brick = allBricks.first(where: { $0.id == match.id }) {
                    return (brick.word, brick.meaning, match.score)
                }
                return nil
            }
            .sorted(by: { $0.2 > $1.2 })
            
            self.exploreWords = Array(scoredExplore.prefix(3))
        }
    }
    
    func fetchSimilarWords(for word: String) {
        activeWord = word
        if let cached = similarWordsCache[word] {
            self.searchResults = cached.similar_words ?? []
            return 
        }
        
        guard let token = appState?.authToken else { return }
        
        isSearching = true
        GetSimilarWordsService.shared.getSimilarWords(
            word: word,
            targetLanguage: engine.lessonData?.target_language ?? "es",
            userLanguage: engine.lessonData?.user_language ?? "en",
            situation: engine.lessonData?.micro_situation,
            sentence: state.drillData.target,
            sessionToken: token
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSearching = false
                switch result {
                case .success(let response):
                    if let data = response.data {
                        // Store using original_word to match key
                        self?.similarWordsCache[word] = data
                        self?.searchResults = data.similar_words ?? []
                    }
                case .failure:
                    self?.searchResults = []
                }
            }
        }
    }
    
}
