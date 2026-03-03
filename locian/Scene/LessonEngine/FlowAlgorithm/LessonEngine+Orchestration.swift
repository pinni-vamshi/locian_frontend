import Foundation
import Combine

// MARK: - THE DRIVER (Session State)
class LessonOrchestrator: ObservableObject {
    
    // State for View
    @Published var activeState: DrillState?
    
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
        
        // --- STAGE 1: VOCAB INTRO (Skip Prereqs) ---
        self.currentMode = .vocabIntro
        self.activeState = materializeState(mode: .vocabIntro, pattern: pattern)
    }
    
    // MARK: - STAGE TRANSITIONS (Called by Parent Logics)
    
    func finishVocabIntro() {
        guard let pattern = currentPattern else { return }
        // --- STAGE 2: PATTERN PRACTICE (Mistakes + Immediate Target) ---
        self.currentMode = .patternPractice
        self.activeState = materializeState(mode: .patternPractice, pattern: pattern)
    }
    
    func finishPatternPractice() {
        guard let pattern = currentPattern else { return }
        // --- STAGE 3: GHOST MODE (History + Final Target) ---
        self.currentMode = .ghostManager
        self.activeState = materializeState(mode: .ghostManager, pattern: pattern)
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
        case .patternPractice: finishPatternPractice()
        case .ghostManager: finishGhostMode(for: currentPattern?.id)
        case .typing: finishPattern(for: currentPattern?.id)
        default: break
        }
    }
    
    // Helper
    private func materializeState(mode: DrillMode?, pattern: PatternData) -> DrillState {
        let item = DrillItem(target: pattern.target, meaning: pattern.meaning, phonetic: pattern.phonetic)
        return DrillState(
            id: pattern.id,  // ✅ Clean ID (no mode suffix)
            patternId: pattern.id, 
            drillIndex: 0, 
            drillData: item, 
            isBrick: false, 
            currentMode: mode  // ✅ nil = let selector decide
        )
    }
}
