import SwiftUI
import Combine

class GhostModeLogic: ObservableObject {
    @Published var activeGhost: DrillState?
    
    let targetPattern: DrillState
    let engine: LessonEngine
    
    init(targetPattern: DrillState, engine: LessonEngine) {
        self.targetPattern = targetPattern
        self.engine = engine
        
        print("   👻 [GhostModeLogic] Initializing ghost search for target: \(targetPattern.id)")
        findGhostToRehearse()
    }
    
    private func findGhostToRehearse() {
        // Use the recent history buffer as requested (Dual-Track Learning)
        let visited = Array(engine.recentPatternHistory).filter { $0 != targetPattern.patternId }
        guard !visited.isEmpty else { 
            print("   👻 [GhostModeLogic] No recent past patterns from history yet.")
            return 
        }
        
        let targetText = targetPattern.drillData.target
        let targetLang = engine.lessonData?.target_language ?? "es"
        
        // 1. Calculate similarity for ALL visited patterns
        var candidates: [(id: String, score: Double)] = []
        
        for id in visited {
            guard let raw = engine.rawPatterns.first(where: { $0.id == id }) else { continue }
            
            let sim = EmbeddingService.compare(textA: targetText, textB: raw.target, languageCode: targetLang)
            let mastery = engine.getBlendedMastery(for: "\(id)-d0")
            
            // Score = Similarity (weighted) + (1 - Mastery)
            let simWeight = sim * 0.7
            let masteryWeight = (1.0 - mastery) * 0.3
            let finalScore = simWeight + masteryWeight
            
            print("      👻 [Ghost: Candidate] [\(id)]")
            print("         ↳ Target Similarity (70%): \(String(format: "%.3f", simWeight))")
            print("         ↳ Mastery Gap (30%): \(String(format: "%.3f", masteryWeight)) (\(String(format: "%.1f%%", mastery*100)) mastered)")
            print("         ↳ TOTAL WEIGHT: \(String(format: "%.3f", finalScore))")
            
            candidates.append((id, finalScore))
        }
        
        // 2. Sort by score descending
        let sortedCandidates = candidates.sorted { $0.score > $1.score }
        
        // 3. Pick the winner
        if let winner = sortedCandidates.first {
            let (ghostId, score) = winner
            print("   👻 [GhostModeLogic] WINNER: [\(ghostId)] (Score: \(String(format: "%.2f", score)))")
            
            if let raw = engine.rawPatterns.first(where: { $0.id == ghostId }) {
                let drillItem = DrillItem(target: raw.target, meaning: raw.meaning, phonetic: raw.phonetic)
                self.activeGhost = DrillState(
                    id: "\(ghostId)-d0",
                    patternId: ghostId,
                    drillIndex: -1,
                    drillData: drillItem,
                    isBrick: false
                )
            }
        } else {
            print("   ⚠️ [GhostModeLogic] No suitable ghost candidate found.")
            self.activeGhost = nil 
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
                // If ghost is found, drill it
                PatternModeSelector(drill: ghost, engine: logic.engine)
                    .id("ghost-practice-\(ghost.id)")
            } else {
                // FALLBACK: Logic found no ghost -> Skip Immediately
                Color.clear.onAppear {
                    print("   ⏩ [GhostView] Auto-Skipping (0ms)...")
                    logic.engine.orchestrator?.finishGhostMode()
                }
            }
        }
    }
}
