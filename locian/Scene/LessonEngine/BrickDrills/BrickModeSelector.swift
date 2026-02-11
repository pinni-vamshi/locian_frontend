import SwiftUI

struct BrickModeSelector: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    var forcedMode: DrillMode? = nil
    var lessonDrillLogic: LessonDrillLogic? = nil // ✅ Wrapper logic for footers
    var patternIntroLogic: PatternIntroLogic? = nil // ✅ NEW: Reporting link
    var onComplete: (() -> Void)? = nil // ✅ Added to resolve PatternIntroView call
    
    static func needsDrill(brickId: String, engine: LessonEngine) -> Bool {
        let score = engine.getDecayedMastery(for: brickId)
        let needs = score < 0.85
        return needs // Bricks < 0.85 need intervention
    }
    
    static func resolveMode(for drill: DrillState, engine: LessonEngine) -> DrillMode {
        if let mode = drill.currentMode { return mode }
        
        let rawId = drill.id
        let brickId = rawId.replacingOccurrences(of: "INT-", with: "")
            .split(separator: "-").first.map(String.init) ?? rawId
            
        let score = engine.getDecayedMastery(for: brickId)
        
        let result: DrillMode
        if score >= 0.70 {
            result = .speaking
        } else if score >= 0.45 { 
            result = .componentTyping 
        } else if score >= 0.20 { 
            result = .cloze 
        } else { 
            result = .componentMcq 
        }
        
        print("   🎯 [BrickSelector] Mastery: \(String(format: "%.2f", score)) | Mode: \(result) | Brick: \(brickId) ('\(drill.drillData.target)')")
        
        return result
    }

    @ViewBuilder
    static func interactionView(
        for drill: DrillState, 
        engine: LessonEngine, 
        showPrompt: Bool = true, 
        patternIntroLogic: PatternIntroLogic? = nil, // ✅ NEW PARAMETER
        onComplete: (() -> Void)? = nil
    ) -> some View {
        let mode = resolveMode(for: drill, engine: engine)
        
        if let introLogic = patternIntroLogic {
            // ✅ Direction A: Pattern Intro (Recap) -> Mini Interaction
            switch mode {
            case .componentMcq:     BrickMCQInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: introLogic, onComplete: onComplete)
            case .cloze:            BrickClozeInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: introLogic, onComplete: onComplete)
            case .componentTyping:  BrickTypingInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: introLogic, onComplete: onComplete)
            case .speaking:         BrickVoiceInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: introLogic, onComplete: onComplete)
            default:                BrickMCQInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: introLogic, onComplete: onComplete)
            }
        } else {
            // ✅ Direction B: Ghost Mode (Practice) -> Full Dedicated Files
            switch mode {
            case .componentMcq:     BrickMCQLogic.view(for: drill, mode: mode, engine: engine, lessonDrillLogic: nil, onComplete: onComplete)
            case .cloze:            BrickClozeLogic.view(for: drill, mode: mode, engine: engine, lessonDrillLogic: nil, onComplete: onComplete)
            case .componentTyping:  BrickTypingLogic.view(for: drill, mode: mode, engine: engine, lessonDrillLogic: nil, onComplete: onComplete)
            case .speaking:         BrickVoiceLogic.view(for: drill, mode: mode, engine: engine, lessonDrillLogic: nil, onComplete: onComplete)
            default:                BrickMCQLogic.view(for: drill, mode: mode, engine: engine, lessonDrillLogic: nil, onComplete: onComplete)
            }
        }
    }
    
    var body: some View {
        let mode = forcedMode ?? drill.currentMode ?? BrickModeSelector.resolveMode(for: drill, engine: engine)
        let completion = onComplete ?? { lessonDrillLogic?.continueToNext() }
        
        switch mode {
        case .componentMcq:     BrickMCQLogic.view(for: drill, mode: mode, engine: engine, patternIntroLogic: patternIntroLogic, lessonDrillLogic: lessonDrillLogic, onComplete: completion)
        case .cloze:            BrickClozeLogic.view(for: drill, mode: mode, engine: engine, patternIntroLogic: patternIntroLogic, lessonDrillLogic: lessonDrillLogic, onComplete: completion)
        case .componentTyping:  BrickTypingLogic.view(for: drill, mode: mode, engine: engine, patternIntroLogic: patternIntroLogic, lessonDrillLogic: lessonDrillLogic, onComplete: completion)
        case .speaking:         BrickVoiceLogic.view(for: drill, mode: mode, engine: engine, patternIntroLogic: patternIntroLogic, lessonDrillLogic: lessonDrillLogic, onComplete: completion)
        default:                BrickMCQLogic.view(for: drill, mode: mode, engine: engine, patternIntroLogic: patternIntroLogic, lessonDrillLogic: lessonDrillLogic, onComplete: completion)
        }
    }
}
