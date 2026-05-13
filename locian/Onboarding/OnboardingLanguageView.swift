import SwiftUI

private struct LanguageOption: Hashable {
    let code: String
    let english: String
    let native: String
}

// Flag mapping
private let languageFlags: [String: String] = [
    "en": "\u{1F1FA}\u{1F1F8}", "es": "\u{1F1EA}\u{1F1F8}", "fr": "\u{1F1EB}\u{1F1F7}",
    "ja": "\u{1F1EF}\u{1F1F5}", "ko": "\u{1F1F0}\u{1F1F7}", "pt": "\u{1F1E7}\u{1F1F7}",
    "it": "\u{1F1EE}\u{1F1F9}", "ru": "\u{1F1F7}\u{1F1FA}", "ta": "\u{1F1EE}\u{1F1F3}",
    "te": "\u{1F1EE}\u{1F1F3}", "ml": "\u{1F1EE}\u{1F1F3}", "hi": "\u{1F1EE}\u{1F1F3}",
    "de": "\u{1F1E9}\u{1F1EA}", "zh": "\u{1F1E8}\u{1F1F3}", "ar": "\u{1F1F8}\u{1F1E6}",
]

struct OnboardingLanguageView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject private var languageService = GetAvailableLanguagesService.shared

    @State private var nativeLanguages: [LanguageOption] = []
    @State private var availableTargets: [LanguageOption] = []

    private let neonPink = ThemeColors.secondaryAccent
    private let neonCyan = ThemeColors.primaryAccent

    var body: some View {
        VStack(spacing: 0) {
            // Row 1: Heading
            VStack(spacing: 0) {
                HStack {
                    Text("Languages")
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

            if languageService.isLoading {
                Spacer()
                ProgressView()
                    .tint(.white)
                Spacer()
            } else {
                // Row 2: Native language picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("I SPEAK")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .tracking(3)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 5)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(nativeLanguages, id: \.self) { lang in
                                let isSelected = appState.nativeLanguage == lang.code
                                Button {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    appState.nativeLanguage = lang.code
                                    appState.selectedTargetLanguages.remove(lang.code)
                                    updateAvailableTargets()
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(languageFlags[lang.code] ?? "\u{1F310}")
                                            .font(.system(size: 14))
                                        Text(lang.english)
                                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    }
                                    .foregroundColor(isSelected ? .white : .gray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        Rectangle()
                                            .fill(isSelected ? neonCyan : Color.white.opacity(0.03))
                                    )
                                    .overlay(
                                        Rectangle()
                                            .stroke(isSelected ? neonCyan : Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .padding(.top, 20)

                // Row 3: Target language picker
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("I WANT TO LEARN")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .tracking(3)
                            .foregroundColor(.gray)
                        Spacer()
                        if !appState.selectedTargetLanguages.isEmpty {
                            Text("\(appState.selectedTargetLanguages.count) selected")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(neonPink)
                        }
                    }
                    .padding(.horizontal, 5)

                    FlowLayout(data: availableTargets, spacing: 8) { lang in
                        let isSelected = appState.selectedTargetLanguages.contains(lang.code)
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            if isSelected {
                                appState.selectedTargetLanguages.remove(lang.code)
                            } else {
                                appState.selectedTargetLanguages.insert(lang.code)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(languageFlags[lang.code] ?? "\u{1F310}")
                                    .font(.system(size: 14))
                                Text(lang.english)
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(isSelected ? .white : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
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
                    .padding(.horizontal, 5)
                }
                .padding(.top, 24)
            }

            Spacer()

            // Tagline
            VStack(spacing: 4) {
                Text("CHOOSE YOUR")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("LANGUAGE")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(neonCyan)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("JOURNEY")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(neonPink)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.bottom, 20)
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadLanguages()
        }
    }

    // MARK: - Data

    private func loadLanguages() {
        // If already loaded, just build the lists
        if !languageService.availableCombinations.isEmpty {
            buildNativeList()
            return
        }
        // Fetch from backend
        languageService.fetch { success in
            if success {
                buildNativeList()
            }
        }
    }

    private func buildNativeList() {
        nativeLanguages = languageService.availableCombinations.map { combo in
            LanguageOption(
                code: combo.native.code,
                english: combo.native.english_name,
                native: combo.native.native_name
            )
        }
        updateAvailableTargets()
    }

    private func updateAvailableTargets() {
        let selectedNative = appState.nativeLanguage
        guard !selectedNative.isEmpty else {
            availableTargets = []
            return
        }
        if let combo = languageService.availableCombinations.first(where: { $0.native.code == selectedNative }) {
            availableTargets = combo.targets.map { t in
                LanguageOption(code: t.code, english: t.english_name, native: t.native_name)
            }
            // Clear targets that are no longer valid for this native
            let validCodes = Set(availableTargets.map(\.code))
            appState.selectedTargetLanguages = appState.selectedTargetLanguages.intersection(validCodes)
        } else {
            availableTargets = []
        }
    }
}

#Preview {
    OnboardingLanguageView(appState: AppStateManager())
        .preferredColorScheme(.dark)
}
