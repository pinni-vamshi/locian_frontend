import SwiftUI

/// Specialized UI for selecting a language to learn.
/// Lives in the GetTargetLanguages domain.
struct TargetLanguageSelectionModal: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var languageService = GetAvailableLanguagesService.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoading = false
    @State private var previewCode: String? = nil
    
    private let columns = [
        GridItem(.fixed(120), spacing: 8),
        GridItem(.fixed(120), spacing: 8),
        GridItem(.fixed(120), spacing: 8)
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: -5) {
                                Text("Select").font(.system(size: 36, weight: .heavy)).foregroundColor(.white)
                                    .diagnosticBorder(.white.opacity(0.5), width: 0.5)
                                Text("Target").font(.system(size: 36, weight: .heavy)).foregroundColor(ThemeColors.secondaryAccent)
                                    .diagnosticBorder(.pink.opacity(0.5), width: 0.5)
                            }
                            .diagnosticBorder(.white.opacity(0.2), width: 1)
                            Spacer()
                            LocianButton(action: { dismiss() }, backgroundColor: .white, foregroundColor: .black, shadowColor: .gray, shadowOffset: 4) { Image(systemName: "xmark").font(.system(size: 16, weight: .bold)).frame(width: 32, height: 32) }
                                .diagnosticBorder(.white, width: 1)
                        }
                        .diagnosticBorder(.pink.opacity(0.3), width: 1.5)
                        .padding().background(Color.black.opacity(0.9))
                        Rectangle().fill(ThemeColors.neonCyan.opacity(0.3)).frame(height: 1)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        previewSection()
                            .frame(height: 150)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    
                    instructionText()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                }
                .padding(.bottom, 10)
                
                ScrollView(.vertical, showsIndicators: false) {
                    verticalGrid()
                        .background(Color.white.opacity(0.01))
                        .padding(.horizontal, 5)
                }
                
                VStack(spacing: 0) {
                    continueButton()
                        .padding(.top, 10)
                }
                .padding(.horizontal, 5)
                .padding(.bottom, 0) // Explicitly remove arbitrary bottom padding
            }
        }
        .onAppear {
            if previewCode == nil {
                previewCode = appState.userLanguagePairs.first?.target_language ?? "es"
            }
        }
    }
    

    
    private func previewSection() -> some View {
        let currentCode = previewCode ?? "es"
        let names = TargetLanguageMapping.shared.getDisplayNames(for: currentCode)
        
        return HStack(alignment: .center, spacing: 20) {
            Rectangle()
                .fill(ThemeColors.primaryAccent)
                .frame(width: 15)
                .frame(maxHeight: .infinity)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(names.english)
                    .font(.system(size: 55, weight: .black))
                    .foregroundColor(ThemeColors.secondaryAccent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                
                Text(names.native)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ThemeColors.secondaryAccent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private func instructionText() -> some View {
        Text(LocalizationManager.shared.string(.chooseTheLanguageYouWantToMaster))
            .font(.custom("Helvetica", size: 12))
            .foregroundColor(.gray)
            .padding(.vertical, 5)
    }

    private func verticalGrid() -> some View {
        Group {
            if languageService.isLoading && TargetLanguageMapping.shared.getAvailableCodes(for: appState.nativeLanguage).isEmpty {
                VStack(spacing: 20) {
                    ProgressView()
                        .tint(.white)
                    Text("Syncing catalog…")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(TargetLanguageMapping.shared.getAvailableCodes(for: appState.nativeLanguage), id: \.self) { code in
                        languageCard(code: code)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }

    private func continueButton() -> some View {
        let currentCode = previewCode ?? "es"
        let targetName = TargetLanguageMapping.shared.getDisplayNames(for: currentCode).english
        
        return Button(action: { saveSelection(code: currentCode) }) {
            ZStack {
                Rectangle()
                    .fill(ThemeColors.secondaryAccent)
                continueButtonCornerMarkings()
                Text("Continue with \(targetName)")
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .overlay(Rectangle().stroke(Color.white.opacity(0.3), lineWidth: 1))
        }
        .padding(.horizontal, 20)
        .padding(.top, 12) // Remove vertical padding to let it hit the bottom
        .disabled(isLoading)
    }
    
    private func languageCard(code: String) -> some View {
        let names = TargetLanguageMapping.shared.getDisplayNames(for: code)
        let name = names.english
        let nativeName = names.native
        let isSelected = (previewCode ?? "") == code
        
        return Button(action: { withAnimation { previewCode = code } }) {
            ZStack {
                if isSelected {
                    Rectangle().fill(ThemeColors.neonCyan.opacity(0.05))
                    Rectangle().stroke(ThemeColors.neonCyan.opacity(0.3), lineWidth: 1).padding(2)
                }
                cardMarkings(isSelected: isSelected)
                VStack(spacing: 4) {
                    Text(name).font(.system(size: 14, weight: .black)).foregroundColor(isSelected ? .white : .white.opacity(0.4))
                    Text("[\(nativeName)]").font(.system(size: 11, weight: .bold)).foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.3))
                }
            }
            .frame(width: 120, height: 120)
            .background(isSelected ? Color.white.opacity(0.05) : Color.clear)
            .overlay(Rectangle().stroke(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
    
    private func cardMarkings(isSelected: Bool) -> some View {
        VStack {
            HStack { Spacer(); dot(isSelected ? .white : .gray.opacity(0.4)) }
            Spacer()
            HStack { dot(isSelected ? .white : .gray.opacity(0.4)); Spacer() }
        }
        .padding(6)
    }

    /// Same dot motif as language cards, but on all four corners (primary CTA only).
    private func continueButtonCornerMarkings() -> some View {
        let markColor = Color.white
        return VStack {
            HStack {
                dot(markColor)
                Spacer()
                dot(markColor)
            }
            Spacer()
            HStack {
                dot(markColor)
                Spacer()
                dot(markColor)
            }
        }
        .padding(6)
    }
    
    private func dot(_ color: Color) -> some View {
        HStack(spacing: 2) { Rectangle().fill(color).frame(width: 3, height: 3); Rectangle().fill(color).frame(width: 3, height: 3) }
    }
    
    private func saveSelection(code: String) {
        // Pre-login flow: persist locally so Login screen updates immediately.
        if AppStateManager.shared.authToken?.isEmpty != false {
            appState.selectedTargetLanguages = [code]
            let nativeCode = appState.nativeLanguage.isEmpty ? "en" : appState.nativeLanguage
            appState.userLanguagePairs = [
                LanguagePair(
                    native_language: nativeCode,
                    target_language: code,
                    is_default: true,
                    user_level: "BEGINNER",
                    practice_dates: []
                )
            ]
            dismiss()
            return
        }

        isLoading = true
        appState.addLanguagePair(nativeLanguage: appState.nativeLanguage, targetLanguage: code) { success in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    dismiss()
                }
            }
        }
    }
}
