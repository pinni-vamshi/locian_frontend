import SwiftUI

/// Specialized UI for selecting a language to learn.
/// Lives in the GetTargetLanguages domain.
struct TargetLanguageSelectionModal: View {
    @ObservedObject var appState: AppStateManager
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
                                Text("SELECT").font(.system(size: 36, weight: .heavy)).foregroundColor(.white)
                                    .diagnosticBorder(.white.opacity(0.5), width: 0.5)
                                Text("TARGET").font(.system(size: 36, weight: .heavy)).foregroundColor(.pink)
                                    .diagnosticBorder(.pink.opacity(0.5), width: 0.5)
                            }
                            .diagnosticBorder(.white.opacity(0.2), width: 1)
                            Spacer()
                            LocianButton(action: { dismiss() }, backgroundColor: .white, foregroundColor: .black, shadowColor: .gray, shadowOffset: 4) { Image(systemName: "xmark").font(.system(size: 16, weight: .bold)).frame(width: 32, height: 32) }
                                .diagnosticBorder(.white, width: 1)
                        }
                        .diagnosticBorder(.pink.opacity(0.3), width: 1.5)
                        .padding().background(Color.black.opacity(0.9))
                        Rectangle().fill(Color.cyan.opacity(0.3)).frame(height: 1)
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
                        .padding(.bottom, 10)
                }
                .padding(.horizontal, 5)
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
                Text(names.english.uppercased())
                    .font(.system(size: 55, weight: .black))
                    .foregroundColor(.white)
                    .padding(.leading, 5)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(names.native)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private func instructionText() -> some View {
        Text(LocalizationManager.shared.string(.chooseTheLanguageYouWantToMaster))
            .font(.system(size: 14, weight: .black, design: .monospaced))
            .foregroundColor(.gray)
            .padding(.vertical, 5)
    }

    private func verticalGrid() -> some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(TargetLanguageMapping.shared.availableCodes, id: \.self) { code in
                languageCard(code: code)
            }
        }
        .padding(.vertical, 8)
    }

    private func continueButton() -> some View {
        let currentCode = previewCode ?? "es"
        let targetName = TargetLanguageMapping.shared.getDisplayNames(for: currentCode).english.uppercased()
        
        return Button(action: { saveSelection(code: currentCode) }) {
            Text("CONTINUE WITH \(targetName)")
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(Color.pink)
                .cornerRadius(0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .disabled(isLoading)
    }
    
    private func languageCard(code: String) -> some View {
        let name = TargetLanguageMapping.shared.getDisplayNames(for: code).english.uppercased()
        let isSelected = (previewCode ?? "") == code
        
        return Button(action: { withAnimation { previewCode = code } }) {
            ZStack {
                if isSelected {
                    Rectangle().fill(Color.cyan.opacity(0.05))
                    Rectangle().stroke(Color.cyan.opacity(0.3), lineWidth: 1).padding(2)
                }
                cardMarkings(isSelected: isSelected)
                Text(name).font(.system(size: 14, weight: .black)).foregroundColor(isSelected ? .white : .white.opacity(0.4))
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
    
    private func dot(_ color: Color) -> some View {
        HStack(spacing: 2) { Rectangle().fill(color).frame(width: 3, height: 3); Rectangle().fill(color).frame(width: 3, height: 3) }
    }
    
    private func saveSelection(code: String) {
        isLoading = true
        let names = TargetLanguageMapping.shared.getDisplayNames(for: code)
        appState.addLanguagePair(nativeLanguage: appState.nativeLanguage, targetLanguage: names.english) { success in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    dismiss()
                }
            }
        }
    }
}
