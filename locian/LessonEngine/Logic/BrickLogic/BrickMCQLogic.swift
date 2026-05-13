import SwiftUI
import Combine

// MARK: - Two-Stage MCQ
//
// Stage 1 — Pick the dictionary (base) form for the highlighted word.
//   • Wrong tap: marks the brick wrong, applies mastery penalty, but flow still
//     advances (the correct base is revealed and Stage 2 opens).
//   • Correct tap: silent gate. No mastery reward, no "answered" marker —
//     Stage 2 opens inline below the picked option.
//
// Stage 2 — Pick the inflected (target) form. This is the scored answer that
// drives mastery and the orchestrator's `markBrickAnswered`.

enum MCQStage: Equatable {
    case pickingBase
    case expandedAtBase(String)   // user picked correct base; targets are now showing
    case answered(Bool)           // final scored result
}

class BrickMCQLogic: ObservableObject {
    let state: DrillState
    let engine: LessonEngine

    // Resolved brick (rich morphology fields live here)
    let brick: BrickItem?

    // Display data
    let prompt: String                    // native meaning of THIS brick (e.g. "we paid")
    let targetLanguage: String

    // Two-stage data
    let baseOptions: [String]
    let correctBase: String?              // nil → fall through to single-stage
    let formKind: String?
    let baseNative: String?
    let pattern: String?
    let why: String?

    // Stage 1 state (base picking)
    @Published var stage: MCQStage = .pickingBase
    @Published var basePickedWrong: String? = nil   // shows red border when wrong
    @Published var awaitingContinueAfterWrongBase: Bool = false

    // Stage 2 state (target picking)
    @Published var targetOptions: [String] = []
    @Published var selectedTargetOption: String? = nil

    // Backwards-compat: existing callers still read `selectedOption` / `isCorrect` /
    // `correctOption` / `options`. We re-expose these to the final-stage values.
    @Published var isAudioPlaying: Bool = false
    private var optionAudioMap: [String: (id: String, voice: String)] = [:]

    @Published var practiceLogic: PatternPracticeLogic?
    @Published var ghostLogic: GhostModeLogic?

    var onComplete: ((Bool) -> Void)?

    /// Single-stage fallback: when the brick has no `base` field, we behave like
    /// the legacy MCQ — show 4 native meaning options and validate directly.
    let isLegacyMode: Bool
    let legacyOptions: [String]
    let legacyOptionPhonetics: [String: String]

    init(state: DrillState, engine: LessonEngine, onComplete: ((Bool) -> Void)? = nil) {
        self.state = state
        self.engine = engine
        self.onComplete = onComplete
        let targetLanguageCode = engine.lessonData?.target_language ?? "es"
        self.targetLanguage = TargetLanguageMapping.shared.getDisplayNames(for: targetLanguageCode).english

        // Look up the brick by id/word
        let allBricksData = engine.allBricks
        let allBricks = (allBricksData?.constants ?? []) +
                        (allBricksData?.variables ?? []) +
                        (allBricksData?.structural ?? [])
        let brickIdNormalized = state.id
            .replacingOccurrences(of: "INT-", with: "")
            .replacingOccurrences(of: "PRACTICE-MISTAKE-", with: "")
            .replacingOccurrences(of: "GHOST-", with: "")
        let resolvedBrick = allBricks.first { $0.id == brickIdNormalized }
            ?? allBricks.first { $0.word == state.drillData.target }
        self.brick = resolvedBrick

        // Prompt = native meaning of this brick (used in fallback path + as a label)
        self.prompt = state.drillData.meaning

        // Decide mode based on whether brick has a base form
        let resolvedBase = resolvedBrick?.base?.trimmingCharacters(in: .whitespaces)
        let hasBase = resolvedBase != nil && !(resolvedBase ?? "").isEmpty
        self.isLegacyMode = !hasBase
        self.correctBase = resolvedBase
        self.formKind = resolvedBrick?.form_kind
        self.baseNative = resolvedBrick?.base_native
        self.pattern = resolvedBrick?.pattern
        self.why = resolvedBrick?.why

        // ── Two-stage: build base options ─────────────────────────────────
        if hasBase, let targetBase = resolvedBase {
            let myKind = resolvedBrick?.base_kind
            let lessonBases = allBricks.compactMap { $0.base }
            let sameKind = allBricks
                .filter { ($0.base_kind ?? "") == (myKind ?? "") && $0.base != nil }
                .compactMap { $0.base }
                .filter { $0 != targetBase }
            let otherBases = lessonBases.filter { $0 != targetBase && !sameKind.contains($0) }
            let fallback = allBricks.map { $0.meaning }.filter { !$0.isEmpty }

            self.baseOptions = MCQOptionGenerator.generateBaseOptions(
                targetBase: targetBase,
                sameKindBases: sameKind,
                otherBases: otherBases,
                fallbackCandidates: fallback
            )
        } else {
            self.baseOptions = []
        }

        // ── Legacy / single-stage fallback options (native L1 distractors) ──
        if !hasBase {
            if let existing = state.mcqOptions {
                self.legacyOptions = existing
            } else {
                let candidates = Array(Set(allBricks.map { $0.word }))
                self.legacyOptions = MCQOptionGenerator.generateNativeOptions(
                    targetMeaning: state.drillData.target,
                    candidates: candidates,
                    validator: NeuralValidator()
                )
            }
            var phoneticMap: [String: String] = [:]
            for option in self.legacyOptions {
                if let match = allBricks.first(where: { $0.word == option }) {
                    phoneticMap[option] = match.phonetic
                    if let voice = match.voice_data {
                        optionAudioMap[option] = (match.id, voice)
                    }
                }
            }
            self.legacyOptionPhonetics = phoneticMap
        } else {
            self.legacyOptions = []
            self.legacyOptionPhonetics = [:]
        }
    }

