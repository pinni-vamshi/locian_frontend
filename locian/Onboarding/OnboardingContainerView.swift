import SwiftUI

// MARK: - Onboarding Debug (flip to false when done tuning)
struct OnboardingDebug {
    static let showBorders = false
}

extension View {
    @ViewBuilder
    func onboardingBorder(_ color: Color, width: CGFloat = 1) -> some View {
        if OnboardingDebug.showBorders {
            self.overlay(Rectangle().stroke(color, lineWidth: width).allowsHitTesting(false))
        } else {
            self
        }
    }
}

struct OnboardingContainerView: View {
    @ObservedObject var appState: AppStateManager

    @State private var currentPage = 0

    private let neonPink = ThemeColors.secondaryAccent
    private let totalPages = 3

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content — fills entire screen behind footer
            ZStack {
                getMiddleContent(for: currentPage)
                    .transition(.opacity)
                    .id(currentPage)
            }
            .animation(.easeInOut(duration: 0.5), value: currentPage)
            .padding(.bottom, 130)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Footer: pagination + button — always fixed at bottom
            VStack(spacing: 20) {
                // Pagination
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        if index == currentPage {
                            Rectangle().fill(neonPink).frame(width: 24, height: 4)
                        } else {
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 24, height: 4)
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                // Action Button with back arrow
                HStack(spacing: 0) {
                    // Back button — always takes space, invisible on page 0
                    Button(action: previousPage) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 52, height: 52)
                    }
                    .background(currentPage > 0 ? ThemeColors.primaryAccent : Color.gray.opacity(0.3))
                    .disabled(currentPage == 0)

                    // Continue / LET'S START
                    Button(action: nextPage) {
                        Text(currentPage == totalPages - 1 ? "LET'S START" : "CONTINUE")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .tracking(3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .background(continueButtonEnabled ? neonPink : neonPink.opacity(0.4))
                    .disabled(!continueButtonEnabled)
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 50)
            .frame(maxWidth: .infinity)
            .animation(.none, value: currentPage)
        }
        .background(Color.black.ignoresSafeArea())
        .ignoresSafeArea()
        .onAppear {
            currentPage = min(max(appState.onboardingEntryPage, 0), totalPages - 1)
        }
    }

    private var continueButtonEnabled: Bool {
        return true
    }

    @ViewBuilder
    private func getMiddleContent(for page: Int) -> some View {
        switch page {
        case 0: OnboardingWelcomeView()
        case 1: OnboardingLocationView()
        case 2: OnboardingNotificationView()
        default: OnboardingWelcomeView()
        }
    }

    private func previousPage() {
        withAnimation {
            if currentPage > 0 {
                currentPage -= 1
            }
        }
    }

    private func nextPage() {
        if currentPage == 1 {
            // Page 2 (Awareness): request location + microphone, then advance
            OnboardingLocationView.requestPermissions {
                withAnimation {
                    currentPage += 1
                }
            }
        } else if currentPage == 2 {
            // Page 3 (Notifications): request notification permission, then advance
            OnboardingNotificationView.requestPermissions {
                appState.completeOnboarding()
            }
        } else {
            withAnimation {
                currentPage += 1
            }
        }
    }
}

#Preview {
    OnboardingContainerView(appState: AppStateManager())
        .preferredColorScheme(.dark)
}
