//
//  LearnTabState.swift
//  locian
//

import SwiftUI
import Combine

private let learnAmbientSubtitleRefreshInterval: TimeInterval = 300

struct ScoredBrick: Identifiable {
    var id: String { brick.word }
    let brick: RecommendationBrickItem
    let score: Double
}

// MARK: - Main State

class LearnTabState: ObservableObject {

    @Published var recommendations: [PlaceRecommendation] = []
    @Published var selectedRecommendationIndex: Int = 0
    @Published var selectedPatternIndex: Int = 0
    @Published var isAnalyzingBricks: Bool = false
    @Published var animateIn: Bool = false
    @Published var startFadeActive: Bool = false
    @Published var startSwipeProgress: CGFloat = 0
    @Published var storyIndex: Int = 0
    @Published var selectedBrickIndex: Int? = nil
    @Published var selectedQuestionBrickIndex: Int? = nil
    @Published var storyProgress: CGFloat = 0
    @Published var lastProgressTick: Date = Date()
    @Published var isHoldingProgress: Bool = false
    @Published var pauseUntil: Date? = nil
    @Published var learnStripShowsTarget: Bool = false

    /// Word-level graph (selected token) vs full user-reply sentence graph in the shared Learn graph slot.
    enum LearnGrammarScope: Int, CaseIterable {
        case word = 0
        case sentence = 1
    }

    @Published var learnGrammarScope: LearnGrammarScope = .word

    /// Set to `true` to show the extra control (word vs full sentence graph). When `false`, only Aa / target appears and the graph area stays word-level.
    @Published var showLearnSentenceGraphToggle: Bool = false

    /// Second header line on Learn tab (ambient tagline from time + sensors).
    @Published var learnAmbientSubtitle: String = LearnAmbientTagline.line(
        for: LearnAmbientInputs(
            time: LearnAmbientTagline.timeBand(),
            rain: false,
            velocity: false,
            altitude: false
        )
    )

    @Published var currentLesson: GenerateSentenceData? = nil
    @Published var showLessonView: Bool = false

    private let storyDuration: TimeInterval = 5.5

    private var lastAmbientSubtitleRefresh: Date?

    // MARK: - Computed Properties

    var patterns: [RecommendationPattern] {
        activeRecommendation?.patterns ?? []
    }

    var activeRecommendation: PlaceRecommendation? {
        guard selectedRecommendationIndex < recommendations.count else { return nil }
        return recommendations[selectedRecommendationIndex]
    }

    var currentPattern: RecommendationPattern? {
        guard storyIndex < patterns.count else { return nil }
        return patterns[storyIndex]
    }

    var currentBricks: [RecommendationBrickItem] {
        guard let p = currentPattern, let b = p.bricks else { return [] }
        return (b.constants ?? []) + (b.variables ?? []) + (b.structural ?? [])
    }

    var currentQuestionBricks: [RecommendationBrickItem] {
        currentPattern?.locian_question_bricks ?? []
    }

    var selectedBrick: RecommendationBrickItem? {
        if let qi = selectedQuestionBrickIndex, qi < currentQuestionBricks.count {
            return currentQuestionBricks[qi]
        }
        guard let i = selectedBrickIndex, i < currentBricks.count else { return nil }
        return currentBricks[i]
    }

    var activePattern: RecommendationPattern? {
        guard let rec = activeRecommendation,
              let patterns = rec.patterns,
              selectedPatternIndex < patterns.count else { return nil }
        return patterns[selectedPatternIndex]
    }

    var isFetchingData: Bool {
        DiscoverMomentsService.shared.isLoading
    }

    var locianQuestionTargetTokens: [SentenceToken] {
        buildSentenceTokens(
            from: currentPattern?.locian_question,
            bricks: currentQuestionBricks,
            candidates: { [$0.targetBrick, $0.word] }
        )
    }

    var locianQuestionNativeTokens: [SentenceToken] {
        buildSentenceTokens(
            from: currentPattern?.locian_question_native,
            bricks: currentQuestionBricks,
            candidates: { [$0.nativeBrick, $0.meaning] }
        )
    }

    var targetSentenceTokens: [SentenceToken] {
        buildSentenceTokens(
            from: currentPattern?.target_pattern,
            bricks: currentBricks,
            candidates: { [$0.targetBrick, $0.word] }
        )
    }

