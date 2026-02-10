import SwiftUI

struct LessonCompletionView: View {
    let onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("LESSON COMPLETE")
                .font(.largeTitle)
                .fontWeight(.black)
                .foregroundColor(CyberColors.neonPink)
            
            CyberProceedButton(
                action: onFinish,
                label: "FINISH",
                title: "RETURN HOME",
                color: CyberColors.neonCyan,
                systemImage: "house.fill",
                isEnabled: true
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}
