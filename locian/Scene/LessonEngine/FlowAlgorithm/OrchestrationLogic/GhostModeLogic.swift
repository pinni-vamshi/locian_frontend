import SwiftUI
import Combine

class GhostModeLogic: ObservableObject {
    @Published var activeGhost: DrillState?
    @Published var shouldSkip: Bool = false
    
    private var mistakeQueue: [DrillState] = []
    private var historyQueue: [DrillState] = []
    
    let targetPattern: DrillState
    let engine: LessonEngine
    
    init(targetPattern: DrillState, engine: LessonEngine) {
        self.targetPattern = targetPattern
        self.engine = engine
        
        print("🌪️ [GhostMode] INITIALIZING...")
        
        // 1. Phase 1: Capturing recycled mistakes from Intro
        self.mistakeQueue = engine.patternIntroMistakes
        print("   🌪️ [GhostMode] Phase 1 (Mistakes): Found \(mistakeQueue.count) items.")
        
        // 2. Phase 2: Building History Rehearsal Queue
        buildHistoryQueue()
        
        // 3. Global Skip Check
        self.shouldSkip = mistakeQueue.isEmpty && historyQueue.isEmpty
        if shouldSkip {
            print("   🌪️ [GhostMode] SKIP: Both queues empty. Bypassing Ghost Mode.")
        } else {
            print("   🌪️ [GhostMode] START: MistakeCount=\(mistakeQueue.count), HistoryCount=\(historyQueue.count)")
        }
    }
    
    private var hasStarted: Bool = false
    
    func start() {
        // ✅ Prevent double-start / accidental queue consumption from multiple onAppears
        guard !hasStarted else { return }
        hasStarted = true
        
        if shouldSkip {
            engine.orchestrator?.finishGhostMode()
            return
        }
        
        // Clear engine mistakes so we don't double-practice if we re-enter
        engine.patternIntroMistakes = []
        
        findGhostToRehearse()
    }
    
    private func buildHistoryQueue() {
        let visited = Array(engine.recentPatternHistory).filter { $0 != targetPattern.patternId }
        print("   🌪️ [GhostMode] Phase 2 (History): Evaluating \(visited.count) recent patterns...")
        
        guard !visited.isEmpty else { 
            print("   🌪️ [GhostMode] Phase 2: No recent patterns visited yet.")
            return 
        }
        
        let targetText = targetPattern.drillData.target
        let targetLang = engine.lessonData?.target_language ?? "es"
        
        var candidates: [(id: String, score: Double)] = []
        for id in visited {
            guard let raw = engine.rawPatterns.first(where: { $0.id == id }) else { continue }
            let sim = EmbeddingService.compare(textA: targetText, textB: raw.target, languageCode: targetLang)
            let mastery = engine.getBlendedMastery(for: "\(id)-d0")
            let finalScore = (sim * 0.7) + ((1.0 - mastery) * 0.3)
            
            print("      - Pattern [\(id)]: Sim=\(String(format: "%.2f", sim)), Mastery=\(String(format: "%.2f", mastery)) -> Final=\(String(format: "%.2f", finalScore))")
            candidates.append((id, finalScore))
        }
        
        let sorted = candidates.sorted { $0.score > $1.score }
        if let winner = sorted.first {
            print("   🌪️ [GhostMode] WINNING GHOST: \(winner.id) with score \(String(format: "%.3f", winner.score))")
            if let raw = engine.rawPatterns.first(where: { $0.id == winner.id }) {
                let drillItem = DrillItem(target: raw.target, meaning: raw.meaning, phonetic: raw.phonetic)
                historyQueue = [DrillState(
                    id: "\(winner.id)-d0",
                    patternId: winner.id,
                    drillIndex: -1,
                    drillData: drillItem,
                    isBrick: false
                )]
            }
        }
    }
    
    func findGhostToRehearse() {
        if !mistakeQueue.isEmpty {
            self.activeGhost = mistakeQueue.removeFirst()
            print("   🌪️ [GhostMode] Playing Phase 1 (Mistake): \"\(activeGhost?.drillData.target ?? "??")\" (\(mistakeQueue.count) remaining)")
        } else if !historyQueue.isEmpty {
            if activeGhost?.id.contains("INT-") == true {
                print("   🌪️ [GhostMode] Phase 1 complete. Transitioning to Phase 2 (History Rehearsal).")
            }
            self.activeGhost = historyQueue.removeFirst()
            print("   🌪️ [GhostMode] Playing Phase 2 (History): \"\(activeGhost?.drillData.target ?? "??")\"")
        } else {
            self.activeGhost = nil
            print("   🌪️ [GhostMode] All queues exhausted. Ending Ghost Mode.")
        }
    }
}

struct GhostModeManagerView: View {
    @StateObject var logic: GhostModeLogic
    
    init(targetPattern: DrillState, engine: LessonEngine) {
        _logic = StateObject(wrappedValue: GhostModeLogic(targetPattern: targetPattern, engine: engine))
    }
    
    var body: some View {
        ZStack {
            if logic.shouldSkip {
                Color.clear.onAppear {
                    logic.engine.orchestrator?.finishGhostMode()
                }
            } else if let ghost = logic.activeGhost {
                FullDrillManagerView(
                    state: ghost, 
                    engine: logic.engine,
                    onNext: { 
                        logic.findGhostToRehearse()
                        if logic.activeGhost == nil {
                            logic.engine.orchestrator?.finishGhostMode()
                        }
                    }
                )
                .id("ghost-practice-\(ghost.id)")
            } else {
                Color.clear.onAppear {
                    logic.engine.orchestrator?.finishGhostMode()
                }
            }
        }
        .onAppear {
            logic.start()
        }
    }
}
