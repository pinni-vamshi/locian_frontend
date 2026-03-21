import SwiftUI
import Combine

struct Token: Identifiable {
    let id = UUID()
    let text: String
    var isUsed: Bool = false
}

class PatternBuilderLogic: ObservableObject {
    @Published var selectedTokens: [Token] = [] {
        didSet {
            let hasInput = !selectedTokens.isEmpty
            // Sync input state across potential parents for Footer Button
            patternIntroLogic?.currentBrickHasInput = hasInput
            practiceLogic?.hasInput = hasInput
            ghostLogic?.hasInput = hasInput
        }
    }
    @Published var availableTokens: [Token] = []
    @Published var checked: Bool = false
    @Published var activeWord: String?
    @Published var isLoadingSimilar: Bool = false
    @Published var similarWordsCache: [String: SimilarWordsData] = [:]
    @Published var validBrickWords: Set<String> = []
    @Published var exploreWords: [(word: String, meaning: String, score: Double)] = [] // Top 3
    @Published var searchResults: [SimilarWord] = []
    @Published var selectedExploreWord: String?
    @Published var isSearching: Bool = false
    
    let state: DrillState
    let engine: LessonEngine
    let prompt: String
    let targetLanguage: String
    var appState: AppStateManager?
    
    var onComplete: ((Bool) -> Void)? // ✅ Direct closure
    weak var patternIntroLogic: PatternIntroLogic?
    weak var practiceLogic: PatternPracticeLogic?
    weak var ghostLogic: GhostModeLogic?
    
    init(state: DrillState, engine: LessonEngine, appState: AppStateManager?, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.appState = appState
        self.patternIntroLogic = patternIntroLogic
        self.practiceLogic = practiceLogic
        self.ghostLogic = ghostLogic
        self.onComplete = onComplete
        self.prompt = state.drillData.meaning
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        setupTokens()
        computeValidBricks()
    }
    
    func bindToParent() {
        // ✅ Bridge Actions to whichever parent is active
        let checkAction: () -> Void = { [weak self] in self?.checkAnswer() }
        let clearAction: () -> Void = { [weak self] in 
            while self?.selectedTokens.isEmpty == false {
                self?.removeToken(at: 0)
            }
        }
        
        patternIntroLogic?.requestCheckAnswer = checkAction
        patternIntroLogic?.requestClearInput = clearAction
        
        practiceLogic?.requestCheckAnswer = checkAction
        practiceLogic?.requestClearInput = clearAction
        
        ghostLogic?.requestCheckAnswer = checkAction
        ghostLogic?.requestClearInput = clearAction

        // Sync initial state
        let hasInput = !selectedTokens.isEmpty
        patternIntroLogic?.currentBrickHasInput = hasInput
        practiceLogic?.hasInput = hasInput
        ghostLogic?.hasInput = hasInput
    }
    
    private func setupTokens() {
        let words = state.drillData.target.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .shuffled()
        availableTokens = words.map { Token(text: $0, isUsed: false) }
    }
    
    func selectToken(at index: Int) {
        guard index < availableTokens.count else { return }
        var token = availableTokens[index]
        
        // Speak what the user JUST tapped
        // Speak what the user JUST tapped
        let language = engine.lessonData?.target_language ?? "es-ES"
        AudioManager.shared.speak(text: token.text, language: language)
        
        token.isUsed = true
        availableTokens[index] = token
        selectedTokens.append(token)
    }
    
    func removeToken(at index: Int) {
        guard index < selectedTokens.count else { return }
        let token = selectedTokens[index]
        selectedTokens.remove(at: index)
        
        if let availableIndex = availableTokens.firstIndex(where: { $0.id == token.id }) {
            availableTokens[availableIndex].isUsed = false
        }
    }
    
    
    var isCorrect: Bool? {
        guard checked else { return nil }
        // Determine correctness from validation result stored in @Published property
        return _isCorrectResult
    }
    
    @Published private var _isCorrectResult: Bool?
    
    func checkAnswer() {
        checked = true
        
        let userInput = selectedTokens.map { $0.text }.joined(separator: " ")
        
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
            type: .typing, // Builder validates like typing
            context: context
        )
        
        // 3. Update Mastery Directly in Engine (Only this pattern)
        // REDUCED DELTA: 0.20 (Gradual progression for Builder)
        let delta = isCorrect ? 0.20 : -0.05
        engine.updateMastery(id: state.patternId, delta: delta)
        
        // 4. Trigger UI Side Effects in Engine
        // 4. Trigger UI Side Effects in Engine
        self._isCorrectResult = isCorrect
        
        // ✅ Localized Feedback
        playFeedback(isCorrect: isCorrect)
        
        // Match standard behavior: Play target audio on correct
        if isCorrect {
            let language = engine.lessonData?.target_language ?? "es-ES"
            
            self.patternIntroLogic?.isAudioPlaying = true
            self.practiceLogic?.isAudioPlaying = true
            self.ghostLogic?.isAudioPlaying = true
            
            AudioManager.shared.speak(text: state.drillData.target, language: language) { [weak self] in
                DispatchQueue.main.async {
                    self?.patternIntroLogic?.isAudioPlaying = false
                    self?.practiceLogic?.isAudioPlaying = false
                    self?.ghostLogic?.isAudioPlaying = false
                }
            }
        }
        
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
            let language = engine.lessonData?.target_language ?? "es-ES"
            AudioManager.shared.speak(text: state.drillData.target, language: language)
        }
    }
    
    func selectExploreWord(_ word: String) {
        selectedExploreWord = word
        fetchSimilarWords(for: word)
    }
    
    // ...
    
    
    // ...
    
    static func view(for state: DrillState, mode: DrillMode, engine: LessonEngine, patternIntroLogic: PatternIntroLogic? = nil, practiceLogic: PatternPracticeLogic? = nil, ghostLogic: GhostModeLogic? = nil, onComplete: ((Bool) -> Void)? = nil) -> some View {
        return PatternBuilderView(state: state, engine: engine, patternIntroLogic: patternIntroLogic, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
            .onAppear {
                PatternBuilderLogic.playIntro(drill: state, engine: engine, mode: mode)
            }
    }
    
    func getWordColor(_ word: String, index: Int) -> Color {
        guard checked else { return .white }
        let targetWords = state.drillData.target.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        if index < targetWords.count && targetWords[index].lowercased() == word.lowercased() {
            return CyberColors.neonGreen
        }
        return .red
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