    var nativeSentenceTokens: [SentenceToken] {
        buildSentenceTokens(
            from: currentPattern?.native_pattern,
            bricks: currentBricks,
            candidates: { [$0.nativeBrick, $0.meaning] }
        )
    }

    var activeBricks: [ScoredBrick] {
        guard let pattern = activePattern, let target = pattern.target_pattern else { return [] }
        let langCode = appState.userLanguagePairs.first(where: { $0.is_default })?.target_language ?? "es"
        let pool = aggregatedBricksPool
        let matches = ContentAnalyzer.findRelevantBricksWithSimilarity(
            in: target,
            meaning: pattern.native_pattern ?? "",
            bricks: pool,
            targetLanguage: langCode
        )
        return matches.compactMap { match -> ScoredBrick? in
            guard let brick = findBrickInPool(id: match.id) else { return nil }
            return ScoredBrick(brick: brick, score: match.score)
        }
        .sorted { $0.score > $1.score }
    }

    private var aggregatedBricksPool: BricksData? {
        var allConstants: [BrickItem] = []
        var allVariables: [BrickItem] = []
        var allStructural: [BrickItem] = []
        var seenWords = Set<String>()

        for rec in recommendations {
            for pattern in rec.patterns ?? [] {
                guard let rb = pattern.bricks else { continue }

                func process(_ list: [RecommendationBrickItem]?, into target: inout [BrickItem], type: String) {
                    for item in list ?? [] {
                        let lower = item.word.lowercased()
                        guard !seenWords.contains(lower) else { continue }
                        seenWords.insert(lower)
                        target.append(BrickItem(
                            id: item.word, word: item.word, meaning: item.meaning,
                            phonetic: item.phonetic, type: type, vector: nil, mastery: nil
                        ))
                    }
                }

                process(rb.constants, into: &allConstants, type: "constant")
                process(rb.variables, into: &allVariables, type: "variable")
                process(rb.structural, into: &allStructural, type: "structural")
            }
        }

        if allConstants.isEmpty && allVariables.isEmpty && allStructural.isEmpty { return nil }
        return BricksData(constants: allConstants, variables: allVariables, structural: allStructural)
    }

    private func findBrickInPool(id: String) -> RecommendationBrickItem? {
        for rec in recommendations {
            for pattern in rec.patterns ?? [] {
                guard let rb = pattern.bricks else { continue }
                let all = (rb.constants ?? []) + (rb.variables ?? []) + (rb.structural ?? [])
                if let found = all.first(where: { $0.word == id }) { return found }
            }
        }
        return nil
    }

    private var firstMappedBrickIndex: Int? {
        targetSentenceTokens.first(where: { $0.brickIndex != nil })?.brickIndex
        ?? nativeSentenceTokens.first(where: { $0.brickIndex != nil })?.brickIndex
        ?? (currentBricks.isEmpty ? nil : 0)
    }

    private var preferredBrickSelectionIndex: Int? {
        guard !currentBricks.isEmpty else { return nil }
        let ranked = currentBricks.enumerated().compactMap { idx, b -> (Int, Double)? in
            guard let imp = b.importance else { return nil }
            return (idx, imp)
        }
        let sorted = ranked.sorted { lhs, rhs in
            if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
            return lhs.0 < rhs.0
        }
        guard let top = sorted.first else {
            return firstMappedBrickIndex
        }
        if sorted.count >= 2 {
            let a = sorted[0].0
            let b = sorted[1].0
            return Bool.random() ? a : b
        }
        return top.0
    }

