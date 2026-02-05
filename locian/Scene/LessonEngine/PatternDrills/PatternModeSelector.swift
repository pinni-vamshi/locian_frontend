import SwiftUI

/// PatternModeSelector
/// The "Dumb Dispatcher" for Pattern drills.
/// It resolve the practice mode (MCQ, Voice, etc.) based on mastery.
struct PatternModeSelector: View {
    let drill: DrillState
    @ObservedObject var session: LessonSessionManager
    var forcedMode: DrillMode? = nil
    
    var body: some View {
        // Resolve Mode (Speaking/MCQ/Builders)
        let mode = forcedMode ?? drill.currentMode ?? session.resolveMode(for: drill)
        
        Group {
            switch mode {
            case .mcq: PatternMCQLogic.view(for: drill, mode: mode, session: session)
            case .sentenceBuilder: PatternBuilderLogic.view(for: drill, mode: mode, session: session)
            case .typing: PatternTypingLogic.view(for: drill, mode: mode, session: session)
            case .speaking, .voiceMcq: PatternVoiceLogic.view(for: drill, mode: mode, session: session)
            default: PatternMCQLogic.view(for: drill, mode: mode, session: session)
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
    }
}
