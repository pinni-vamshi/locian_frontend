//
//  LearnTabView.swift
//  locian
//

import SwiftUI
import Combine

struct LearnTabView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var appState: AppStateManager
    @ObservedObject var state: LearnTabState
    @Binding var selectedTab: MainTabView.TabItem
    @ObservedObject private var audioManager = AudioManager.shared
    @State private var isLocianQuestionSpeaking = false
    @State private var isUserSentenceSpeaking = false

    // Hold-to-launch state
    @State private var holdProgress: CGFloat = 0
    @State private var asteriskAngle: Double = 0   // independent rotation; reverses on finger lift
    @State private var holdTimer: Timer? = nil

    @AppStorage("learnCoachTour_userSawIntro_v1") private var learnCoachTourUserSawIntro: Bool = false
    @State private var showLearnCoachTour = false
    @State private var learnCoachTourFrames: [String: CGRect] = [:]
    @State private var sessionScheduledAutoCoachTour = false

    private var screenEdgePadding: CGFloat { learnScaled(2.5, hSizeClass: horizontalSizeClass, min: 2.5, max: 6) }
    private var placeRailHeight: CGFloat { learnScaled(130, hSizeClass: horizontalSizeClass, min: 120, max: 170) }
    private var sentenceConversationChromeSize: CGFloat { learnScaled(28, hSizeClass: horizontalSizeClass, min: 28, max: 36) }
    /// Fixed slot for the full-sentence graph strip only (word graph is intrinsic height).
    private var learnGraphSlotHeight: CGFloat { learnScaled(340, hSizeClass: horizontalSizeClass, min: 298, max: 380) }
    /// Minimum height of the dashed panel that wraps the **whole** transformation graph (not individual word boxes).
    private var learnTransformationGraphSockMinHeight: CGFloat {
        learnScaled(292, hSizeClass: horizontalSizeClass, min: 268, max: 368)
    }

    // MARK: - Derived values

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12:  return "Good morning,"
        case 12..<18: return "Good afternoon,"
        case 18..<21: return "Good evening,"
        default:      return "Good night,"
        }
    }

    private var currentPattern: RecommendationPattern? { state.currentPattern }

    /// When the sentence-graph control is hidden, the graph slot always behaves as word scope.
    private var effectiveLearnGrammarScope: LearnTabState.LearnGrammarScope {
        state.showLearnSentenceGraphToggle ? state.learnGrammarScope : .word
    }

    private var currentTargetLanguageCode: String {
        AppStateManager.shared
            .userLanguagePairs
            .first(where: { $0.is_default })?
            .target_language ?? "es"
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerBlock
                    placeCardsRail
                    brickArea
                        .layoutPriority(1)
                    startButton
                        .learnCoachTourHighlight(.startLearning)
                }
                .diagnosticBorder(.red, width: 1)
            }
            .onPreferenceChange(LearnCoachTourFramesKey.self) { learnCoachTourFrames = $0 }
            .overlay {
                if showLearnCoachTour {
                    LearnCoachTourOverlayView(
                        isPresented: $showLearnCoachTour,
                        frames: learnCoachTourFrames,
                        onCompleted: {
                            learnCoachTourUserSawIntro = true
                        }
                    )
                    .transition(.opacity)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                if state.recommendations.isEmpty { state.discover() }
                state.onAppearSetup()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.easeOut(duration: 0.4)) { state.animateIn = true }
                }
                if !learnCoachTourUserSawIntro && !sessionScheduledAutoCoachTour {
                    sessionScheduledAutoCoachTour = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
                        guard !learnCoachTourUserSawIntro else { return }
                        withAnimation(.easeOut(duration: 0.25)) { showLearnCoachTour = true }
                    }
                }
            }
            .onDisappear {
                withAnimation(.none) { state.animateIn = false }
            }
            .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { now in
                state.tickStoryProgress(now: now)
            }
            .onChange(of: state.selectedRecommendationIndex) { _, _ in state.onRecommendationOrFetchChanged() }
            .onChange(of: state.isFetchingData) { _, loading in if !loading { state.onRecommendationOrFetchChanged() } }
            .onChange(of: currentPattern?.id) { _, _ in state.onCurrentPatternChanged() }
            .onChange(of: state.showLessonView) { _, shown in if !shown { state.currentLesson = nil } }
            .onChange(of: state.showLearnSentenceGraphToggle) { _, show in
                if !show { state.learnGrammarScope = .word }
            }
            .onChange(of: audioManager.isVoiceSpeaking) { _, speaking in
                print("📚 [LearnTab] conversation icon state -> \(speaking ? "SPEAKER" : "PERSON")")
            }
            .navigationDestination(isPresented: $state.showLessonView) {
                if let lesson = state.currentLesson {
                    ConversationLessonView(lessonData: lesson).environmentObject(appState)
                }
            }
            .task(id: appState.learnCoachTourManualTrigger) {
                let trigger = appState.learnCoachTourManualTrigger
                guard trigger > appState.learnCoachTourManualTriggerPresentedUpTo else { return }
                try? await Task.sleep(nanoseconds: 420_000_000)
                await MainActor.run {
                    appState.learnCoachTourManualTriggerPresentedUpTo = trigger
                    withAnimation(.easeOut(duration: 0.25)) { showLearnCoachTour = true }
                }
            }
        }
    }

    // MARK: - Header

    private var headerBlock: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(learnFont(size: 18, weight: .medium, hSizeClass: horizontalSizeClass))
                    .foregroundColor(.white)

                Text(state.learnAmbientSubtitle)
                    .font(learnFont(size: 22, weight: .light, hSizeClass: horizontalSizeClass))
                    .italic()
                    .foregroundColor(Color(white: 0.55))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .allowsTightening(true)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: false)
            }

            Spacer(minLength: 10)

            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                state.discover()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: learnScaled(16, hSizeClass: horizontalSizeClass, min: 16, max: 20), weight: .black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: learnScaled(40, hSizeClass: horizontalSizeClass, min: 40, max: 52))
            .frame(maxHeight: .infinity)
            .background(Color(white: 0.12))
            .overlay {
                Rectangle().stroke(Color(white: 0.25), lineWidth: 1)
            }
            .buttonStyle(.plain)
            .disabled(state.isFetchingData)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, screenEdgePadding)
        .padding(.top, learnScaled(18, hSizeClass: horizontalSizeClass, min: 18, max: 24))
        .padding(.bottom, learnScaled(23, hSizeClass: horizontalSizeClass, min: 23, max: 30))
        .diagnosticBorder(.orange, width: 1)
        .opacity(state.animateIn ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.05), value: state.animateIn)
    }

    private var placeCardsRail: some View {
        LearnPlaceCardsRail(
            recommendations: Array(state.recommendations.prefix(4)),
            activeRecommendation: state.activeRecommendation,
            isFetchingData: state.isFetchingData,
            selectedRecommendationIndex: state.selectedRecommendationIndex,
            screenEdgePadding: screenEdgePadding,
            animateIn: state.animateIn,
            onSelectRecommendation: { index in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    state.selectRecommendation(index: index)
                }
            }
        )
        .frame(height: placeRailHeight)
        .learnCoachTourHighlight(.placeRail)
    }

    // MARK: - Brick Area

    private var brickArea: some View {
        ScrollView(.vertical, showsIndicators: false) {

            VStack(spacing: 0) {
                brickHeader
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .learnCoachTourHighlight(.brickHeader)

                VStack(spacing: 0) {
                    storiesSection
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .learnCoachTourHighlight(.sentenceStrip)

                    wordSection
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .learnCoachTourHighlight(.transformationGraph)
                }
                .contentShape(Rectangle())
                .onLongPressGesture(minimumDuration: 0.2, maximumDistance: 32, pressing: { pressing in
                    state.setProgressHold(pressing)
                }, perform: {})
            }
        }
        .padding(.horizontal, screenEdgePadding)
        .padding(.top, learnScaled(18, hSizeClass: horizontalSizeClass, min: 15, max: 22))
        .opacity(state.animateIn ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.15), value: state.animateIn)
    }

    private var brickHeader: some View {
        LearnBrickHeaderView(
            activeRecommendation: state.activeRecommendation,
            currentPattern: currentPattern,
            learnStripShowsTarget: $state.learnStripShowsTarget,
            learnGrammarScope: $state.learnGrammarScope,
            showSentenceGraphToggle: state.showLearnSentenceGraphToggle,
            locianQuestionTargetTokens: state.locianQuestionTargetTokens,
            locianQuestionNativeTokens: state.locianQuestionNativeTokens,
            selectedQuestionBrickIndex: $state.selectedQuestionBrickIndex,
            selectedBrickIndex: $state.selectedBrickIndex,
            currentQuestionBricks: state.currentQuestionBricks,
            onPauseRequested: {
                state.pauseUntil = Date().addingTimeInterval(3)
            },
            onPlayAudio: { brick, token, source in
                playAudioForLearnBrick(
                    brick: brick,
                    tokenDisplayText: token,
                    source: source
                )
            },
            isLocianQuestionSpeaking: isLocianQuestionSpeaking,
            onDoubleTapLocianQuestion: playLocianQuestionSentence
        )
    }

    private var storiesSection: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Segmented progress bars
            HStack(spacing: 4) {
                ForEach(0..<max(state.patterns.count, 1), id: \.self) { i in
                    StorySegmentBar(
                        isActive: i == state.storyIndex && !state.patterns.isEmpty,
                        isDone: i < state.storyIndex,
                        progress: state.storyProgress
                    )
                    .onTapGesture { state.goToStory(i) }
                }
            }

            // Sentence content
            if state.isFetchingData {
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 1).fill(Color(white: 0.15)).frame(height: learnScaled(18, hSizeClass: horizontalSizeClass, min: 16, max: 22))
                    RoundedRectangle(cornerRadius: 1).fill(Color(white: 0.1)).frame(width: learnScaled(130, hSizeClass: horizontalSizeClass, min: 130, max: 170), height: learnScaled(11, hSizeClass: horizontalSizeClass, min: 11, max: 14))
                }
            } else if currentPattern != nil {
                HStack(alignment: .top, spacing: 8) {

                    // ── Column 1: icon + colon — fixed width, full height, content centred ──
                    HStack(alignment: .center, spacing: 4) {
                        ZStack {
                            Color.clear
                            ConversationSpeakerGlyph(
                                slotSize: sentenceConversationChromeSize,
                                isSpeaking: isUserSentenceSpeaking
                            )
                        }
                        .frame(width: sentenceConversationChromeSize, height: sentenceConversationChromeSize)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: playUserSentenceTarget)
                        .diagnosticBorder(.yellow)
                        Text(":")
                            .font(learnFont(size: 17, weight: .semibold, hSizeClass: horizontalSizeClass))
                            .foregroundColor(Color.white.opacity(0.38))
                            .diagnosticBorder(.yellow)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                    .diagnosticBorder(.orange)

                    // ── Column 2: sentence tokens — vertically centred in slot ──
                    VStack(alignment: .leading, spacing: 4) {
                        if state.learnStripShowsTarget {
                            FlowLayout(data: state.targetSentenceTokens, spacing: 0) { token in
                                if let brickIndex = token.brickIndex {
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                            state.selectSentenceBrick(index: brickIndex)
                                        }
                                        if brickIndex < state.currentBricks.count {
                                            playAudioForLearnBrick(brick: state.currentBricks[brickIndex], tokenDisplayText: token.text, source: "sentence-target")
                                        }
                                    }) {
                                        Text(token.text)
                                            .font(learnFont(size: 18, weight: .semibold, hSizeClass: horizontalSizeClass))
                                            .foregroundColor(state.selectedBrickIndex == brickIndex ? ThemeColors.secondaryAccent : .white)
                                            .overlay(alignment: .bottom) {
                                                Rectangle().fill(Color.white.opacity(0.22)).frame(height: 1)
                                            }
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Text(token.text)
                                        .font(learnFont(size: 18, weight: .semibold, hSizeClass: horizontalSizeClass))
                                        .foregroundColor(.white)
                                }
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .diagnosticBorder(.blue)

                            if let translit = currentPattern?.transliteration, !translit.isEmpty {
                                Text(translit)
                                    .font(learnFont(size: 11, weight: .regular, hSizeClass: horizontalSizeClass))
                                    .foregroundColor(Color(white: 0.45))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .diagnosticBorder(.cyan)
                            }
                        } else {
                            FlowLayout(data: state.nativeSentenceTokens, spacing: 0) { token in
                                if let brickIndex = token.brickIndex {
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                            state.selectSentenceBrick(index: brickIndex)
                                        }
                                        if brickIndex < state.currentBricks.count {
                                            playAudioForLearnBrick(brick: state.currentBricks[brickIndex], tokenDisplayText: token.text, source: "sentence-native")
                                        }
                                    }) {
                                        Text(token.text)
                                            .font(learnFont(size: 18, weight: .semibold, hSizeClass: horizontalSizeClass))
                                            .foregroundColor(state.selectedBrickIndex == brickIndex ? ThemeColors.secondaryAccent : .white)
                                            .overlay(alignment: .bottom) {
                                                Rectangle().fill(Color.white.opacity(0.22)).frame(height: 1)
                                            }
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Text(token.text)
                                        .font(learnFont(size: 18, weight: .semibold, hSizeClass: horizontalSizeClass))
                                        .foregroundColor(.white)
                                }
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .diagnosticBorder(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2, perform: playUserSentenceTarget)
                    .diagnosticBorder(.green)
                }
                .padding(.top, 2)
                .frame(maxWidth: .infinity)
                .frame(height: state.learnStripShowsTarget ? 68 : 50, alignment: .top)
                .clipped()
            } else {
                Text("SELECT A PLACE ABOVE")
                    .font(learnFont(size: 15, weight: .medium, hSizeClass: horizontalSizeClass))
                    .foregroundColor(Color(white: 0.25))
            }
        }
        .padding(.horizontal, learnScaled(2, hSizeClass: horizontalSizeClass, min: 2, max: 4))
        .padding(.top, learnScaled(3, hSizeClass: horizontalSizeClass, min: 3, max: 6))
        .frame(maxWidth: .infinity, alignment: .leading)
        .diagnosticBorder(.blue, width: 1)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onEnded { val in
                    if val.translation.width < -30 {
                        state.goToStory((state.storyIndex + 1) % max(state.patterns.count, 1))
                    } else if val.translation.width > 30 {
                        state.goToStory(max(state.storyIndex - 1, 0))
                    }
                }
        )
    }

    private var wordSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                if effectiveLearnGrammarScope == .word {
                    if let brick = state.selectedBrick {
                        tappedWordDetails(brick: brick)
                    }
                } else {
                    LearnInlineSentenceGraphStrip(
                        pattern: currentPattern,
                        line: state.selectedQuestionBrickIndex != nil ? .locianQuestion : .userReply
                    )
                    .frame(maxWidth: .infinity, minHeight: learnGraphSlotHeight, maxHeight: learnGraphSlotHeight, alignment: .top)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, learnScaled(2, hSizeClass: horizontalSizeClass, min: 2, max: 4))
            .multilineTextAlignment(.center)
            .clipped()

            if effectiveLearnGrammarScope == .word {
                triggerAndChangeBlock
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .diagnosticBorder(.purple, width: 1)
        .overlay {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    Color.clear
                        .frame(width: geo.size.width * 0.22)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard state.patterns.count > 0 else { return }
                            let prev = state.storyIndex - 1 < 0 ? max(state.patterns.count - 1, 0) : state.storyIndex - 1
                            state.goToStory(prev)
                        }
                    Spacer(minLength: 0)
                    Color.clear
                        .frame(width: geo.size.width * 0.22)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard state.patterns.count > 0 else { return }
                            state.goToStory((state.storyIndex + 1) % max(state.patterns.count, 1))
                        }
                }
            }
        }
    }

    private var triggerAndChangeBlock: some View {
        let brick = state.selectedBrick
        // Bottom box shows the reusable `pattern` rule for this brick
        // (the human-readable string from demo_response.json).
        let pattern = brick?.pattern

        return VStack(alignment: .center, spacing: 6) {
            if let pattern, !pattern.isEmpty {
                Text(pattern)
                    .font(learnFont(size: 13, weight: .regular, hSizeClass: horizontalSizeClass))
                    .foregroundColor(Color(white: 0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, learnScaled(2, hSizeClass: horizontalSizeClass, min: 2, max: 4))
        .padding(.top, learnScaled(4, hSizeClass: horizontalSizeClass, min: 2, max: 8))
        .padding(.bottom, learnScaled(12, hSizeClass: horizontalSizeClass, min: 10, max: 16))
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color.clear)
        .diagnosticBorder(.pink, width: 1)
    }

    /// Discovery bricks do not include backend voice paths yet; playback is a no-op until
    /// the API exposes per-token audio URLs (same contract as ``AudioManager/playVoiceFromBackendIfAvailable``).
    private func playAudioForLearnBrick(
        brick: RecommendationBrickItem,
        tokenDisplayText: String,
        source: String
    ) {
        print("📚 [LearnTab] \(source) — skip voice (no backend path) brickId=\(brick.brickId ?? "nil") token=\"\(tokenDisplayText.prefix(48))\"")
    }

    private func playLocianQuestionSentence() {
        guard let text = currentPattern?.locian_question?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        print("📚 [LearnTab] playLocianQuestionSentence — skip voice (no backend path); text len=\(text.count)")
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func playUserSentenceTarget() {
        guard let pattern = currentPattern else { return }
        let preferredTarget = pattern.target_pattern?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let text = (preferredTarget.isEmpty
            ? state.targetSentenceTokens.map(\.text).joined()
            : preferredTarget)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        print("📚 [LearnTab] playUserSentenceTarget — skip voice (no backend path); text len=\(text.count)")
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// One-tap voice for explanation words — requires a backend voice path (none in discovery UI yet).
    private func speakWord(_ text: String, source: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        print("📚 [LearnTab] speakWord(\(source)) — skip (no backend path) \"\(trimmed.prefix(48))\"")
    }

    private func tappedWordDetails(brick: RecommendationBrickItem) -> some View {
        // Graph-only — the horizontal base -> ops -> target chain is the
        // entire detail panel. Tap an op chip to highlight from/to letters
        // in the adjacent stages. Falls back to a plain "form (native)"
        // line when the brick has no `pattern_json` yet.
        return VStack(alignment: .center, spacing: 0) {
            if brick.patternJson != nil {
                TransformationGraphView(brick: brick)
            } else {
                fallbackPlainBrickLine(brick: brick)
            }
        }
        .frame(maxWidth: .infinity, minHeight: brick.patternJson != nil ? learnTransformationGraphSockMinHeight : 0, alignment: .center)
        .diagnosticBorder(.white, width: 1, style: .dashed)
    }

    /// Used only for bricks whose backend payload doesn't carry
    /// `pattern_json` yet. Compact one-liner so the panel doesn't go
    /// blank — until every brick has structured data, this keeps the
    /// remaining sentences usable.
    @ViewBuilder
    private func fallbackPlainBrickLine(brick: RecommendationBrickItem) -> some View {
        let formWord = (brick.targetBrick ?? brick.word).lowercased()
        let formTranslation = brick.nativeBrick?.lowercased()
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            playAudioForLearnBrick(
                brick: brick,
                tokenDisplayText: brick.targetBrick ?? brick.word,
                source: "detail-fallback"
            )
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(formWord)
                    .font(learnFont(size: 26, weight: .bold, hSizeClass: horizontalSizeClass))
                    .foregroundColor(ThemeColors.secondaryAccent)
                if let t = formTranslation, !t.isEmpty {
                    Text("(\(t))")
                        .font(learnFont(size: 11, weight: .regular, hSizeClass: horizontalSizeClass))
                        .foregroundColor(Color(white: 0.55))
                }
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: learnScaled(11, hSizeClass: horizontalSizeClass, min: 11, max: 14), weight: .bold))
                    .foregroundColor(.cyan)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Start Button

    private var startButton: some View {
        let buttonHeight = learnScaled(70, hSizeClass: horizontalSizeClass, min: 70, max: 84)

        return VStack(spacing: 0) {

            // ── Lines + asterisk — full width, no padding ────────────────
            HStack(spacing: 14) {

                // Left line — cyan grows from right (arrow side) toward left (outer)
                ZStack(alignment: .trailing) {
                    Rectangle()
                        .fill(ThemeColors.secondaryAccent)
                        .frame(height: 5)
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: geo.size.width * holdProgress)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .frame(height: 5)
                }

                // Asterisk — rotates forward on hold, reverses on finger lift.
                // .rotationEffect is a native SwiftUI animatable modifier so
                // withAnimation() properly interpolates it both ways.
                AsteriskMark(
                    size: learnScaled(18, hSizeClass: horizontalSizeClass, min: 18, max: 22),
                    color: ThemeColors.secondaryAccent
                )
                .rotationEffect(.degrees(asteriskAngle))
                .fixedSize()

                // Right line — cyan grows from left (arrow side) toward right (outer)
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(ThemeColors.secondaryAccent)
                        .frame(height: 5)
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: geo.size.width * holdProgress)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 5)
                }
            }
            .padding(.bottom, learnScaled(6, hSizeClass: horizontalSizeClass, min: 6, max: 9))

            // ── Flat pink rectangle ───────────────────────────────────────
            ZStack {
                ThemeColors.secondaryAccent

                VStack(spacing: 2) {
                    Text("HOLD TO START LEARNING")
                        .font(learnFont(size: 16, weight: .black, hSizeClass: horizontalSizeClass))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("[\(max(state.patterns.count, 1)) SENTENCES]")
                        .font(learnFont(size: 9, weight: .bold, hSizeClass: horizontalSizeClass))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.vertical, learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 14))
            }
            .frame(maxWidth: .infinity, minHeight: buttonHeight)
            .padding(.horizontal, screenEdgePadding)
        }
        .padding(.top, learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 14))
        .padding(.bottom, learnScaled(8, hSizeClass: horizontalSizeClass, min: 8, max: 12))
        .onLongPressGesture(minimumDuration: .infinity, pressing: { isPressing in
            if isPressing {
                beginHold()
            } else {
                cancelHold()
            }
        }, perform: {})
        .opacity(state.animateIn ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.2), value: state.animateIn)
    }

    private func beginHold() {
        guard holdTimer == nil else { return }
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            DispatchQueue.main.async {
                let step = CGFloat(0.016 / 0.3)
                holdProgress = min(1, holdProgress + step)
                asteriskAngle += Double(step) * 360.0   // spin forward in sync
                if holdProgress >= 1 {
                    holdTimer?.invalidate()
                    holdTimer = nil
                    state.startPractice()
                    withAnimation(.easeOut(duration: 0.3)) {
                        holdProgress  = 0
                        asteriskAngle = 0
                    }
                }
            }
        }
    }

    private func cancelHold() {
        holdTimer?.invalidate()
        holdTimer = nil
        guard holdProgress < 1 else { return }
        // Bars shrink forward, asterisk explicitly spins back to 0
        withAnimation(.easeOut(duration: 0.35)) {
            holdProgress  = 0
            asteriskAngle = 0
        }
    }

}

/// Conversation icon swaps to speaker while voice is active.
private struct ConversationSpeakerGlyph: View {
    let slotSize: CGFloat
    let isSpeaking: Bool

    private var headDiameter: CGFloat { slotSize * 0.38 }
    private var torsoWidth: CGFloat { slotSize * 0.54 }
    private var torsoHeight: CGFloat { slotSize * 0.40 }

    var body: some View {
        ZStack {
            if isSpeaking {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: slotSize * 0.66, weight: .semibold))
                    .foregroundColor(.cyan)
                    .transition(.opacity)
            } else {
                VStack(spacing: slotSize * 0.07) {
                    Circle()
                        .fill(ThemeColors.secondaryAccent)
                        .frame(width: headDiameter, height: headDiameter)
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: torsoWidth, height: torsoHeight)
                }
                .transition(.opacity)
            }
        }
        .frame(width: slotSize, height: slotSize)
        .animation(.easeInOut(duration: 0.12), value: isSpeaking)
        .onChange(of: isSpeaking) { _, speaking in
            print("📚 [LearnTab] ConversationSpeakerGlyph render -> \(speaking ? "SPEAKER" : "PERSON")")
        }
    }
}
