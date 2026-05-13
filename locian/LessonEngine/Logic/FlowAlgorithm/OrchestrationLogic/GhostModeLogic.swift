import SwiftUI
import Combine

class GhostModeLogic: ObservableObject {
    @Published var activeGhost: DrillState?
    @Published var shouldSkip: Bool = false
    @Published var isShowingHistoryIntro: Bool = false  // Controls full-screen animation starting point
    
    // Internal State for Footer
    @Published var currentIndex: Int = 0
    @Published var isAnswered: Bool = false
    @Published var isCorrect: Bool = false
    @Published var isAudioPlaying: Bool = false
    @Published var hasInput: Bool = false
    
    // ✅ Action Bridging (Parent View -> Child Logic)
    var requestCheckAnswer: (() -> Void)?
    var requestClearInput: (() -> Void)?
    
    enum GhostPhase {
        case history
        case finished
    }
    @Published var currentPhase: GhostPhase = .history

    // Data Source
    var historyQueue: [DrillState] = []
    
    let targetPattern: DrillState
    let engine: LessonEngine
    
    init(targetPattern: DrillState, engine: LessonEngine) {
        self.targetPattern = targetPattern
        self.engine = engine
        
        print("\n⚖️⚖️⚖️ [GHOST COURT] SESSION START ⚖️⚖️⚖️")
        print("   👨‍⚖️ TARGET: [\(targetPattern.id)] \"\(targetPattern.drillData.target)\"")
        print("   👨‍⚖️ HISTORY DEPTH: \(engine.recentPatternHistory.count) patterns")
        
        // 1. Build History Queue from Recent Patterns (Ghost Items)
        buildHistoryQueue()
        
        // 2. UNIFIED SKIP LOGIC (V5)
        if historyQueue.isEmpty {
            print("   🚫 [GHOST COURT] VERDICT: NO EVIDENCE (Queue Empty). SKIPPING.")
            self.shouldSkip = true
            self.isShowingHistoryIntro = false
            
            DispatchQueue.main.async {
                // FIX: Must pass raw patternId (e.g. "p1"), not the Ghost ID (e.g. "p1-Ghost-Manager")
                self.engine.orchestrator?.finishGhostMode(for: self.targetPattern.patternId)
            }
        } else {
            // Only add final target if it's NOT mastered
            if !isMastered(targetPattern.patternId) {
                appendFinalTarget()
            }
            
            // Re-check empty after conditional append
            if historyQueue.isEmpty {
                print("   🚫 [GHOST COURT] VERDICT: ALL EVIDENCE DISMISSED (Everything Mastered). SKIPPING.")
                self.shouldSkip = true
                self.isShowingHistoryIntro = false
                DispatchQueue.main.async {
                    self.engine.orchestrator?.finishGhostMode(for: self.targetPattern.patternId)
                }
                return
            }
            
            print("   📜 [GHOST COURT] FINAL DOCKET (\(historyQueue.count) items):")
            for (i, drill) in historyQueue.enumerated() {
                let type = drill.isBrick ? "🧱 BRICK" : "🌐 PATTERN"
                print("      \(i+1). [\(type)] \(drill.id) -> \"\(drill.drillData.target)\"")
            }
            
            self.currentPhase = .history
            self.currentIndex = 0
            self.isShowingHistoryIntro = true
        }
        print("⚖️⚖️⚖️ [GHOST COURT] SESSION ADJOURNED ⚖️⚖️⚖️\n")
    }
    
