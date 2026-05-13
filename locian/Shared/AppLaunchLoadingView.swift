import SwiftUI
import Combine

struct AppLaunchLoadingView: View {
    @ObservedObject var appState: AppStateManager
    @State private var appearAmount: Double = 0.0
    
    private let animationDuration: Double = 0.3
    
    var body: some View {
        ZStack {
            // 1. Solid Black Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // 2. Large App Icon
                Image("AppIconImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 44))
                    .scaleEffect(0.95 + (0.05 * appearAmount))
                    .padding(.bottom, 40)
                
                // 3. App Name
                Text("LOCIAN")
                    .font(.system(size: 64, weight: .black))
                    .foregroundColor(.white)
                    .tracking(10)
                    .padding(.bottom, 24)
                    .diagnosticBorder(.white.opacity(0.1))
                
                // 4. Tagline
                VStack(spacing: 8) {
                    Text("from where you stand")
                    Text("to")
                    Text("every word you need")
                }
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
                .tracking(2)
                .multilineTextAlignment(.center)
                .diagnosticBorder(.white.opacity(0.1))
                
                Spacer()
                
                // 5. Status Text
                Text(statusText)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(CyberColors.neonCyan.opacity(0.6))
                    .padding(.bottom, 60)
                    .diagnosticBorder(CyberColors.neonCyan.opacity(0.2))
            }
            .opacity(appearAmount) // Apply opacity to the entire group
            .diagnosticBorder(.white.opacity(0.05))
        }
        .animation(.easeInOut(duration: 0.3), value: statusText) // Match branding speed
        .onAppear {
            // Immediate start to match user request for zero "hang" time
            withAnimation(.easeInOut(duration: animationDuration)) {
                appearAmount = 1.0
            }
        }
    }
    
    private var statusText: String {
        switch appState.startupMomentsStatus {
        case .idle, .loading:
            return "getting your moments..."
        case .succeeded:
            return "ready."
        case .failed:
            return "offline mode active."
        }
    }
}

#Preview {
    AppLaunchLoadingView(appState: AppStateManager.shared)
}
