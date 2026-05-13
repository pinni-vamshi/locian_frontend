import SwiftUI
import UserNotifications

struct OnboardingNotificationView: View {

    @State private var iconPulse: Bool = false

    private let neonPink = ThemeColors.secondaryAccent
    private let neonCyan = ThemeColors.primaryAccent

    var body: some View {
        VStack(spacing: 0) {
            // Row 1: Heading
            VStack(spacing: 0) {
                HStack {
                    Text("Notifications")
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

            // Row 2: Bell visual with static rings and pulsing language icons
            ZStack {
                // Three static circles
                Circle()
                    .stroke(neonPink.opacity(0.2), lineWidth: 1)
                    .frame(width: 140, height: 140)
                Circle()
                    .stroke(neonPink.opacity(0.12), lineWidth: 1)
                    .frame(width: 220, height: 220)
                Circle()
                    .stroke(neonPink.opacity(0.06), lineWidth: 1)
                    .frame(width: 300, height: 300)

                // Icon 1 — 文 top center (same as house.fill position)
                Text("\u{6587}")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .padding(6)
                    .background(Circle().fill(neonCyan))
                    .scaleEffect(iconPulse ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: iconPulse)
                    .offset(y: -70)

                // Icon 2 — A bottom-right (same as car.fill position)
                Text("A")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .padding(6)
                    .background(Circle().fill(neonPink))
                    .scaleEffect(iconPulse ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true).delay(0.3), value: iconPulse)
                    .offset(x: 95, y: 50)

                // Icon 3 — あ bottom-left (same as cup.and.saucer.fill position)
                Text("\u{3042}")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .padding(6)
                    .background(Circle().fill(neonCyan))
                    .scaleEffect(iconPulse ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true).delay(0.6), value: iconPulse)
                    .offset(x: -120, y: 60)

                // Center bell icon
                Image(systemName: "bell.fill")
                    .font(.system(size: 44))
                    .foregroundColor(neonPink)
            }
            .frame(width: 320, height: 320)
            .frame(maxWidth: .infinity)
            .onboardingBorder(.cyan.opacity(0.5))

            // Row 3: Tagline — center-aligned in expanding stack
            VStack(spacing: 4) {
                Spacer()
                Text("WE NOTIFY YOU")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("THE MOMENT")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(neonCyan)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("YOU NEED TO SPEAK")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(neonPink)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onboardingBorder(.yellow.opacity(0.5))
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            iconPulse = true
        }
    }

    // Called from OnboardingContainerView when LET'S START is tapped
    static func requestPermissions(completion: @escaping () -> Void) {
        NotificationManager.shared.ensureNotificationAccess { _ in
            completion()
        }
    }
}

#Preview {
    OnboardingNotificationView()
        .preferredColorScheme(.dark)
}
