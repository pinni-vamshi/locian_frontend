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
        self.currentMode = .ghostManager
        self.activeState = materializeState(mode: .ghostManager, pattern: pattern)
    }
    
    func finishGhostMode() {
        if let override = onGhostCompleteOverride {
            override()
            return
        }
        
        guard let pattern = currentPattern else { return }
        self.currentMode = nil  // ✅ Let PatternModeSelector decide based on mastery
        self.activeState = materializeState(mode: nil, pattern: pattern)
    }
    
    func finishPattern() {
        if let override = onGhostCompleteOverride {
            override()
            return
        }
        
        guard let pattern = currentPattern else { return }
        self.currentPattern = nil
        self.currentMode = nil
        self.activeState = nil
        
        engine?.patternCompleted(id: pattern.id)
    }
    
    // Compatibility shim (to be removed once all dependencies are updated)
    func advance() {
        switch currentMode {

        case .vocabIntro: finishVocabIntro()
        case .ghostManager: finishGhostMode()
        case .typing: finishPattern()
        default: break
        }
    }
    
    // Helper
    private func materializeState(mode: DrillMode?, pattern: PatternData) -> DrillState {
        let item = DrillItem(target: pattern.target, meaning: pattern.meaning, phonetic: pattern.phonetic)
        return DrillState(
            id: "\(pattern.id)-\(mode?.rawValue ?? "auto")", 
            patternId: pattern.id, 
            drillIndex: 0, 
            drillData: item, 
            isBrick: false, 
            currentMode: mode  // ✅ nil = let selector decide
        )
    }
}
