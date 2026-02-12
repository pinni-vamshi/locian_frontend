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
        
        print("🌪️ [GhostMode] INITIALIZING... (Transitioning to: \(targetPattern.id) - \(targetPattern.drillData.target))")
        
        // 1. Phase 1: Capturing recycled mistakes from Intro
        self.mistakeQueue = engine.patternIntroMistakes
        print("   🌪️ [GhostMode] Phase 1 (Mistakes): Found \(mistakeQueue.count) items. Pool: [\(mistakeQueue.map { $0.id }.joined(separator: ", "))]")
        for item in mistakeQueue {
            print("      - Pool Mistake: \(item.id) (\(item.drillData.target))")
        }
        
        // 2. Phase 2: Building History Rehearsal Queue
        print("   🌪️ [GhostMode] Phase 2 (History): Full Engine History: [\(engine.recentPatternHistory.joined(separator: ", "))]")
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
        
        findGhostToRehearse()
    }
    
    private func buildHistoryQueue() {
        let visited = Array(engine.recentPatternHistory).filter { $0 != targetPattern.patternId }
        print("   🌪️ [GhostMode] History Evaluation (Filtered): \(visited)")
        print("   🌪️ [GhostMode] Phase 2 (History): Evaluating \(visited.count) recent patterns...")
        
        guard !visited.isEmpty else { 
            print("   🌪️ [GhostMode] Phase 2: No recent patterns visited yet.")
            return 
        }
        
        let targetLang = engine.lessonData?.target_language ?? "es"
        
        // 2. Centroid Selection Strategy
        // Goal: Pick the pattern closest to the "Average" of the recent session.
        // This reinforces the core theme rather than just chasing the last item.
        
        var vectors: [[Double]] = []
        var validCandidates: [(id: String, vector: [Double])] = []
        
        for id in visited {
            if let raw = engine.rawPatterns.first(where: { $0.id == id }),
               let v = EmbeddingService.getVector(for: raw.target, languageCode: targetLang) {
                vectors.append(v)
                validCandidates.append((id, v))
            }
        }
        
        guard !vectors.isEmpty, let firstVec = vectors.first else { return }
        
        // A. Calculate Average Vector (Centroid)
        let dim = firstVec.count
        var avgVector = [Double](repeating: 0.0, count: dim)
        
        for v in vectors {
            for i in 0..<dim {
                avgVector[i] += v[i]
            }
        }
        
        for i in 0..<dim {
            avgVector[i] /= Double(vectors.count)
        }
        
        print("\n   🌪️ [GhostMode] CENTROID CALCULATION")
        print("      - Vectors Averaged: \(vectors.count)")
        print("      - Dimensions: \(dim)")
        print("      - Centroid Preview: [\(avgVector.prefix(3).map{ String(format: "%.3f", $0) }.joined(separator: ", "))...]")

        // B. Find Closest to Centroid (Select Top 2)
        var scoredCandidates: [(id: String, score: Double)] = []
        
        print("\n   🌪️ [GhostMode] CANDIDATE SCORING (Distance to Center)")
        for candidate in validCandidates {
            let score = EmbeddingService.cosineSimilarity(v1: avgVector, v2: candidate.vector)
            let mastery = engine.getBlendedMastery(for: "\(candidate.id)-d0")
            let weightedScore = (score * 0.7) + ((1.0 - mastery) * 0.3)
            
            print("      - [\(candidate.id)] Dist: \(String(format: "%.3f", score)) | Mastery: \(String(format: "%.2f", mastery)) -> Score: \(String(format: "%.3f", weightedScore))")
            
            scoredCandidates.append((candidate.id, weightedScore))
        }
        
        // Sort by Score DESCENDING
        scoredCandidates.sort { $0.score > $1.score }
        
        // Take Top 2
        let winners = scoredCandidates.prefix(2)
        
        for (index, winner) in winners.enumerated() {
            print("   ✅ [GhostMode] WINNER #\(index + 1): \(winner.id) (Score: \(String(format: "%.3f", winner.score)))")
            
            if let raw = engine.rawPatterns.first(where: { $0.id == winner.id }) {
                let drillItem = DrillItem(target: raw.target, meaning: raw.meaning, phonetic: raw.phonetic)
                historyQueue.append(DrillState(
                    id: "\(winner.id)-d0",
                    patternId: winner.id,
                    drillIndex: -1,
                    drillData: drillItem,
                    isBrick: false
                ))
            }
        }
        
        // ✅ PATTERN REINFORCEMENT: Add original pattern at the beginning if needed
        let patternMastery = engine.getBlendedMastery(for: targetPattern.id)
        let hadMistakes = !mistakeQueue.isEmpty
        
        if patternMastery < 0.60 || hadMistakes {
            print("   🔄 [GhostMode] REINFORCEMENT: Adding original pattern '\(targetPattern.id)' to start of history queue")
            print("      - Mastery: \(String(format: "%.2f", patternMastery)) | Had Mistakes: \(hadMistakes)")
            
            let drillItem = DrillItem(
                target: targetPattern.drillData.target,
                meaning: targetPattern.drillData.meaning,
                phonetic: targetPattern.drillData.phonetic
            )
            
            let reinforcementDrill = DrillState(
                id: "\(targetPattern.patternId)-d0",
                patternId: targetPattern.patternId,
                drillIndex: -1,
                drillData: drillItem,
                isBrick: false
            )

            
            // Insert at the beginning of history queue
            historyQueue.insert(reinforcementDrill, at: 0)
        } else {
            print("   ⏭️ [GhostMode] SKIP REINFORCEMENT: Pattern mastery sufficient (\(String(format: "%.2f", patternMastery))) and no mistakes")
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
            if let ghost = logic.activeGhost {
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
                .id("ghost-\(ghost.isBrick ? "brick" : "pattern")-\(ghost.id)")
            } else {
                // Waiting/Finished state
                Color.black.ignoresSafeArea()
            }
        }
        .onAppear {
            logic.start()
        }
    }
}
