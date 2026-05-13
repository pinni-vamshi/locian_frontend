import SwiftUI
import CoreLocation

struct OnboardingLocationView: View {

    @State private var ringPulse: Bool = false

    private let neonPink = ThemeColors.secondaryAccent
    private let neonCyan = ThemeColors.primaryAccent

    var body: some View {
        VStack(spacing: 0) {
            // Row 1: Heading
            VStack(spacing: 0) {
                HStack {
                    Text("Awareness")
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

            // Row 2: Location rings with pulsing wavy animation
            ZStack {
                // Ring 1 (innermost) — Home
                Circle()
                    .stroke(neonCyan.opacity(0.2), lineWidth: 1)
                    .frame(width: 140, height: 140)
                    .scaleEffect(ringPulse ? 1.06 : 0.94)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: ringPulse)

                Image(systemName: "house.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                    .padding(6)
                    .background(Circle().fill(neonPink))
                    .offset(y: -70)
                    .scaleEffect(ringPulse ? 1.06 : 0.94)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: ringPulse)

                // Ring 2 (middle) — Car
                Circle()
                    .stroke(neonCyan.opacity(0.12), lineWidth: 1)
                    .frame(width: 220, height: 220)
                    .scaleEffect(ringPulse ? 1.08 : 0.92)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true).delay(0.3), value: ringPulse)

                Image(systemName: "car.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                    .padding(6)
                    .background(Circle().fill(neonCyan))
                    .offset(x: 95, y: 50)
                    .scaleEffect(ringPulse ? 1.08 : 0.92)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true).delay(0.3), value: ringPulse)

                // Ring 3 (outermost) — Cafe
                Circle()
                    .stroke(neonCyan.opacity(0.06), lineWidth: 1)
                    .frame(width: 300, height: 300)
                    .scaleEffect(ringPulse ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true).delay(0.6), value: ringPulse)

                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                    .padding(6)
                    .background(Circle().fill(neonPink))
                    .offset(x: -120, y: 60)
                    .scaleEffect(ringPulse ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true).delay(0.6), value: ringPulse)

                // Center location icon
                Image(systemName: "location.fill")
                    .font(.system(size: 40))
                    .foregroundColor(neonCyan)
            }
            .frame(width: 320, height: 320)
            .frame(maxWidth: .infinity)
            .onboardingBorder(.cyan.opacity(0.5))

            // Row 3: Tagline — center-aligned in expanding stack
            VStack(spacing: 4) {
                Spacer()
                Text("YOUR SURROUNDINGS")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onboardingBorder(.red.opacity(0.4))

                Text("ARE YOUR")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(neonCyan)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onboardingBorder(.red.opacity(0.4))

                Text("LESSONS")
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
        .onAppear {
            ringPulse = true
        }
    }

    /// Location only — microphone is requested later when the user uses voice (Learn / SpeechRecognizer).
    static func requestPermissions(completion: @escaping () -> Void) {
        LocationManager.shared.ensureLocationAccess { _ in
            completion()
        }
    }
}

#Preview {
    OnboardingLocationView()
        .preferredColorScheme(.dark)
}
