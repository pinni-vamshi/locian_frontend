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
            // Sync input state across potential parents for Footer Button
            patternIntroLogic?.currentBrickHasInput = hasText
            practiceLogic?.hasInput = hasText
            ghostLogic?.hasInput = hasText
        }
    }
    @Published var isCorrect: Bool?
    
    // Similar Words Logic
    @Published var activeWord: String?
    @Published var isLoadingSimilar: Bool = false
    @Published var similarWordsCache: [String: SimilarWordsData] = [:]
    @Published var exploreWords: [(word: String, meaning: String, score: Double)] = [] // Top 3
    @Published var searchResults: [SimilarWord] = []
    @Published var selectedExploreWord: String?
    @Published var isSearching: Bool = false
    @Published var validBrickWords: Set<String> = []

    var onComplete: ((Bool) -> Void)? // ✅ Direct closure reference
    var appState: AppStateManager?
    weak var patternIntroLogic: PatternIntroLogic?
    weak var practiceLogic: PatternPracticeLogic?
    weak var ghostLogic: GhostModeLogic?
    
    init(state: DrillState, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.patternIntroLogic = patternIntroLogic
        self.practiceLogic = practiceLogic
        self.ghostLogic = ghostLogic
        // We might still receive lessonDrillLogic from legacy callers, but we prefer onComplete.
        // If onComplete is nil, we can't do much, so we rely on the caller to provide it.
        self.onComplete = onComplete
        
        self.prompt = state.drillData.meaning
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        computeValidBricks()
    }
    
    func bindToParent() {
        // ✅ Bridge Actions to whichever parent is active
        let checkAction: () -> Void = { [weak self] in self?.checkAnswer() }
        
        patternIntroLogic?.requestCheckAnswer = checkAction
        practiceLogic?.requestCheckAnswer = checkAction
        ghostLogic?.requestCheckAnswer = checkAction

        // Sync initial state
        let hasText = !userInput.isEmpty
        patternIntroLogic?.currentBrickHasInput = hasText
        practiceLogic?.hasInput = hasText
        ghostLogic?.hasInput = hasText
    }
    
    var hasInput: Bool {
        !userInput.isEmpty
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
        let isCorrect = (result == .correct || result == .meaningCorrect)

        
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
        let delta = isCorrect ? 0.15 : -0.05
        engine.updateMastery(id: state.patternId, delta: delta)
        
        // 4. Trigger UI Side Effects
        self.isCorrect = isCorrect
        
        // ✅ Localized Feedback (with speaking nudge)
        playFeedback(isCorrect: isCorrect)
        
        playAudio()
        
        // ✅ Notify Wrapper
        patternIntroLogic?.markBrickAnswered(isCorrect: isCorrect, input: userInput)
        practiceLogic?.markDrillAnswered(isCorrect: isCorrect)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrect)
    }
    
    // MARK: - 🎙️ Voice Assets (Decentralized)
    
    // 1. Full Context
    
    

    
    
    // 3. Concise Feedback
    
    
    static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ Using Voice Override: '\(override)'")
            AudioManager.shared.speak(text: override, language: drill.voiceLanguage ?? "en-US")
        }
    }
    
    private func playFeedback(isCorrect: Bool) {
        if isCorrect {
            playAudio()
        }
    }
    
    func playAudio() {
        let text = state.drillData.target
        let language = engine.lessonData?.target_language ?? "es-ES"
        
        self.patternIntroLogic?.isAudioPlaying = true
        self.practiceLogic?.isAudioPlaying = true
        self.ghostLogic?.isAudioPlaying = true
        
        AudioManager.shared.speak(text: text, language: language) { [weak self] in
            DispatchQueue.main.async {
                self?.patternIntroLogic?.isAudioPlaying = false
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
    
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) -> some View {
        // View now owns the logic creation via StateObject
        return PatternTypingView(state: state, engine: engine, patternIntroLogic: patternIntroLogic, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
            .onAppear {
                PatternTypingLogic.playIntro(drill: state, engine: engine, mode: mode)
            }
    }
    
    func computeValidBricks() {
        let targetCode = engine.lessonData?.target_language ?? "es"
        let nativeCode = engine.lessonData?.user_language ?? "en"

        // Use SemanticFilterService to get actual scores for all candidate bricks
        // Use threshold 0.0 here because we want to see ALL matches to rank them
        // ✅ NOW USING GROUP-SPECIFIC BRICKS ONLY
        let brickMatches = SemanticFilterService.getFilteredBricks(
            text: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: engine.activeGroupBricks,
            targetLanguage: targetCode,
            nativeLanguage: nativeCode,
            validator: NeuralValidator(),
            threshold: 0.0
        )
        
        let brickIds = brickMatches.map { $0.brickId }
        
        // ✅ NOW USING GROUP-SPECIFIC BRICKS ONLY
        if let groupBricks = engine.activeGroupBricks {
            let allBricks = (groupBricks.constants ?? []) + 
                           (groupBricks.variables ?? []) + 
                           (groupBricks.structural ?? [])
            
            for brickId in brickIds {
                if let brick = allBricks.first(where: { $0.id == brickId }) {
                    validBrickWords.insert(brick.word.lowercased())
                }
            }
            
            // NEW: Identify Top 3 Explore Words (ALREADY WEIGHTED by Laser)
            // The brickMatches already contain the Joint Neural Score (JNS)
            // so we don't need to tag or filter for nouns/verbs manually anymore.
            
            let scoredExplore = brickMatches.compactMap { match -> (String, String, Double)? in
                if let brick = allBricks.first(where: { $0.id == match.brickId }) {
                    return (brick.word, brick.meaning, match.similarityScore)
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
