import SwiftUI

struct BrickModeSelector: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    var forcedMode: DrillMode? = nil
    var patternIntroLogic: PatternIntroLogic? = nil // ✅ NEW: Reporting link
    var practiceLogic: PatternPracticeLogic? = nil  // ✅ NEW: Reporting link
    var ghostLogic: GhostModeLogic? = nil           // ✅ NEW: Reporting link
    var onComplete: ((Bool) -> Void)? = nil // ✅ Unified signature
    
    static func needsDrill(brickId: String, engine: LessonEngine) -> Bool {
        let score = engine.getDecayedMastery(for: brickId)
        let needs = score < 0.85
        return needs // Bricks < 0.85 need intervention
    }
    
    static func resolveMode(for drill: DrillState, engine: LessonEngine) -> DrillMode {
        if let mode = drill.currentMode, mode != .ghostManager {
            print("🧱 [BrickModeSelector] Using pre-set mode: \(mode) for \(drill.id)")
            return mode
        }
        
        let rawId = drill.id
        let brickId = rawId.replacingOccurrences(of: "INT-", with: "")
            .replacingOccurrences(of: "PRACTICE-MISTAKE-", with: "") // Handle Practice IDs too
            .split(separator: "-").first.map(String.init) ?? rawId
            
        let score = engine.getDecayedMastery(for: brickId)
        
        print("🧱 [BrickModeSelector] Resolving for Brick: '\(brickId)' (Raw: \(rawId))")
        print("   - Mastery Score: \(String(format: "%.2f", score))")
        
        let mode: DrillMode
        if score < 0.25 {
            mode = .componentMcq
        } else if score < 0.40 {
            mode = .cloze
        } else if score < 0.55 {
            mode = .componentTyping
        } else if score < 0.85 {
            mode = .speaking
        } else {
            mode = .mastered
        }
        
        print("   - Selected Mode: \(mode) (Thresholds: <0.25=MCQ, <0.40=Cloze, <0.55=Type, <0.85=Speak, >=0.85=Mastered)")
        
        // Print Override if present
        if let override = drill.overrideVoiceInstructions {
            print("   - 🎙️ Override Detected: \"\(override)\"")
        }
        
        return mode
    }

    @ViewBuilder
    static func interactionView(
        for drill: DrillState, 
        engine: LessonEngine, 
        showPrompt: Bool = true, 
        patternIntroLogic: PatternIntroLogic? = nil, // ✅ NEW PARAMETER
        practiceLogic: PatternPracticeLogic? = nil,  // ✅ NEW PARAMETER
        ghostLogic: GhostModeLogic? = nil,           // ✅ NEW PARAMETER
        onComplete: ((Bool) -> Void)? = nil
    ) -> some View {
        let mode = resolveMode(for: drill, engine: engine)
        
        if let introLogic = patternIntroLogic {
            // ✅ Direction A: Pattern Intro (Recap) -> Mini Interaction
            switch mode {
            case .componentMcq:     BrickMCQInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: introLogic, onComplete: onComplete)
            case .cloze:            BrickClozeInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: introLogic, onComplete: onComplete)
            case .componentTyping:  BrickTypingInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: introLogic, onComplete: onComplete)
            case .speaking:         BrickVoiceInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: introLogic, onComplete: onComplete)
            case .mastered:         DrillMasteryVictoryView(drill: drill, onComplete: onComplete)
            default:                BrickMCQInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: introLogic, onComplete: onComplete)
            }
        } else {
            // ✅ Direction B: Ghost Mode (Practice) -> Full Dedicated Files
            switch mode {
            case .componentMcq:     BrickMCQLogic.view(for: drill, mode: mode, engine: engine, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
            case .cloze:            BrickClozeLogic.view(for: drill, mode: mode, engine: engine, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
            case .componentTyping:  BrickTypingLogic.view(for: drill, mode: mode, engine: engine, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
            case .speaking:         BrickVoiceLogic.view(for: drill, mode: mode, engine: engine, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
            case .mastered:         DrillMasteryVictoryView(drill: drill, onComplete: onComplete)
            default:                BrickMCQLogic.view(for: drill, mode: mode, engine: engine, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
            }
        }
    }
    
    var body: some View {
        let mode = forcedMode ?? drill.currentMode ?? BrickModeSelector.resolveMode(for: drill, engine: engine)
        let completion = onComplete // ?? { /* Default fallback? */ }
        
        switch mode {
        case .componentMcq:     BrickMCQLogic.view(for: drill, mode: mode, engine: engine, patternIntroLogic: patternIntroLogic, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: completion)
        case .cloze:            BrickClozeLogic.view(for: drill, mode: mode, engine: engine, patternIntroLogic: patternIntroLogic, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: completion)
        case .componentTyping:  BrickTypingLogic.view(for: drill, mode: mode, engine: engine, patternIntroLogic: patternIntroLogic, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: completion)
        case .speaking:         BrickVoiceLogic.view(for: drill, mode: mode, engine: engine, patternIntroLogic: patternIntroLogic, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: completion)
        case .mastered:         DrillMasteryVictoryView(drill: drill, onComplete: onComplete)
        default:                BrickMCQLogic.view(for: drill, mode: mode, engine: engine, patternIntroLogic: patternIntroLogic, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: completion)
        }
    }
}
