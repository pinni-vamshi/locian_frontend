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
            // Sync input state to parent for Footer Button
            patternIntroLogic?.currentBrickHasInput = !selectedTokens.isEmpty
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
        // ✅ Bridge Actions to Parent (Intro Recap Phase)
        patternIntroLogic?.requestCheckAnswer = { [weak self] in
            self?.checkAnswer()
        }
        patternIntroLogic?.requestClearInput = { [weak self] in
             self?.removeToken(at: 0) // Example clear
        }
        
        // Sync initial state
        patternIntroLogic?.currentBrickHasInput = !selectedTokens.isEmpty
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
        AudioManager.shared.speak(segments: [.init(text: token.text, language: language)])
        
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
            AudioManager.shared.speak(segments: [.init(text: state.drillData.target, language: language)])
        }
        
        // ✅ Notify Wrapper
        patternIntroLogic?.markBrickAnswered(isCorrect: isCorrect, input: userInput)
        practiceLogic?.markDrillAnswered(isCorrect: isCorrect)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrect)
    }
    
    // MARK: - 🎙️ Voice Assets (Decentralized)
    
    // 1. Full Context
    private static let fullIntroVoices = [
        "Build the sentence for \"%@\" in %@",
        "Put the words in order for \"%@\" in %@",
        "Arrange the %@ phrase: \"%@\"",
        "Construct the %@ sentence meaning \"%@\"",
        "What is the correct order for \"%@\" in %@"
    ]
    

    private static let correctVoices = [
        "You are right! \"%@\" in %@ is \"%@\"",
        "Exactly. \"%@\" in %@ translates to \"%@\"",
        "Spot on. In %@, \"%@\" matches \"%@\"",
        "That's correct. We say \"%@\" for \"%@\" in %@",
        "Perfect. \"%@\" in %@ is \"%@\""
    ]
    
    // 3. Concise Feedback
    private static let wrongVoices = [
        "Actually, it's \"%@\"",
        "The correct way is \"%@\"",
        "Note the order: \"%@\"",
        "The sentence is \"%@\"",
        "Listen carefully: \"%@\""
    ]
    
    static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ [PatternBuilder] Using Voice Override: '\(override)'")
            AudioManager.shared.speak(segments: [.init(text: override, language: drill.voiceLanguage ?? "en-US")])
            return
        }
        
        guard !drill.suppressIntroAudio else { return }
        
        let languageCode = engine.lessonData?.target_language ?? "es"
        let languageName = TargetLanguageMapping.shared.getDisplayNames(for: languageCode).english
        let meaning = drill.drillData.meaning
        
        let template = fullIntroVoices.randomElement() ?? fullIntroVoices[0]
        
        // Simple Interpolation
        var text = template.replacingOccurrences(of: "%@", with: meaning, range: template.range(of: "%@"))
        text = text.replacingOccurrences(of: "%@", with: languageName)
        
        AudioManager.shared.speak(segments: [.init(text: text, language: "en-US")])
    }
    
    private func playFeedback(isCorrect: Bool) {
        // ✅ USER REQUEST: Silence local feedback if practiceLogic is handling the meaningful bilingual feedback
        if let practiceLogic = practiceLogic, practiceLogic.currentIndex == practiceLogic.mistakes.count {
            print("🎙️ [PatternBuilder] Silencing local feedback. practiceLogic will handle bilingual confirmation.")
            return
        }
        
        let target = state.drillData.target
        let meaning = state.drillData.meaning
        let targetLang = targetLanguage
        
        let template = isCorrect ? 
            (PatternBuilderLogic.correctVoices.randomElement() ?? "Correct! \"%@\" in %@ is \"%@\"") :
            (PatternBuilderLogic.wrongVoices.randomElement() ?? "Actually, \"%@\" in %@ is \"%@\"")
        
        // 1. Generate the Bilingual sentence components
        // We split at the last placeholder to speak the final word in the target language.
        let components = template.components(separatedBy: "\"%@\"")
        guard components.count >= 2 else { return }
        
        // Reconstruct the English part
        // We assume 3 placeholders: Meaning, Language, Target
        // If template has 3 placeholders, we need to handle them carefully.
        // Actually, let's look at the templates.
        // "You are right! \"%@\" (meaning) in %@ (lang) is \"%@\" (target)"
        
        var englishPart = components[0].replacingOccurrences(of: "%@", with: meaning)
        englishPart = englishPart.replacingOccurrences(of: "%@", with: targetLang)
        
        // Final construction of English segment
        // If there's an intermediate part between 1st and 2nd or 2nd and 3rd...
        // Let's simplify and just do a robust interpolation for the first N-1 parts.
        
        var textToSpeak = template.replacingOccurrences(of: "%@", with: meaning, range: template.range(of: "%@"))
        if let langRange = textToSpeak.range(of: "%@") {
            textToSpeak = textToSpeak.replacingOccurrences(of: "%@", with: targetLang, range: langRange)
        }
        
        // Now split at the final placeholder
        let finalComponents = textToSpeak.components(separatedBy: "\"%@\"")
        guard finalComponents.count >= 2 else { return }
        
        let introText = finalComponents[0]
        let langCode = self.engine.lessonData?.target_language ?? "es-ES"
        
        AudioManager.shared.speak(segments: [
            .init(text: introText, language: "en-US"),
            .init(text: target, language: langCode)
        ])
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
