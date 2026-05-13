//
//  ActiveTurnView.swift
//  locian
//
//  Conversation conveyor:
//   • Single visible stage — only the live pattern row (Locian prompt +
//     learner reply + drills). Past turns are not replayed in a header bubble.
//   • Each pattern emits one conversational slot — **user reply only**
//     (pattern intro → practice → …). Locian comprehension MCQ is skipped.
//   • ForEach is keyed by `turn.id` so when the active pattern changes,
//     transitions animate cleanly between turns.
//

import SwiftUI

// MARK: - Turn model

private struct Turn: Identifiable, Equatable {
    let id: String                 // "<patternId>-user"
    let patternId: String
    let textTarget: String         // L2 form (target language)
    let textNative: String         // L1 form (native language)

    static func user(for p: PatternData) -> Turn {
        Turn(
            id: "\(p.id)-user",
            patternId: p.id,
            textTarget: p.target,
            textNative: p.meaning
        )
    }
}

// MARK: - View

struct ActiveTurnView: View {
    @ObservedObject var engine: LessonEngine
    let activePatternId: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(visibleTurns, id: \.id) { turn in
                TurnConveyorView(
                    turn: turn,
                    engine: engine
                )
                .diagnosticBorder(.orange)
                .transition(
                    .asymmetric(
                        insertion: .identity,
                        removal: .offset(y: -80).combined(with: .opacity)
                    )
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .clipped()
        .diagnosticBorder(.red)
        .animation(.spring(response: 0.55, dampingFraction: 0.82), value: conveyorKey)
    }

    // MARK: - Turn derivation

    /// Active pattern — always the user's reply row (intro + drills).
    private var currentTurn: Turn? {
        guard let pid = activePatternId,
              let p = engine.allPatterns.first(where: { $0.id == pid }) else { return nil }
        return Turn.user(for: p)
    }

    private var visibleTurns: [Turn] {
        guard let curr = currentTurn else { return [] }
        return [curr]
    }

    private var conveyorKey: String {
        currentTurn?.id ?? "-"
    }
}

// MARK: - Turn container (bubble ↔ active stage)

private struct TurnConveyorView: View {
    let turn: Turn
    @ObservedObject var engine: LessonEngine

    @State private var qIn: Bool = false   // question row entered
    @State private var aIn: Bool = false   // answer row entered

    private let rowSpring: Animation = .spring(response: 0.48, dampingFraction: 0.78)

    var body: some View {
        userActive
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .onAppear {
                withAnimation(rowSpring) { qIn = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.13) {
                    withAnimation(rowSpring) { aIn = true }
                }
            }
    }

    private var isPracticeMode: Bool {
        engine.orchestrator?.activeState?.currentMode == .patternPractice
    }

    // Fixed slot heights — each row lives in its own immovable container.
    // Text can wrap / scale inside the slot but the slot height never changes
    // between sentences, so the whole header block never shifts up or down.
    private var questionSlotH: CGFloat { isPracticeMode ? 140 : 56 }
    private var answerSlotH:   CGFloat { isPracticeMode ? 36  : 96 }

    private var userActive: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {

                // ── Row 1: Locian icon + question  (fixed-height slot) ───────
                HStack(alignment: .top, spacing: 6) {

                    Image("AppIconImage")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: isPracticeMode ? 24 : 20, height: isPracticeMode ? 24 : 20)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .diagnosticBorder(.mint)

                    Text(":")
                        .font(LearnHelvetica.font(size: 12, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.38))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(headerQuestionTarget)
                            .font(.custom("Helvetica-Bold", size: isPracticeMode ? 28 : 13))
                            .foregroundColor(isPracticeMode ? MockTokens.fg : MockTokens.muted2)
                            .lineLimit(isPracticeMode ? 3 : 2)
                            .minimumScaleFactor(0.75)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .diagnosticBorder(.blue)

                        if let native = headerQuestionNative {
                            Text(native)
                                .font(LearnHelvetica.font(size: isPracticeMode ? 13 : 11, weight: .regular))
                                .foregroundColor(isPracticeMode ? MockTokens.muted2 : MockTokens.muted)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .diagnosticBorder(.cyan)
                        }
                    }
                    .diagnosticBorder(.purple)
                    Spacer(minLength: 0)
                }
                // Fixed-height slot — never grows or shrinks between sentences
                .frame(maxWidth: .infinity)
                .frame(height: questionSlotH, alignment: .topLeading)
                .clipped()
                .offset(y: qIn ? 0 : 52)
                .opacity(qIn ? 1 : 0)
                .diagnosticBorder(.yellow)

