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
            appendFinalTarget()
            
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
        // 1. Create Drill (No overrides or complex data in Ghost Mode)
        let finalTarget = DrillState(
            id: targetPattern.id,
            patternId: targetPattern.id,
            drillIndex: 0,
            drillData: DrillItem(target: targetPattern.drillData.target, meaning: targetPattern.drillData.meaning, phonetic: targetPattern.drillData.phonetic),
            isBrick: false,
            currentMode: PatternModeSelector.resolveMode(for: targetPattern, engine: engine)
        )
        
        self.historyQueue.append(finalTarget)
        print("   🌪️ [GhostMode] Added Final Target to Queue (Total: \(historyQueue.count))")
    }
    
    private func buildHistoryQueue() {
        // 1. Get the "F4" list from Engine
        // ✅ ROBUST SYNC: Normalize IDs (trim + lower) to prevent duplication failure
        let targetIdClean = targetPattern.patternId.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let visited = Array(engine.recentPatternHistory).filter { historyId in
            let historyIdClean = historyId.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let isCurrent = (historyIdClean == targetIdClean)
            if isCurrent {
                print("   🛡️ [GHOST COURT] EXCLUDING CURRENT PATTERN FROM HISTORY: \(historyId)")
            }
            return !isCurrent
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
        
        // 4. Populate Queue
        for winner in winners {
            if let raw = engine.rawPatterns.first(where: { $0.id == winner.id }) {
                let drillItem = DrillItem(target: raw.target, meaning: raw.meaning, phonetic: raw.phonetic)
                historyQueue.append(DrillState(
                    id: winner.id,
                    patternId: winner.id,
                    drillIndex: -1,
                    drillData: drillItem,
                    isBrick: false,
                    currentMode: PatternModeSelector.resolveMode(for: DrillState(id: winner.id, patternId: winner.id, drillIndex: -1, drillData: drillItem, isBrick: false), engine: engine)
                ))
                print("   ⛓️ [GHOST COURT] ADDED SUBPOENAED PATTERN: \(winner.id)")
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
                            onComplete: { isCorrect in 
                                logic.markDrillAnswered(isCorrect: isCorrect)
                            }
                         )
                    } else {
                        // Pattern Selector (Direct)
                        PatternModeSelector(
                            drill: ghost,
                            engine: logic.engine,
                            forcedMode: ghost.currentMode,
                            ghostLogic: logic,
                            onComplete: { isCorrect in
                                logic.markDrillAnswered(isCorrect: isCorrect)
                            }
                        )
                    }
                }
                .id("ghost-\(ghost.isBrick ? "brick" : "pattern")-\(ghost.id)")
                .zIndex(1)
                
                // 3. FOOTER LAYER (Overlay)
                if logic.isAnswered {
                    footer
                        .transition(.move(edge: .bottom))
                        .zIndex(10)
                }
            } else {
                Color.black.ignoresSafeArea()
            }
        }
        .onAppear {
            logic.start()
        }
    }
    
    // MARK: - Footer Component
    private var footer: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.1))
            
            let color: Color = logic.isCorrect ? CyberColors.neonPink : .red
            let title = logic.isCorrect ? "CORRECT!" : "INCORRECT"
            
            CyberProceedButton(
                action: { logic.advance() },
                label: "CONTINUE",
                title: title,
                color: color,
                systemImage: "arrow.right"
            )
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(Color.black)
        }
    }
}
