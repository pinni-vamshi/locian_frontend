import SwiftUI

struct BrickModeSelector: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    var forcedMode: DrillMode? = nil
    var lessonDrillLogic: LessonDrillLogic? = nil // ✅ Wrapper logic for footers
    
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
        
        switch mode {
        case .componentMcq:
            BrickMCQInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: patternIntroLogic, onComplete: onComplete)
        case .cloze:
            BrickClozeInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: patternIntroLogic, onComplete: onComplete)
        case .componentTyping:
            BrickTypingInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: patternIntroLogic, onComplete: onComplete)
        case .speaking:
            BrickVoiceInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: patternIntroLogic, onComplete: onComplete)
        default:
            BrickMCQInteraction(drill: drill, engine: engine, showPrompt: showPrompt, patternIntroLogic: patternIntroLogic, onComplete: onComplete)
        }
    }
    
    var body: some View {
        // ...Existing body logic...
        let brickId = drill.id.replacingOccurrences(of: "INT-", with: "")
            .split(separator: "-").first.map(String.init) ?? drill.id
        
        if !BrickModeSelector.needsDrill(brickId: brickId, engine: engine) {
            EmptyView()
        } else {
            let mode = forcedMode ?? drill.currentMode ?? BrickModeSelector.resolveMode(for: drill, engine: engine)
            switch mode {
            case .componentMcq:     BrickMCQLogic.view(for: drill, mode: mode, engine: engine, onComplete: { lessonDrillLogic?.continueToNext() })
            case .cloze:            BrickClozeLogic.view(for: drill, mode: mode, engine: engine, onComplete: { lessonDrillLogic?.continueToNext() })
            case .componentTyping:  BrickTypingLogic.view(for: drill, mode: mode, engine: engine, onComplete: { lessonDrillLogic?.continueToNext() })
            case .speaking:         BrickVoiceLogic.view(for: drill, mode: mode, engine: engine, onComplete: { lessonDrillLogic?.continueToNext() })
            default:                BrickMCQLogic.view(for: drill, mode: mode, engine: engine, onComplete: { lessonDrillLogic?.continueToNext() })
            }
        }
    }
}