                // ── Row 2: User person glyph + reply  (fixed-height slot) ────
                HStack(alignment: .top, spacing: 6) {
                    let slotSize: CGFloat = 20
                    ZStack {
                        VStack(spacing: slotSize * 0.07) {
                            Circle()
                                .fill(ThemeColors.secondaryAccent)
                                .frame(width: slotSize * 0.38, height: slotSize * 0.38)
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: slotSize * 0.54, height: slotSize * 0.40)
                        }
                    }
                    .frame(width: slotSize, height: slotSize)
                    .diagnosticBorder(.cyan)

                    Text(":")
                        .font(LearnHelvetica.font(size: 12, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.38))

                    Text(headlineAttributed)
                        .font(.custom("Helvetica-Bold", size: isPracticeMode ? 13 : 30))
                        .foregroundColor(isPracticeMode ? MockTokens.muted2 : MockTokens.fg)
                        .lineLimit(isPracticeMode ? 2 : 3)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .animation(.easeInOut(duration: 0.45), value: engine.revealedIntroBrickIDs)
                        .animation(.easeInOut(duration: 0.45), value: engine.introAllRevealed)
                        .animation(.easeInOut(duration: 0.35), value: engine.currentIntroBrickID)
                        .diagnosticBorder(.blue)
                    Spacer(minLength: 0)
                }
                // Fixed-height slot
                .frame(maxWidth: .infinity)
                .frame(height: answerSlotH, alignment: .topLeading)
                .clipped()
                .offset(y: aIn ? 0 : 52)
                .opacity(aIn ? 1 : 0)
                .diagnosticBorder(.green)
            }
            .padding(.horizontal, 2)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.04))
            .diagnosticBorder(.orange)

            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 0.5)
                .diagnosticBorder(.purple)

            drillContent
                .padding(.top, 14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .clipped()
                .compositingGroup()
                .environment(\.compactDrillZone, true)
                .background(Color.black)
                .diagnosticBorder(.green)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .diagnosticBorder(.red)
    }

    private static let introHighlightColor: Color = MockTokens.pink

    private var headlineAttributed: AttributedString {
        var attr = AttributedString(turn.textNative)

        guard engine.orchestrator?.activeState?.currentMode == .vocabIntro,
              !engine.lastIntroBrickIDs.isEmpty else { return attr }

        let raw = String(attr.characters)
        let bricksContainer = engine.allBricks

        // ── Animation phase: grey sentence, revealed words → white + white underline ──
        if engine.isPlayingPatternIntroAnimation {
            let allRevealed = engine.introAllRevealed

            if allRevealed {
                // All words done — full sentence white, taught words underlined
                for brickId in engine.lastIntroBrickIDs {
                    guard let brick = MasteryFilterService.getBrick(id: brickId, from: bricksContainer) else { continue }
                    let searchToken = (brick.nativeBrick ?? brick.meaning).trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !searchToken.isEmpty else { continue }
                    for stringRange in wholeWordRanges(of: searchToken, in: raw) {
                        guard let attrRange = Range(stringRange, in: attr) else { continue }
                        attr[attrRange].underlineStyle = Text.LineStyle(pattern: .solid, color: MockTokens.fg)
                    }
                }
            } else {
                // Sentence grey; each revealed word → white + white underline
                if let fullRange = attr.range(of: String(attr.characters)) {
                    attr[fullRange].foregroundColor = Color(white: 0.35)
                }
                for brickId in engine.revealedIntroBrickIDs {
                    guard let brick = MasteryFilterService.getBrick(id: brickId, from: bricksContainer) else { continue }
                    let searchToken = (brick.nativeBrick ?? brick.meaning).trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !searchToken.isEmpty else { continue }
                    for stringRange in wholeWordRanges(of: searchToken, in: raw) {
                        guard let attrRange = Range(stringRange, in: attr) else { continue }
                        attr[attrRange].foregroundColor = MockTokens.fg
                        attr[attrRange].underlineStyle = Text.LineStyle(pattern: .solid, color: MockTokens.fg)
                    }
                }
            }
            return attr
        }

        // ── Graph / main lesson phase: existing behaviour unchanged ──
        let underlineStyle = Text.LineStyle(pattern: .solid, color: Color.white.opacity(0.3))
        let activeBrickId = engine.currentIntroBrickID
        let teachMasteryCeiling = 0.40

        for brickId in engine.lastIntroBrickIDs {
            guard let brick = MasteryFilterService.getBrick(id: brickId, from: bricksContainer) else { continue }
            let mastery = engine.getDecayedMastery(for: brick.word)
            if brickId != activeBrickId && mastery >= teachMasteryCeiling { continue }

            let searchToken = (brick.nativeBrick ?? brick.meaning).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !searchToken.isEmpty else { continue }

            for stringRange in wholeWordRanges(of: searchToken, in: raw) {
                guard let attrRange = Range(stringRange, in: attr) else { continue }
                attr[attrRange].underlineStyle = underlineStyle
                if brickId == activeBrickId {
                    attr[attrRange].foregroundColor = Self.introHighlightColor
                }
            }
        }

        return attr
    }

    private func wholeWordRanges(of needle: String, in haystack: String) -> [Range<String.Index>] {
        guard !needle.isEmpty else { return [] }
        var results: [Range<String.Index>] = []
        var searchStart = haystack.startIndex
        while searchStart < haystack.endIndex,
              let found = haystack.range(of: needle, options: .caseInsensitive, range: searchStart..<haystack.endIndex) {
            let leftOK: Bool = {
                guard found.lowerBound > haystack.startIndex else { return true }
                let prev = haystack[haystack.index(before: found.lowerBound)]
                return !prev.isLetter && !prev.isNumber
            }()
            let rightOK: Bool = {
                guard found.upperBound < haystack.endIndex else { return true }
                let next = haystack[found.upperBound]
                return !next.isLetter && !next.isNumber
            }()
            if leftOK && rightOK {
                results.append(found)
            }
            searchStart = found.upperBound
        }
        return results
    }

    private var headerQuestionTarget: String {
        guard let pid = engine.orchestrator?.activeState?.patternId,
              let pattern = engine.allPatterns.first(where: { $0.id == pid }) else {
            return turn.textTarget
        }
        let t = (pattern.locian_question ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? turn.textTarget : t
    }

    private var headerQuestionNative: String? {
        guard let pid = engine.orchestrator?.activeState?.patternId,
              let pattern = engine.allPatterns.first(where: { $0.id == pid }) else {
            return nil
        }
        let n = (pattern.locian_question_native ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return n.isEmpty ? nil : n
    }

    @ViewBuilder
    private var drillContent: some View {
        if let orchestrator = engine.orchestrator, let state = orchestrator.activeState {
            switch state.currentMode {
            case .vocabIntro:
                PatternIntroManagerView(state: state, engine: engine)
                    .id("intro-\(state.id)")
            case .ghostManager:
                Color.clear
                    .id("ghost-skip-\(state.id)")
                    .onAppear {
                        engine.orchestrator?.finishPattern(for: state.patternId)
                    }
            case .patternPractice:
                PatternPracticeView(targetPattern: state, engine: engine)
                    .id("practice-\(state.id)")
            default:
                if state.isBrick {
                    BrickModeSelector(drill: state, engine: engine, onComplete: { _ in
                        engine.orchestrator?.finishPattern(for: state.patternId)
                    })
                    .id("drill-brick-\(state.id)")
                } else {
                    PatternModeSelector(drill: state, engine: engine, onComplete: { _ in
                        engine.orchestrator?.finishPattern(for: state.patternId)
                    })
                    .id("drill-pattern-\(state.id)")
                }
            }
        } else {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: CyberColors.neonCyan))
        }
    }
}
