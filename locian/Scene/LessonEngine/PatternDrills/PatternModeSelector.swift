import SwiftUI

/// PatternModeSelector
/// The "Dumb Dispatcher" for Pattern drills.
/// It resolve the practice mode (MCQ, Voice, etc.) based on mastery.
struct PatternModeSelector: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    var forcedMode: DrillMode? = nil
    
    // Static Resolver (Moved from Manager)
    static func resolveMode(for drill: DrillState, engine: LessonEngine) -> DrillMode {
        if let mode = drill.currentMode { return mode }
        
        // Default Logic based on Mastery
        let mastery = engine.getBlendedMastery(for: drill.id)
        
        if mastery >= 0.85 { return .speaking }
        if mastery >= 0.60 { return .typing }
        if mastery >= 0.30 { return .sentenceBuilder }
        return .mcq // Foundation
    }
    
    var body: some View {
        // Resolve Mode (Speaking/MCQ/Builders)
        let mode = forcedMode ?? drill.currentMode ?? PatternModeSelector.resolveMode(for: drill, engine: engine)
        
        Group {
            switch mode {
            case .mcq: PatternMCQLogic.view(for: drill, mode: mode, engine: engine)
            case .sentenceBuilder: PatternBuilderLogic.view(for: drill, mode: mode, engine: engine)
            case .typing: PatternTypingLogic.view(for: drill, mode: mode, engine: engine)
            case .speaking, .voiceMcq: PatternVoiceLogic.view(for: drill, mode: mode, engine: engine)
            default: PatternMCQLogic.view(for: drill, mode: mode, engine: engine)
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
    }
}
