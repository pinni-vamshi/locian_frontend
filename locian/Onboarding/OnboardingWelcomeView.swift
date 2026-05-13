import SwiftUI

struct OnboardingWelcomeView: View {

    @State private var iconScale: CGFloat = 0.8
    @State private var iconOpacity: Double = 0.0

    private let neonPink = ThemeColors.secondaryAccent
    private let neonCyan = ThemeColors.primaryAccent

    var body: some View {
        VStack(spacing: 0) {
            // Row 1: App name — full width, left-aligned
            VStack(spacing: 0) {
                HStack {
                    Text("Locian")
                        .font(.system(size: 50, weight: .heavy))
                        .foregroundColor(neonPink)
                    Spacer()
                }
                .padding(.horizontal, 5)

                LinearGradient(
                    gradient: Gradient(colors: [.white, .white.opacity(0)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
            .onboardingBorder(.white.opacity(0.5))

            // Row 2: App icon — full width, centered, internal padding top & bottom
            Image("AppIconImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 44))
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .frame(width: 320, height: 320)
                .frame(maxWidth: .infinity)
                .onboardingBorder(.cyan.opacity(0.5))

            // Row 3: Tagline — center-aligned in its own expanding stack
            VStack(spacing: 4) {
                Spacer()
                Text("FROM WHERE YOU STAND")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onboardingBorder(.red.opacity(0.4))

                Text("TO")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(neonCyan)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onboardingBorder(.red.opacity(0.4))

                Text("EVERY WORD YOU NEED")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(neonPink)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onboardingBorder(.red.opacity(0.4))
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onboardingBorder(.yellow.opacity(0.5))
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(duration: 0.8)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
        }
    }
}

#Preview {
    OnboardingWelcomeView()
        .preferredColorScheme(.dark)
}
