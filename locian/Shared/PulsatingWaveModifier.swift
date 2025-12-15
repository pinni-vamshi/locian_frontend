import SwiftUI

struct PulsatingWaveModifier: ViewModifier {
    @State private var isPulsating: Bool = false
    
    let speed: Double = 2.5 // Slower, more subtle
    let amplitude: CGFloat = 0.05 // Much more subtle amplitude
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsating ? 1.0 + amplitude : 1.0 - amplitude)
            .onAppear {
                // Start pulsating animation
                withAnimation(.easeInOut(duration: speed).repeatForever(autoreverses: true)) {
                    isPulsating = true
                }
            }
    }
}

extension View {
    func pulsatingWave() -> some View {
        modifier(PulsatingWaveModifier())
    }
}