    private func buildSentenceTokens(
        from sentence: String?,
        bricks: [RecommendationBrickItem],
        candidates: (RecommendationBrickItem) -> [String?]
    ) -> [SentenceToken] {
        guard let sentence, !sentence.isEmpty else { return [] }
        let rawTokens = sentence.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard !rawTokens.isEmpty else { return [] }

        let normalizedTokens = rawTokens.map(normalizedWord(_:))
        var tokenToBrick: [Int: Int] = [:]

        let indexedBricks = Array(bricks.enumerated()).sorted { lhs, rhs in
            let leftPhrase = candidates(lhs.element).compactMap { $0 }.first ?? lhs.element.word
            let rightPhrase = candidates(rhs.element).compactMap { $0 }.first ?? rhs.element.word
            let leftCount = leftPhrase.split(separator: " ", omittingEmptySubsequences: true).count
            let rightCount = rightPhrase.split(separator: " ", omittingEmptySubsequences: true).count
            return leftCount > rightCount
        }

        for (brickIndex, brick) in indexedBricks {
            let candidatePhrases = candidates(brick).compactMap { $0 }
            for phrase in candidatePhrases {
                let phraseTokens = phrase
                    .split(separator: " ", omittingEmptySubsequences: true)
                    .map { normalizedWord(String($0)) }
                    .filter { !$0.isEmpty }

                guard !phraseTokens.isEmpty, phraseTokens.count <= normalizedTokens.count else { continue }
                let lastStart = normalizedTokens.count - phraseTokens.count

                var matched = false
                for start in 0...lastStart {
                    let end = start + phraseTokens.count
                    let window = Array(normalizedTokens[start..<end])
                    guard window == phraseTokens else { continue }

                    let hasConflict = (start..<end).contains { tokenToBrick[$0] != nil }
                    guard !hasConflict else { continue }

                    for tokenIndex in start..<end {
                        tokenToBrick[tokenIndex] = brickIndex
                    }
                    matched = true
                    break
                }

                if matched { break }
            }
        }

        var result: [SentenceToken] = []
        var nextId = 0
        var i = 0
        while i < rawTokens.count {
            let myBrick = tokenToBrick[i]
            var j = i + 1
            while j < rawTokens.count, tokenToBrick[j] == myBrick {
                j += 1
            }
            let merged = rawTokens[i..<j].joined(separator: " ")
            result.append(SentenceToken(id: nextId, text: merged, brickIndex: myBrick))
            nextId += 1

            if j < rawTokens.count {
                result.append(SentenceToken(id: nextId, text: " ", brickIndex: nil))
                nextId += 1
            }
            i = j
        }
        return result
    }

    let appState: AppStateManager
    var cancellables = Set<AnyCancellable>()

