import SwiftUI

struct AppLaunchLoadingView: View {
    @ObservedObject var appState: AppStateManager
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Techy Logo Branding
                VStack(spacing: 8) {
                    Text("LOCIAN")
                        .font(.system(size: 60, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .tracking(10)
                        .shadow(color: ThemeColors.secondaryAccent.opacity(0.8), radius: 0, x: 4, y: 4)
                    
                    Text("ADAPTIVE LANGUAGE ENGINE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(ThemeColors.secondaryAccent)
                        .tracking(4)
                }
                
                Spacer()
                
                // Minimalist Loader
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    
                    Text("FETCHING YOUR MOMENTS...")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(2)
                }
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    AppLaunchLoadingView(appState: AppStateManager.shared)
}
