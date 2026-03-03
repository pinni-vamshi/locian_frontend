import SwiftUI

/// PatternModeSelector
/// The "Dumb Dispatcher" for Pattern drills.
/// It resolve the practice mode (MCQ, Voice, etc.) based on mastery.
struct PatternModeSelector: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    var forcedMode: DrillMode? = nil
    var practiceLogic: PatternPracticeLogic? = nil // ✅ NEW: Reporting link
    var ghostLogic: GhostModeLogic? = nil          // ✅ NEW: Reporting link
    var onComplete: ((Bool) -> Void)? = nil  // ✅ NEW: Direct callback, no wrapper
    
    static func resolveMode(for drill: DrillState, engine: LessonEngine) -> DrillMode {
        let mastery = engine.getBlendedMastery(for: drill.id)
        
        // 1. Ghost Mode Authority (Internal)
        if drill.id.hasSuffix("-ghostManager") {
            let mode = resolveGhostMode(for: drill, mastery: mastery)
            print("👻 [PatternModeSelector] Ghost Mode detected for \(drill.id)")
            print("   - Mastery: \(String(format: "%.2f", mastery))")
            print("   - Resolved Mode: \(mode)")
            return mode
        }
        
        // 2. Regular Mastery Resolution
        
        print("🧩 [PatternModeSelector] Resolving for Pattern: '\(drill.id)'")
        print("   - Mastery Score: \(String(format: "%.2f", mastery))")
        
        let mode: DrillMode
        if mastery < 0.25 {
            mode = .mcq
        } else if mastery < 0.40 {
            mode = .sentenceBuilder
        } else if mastery < 0.60 {
            mode = .typing
        } else if mastery < 0.85 {
            mode = .speaking
        } else {
            mode = .mastered
        }
        
        print("   - Selected Mode: \(mode) (Thresholds: <0.25=MCQ, <0.40=Build, <0.55=Type, <0.85=Speak, >=0.85=Mastered)")
        
        // Print Override if present
        if let override = drill.overrideVoiceInstructions {
            print("   - 🎙️ Override Detected: \"\(override)\"")
        }
        
        return mode
    }
    
    var body: some View {
        // Resolve Mode (Speaking/MCQ/Builders)
        let mode = forcedMode ?? PatternModeSelector.resolveMode(for: drill, engine: engine)
        
        Group {
            switch mode {
            case .mcq: 
                PatternMCQLogic.view(for: drill, mode: mode, engine: engine, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
            case .sentenceBuilder: 
                PatternBuilderLogic.view(for: drill, mode: mode, engine: engine, onComplete: onComplete)
            case .typing: 
                PatternTypingLogic.view(for: drill, mode: mode, engine: engine, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
            case .speaking, .voiceMcq: 
                PatternVoiceLogic.view(for: drill, mode: mode, engine: engine, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
            case .ghostManager:
                // If it somehow reached here as ghostManager, resolve again
                let actual = PatternModeSelector.resolveMode(for: drill, engine: engine)
                PatternModeSelector(drill: drill, engine: engine, forcedMode: actual, practiceLogic: practiceLogic, ghostLogic: ghostLogic, onComplete: onComplete)
            case .mastered:
                DrillMasteryVictoryView(drill: drill, onComplete: onComplete)
            default: 
                PatternMCQLogic.view(for: drill, mode: mode, engine: engine, onComplete: onComplete)
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
    }
    
    private static func resolveGhostMode(for drill: DrillState, mastery: Double) -> DrillMode {
        if mastery < 0.25 { return .mcq }
        else if mastery < 0.40 { return .sentenceBuilder }
        else if mastery < 0.55 { return .typing }
        else if mastery < 0.85 { return .speaking }
        else { return .mastered }
    }
}
