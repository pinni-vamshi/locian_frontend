import SwiftUI

// MARK: - Drill Footer Wrapper
/// A shared footer component that observes LessonDrillLogic.
/// Displays "CORRECT!" / "INCORRECT" feedback and the "CONTINUE" button.
struct DrillFooterWrapper: View {
    @ObservedObject var logic: LessonDrillLogic
    
    var body: some View {
        VStack(spacing: 0) {
            if logic.isDrillAnswered {
                Divider().background(Color.white.opacity(0.1))
                
                let isCorrect = logic.isCorrect
                let color: Color = isCorrect ? CyberColors.neonPink : .red
                let title = isCorrect ? "CORRECT!" : "INCORRECT"
                
                CyberProceedButton(
                    action: { logic.continueToNext() },
                    label: "CONTINUE",
                    title: title,
                    color: color,
                    systemImage: "arrow.right",
                    isEnabled: !logic.isAudioPlaying
                )
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.black)
            }
        }
    }
}
