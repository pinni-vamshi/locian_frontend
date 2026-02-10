import Foundation
import Combine

// MARK: - THE DRIVER (Session State)
class LessonOrchestrator: ObservableObject {
    
    // State for View
    @Published var activeState: DrillState?
    
    // Dependencies
    weak var engine: LessonEngine?
    
    // Internal State
    private var currentPattern: PatternData?
    private var currentMode: DrillMode?
    
    // MARK: - Entry Point (Called by Flow)
    func startPattern(_ pattern: PatternData) {
        print("   🎬 [Orchestrator] Starting Pattern: \(pattern.id)")
        self.currentPattern = pattern
        
        // --- STAGE 1: PREREQUISITES ---
        self.currentMode = .prerequisites
        self.activeState = materializeState(mode: .prerequisites, pattern: pattern)
    }
    
    // MARK: - STAGE TRANSITIONS (Called by Parent Logics)
    
    func finishPrerequisites() {
        guard let pattern = currentPattern else { return }
        print("   ✅ [Orchestrator] Prerequisites Finished. Moving to Vocab Intro.")
        self.currentMode = .vocabIntro
        self.activeState = materializeState(mode: .vocabIntro, pattern: pattern)
    }
    
    func finishVocabIntro() {
        guard let pattern = currentPattern else { return }
        print("   ✅ [Orchestrator] Vocab Intro Finished. Moving to Ghost Mode.")
        self.currentMode = .ghostManager
        self.activeState = materializeState(mode: .ghostManager, pattern: pattern)
    }
    
    func finishGhostMode() {
        guard let pattern = currentPattern else { return }
        print("   ✅ [Orchestrator] Ghost Mode Finished. Moving to Final Drill.")
        self.currentMode = .typing
        self.activeState = materializeState(mode: .typing, pattern: pattern)
    }
    
    func finishPattern() {
        guard let pattern = currentPattern else { return }
        print("   🏁 [Orchestrator] Pattern '\(pattern.id)' Complete. Calling Engine.")
        self.currentPattern = nil
        self.currentMode = nil
        self.activeState = nil
        
        engine?.patternCompleted(id: pattern.id)
    }
    
    // Compatibility shim (to be removed once all dependencies are updated)
    func advance() {
        print("   ⚠️ [Orchestrator] Legacy advance() called. Transitioning to explicit logic.")
        switch currentMode {
        case .prerequisites: finishPrerequisites()
        case .vocabIntro: finishVocabIntro()
        case .ghostManager: finishGhostMode()
        case .typing: finishPattern()
        default: break
        }
    }
    
    // Helper
    private func materializeState(mode: DrillMode, pattern: PatternData) -> DrillState {
        let item = DrillItem(target: pattern.target, meaning: pattern.meaning, phonetic: pattern.phonetic)
        return DrillState(
            id: "\(pattern.id)-\(mode.rawValue)", 
            patternId: pattern.id, 
            drillIndex: 0, 
            drillData: item, 
            isBrick: false, 
            currentMode: mode
        )
    }
}
