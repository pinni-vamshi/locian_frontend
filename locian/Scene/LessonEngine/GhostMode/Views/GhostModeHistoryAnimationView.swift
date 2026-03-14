import SwiftUI

struct GhostModeHistoryAnimationView: View {
    let onComplete: () -> Void
    
    // UI Text (Static)
    @State private var viewOpacity: Double = 1.0
    @State private var currentHeaderText: String = "HISTORY"
    @State private var isVisible = false
    
    private let headingText = "Let's review some older patterns."
    
    // ✅ UI Header Variations (Static Visuals)
    private let headerVariations = [
        "HISTORY",
        "PAST LESSONS",
        "RETENTION",
        "OLDER WORDS",
        "RECALL PHASE"
    ]
    
    // Removed AI Voice Templates (Internal) to prevent conversational speech.
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isVisible {
                Text(currentHeaderText)
                    .font(.system(size: 40, weight: .black))
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 5)
                    .padding(.top, 60)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .opacity(viewOpacity) // ✅ SMOOTH VIEW TRANSITION
        .onAppear {
            currentHeaderText = headerVariations.randomElement() ?? "HISTORY"
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isVisible = true
            }
            
            // ✅ Conversational voice removed. Just animate and advance.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    viewOpacity = 0.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                print("🏁 [GhostHistory] Animation Loop Finished.")
                onComplete()
            }
        }
    }
}
