import SwiftUI
import Combine

class GhostModeLogic: ObservableObject {
    @Published var activeGhost: DrillState?
    
    let targetPattern: DrillState
    let session: LessonSessionManager
    
    init(targetPattern: DrillState, session: LessonSessionManager) {
        self.targetPattern = targetPattern
        self.session = session
        
        print("   👻 [GhostModeLogic] Initializing ghost search for target: \(targetPattern.id)")
        findGhostToRehearse()
    }
    
    private func findGhostToRehearse() {
        let visited = Array(session.engine.visitedPatternIds).filter { $0 != targetPattern.patternId }
        guard !visited.isEmpty else { 
            print("   👻 [GhostModeLogic] No past patterns visited yet.")
            return 
        }
        
        // Pick most similar or weak past pattern
        let targetText = targetPattern.drillData.target
        let targetLang = session.engine.lessonData?.target_language ?? "es"
        
        let candidates = visited.compactMap { id -> (String, Double)? in
            guard let raw = session.engine.rawPatterns.first(where: { $0.pattern_id == id }) else { return nil }
            let sim = EmbeddingService.compare(textA: targetText, textB: raw.target, languageCode: targetLang)
            let mastery = session.engine.getBlendedMastery(for: "\(id)-d0")
            
            // Score = Similarity (weighted) + (1 - Mastery)
            let simWeight = sim * 0.7
            let masteryWeight = (1.0 - mastery) * 0.3
            let score = simWeight + masteryWeight
            
            print("      👻 [Ghost: Candidate] [\(id)]")
            print("         ↳ Target Similarity (70%): \(String(format: "%.3f", simWeight))")
            print("         ↳ Mastery Gap (30%): \(String(format: "%.3f", masteryWeight)) (\(String(format: "%.1f%%", mastery*100)) mastered)")
            print("         ↳ TOTAL WEIGHT: \(String(format: "%.3f", score))")
            
            return (id, score)
        }
        
        // Pick the best candidate above a certain threshold or if mastery is very low
        if let winner = candidates.sorted(by: { $0.1 > $1.1 }).first {
            let (ghostId, score) = winner
            print("   👻 [GhostModeLogic] Selected Ghost: [\(ghostId)] (Score: \(String(format: "%.2f", score)))")
            
            if let raw = session.engine.rawPatterns.first(where: { $0.pattern_id == ghostId }) {
                let drillItem = DrillItem(target: raw.target, meaning: raw.meaning, phonetic: raw.phonetic)
                self.activeGhost = DrillState(
                    id: "\(ghostId)-d0",
                    patternId: ghostId,
                    drillIndex: -1,
                    drillData: drillItem,
                    isBrick: false
                )
            }
        }
    }
}

struct GhostModeManagerView: View {
    @StateObject var logic: GhostModeLogic
    
    init(targetPattern: DrillState, session: LessonSessionManager) {
        _logic = StateObject(wrappedValue: GhostModeLogic(targetPattern: targetPattern, session: session))
    }
    
    var body: some View {
        ZStack {
            if let ghost = logic.activeGhost {
                PatternModeSelector(drill: ghost, session: logic.session)
                    .id("ghost-practice-\(ghost.id)")
            } else {
                // FALLBACK: If orchestrator failed to skip, and logic found no ghost
                Color.clear.onAppear {
                    print("   ⚠️ [GhostModeManager] Fallback: No ghost found, skipping to next.")
                    logic.session.continueToNext()
                }
            }
        }
    }
}
