import SwiftUI

/// Specialized UI for selecting your native language.
/// Lives in the GetNativeLanguage domain.
struct NativeLanguageSelectionModal: View {
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
                    HStack(alignment: .center) {
                        headingBadge()
                        Spacer()
                        dismissButton()
                    }
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    
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
                previewCode = appState.nativeLanguage.isEmpty ? "en" : appState.nativeLanguage
            }
        }
    }
    
    private func headingBadge() -> some View {
        Text("NATIVE LANGUAGE")
            .font(.system(size: 20, weight: .black, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.pink)
    }
    
    private func dismissButton() -> some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(8)
        }
    }
    
    private func previewSection() -> some View {
        let currentCode = previewCode ?? "en"
        let names = NativeLanguageMapping.shared.getDisplayNames(for: currentCode)
        
        return HStack(alignment: .center, spacing: 20) {
            Rectangle()
                .fill(Color.cyan)
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
        Text(LocalizationManager.shared.string(.whichLanguageDoYouSpeakComfortably))
            .font(.system(size: 14, weight: .black, design: .monospaced))
            .foregroundColor(.gray)
            .padding(.vertical, 5)
    }

    private func verticalGrid() -> some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(NativeLanguageMapping.shared.availableCodes, id: \.self) { code in
                languageCard(code: code)
            }
        }
        .padding(.vertical, 8)
    }

    private func continueButton() -> some View {
        let currentCode = previewCode ?? "en"
        let targetName = NativeLanguageMapping.shared.getDisplayNames(for: currentCode).english.uppercased()
        
        return Button(action: { saveSelection(code: currentCode) }) {
            Text("SET AS NATIVE: \(targetName)")
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(Color.pink)
                .padding(.vertical, 12)
        }
        .disabled(isLoading)
    }
    
    private func languageCard(code: String) -> some View {
        let name = NativeLanguageMapping.shared.getDisplayNames(for: code).english.uppercased()
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
        let names = NativeLanguageMapping.shared.getDisplayNames(for: code)
        appState.updateNativeLanguage(newNativeLanguage: names.english) { success in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    dismiss()
                }
            }
        }
    }
}
