import SwiftUI

struct BrickModeSelector: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    var forcedMode: DrillMode? = nil
    var practiceLogic: PatternPracticeLogic? = nil
    var ghostLogic: GhostModeLogic? = nil
    var onComplete: ((Bool) -> Void)? = nil
    
    static func needsDrill(brickId: String, engine: LessonEngine) -> Bool {
        let score = engine.getDecayedMastery(for: brickId)
        let needs = score < 0.95
        return needs // Bricks < 0.95 need intervention
    }
    
    static func resolveMode(for drill: DrillState, engine: LessonEngine) -> DrillMode {
        if let mode = drill.currentMode, mode != .ghostManager {
            print("🧱 [BrickModeSelector] Using pre-set mode: \(mode) for \(drill.id)")
            return mode
        }
        
        let rawId = drill.id
        let brickId = rawId.replacingOccurrences(of: "INT-", with: "")
            .replacingOccurrences(of: "PRACTICE-MISTAKE-", with: "")
            .split(separator: "-").first.map(String.init) ?? rawId
            
        let score = engine.getDecayedMastery(for: brickId)
        
        print("🧱 [BrickModeSelector] Resolving for Brick: '\(brickId)' (Raw: \(rawId))")
        print("   - Mastery Score: \(String(format: "%.2f", score))")
        
        // Per-round gain for an intro brick is +0.25 (intro success +0.15 + pattern
        // ripple +0.10). Bands are tuned so a brick that has been drilled exactly
        // once (score == 0.25) still resolves to MCQ the next time it appears,
        // then progresses Typing → Cloze → Speaking → Mastered.
        let mode: DrillMode
        if score < 0.30 {
            mode = .componentMcq
        } else if score < 0.55 {
            mode = .componentTyping
        } else if score < 0.80 {
            mode = .cloze
        } else if score < 0.95 {
            mode = .speaking
        } else {
            mode = .mastered
        }
        
        print("   - Selected Mode: \(mode) (Thresholds: <0.30=MCQ, <0.55=Type, <0.80=Cloze, <0.95=Speak, >=0.95=Mastered)")
        
        return mode
    }

    var body: some View {
        let mode = forcedMode ?? drill.currentMode ?? BrickModeSelector.resolveMode(for: drill, engine: engine)

        switch mode {
        case .componentMcq:     BrickMCQLogic.view(for: drill, mode: mode, engine: engine, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
        case .cloze:            BrickClozeLogic.view(for: drill, mode: mode, engine: engine, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
        case .componentTyping:  BrickTypingLogic.view(for: drill, mode: mode, engine: engine, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
        case .speaking:         BrickVoiceLogic.view(for: drill, mode: mode, engine: engine, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
        case .mastered:         Color.clear.onAppear { onComplete?(true) }
        default:                BrickMCQLogic.view(for: drill, mode: mode, engine: engine, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
        }
    }
}
