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
            let has = !selectedTokens.isEmpty
            practiceLogic?.hasInput = has
            ghostLogic?.hasInput = has
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
    @Published var practiceLogic: PatternPracticeLogic?
    @Published var ghostLogic: GhostModeLogic?
    @Published var isAudioPlaying: Bool = false
    var isAnswered: Bool { checked }
    
    let state: DrillState
    let engine: LessonEngine
    let prompt: String
    let targetLanguage: String
    var appState: AppStateManager?
    
    var onComplete: ((Bool) -> Void)? // ✅ Direct closure
    
    init(state: DrillState, engine: LessonEngine, appState: AppStateManager?, onComplete: ((Bool) -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.appState = appState
        self.onComplete = onComplete
        self.prompt = state.drillData.meaning
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english
        
        setupTokens()
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
    
    var hasInput: Bool {
        !selectedTokens.isEmpty
    }
    
    func clearInput() {
        for _ in 0..<selectedTokens.count {
            removeToken(at: 0)
        }
        self.checked = false

        practiceLogic?.isAnswered = false
        practiceLogic?.isCorrect = false
        
        ghostLogic?.isAnswered = false
        ghostLogic?.isCorrect = false
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
        
        // Speak what the user JUST tapped (Disabled since we don't have per-word audio)
        print("🎙️ Skipping token audio (TTS Disabled): '\(token.text)'")
        
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
        let isCorrectResult = (result == .correct || result == .meaningCorrect)
        
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

        if isCorrectResult {
            engine.updateMastery(id: state.patternId, delta: 0.20)
        } else {
            engine.updateMastery(id: state.patternId, delta: -0.05)
        }
        
        // 4. Trigger UI Side Effects in Engine
        // 4. Trigger UI Side Effects in Engine
        self._isCorrectResult = isCorrectResult
        
        // ✅ Localized Feedback
        playFeedback(isCorrect: isCorrectResult)
        
        // Keep builder flow silent on CHECK to avoid duplicate replay.
        
        practiceLogic?.markDrillAnswered(isCorrect: isCorrectResult)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrectResult)
    }
    
    func continueToNext() {
        AudioManager.shared.stop()
        onComplete?(getBuilderMastery() >= 0.85) // or just use isCorrect logic if simpler
    }
    
    private func getBuilderMastery() -> Double {
        // ... (existing logic or just return true/false based on checked)
        return checked ? 1.0 : 0.0
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
        // Audio playback handled in checkAnswer manually here
    }
    
    func selectExploreWord(_ word: String) {
        selectedExploreWord = word
        fetchSimilarWords(for: word)
    }
    
    // ...
    
    
    // ...
    
    @ViewBuilder
    static func view(
        for state: DrillState,
        mode: DrillMode,
        engine: LessonEngine,
        appState: AppStateManager? = nil,
        practiceLogic: PatternPracticeLogic? = nil,
        ghostLogic: GhostModeLogic? = nil,
        onComplete: ((Bool) -> Void)? = nil
    ) -> some View {
        PatternBuilderView(
            state: state, 
            engine: engine, 
            practiceLogic: practiceLogic, 
            ghostLogic: ghostLogic, 
            onComplete: onComplete
        )
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
