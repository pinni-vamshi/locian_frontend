import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -200
    
    let duration: Double = 4.5 // Slower shimmer effect
    let cornerRadius: CGFloat = 24
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.2), // More opaque (less distracting)
                            Color.white.opacity(0.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
                    .frame(width: geometry.size.width * 2)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .onAppear {
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                phase = 400
            }
        }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

