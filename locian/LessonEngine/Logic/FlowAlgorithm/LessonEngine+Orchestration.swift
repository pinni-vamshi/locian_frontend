import Foundation
import Combine

// MARK: - THE DRIVER (Session State)
class LessonOrchestrator: ObservableObject {
    
    // State for View
    @Published var activeState: DrillState?
    /// Index within grammar bridge steps (`grammar_bricks` preferred, else legacy index rules).
    @Published var grammarBridgeStep: Int = 0
    
    // Ghost Mode Overrides
    var onGhostCompleteOverride: (() -> Void)?
    
    // Dependencies
    weak var engine: LessonEngine?
    
    // Internal State
    private var currentPattern: PatternData?
    private var currentMode: DrillMode?
    
    // MARK: - Entry Point (Called by Flow)
    func startPattern(_ pattern: PatternData) {
        self.currentPattern = pattern
        self.grammarBridgeStep = 0

        // --- STAGE 1: VOCAB INTRO (Skip Prereqs) ---
        self.currentMode = .vocabIntro
        let state = materializeState(mode: .vocabIntro, pattern: pattern)

        // Stamp the intro brick set BEFORE publishing activeState, so the
        // headline (ActiveTurnView) and the drill builder (PatternIntroLogic)
        // both observe the exact same list on the very first render.
        let introIDs = engine?.computeIntroBricks(for: state).map { $0.id } ?? []
        engine?.lastIntroBrickIDs = introIDs
        engine?.currentIntroBrickID = introIDs.first

        self.activeState = state
    }
    
    // MARK: - STAGE TRANSITIONS (Called by Parent Logics)
    
    func finishVocabIntro() {
        guard let pattern = currentPattern, let engine else {
            return
        }
        // Grammar bridge (own skip rules) → pattern practice.
        if Self.shouldSkipGrammarBridge(pattern: pattern, engine: engine)
            || Self.grammarBridgeStepCount(for: pattern, engine: engine) == 0 {
            enterPatternPractice(pattern)
            return
        }
        grammarBridgeStep = 0
        currentMode = .grammarBridge
        activeState = materializeState(mode: .grammarBridge, pattern: pattern)
    }

    /// After the last grammar question, enter practice.
    func finishGrammarBridge() {
        guard let pattern = currentPattern else { return }
        enterPatternPractice(pattern)
    }

    /// User completed the current grammar question; advance to next rule or practice.
    func advanceGrammarBridge() {
        guard let pattern = currentPattern, let engine else { return }
        let count = Self.grammarBridgeStepCount(for: pattern, engine: engine)
        guard count > 0 else {
            enterPatternPractice(pattern)
            return
        }
        if grammarBridgeStep + 1 < count {
            grammarBridgeStep += 1
        } else {
            finishGrammarBridge()
        }
    }

    private func enterPatternPractice(_ pattern: PatternData) {
        currentMode = .patternPractice
        activeState = materializeState(mode: .patternPractice, pattern: pattern)
    }
    
    func finishPatternPractice() {
        guard let pattern = currentPattern else { return }
        // Rehearsal / ghost stage kept in codebase for other shells — not invoked here.
        finishPattern(for: pattern.id)
    }
    
    func finishGhostMode(for patternId: String? = nil) {
        if let override = onGhostCompleteOverride {
            override()
            return
        }
        
        guard let current = currentPattern else { return }
        
        // Identity Check: Prevent "Late Assassin" signals from previous patterns
        if let id = patternId, current.id != id {
            print("⚠️ [GHOST COURT] DISMISSED LATE FINISH SIGNAL: Expected \(current.id), got \(id)")
            return
        }
        
        // --- STAGE 4: FINISH (No Extra Drill) ---
        // The Final Target was already inside Ghost Mode.
        // We just clean up.
        self.finishPattern(for: current.id)
    }
    
    func finishPattern(for patternId: String? = nil) {
        if let override = onGhostCompleteOverride {
            override()
            return
        }
        
        guard let pattern = currentPattern else { return }
        
        // Identity Check
        if let id = patternId, pattern.id != id {
            print("⚠️ [GHOST COURT] DISMISSED LATE PATTERN FINISH: Expected \(pattern.id), got \(id)")
            return
        }
        
        self.currentPattern = nil
        self.currentMode = nil
        self.activeState = nil
        
        engine?.patternCompleted(id: pattern.id)
    }
    
    // Compatibility shim (to be removed once all dependencies are updated)
    func advance() {
        switch currentMode {

        case .vocabIntro: finishVocabIntro()
        case .grammarBridge: break // User-driven via `advanceGrammarBridge()` from grammar UI
        case .patternPractice: finishPatternPractice()
        case .ghostManager: finishGhostMode(for: currentPattern?.id)
        case .typing: finishPattern(for: currentPattern?.id)
        default: break
        }
    }
    
    // Helper
    private func materializeState(mode: DrillMode?, pattern: PatternData) -> DrillState {
        let item = DrillItem(
            target: pattern.target,
            meaning: pattern.meaning,
            phonetic: pattern.phonetic,
            voice_url: pattern.voice_url,
            voice_data: pattern.voice_data
        )
        return DrillState(
            id: pattern.id,  // ✅ Clean ID (no mode suffix)
            patternId: pattern.id, 
            drillIndex: 0, 
            drillData: item, 
            isBrick: false, 
            currentMode: mode  // ✅ nil = let selector decide
        )
    }

    // MARK: - Grammar bridge helpers

    /// Rich `grammar_bricks` from discover (preferred); up to two steps.
    static func effectiveGrammarBricks(for pattern: PatternData) -> [PatternGrammarBrick] {
        let all = pattern.grammar_bricks ?? []
        let usable = all.filter { brick in
            let q = brick.pattern_json?.question?.native?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let a = brick.pattern_json?.reply?.native?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return !q.isEmpty && !a.isEmpty
        }
        return Array(usable.prefix(2))
    }

    /// Total grammar-bridge steps (rich bricks, else legacy index rules).
    static func grammarBridgeStepCount(for pattern: PatternData, engine: LessonEngine) -> Int {
        let bricks = effectiveGrammarBricks(for: pattern)
        if !bricks.isEmpty { return bricks.count }
        return effectiveGrammarRules(for: pattern, engine: engine).count
    }

    /// Legacy: up to two rules with resolvable brick indices for this pattern.
    static func effectiveGrammarRules(for pattern: PatternData, engine: LessonEngine) -> [PatternGrammarRule] {
        let all = pattern.grammar_rules ?? []
        let ordered = engine.orderedSentenceBricks(for: pattern.id)
        guard !ordered.isEmpty else { return [] }
        let resolved = all.filter { rule in
            rule.q_anchor_index >= 0 && rule.q_anchor_index < ordered.count
                && rule.a_brick_index >= 0 && rule.a_brick_index < ordered.count
        }
        return Array(resolved.prefix(2))
    }

    /// Parallel skip idea to vocab intro: pattern blend **or** average word mastery over sentence bricks.
    static func shouldSkipGrammarBridge(pattern: PatternData, engine: LessonEngine) -> Bool {
        if engine.getBlendedMastery(for: pattern.id) >= 0.85 { return true }
        let avg = engine.averageSentenceBrickMastery(for: pattern.id)
        return avg >= 0.85
    }
}