    // MARK: - Public surface (matches old API for orchestrator compatibility)

    /// Final correct answer (target word) — used by status-glow code.
    var correctOption: String { state.drillData.target }

    /// "Selected option" in the legacy sense = the picked target.
    var selectedOption: String? {
        switch stage {
        case .answered: return selectedTargetOption
        default: return nil
        }
    }

    /// Final correctness — only set once Stage 2 is answered.
    var isCorrect: Bool? {
        if case .answered(let v) = stage { return v }
        return nil
    }

    /// Backwards-compat — code that previously enumerated `logic.options` will
    /// still get a usable list. In two-stage mode this is whatever options are
    /// currently visible (base or target).
    var options: [String] {
        if isLegacyMode { return legacyOptions }
        switch stage {
        case .pickingBase: return baseOptions
        default: return targetOptions
        }
    }

    var optionPhonetics: [String: String] {
        // Phonetics only exist for native meaning lookups; in two-stage mode
        // we don't carry phonetics for bases or sibling-targets.
        return legacyOptionPhonetics
    }

    var hasInput: Bool { selectedTargetOption != nil || isCorrect != nil }

    // MARK: - Stage 1 (base)

    func selectBase(_ option: String) {
        guard !isLegacyMode, case .pickingBase = stage else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        if option == correctBase {
            // Silent gate — no mastery, no markBrickAnswered.
            // Compute target options now (lazily, so a wrong tap doesn't reveal them).
            buildTargetOptions()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                stage = .expandedAtBase(option)
            }
        } else {
            // Wrong base — penalty and active-wrong flag. Gate on user CONTINUE
            // tap before revealing the correct base + opening Stage 2.
            basePickedWrong = option
            engine.updateMastery(id: brickIdForMastery, delta: -0.05)
            withAnimation(.easeOut(duration: 0.18)) {
                awaitingContinueAfterWrongBase = true
            }
        }
    }

    /// Called when the user taps CONTINUE on the red INCORRECT footer after a
    /// wrong base pick. Reveals the correct base and opens Stage 2.
    func continueAfterWrongBase() {
        guard awaitingContinueAfterWrongBase else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        buildTargetOptions()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.awaitingContinueAfterWrongBase = false
            self.stage = .expandedAtBase(self.correctBase ?? "")
        }
    }

    private func buildTargetOptions() {
        let allBricksData = engine.allBricks
        let allBricks = (allBricksData?.constants ?? []) +
                        (allBricksData?.variables ?? []) +
                        (allBricksData?.structural ?? [])
        let siblings = brick?.sibling_targets ?? []
        let fallback = Array(Set(allBricks.map { $0.word })).filter { !$0.isEmpty }
        self.targetOptions = MCQOptionGenerator.generateSiblingTargetOptions(
            correctTarget: state.drillData.target,
            siblingTargets: siblings,
            fallbackCandidates: fallback
        )

        // Re-populate audio map for these target options
        for option in self.targetOptions {
            if let match = allBricks.first(where: { $0.word == option }) {
                if let voice = match.voice_data {
                    optionAudioMap[option] = (match.id, voice)
                }
            }
        }
    }

    // MARK: - Stage 2 (target)

    func selectTarget(_ option: String) {
        guard case .expandedAtBase = stage else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        selectedTargetOption = option

        // Notify parents of input
        practiceLogic?.hasInput = true
        ghostLogic?.hasInput = true

        // Play audio for the tapped option (backend voice path only)
        self.isAudioPlaying = true
        let voicePath: String? = {
            guard let audioTuple = optionAudioMap[option] else { return nil }
            let p = audioTuple.voice.trimmingCharacters(in: .whitespacesAndNewlines)
            return p.isEmpty ? nil : p
        }()
        let voiceId = optionAudioMap[option]?.id ?? state.id
        AudioManager.shared.playVoiceFromBackendIfAvailable(relativePath: voicePath, id: voiceId) { [weak self] in
            DispatchQueue.main.async { self?.isAudioPlaying = false }
        }

        // Validate
        let actualTarget = state.drillData.target
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        let validator = MCQValidator()
        let result = validator.validate(input: option, target: actualTarget, context: context)
        let isCorrectResult = (result == .correct || result == .meaningCorrect)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            stage = .answered(isCorrectResult)
        }

        // Inform parents
        practiceLogic?.markDrillAnswered(isCorrect: isCorrectResult)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrectResult)

        // Mastery
        if isCorrectResult {
            engine.updateMastery(id: brickIdForMastery, delta: 0.15)
        } else {
            engine.updateMastery(id: brickIdForMastery, delta: -0.05)
        }
    }

    private var brickIdForMastery: String {
        state.id
            .replacingOccurrences(of: "INT-", with: "")
            .replacingOccurrences(of: "PRACTICE-MISTAKE-", with: "")
            .replacingOccurrences(of: "GHOST-", with: "")
    }

    // MARK: - Legacy single-stage path (unchanged behavior for bricks w/o base)

    func selectOption(_ option: String) {
        if !isLegacyMode {
            // Two-stage: route to whichever stage is active
            switch stage {
            case .pickingBase: selectBase(option)
            case .expandedAtBase: selectTarget(option)
            case .answered: return
            }
            return
        }
        // ── Legacy path ────────────────────────────────────────────────
        guard isCorrect == nil else { return }
        selectedTargetOption = option
        practiceLogic?.hasInput = true
        ghostLogic?.hasInput = true
        self.isAudioPlaying = true
        let voicePath: String? = {
            guard let audioTuple = optionAudioMap[option] else { return nil }
            let p = audioTuple.voice.trimmingCharacters(in: .whitespacesAndNewlines)
            return p.isEmpty ? nil : p
        }()
        let voiceId = optionAudioMap[option]?.id ?? state.id
        AudioManager.shared.playVoiceFromBackendIfAvailable(relativePath: voicePath, id: voiceId) { [weak self] in
            DispatchQueue.main.async { self?.isAudioPlaying = false }
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

    func clearInput() {
        self.selectedTargetOption = nil
        self.basePickedWrong = nil
        self.awaitingContinueAfterWrongBase = false
        self.stage = .pickingBase
        practiceLogic?.isAnswered = false
        practiceLogic?.isCorrect = false
        ghostLogic?.isAnswered = false
        ghostLogic?.isCorrect = false
    }

    func checkAnswer() {
        // Two-stage MCQ validates on tap; this is a no-op for parity.
        // Legacy mode: validate the picked native option.
        guard isLegacyMode, let option = selectedTargetOption, isCorrect == nil else { return }
        let actualTarget = state.drillData.target
        let context = ValidationContext(
            state: state,
            locale: TargetLanguageMapping.shared.getLocale(for: engine.lessonData?.target_language ?? "en"),
            engine: engine,
            neuralEngine: NeuralValidator()
        )
        let validator = MCQValidator()
        let result = validator.validate(input: option, target: actualTarget, context: context)
        let isCorrectResult = (result == .correct || result == .meaningCorrect)
        stage = .answered(isCorrectResult)

        practiceLogic?.markDrillAnswered(isCorrect: isCorrectResult)
        ghostLogic?.markDrillAnswered(isCorrect: isCorrectResult)

        if isCorrectResult {
            engine.updateMastery(id: brickIdForMastery, delta: 0.15)
        } else {
            engine.updateMastery(id: brickIdForMastery, delta: -0.05)
        }
    }

    // MARK: - Audio / playthrough

    private static var introIndex = 0
    static func playIntro(drill: DrillState, engine: LessonEngine, mode: DrillMode) {
        if let override = drill.overrideVoiceInstructions {
            print("🎙️ Skipping Voice Override text (TTS Disabled): '\(override)'")
        }
    }

    func playAudio() {
        let voiceData = state.drillData.voice_data
        self.isAudioPlaying = true
        self.practiceLogic?.isAudioPlaying = true
        self.ghostLogic?.isAudioPlaying = true
        AudioManager.shared.playVoiceFromBackendIfAvailable(
            relativePath: voiceData,
            id: state.id
        ) { [weak self] in
            DispatchQueue.main.async {
                self?.isAudioPlaying = false
                self?.practiceLogic?.isAudioPlaying = false
                self?.ghostLogic?.isAudioPlaying = false
            }
        }
    }

    func continueToNext() {
        AudioManager.shared.stop()
        onComplete?(isCorrect ?? true)
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
        BrickMCQView(
            state: state,
            engine: engine,
            practiceLogic: practiceLogic,
            ghostLogic: ghostLogic,
            onComplete: onComplete
        )
        .onAppear {
            BrickMCQLogic.playIntro(drill: state, engine: engine, mode: mode)
        }
    }
}
