import SwiftUI
import AuthenticationServices
import Combine

struct LoginView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var appState: AppStateManager
    @ObservedObject private var localizationManager = LocalizationManager.shared

    private let neonPink = ThemeColors.secondaryAccent
    private let neonCyan = ThemeColors.primaryAccent

    let places = PlaceCategoryMapping.allPlaces

    private var remainingPlaces: Int {
        max(0, PlaceCategoryMapping.minimumSelection - appState.selectedPlaces.count)
    }

    private var selectedNativeLabel: String {
        let code = appState.nativeLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else { return "NOT SELECTED" }
        return NativeLanguageMapping.shared.getDisplayNames(for: code).english.uppercased()
    }

    private var selectedTargetLabels: [String] {
        let selectedTargets: [String]
        if !appState.selectedTargetLanguages.isEmpty {
            selectedTargets = Array(appState.selectedTargetLanguages)
        } else {
            selectedTargets = appState.userLanguagePairs.map(\.target_language)
        }

        return selectedTargets
            .map { TargetLanguageMapping.shared.getDisplayNames(for: $0).english.uppercased() }
            .sorted()
    }

    private var selectedTargetDisplay: String {
        let targets = selectedTargetLabels
        return targets.isEmpty ? "NOT SELECTED" : targets.joined(separator: ", ")
    }

    private var hasNativeSelection: Bool {
        !appState.nativeLanguage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Login / Registration heading
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Login /")
                            .font(.system(size: learnScaled(35, hSizeClass: horizontalSizeClass, min: 32, max: 44), weight: .heavy))
                            .foregroundColor(neonPink)
                        Text("Registration")
                            .font(.system(size: learnScaled(35, hSizeClass: horizontalSizeClass, min: 32, max: 44), weight: .heavy))
                            .foregroundColor(neonCyan)
                    }
                    .padding(.horizontal, learnScaled(5, hSizeClass: horizontalSizeClass, min: 5, max: 8))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 14))

                    LinearGradient(
                        gradient: Gradient(colors: [.white, .white.opacity(0)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 2)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 14))
                .padding(.bottom, learnScaled(50, hSizeClass: horizontalSizeClass, min: 44, max: 64))

                selectedLanguagesSection

                // MARK: Select places label
                HStack {
                    Text("Select your places")
                        .font(.system(size: learnScaled(14, hSizeClass: horizontalSizeClass, min: 14, max: 18), weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    if remainingPlaces > 0 {
                        Text("Select \(remainingPlaces) more")
                            .font(.system(size: learnScaled(14, hSizeClass: horizontalSizeClass, min: 14, max: 18), weight: .medium))
                            .foregroundColor(neonPink)
                    } else {
                        Text("Ready!")
                            .font(.system(size: learnScaled(14, hSizeClass: horizontalSizeClass, min: 14, max: 18), weight: .medium))
                            .foregroundColor(ThemeColors.neonGreen)
                    }
                }
                .padding(.horizontal, learnScaled(5, hSizeClass: horizontalSizeClass, min: 5, max: 8))
                .padding(.top, learnScaled(24, hSizeClass: horizontalSizeClass, min: 20, max: 30))
                .padding(.bottom, learnScaled(16, hSizeClass: horizontalSizeClass, min: 16, max: 22))

                // MARK: Places grid (dedicated scroll section)
                ScrollView(showsIndicators: false) {
                    FlowLayout(data: places, spacing: 10) { place in
                        let isSelected = appState.selectedPlaces.contains(place.id)
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            if isSelected {
                                appState.selectedPlaces.remove(place.id)
                            } else {
                                appState.selectedPlaces.insert(place.id)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: place.icon)
                                    .font(.system(size: learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16)))
                                Text(place.displayName)
                                    .font(.system(size: learnScaled(13, hSizeClass: horizontalSizeClass, min: 13, max: 17), weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(isSelected ? .white : .gray)
                            .padding(.horizontal, learnScaled(14, hSizeClass: horizontalSizeClass, min: 14, max: 18))
                            .padding(.vertical, learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 14))
                            .frame(minWidth: learnScaled(80, hSizeClass: horizontalSizeClass, min: 80, max: 100))
                            .background(
                                Rectangle()
                                    .fill(isSelected ? neonPink : Color.white.opacity(0.03))
                            )
                            .overlay(
                                Rectangle()
                                    .stroke(isSelected ? neonPink : Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, learnScaled(5, hSizeClass: horizontalSizeClass, min: 5, max: 8))
                    .padding(.bottom, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
                }
                .frame(maxHeight: .infinity)
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    SignInWithAppleButton(.signIn) { request in
                        appState.configureAppleSignIn(request, username: nil, emailOverride: nil)
                    } onCompletion: { result in
                        appState.handleAppleSignIn(result: result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: learnScaled(52, hSizeClass: horizontalSizeClass, min: 52, max: 60))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, learnScaled(24, hSizeClass: horizontalSizeClass, min: 24, max: 32))
                    .opacity(appState.selectedPlaces.count < PlaceCategoryMapping.minimumSelection ? 0.4 : 1.0)
                    .disabled(appState.selectedPlaces.count < PlaceCategoryMapping.minimumSelection || appState.isAuthenticating)
                }
                .padding(.top, learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16))
                .padding(.bottom, learnScaled(24, hSizeClass: horizontalSizeClass, min: 24, max: 32))
                .background(Color.black)
            }
            .blur(radius: appState.isAuthenticating ? 10 : 0)
            .animation(.spring(), value: appState.isAuthenticating)

            // MARK: Auth Overlay
            if appState.isAuthenticating {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()

                    HStack(spacing: 10) {
                        Text(">")
                            .font(.system(size: learnScaled(18, hSizeClass: horizontalSizeClass, min: 18, max: 22), weight: .bold, design: .monospaced))
                            .foregroundColor(neonCyan)
                        Text(localizationManager.string(.authenticatingUser).replacingOccurrences(of: "...", with: ""))
                            .font(.system(size: learnScaled(14, hSizeClass: horizontalSizeClass, min: 14, max: 18), weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .fixedSize()
                        AnimatedDots()
                        Spacer()
                    }
                    .padding(.horizontal, learnScaled(16, hSizeClass: horizontalSizeClass, min: 16, max: 22))
                    .padding(.vertical, learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 14))
                    .frame(maxWidth: .infinity)
                    .background(
                        Rectangle()
                            .stroke(neonCyan, lineWidth: 1)
                            .background(neonCyan.opacity(0.1))
                    )
                }
                .transition(.opacity)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            appState.resetAuthStatus()
        }
        .alert(localizationManager.string(.error), isPresented: $appState.showAuthError) {
            Button(localizationManager.string(.ok)) {
                appState.resetAuthStatus()
            }
        } message: {
            if let error = appState.authError {
                Text(error)
            }
        }
    }

    private var selectedLanguagesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Selected languages")
                .font(.system(size: learnScaled(14, hSizeClass: horizontalSizeClass, min: 14, max: 18), weight: .medium))
                .foregroundColor(.gray)

            languageConfigRow(
                title: "Native:",
                value: appState.nativeLanguage.isEmpty ? "SET" : selectedNativeLabel,
                action: openNativeLanguageModal
            )

            languageConfigRow(
                title: "Target:",
                value: selectedTargetLabels.isEmpty ? "SET" : selectedTargetDisplay,
                isEnabled: hasNativeSelection,
                action: openTargetLanguageModal
            )
        }
        .padding(.horizontal, learnScaled(5, hSizeClass: horizontalSizeClass, min: 5, max: 8))
        .padding(.bottom, learnScaled(16, hSizeClass: horizontalSizeClass, min: 16, max: 22))
    }

    private func languageConfigRow(title: String, value: String, isEnabled: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title.uppercased())
                    .font(.system(size: learnScaled(30, hSizeClass: horizontalSizeClass, min: 28, max: 38), weight: .black, design: .monospaced))
                    .foregroundColor(isEnabled ? .white : .gray)

                Text(value)
                    .font(.system(size: learnScaled(30, hSizeClass: horizontalSizeClass, min: 28, max: 38), weight: .black, design: .monospaced))
                    .foregroundColor(isEnabled ? neonPink : .gray)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private func openNativeLanguageModal() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if GetAvailableLanguagesService.shared.availableCombinations.isEmpty {
            GetAvailableLanguagesService.shared.fetch()
        }
        appState.shouldShowTargetLanguageModal = false
        appState.shouldShowNativeLanguageModal = true
    }

    private func openTargetLanguageModal() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard hasNativeSelection else { return }
        if GetAvailableLanguagesService.shared.availableCombinations.isEmpty {
            GetAvailableLanguagesService.shared.fetch()
        }
        appState.shouldShowNativeLanguageModal = false
        appState.shouldShowTargetLanguageModal = true
    }
}

// MARK: - Animated Dots
private struct AnimatedDots: View {
    @State private var dotCount = 0
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(String(repeating: ".", count: dotCount + 1))
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .frame(width: 36, height: 18, alignment: .leading)
            .onReceive(timer) { _ in
                dotCount = (dotCount + 1) % 3
            }
    }
}

#Preview {
    LoginView(appState: AppStateManager())
        .preferredColorScheme(.dark)
}
