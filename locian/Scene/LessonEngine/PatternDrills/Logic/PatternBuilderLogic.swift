import SwiftUI
import Combine

struct Token: Identifiable {
    let id = UUID()
    let text: String
    var isUsed: Bool = false
}

class PatternBuilderLogic: ObservableObject {
    @Published var selectedTokens: [Token] = []
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
    let session: LessonSessionManager
    var appState: AppStateManager?
    
    // Data only
    let prompt: String
    let targetLanguage: String
    
    init(state: DrillState, session: LessonSessionManager, appState: AppStateManager?) {
        self.state = state
        self.session = session
        self.appState = appState
        self.prompt = state.drillData.meaning
        self.targetLanguage = LanguageUtils.getFullLanguageName(session.lessonData?.target_language) ?? "Unknown"
        
        setupTokens()
        computeValidBricks()
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
        guard !checked else { return }
        checked = true
        
        let userInput = selectedTokens.map { $0.text }.joined(separator: " ")
        print("      🔍 [LessonFlow] [PatternBuilder] Validating with inputs: '\(userInput)'")
        
        let context = ValidationContext(
            state: state,
            locale: session.targetLocale,
            session: session,
            neuralEngine: session.neuralValidator
        )
        
        // 1. Validate the FULL Pattern using Typing Validator
        let validator = TypingValidator()
        let result = validator.validate(input: userInput, target: state.drillData.target, context: context)
        let isCorrect = (result == .correct || result == .meaningCorrect)
        
        // 2. Perform Granular Analysis (The Ripple Effect)
        let brickMatches = ContentAnalyzer.findRelevantBricks(
            in: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: session.lessonData?.bricks,
            targetLanguage: session.lessonData?.target_language ?? "es"
        )
        let bricks = MasteryFilterService.resolveBricks(ids: Set(brickMatches), from: session.lessonData?.bricks)
        
        let rippleResults = GranularAnalyzer.analyze(
            input: userInput,
            target: state.drillData.target,
            requiredBricks: Array(bricks),
            type: .typing, // Builder validates like typing
            context: context
        )
        print("      🌊 [Ripple] Analyzed \(rippleResults.count) bricks in the pattern")
        
        // 3. Update Mastery Directly in Engine
        let delta = isCorrect ? 0.30 : -0.10
        session.engine.updateMastery(id: state.id, delta: delta, reason: "[Pattern Builder]")
        
        // Ripple Effect on Bricks
        for res in rippleResults {
            let brickDelta = res.isCorrect ? 0.10 : -0.05
            session.engine.updateMastery(id: res.brickId, delta: brickDelta, reason: "[Ripple: Builder]")
        }
        
        // 4. Trigger UI Side Effects in Session
        session.handleValidationResult(isCorrect: isCorrect, targetContent: state.drillData.target)
        self._isCorrectResult = isCorrect
    }
    
    func selectExploreWord(_ word: String) {
        selectedExploreWord = word
        fetchSimilarWords(for: word)
    }
    
    func continueToNext() {
        session.continueToNext()
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
        let targetCode = session.lessonData?.target_language ?? "es"
        let nativeCode = session.lessonData?.user_language ?? "en"

        // Use SemanticFilterService to get actual scores for all candidate bricks
        // Use threshold 0.0 here because we want to see ALL matches to rank them
        let brickMatches = SemanticFilterService.getFilteredBricks(
            text: state.drillData.target,
            meaning: state.drillData.meaning,
            bricks: session.engine.lessonData?.bricks,
            targetLanguage: targetCode,
            nativeLanguage: nativeCode,
            validator: session.neuralValidator,
            threshold: 0.0
        )
        
        let brickIds = brickMatches.map { $0.brickId }
        
        if let lessonData = session.engine.lessonData {
            let allBricks = (lessonData.bricks?.constants ?? []) + 
                           (lessonData.bricks?.variables ?? []) + 
                           (lessonData.bricks?.structural ?? [])
            
            for brickId in brickIds {
                if let brick = allBricks.first(where: { ($0.id ?? $0.word) == brickId }) {
                    validBrickWords.insert(brick.word.lowercased())
                }
            }
            
            // NEW: Identify Top 3 Explore Words (FILTERED BY NOUNS/VERBS)
            // First, tag the target string
            let tags = TokenTaggerService.tagContent(
                text: state.drillData.target,
                languageCode: targetCode
            )

            // Map results to scoring
            let scoredExplore = brickMatches.compactMap { match -> (String, String, Double)? in
                if let brick = allBricks.first(where: { ($0.id ?? $0.word) == match.brickId }) {
                    // Only include if it's a noun or a verb
                    if TokenTaggerService.isNoun(brick.word, in: tags) || TokenTaggerService.isVerb(brick.word, in: tags) {
                        return (brick.word, brick.meaning, match.similarityScore)
                    }
                }
                return nil
            }
            .sorted(by: { $0.2 > $1.2 })
            
            self.exploreWords = Array(scoredExplore.prefix(3))
            print("   🛠️ [PatternBuilder] Computed \(validBrickWords.count) valid bricks and \(exploreWords.count) explore words")
        }
    }
    
    func fetchSimilarWords(for word: String) {
        activeWord = word
        if let cached = similarWordsCache[word] {
            self.searchResults = cached.similar_words ?? []
            return 
        }
        
        guard let token = appState?.authToken else { return }
        
        let request = GetSimilarWordsRequest(
            word: word,
            target_language: session.lessonData?.target_language ?? "es",
            user_language: session.lessonData?.user_language ?? "en",
            situation: session.lessonData?.micro_situation,
            sentence: state.drillData.target
        )
        
        isSearching = true
        LanguageAPIManager.shared.getSimilarWords(request: request, sessionToken: token) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSearching = false
                switch result {
                case .success(let response):
                    if let data = response.data {
                        self?.similarWordsCache[word] = data
                        self?.searchResults = data.similar_words ?? []
                    }
                case .failure(let error):
                    print("❌ [SimilarWords] Error: \(error.localizedDescription)")
                    self?.searchResults = []
                }
            }
        }
    }
    
    static func view(for state: DrillState, mode: DrillMode, session: LessonSessionManager) -> some View {
        return PatternBuilderView(state: state, session: session)
    }
}