    private var hasStarted: Bool = false
    
    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        loadCurrentGhost()
    }

    private func loadCurrentGhost() {
        // Reset Footer
        self.isAnswered = false
        self.isCorrect = false
        self.hasInput = false
        self.requestCheckAnswer = nil
        self.requestClearInput = nil
        
        if currentIndex < historyQueue.count {
            let next = historyQueue[currentIndex]
            print("   🌪️ [GhostMode] Serving Ghost \(currentIndex + 1)/\(historyQueue.count): \"\(next.id)\"")
            self.activeGhost = next
        } else {
            print("✅ [GhostMode] Sequence Complete.")
            self.activeGhost = nil
            self.currentPhase = .finished
            // FIX: Must pass raw patternId
            engine.orchestrator?.finishGhostMode(for: targetPattern.patternId)
        }
    }
    
    func markDrillAnswered(isCorrect: Bool) {
        print("🌪️ [GhostMode] markDrillAnswered: \(isCorrect)")
        self.isCorrect = isCorrect
        self.isAnswered = true
    }
    
    func advance() {
        guard isAnswered else { return }
        withAnimation {
            currentIndex += 1
            loadCurrentGhost()
        }
    }
    
    // MARK: - Handlers for Animation Completions
    func onHistoryIntroComplete() {
        withAnimation {
            isShowingHistoryIntro = false
            start() // Ensure start is called if blocked by intro
        }
    }

    // MARK: - Queue Building Logic
    
    private func appendFinalTarget() {
        // Create Drill — lock mode at creation time to prevent mid-drill
        // re-resolution when checkAnswer() updates engine mastery
        var finalTarget = DrillState(
            id: targetPattern.id,
            patternId: targetPattern.id,
            drillIndex: 0,
            drillData: targetPattern.drillData,
            isBrick: false,
            currentMode: nil
        )
        finalTarget.currentMode = PatternModeSelector.resolveMode(for: finalTarget, engine: engine)
        
        self.historyQueue.append(finalTarget)
        print("   🌪️ [GhostMode] Added Final Target to Queue (mode: \(finalTarget.currentMode?.rawValue ?? "nil"), Total: \(historyQueue.count))")
    }
    
    // --- 🎯 AUTO-SKIP GUARD (V5.1) ---
    // If a pattern is already mastered, it should be treated as "Closed Case" and skipped.
    private func isMastered(_ id: String) -> Bool {
        return engine.getBlendedMastery(for: id) >= 0.85
    }
    
    private func buildHistoryQueue() {
        // 1. Get the "F4" list from Engine and deduplicate
        // ✅ ROBUST SYNC: Normalize IDs (trim + lower) to prevent duplication failure
        let targetIdClean = targetPattern.patternId.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Use a Set to track seen IDs for uniqueness within the visited list
        var seenVisitedIds = Set<String>()
        let visited = Array(engine.recentPatternHistory).filter { historyId in
            let historyIdClean = historyId.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let isCurrent = (historyIdClean == targetIdClean)
            let isDuplicate = seenVisitedIds.contains(historyIdClean)
            
            if !isCurrent && !isMastered(historyId) && !isDuplicate {
                seenVisitedIds.insert(historyIdClean)
                return true
            }
            return false
        }
        
        print("   👨‍⚖️ [GHOST COURT] EVALUATING CANDIDATES FROM HISTORY: \(visited)")
        
        guard !visited.isEmpty else { 
            print("   ⚠️ [GHOST COURT] NO HISTORY FOUND. DISMISSING CASE.")
            return 
        }
        
        // 2. Calculate Average Mastery across the History
        var totals: Double = 0
        var candidates: [(id: String, mastery: Double)] = []
        
        for id in visited {
            let m = engine.getBlendedMastery(for: id)
            totals += m
            candidates.append((id, m))
            print("      - Candidate: [\(id)] Mastery: \(String(format: "%.2f", m))")
        }
        
        let average = totals / Double(visited.count)
        print("   👨‍⚖️ [GHOST COURT] CALCULATED AVERAGE MASTERY: \(String(format: "%.2f", average))")
        
        // 3. Select 2 patterns closest to the average
        let sortedByProximity = candidates.sorted { 
            abs($0.mastery - average) < abs($1.mastery - average)
        }
        
        let winners = sortedByProximity.prefix(2)
        print("   🏆 [GHOST COURT] WINNING CANDIDATES: \(winners.map { $0.id })")
        
        // 4. Populate Queue — lock mode at creation time
        for winner in winners {
            if let raw = engine.rawPatterns.first(where: { $0.id == winner.id }) {
                let drillItem = DrillItem(
                    target: raw.target,
                    meaning: raw.meaning,
                    phonetic: raw.phonetic,
                    voice_url: raw.voice_url,
                    voice_data: raw.voice_data
                )
                var ghostDrill = DrillState(
                    id: winner.id,
                    patternId: winner.id,
                    drillIndex: -1,
                    drillData: drillItem,
                    isBrick: false,
                    currentMode: nil
                )
                ghostDrill.currentMode = PatternModeSelector.resolveMode(for: ghostDrill, engine: engine)
                historyQueue.append(ghostDrill)
                print("   ⛓️ [GHOST COURT] ADDED SUBPOENAED PATTERN: \(winner.id) (mode: \(ghostDrill.currentMode?.rawValue ?? "nil"))")
            }
        }
    }
}

// MARK: - View Component (Self-Contained)

struct GhostModeManagerView: View {
    @StateObject var logic: GhostModeLogic
    
    init(targetPattern: DrillState, engine: LessonEngine) {
        _logic = StateObject(wrappedValue: GhostModeLogic(targetPattern: targetPattern, engine: engine))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // 1. ANIMATION LAYER
            if logic.isShowingHistoryIntro {
                GhostModeHistoryAnimationView(
                    engine: logic.engine,
                    onComplete: { logic.onHistoryIntroComplete() }
                )
                .transition(.opacity).zIndex(2)
            }
            
            // 2. MAIN CONTENT LAYER
            else if let ghost = logic.activeGhost {
                Group {
                    if ghost.isBrick {
                         // Should not happen in Ghost Mode History (usually), but safe to handle
                         BrickModeSelector(
                            drill: ghost,
                            engine: logic.engine,
                            ghostLogic: logic,
                            onComplete: { _ in 
                                logic.markDrillAnswered(isCorrect: true) // ✅ Ensure advance() can proceed
                                logic.advance()
                            }
                         )
                    } else {
                        // Pattern Selector (Direct)
                        PatternModeSelector(
                            drill: ghost,
                            engine: logic.engine,
                            forcedMode: ghost.currentMode,
                            ghostLogic: logic,
                            onComplete: { _ in
                                logic.markDrillAnswered(isCorrect: true) // ✅ Ensure advance() can proceed
                                logic.advance()
                            }
                        )
                    }
                }
                .id("ghost-\(ghost.isBrick ? "brick" : "pattern")-\(ghost.id)")
                .zIndex(1)
            } else {
                Color.black
            }
        }
        .onAppear {
            logic.start()
        }
    }
    
    // MARK: - Footer Component
    private var footer: some View {
        EmptyView()
    }
}