    init(appState: AppStateManager) {
        self.appState = appState
        DiscoverMomentsService.shared.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Discovery

    func discover(explicitText: String? = nil, image: UIImage? = nil) {
        DispatchQueue.main.async {
            self.recommendations = []
            self.selectedRecommendationIndex = 0
            self.selectedPatternIndex = 0
        }

        DiscoverMomentsService.shared.discoverMoments(explicitRequest: explicitText, image: image) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    let rawRecs = response.recommendations
                    guard !rawRecs.isEmpty else {
                        self.recommendations = []
                        self.refreshLearnAmbientSubtitleIfNeeded(force: true)
                        return
                    }
                    let valid = rawRecs.compactMap { rec -> PlaceRecommendation? in
                        let original = rec.patterns ?? []
                        let clean = original.filter { ($0.target_pattern?.isEmpty == false) }
                        if clean.count != original.count {
                            let dropped = original.enumerated().filter { _, p in
                                p.target_pattern?.isEmpty != false
                            }.map { idx, p in
                                "[\(idx)] target='\(p.target_pattern ?? "<nil>")', native='\(p.native_pattern ?? "<nil>")'"
                            }
                            print("⚠️ [LearnTabState] '\(rec.place_id)' dropped \(original.count - clean.count) of \(original.count) patterns (empty target_pattern):")
                            for d in dropped { print("    DROPPED \(d)") }
                        }
                        guard !clean.isEmpty, rec.place_id.lowercased() != "unknown" else { return nil }
                        var r = rec; r.patterns = clean; return r
                    }
                    self.recommendations = valid
                    self.selectedRecommendationIndex = 0
                    self.selectedPatternIndex = 0
                    self.resetStory()
                    self.refreshLearnAmbientSubtitleIfNeeded(force: true)
                }
            case .failure:
                DispatchQueue.main.async {
                    self.refreshLearnAmbientSubtitleIfNeeded(force: true)
                }
            }
        }
    }

    func selectRecommendation(index: Int) {
        selectedRecommendationIndex = index
        selectedBrickIndex = nil
        resetStory()
    }

    func selectQuestionBrick(index: Int) {
        selectedQuestionBrickIndex = index
        selectedBrickIndex = nil
        pauseUntil = Date().addingTimeInterval(3)
    }

    func selectSentenceBrick(index: Int) {
        selectedBrickIndex = index
        selectedQuestionBrickIndex = nil
        pauseUntil = Date().addingTimeInterval(3)
    }

    func setProgressHold(_ isHolding: Bool) {
        isHoldingProgress = isHolding
        if isHolding { lastProgressTick = Date() }
    }

    func onAppearSetup() {
        ensureDefaultBrickSelection()
        lastProgressTick = Date()
        refreshLearnAmbientSubtitleIfNeeded(force: false)
    }

    /// Refreshes the ambient subtitle from clock + location weather/speed/altitude (throttled unless `force`).
    func refreshLearnAmbientSubtitleIfNeeded(force: Bool) {
        if !force {
            if let last = lastAmbientSubtitleRefresh,
               Date().timeIntervalSince(last) < learnAmbientSubtitleRefreshInterval {
                return
            }
        }
        lastAmbientSubtitleRefresh = Date()
        Task { [weak self] in
            await self?.performLearnAmbientSubtitleRefresh()
        }
    }

    private func performLearnAmbientSubtitleRefresh() async {
        let time = LearnAmbientTagline.timeBand()
        var rain = false

        if let loc = LocationManager.shared.currentLocation {
            let (_, condition) = await WeatherServiceManager.shared.fetchWeatherData(for: loc)
            rain = (condition == "rain")
        }

        let kmh = max(0, LocationManager.shared.speed ?? 0) * 3.6
        let velocity = kmh >= 10

        var altitudeHigh = false
        if let alt = LocationManager.shared.altitude {
            altitudeHigh = alt > 750 && alt < 8900
        }

        let inputs = LearnAmbientInputs(time: time, rain: rain, velocity: velocity, altitude: altitudeHigh)
        let line = LearnAmbientTagline.line(for: inputs)

        await MainActor.run { [weak self] in
            self?.learnAmbientSubtitle = line
        }
    }

    func updateStartSwipeProgress(translationHeight: CGFloat) {
        let upwardDrag = max(0, -translationHeight)
        let normalized = min(1, upwardDrag / 90)
        startSwipeProgress = normalized
    }

    func resetStartSwipeProgress() {
        startSwipeProgress = 0
    }

    func onRecommendationOrFetchChanged() {
        resetStory()
    }

    func onCurrentPatternChanged() {
        ensureDefaultBrickSelection()
    }

    func resetStory() {
        storyIndex = 0
        storyProgress = 0
        selectedQuestionBrickIndex = nil
        selectedBrickIndex = preferredBrickSelectionIndex
        selectedPatternIndex = 0
        lastProgressTick = Date()
        pauseUntil = nil
    }

    func goToStory(_ index: Int) {
        guard !patterns.isEmpty else { return }
        let target = max(0, min(index, patterns.count - 1))
        storyIndex = target
        storyProgress = 0
        selectedQuestionBrickIndex = nil
        selectedBrickIndex = preferredBrickSelectionIndex
        selectedPatternIndex = target
        lastProgressTick = Date()
        pauseUntil = nil
    }

    func tickStoryProgress(now: Date) {
        guard !patterns.isEmpty else { return }
        let pausedByWordTap = (pauseUntil ?? .distantPast) > now
        guard !isHoldingProgress && !pausedByWordTap else {
            lastProgressTick = now
            return
        }

        let delta = now.timeIntervalSince(lastProgressTick)
        lastProgressTick = now
        guard delta > 0 else { return }

        let nextProgress = storyProgress + CGFloat(delta / storyDuration)
        if nextProgress >= 1 {
            if patterns.count > 1 {
                goToStory((storyIndex + 1) % patterns.count)
            } else {
                storyProgress = 1
            }
        } else {
            storyProgress = nextProgress
        }
    }

    private func ensureDefaultBrickSelection() {
        if selectedBrickIndex == nil {
            selectedBrickIndex = preferredBrickSelectionIndex
            return
        }
        if let sel = selectedBrickIndex, sel >= currentBricks.count {
            selectedBrickIndex = preferredBrickSelectionIndex
        }
    }

    func startPractice() {
        guard let recommendation = activeRecommendation,
              !(recommendation.patterns ?? []).isEmpty else { return }

        let structuredPlaces: [DiscoverPlaceInput] = []
        CompletePatternService.shared.completePattern(
            patternId: nil,
            placeId: recommendation.place_id,
            places: structuredPlaces
        ) { _ in }

        GenerateSentenceLogic.shared.hydrateFromV3(recommendation: recommendation) { [weak self] lessonData in
            guard let self else { return }
            self.currentLesson = lessonData
            self.showLessonView = true
        }
    }

    // MARK: - Deep Link

    func handleDeepLink(placeName: String, hour: Int) {
        discover(explicitText: "I am at \(placeName)")
    }
}
