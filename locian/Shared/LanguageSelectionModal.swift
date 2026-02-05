//
//  LanguageSelectionModal.swift
//  locian
//

import SwiftUI

struct LanguageSelectionModal: View {
    @ObservedObject var appState: AppStateManager
    @Environment(\.dismiss) var dismiss
    let mode: LanguageSelectionFlowMode
    
    @State private var isLoading = false
    @State private var previewCode: String? = nil
    
    // MARK: - Layout Configurations
    
    // Vertical Grid Columns (3 columns of 120pt)
    private let columns = [
        GridItem(.fixed(120), spacing: 8),
        GridItem(.fixed(120), spacing: 8),
        GridItem(.fixed(120), spacing: 8)
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // ZONE 1 & 2 & Instruction: FIXED TOP SECTION (UNCHANGED)
                VStack(alignment: .leading, spacing: 0) {
                    // ZONE 1: TOP (BADGE + X)
                    HStack(alignment: .center) {
                        headingBadge()
                        Spacer()
                        dismissButton()
                    }
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    .diagnosticBorder(.white, width: 1, label: "ZONE1:HDR")
                    
                    // ZONE 2: INFO SECTION (PREVIEW) - FIXED 150PT
                    VStack(alignment: .leading, spacing: 10) {
                        previewSection()
                            .frame(height: 150) // FIXED HEIGHT 150PT
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 5)
                    .padding(.top, 10)
                    .diagnosticBorder(.cyan, width: 1, label: "ZONE2:PREV")
                    
                    // INSTRUCTION TEXT (MOVED TO FIXED)
                    instructionText()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                }
                .padding(.bottom, 10)
                
                // SCROLLABLE GRID (ZONE 3)
                ScrollView(.vertical, showsIndicators: false) {
                    verticalGrid()
                        .background(Color.white.opacity(0.01))
                        .padding(.horizontal, 5)
                }
                .diagnosticBorder(.white.opacity(0.5), width: 1, label: "SCROLL-GRID")
                
                // FIXED BOTTOM BUTTON (ZONE 4)
                VStack(spacing: 0) {
                    continueButton()
                        .padding(.top, 10)
                        .padding(.bottom, 10) // Small bottom padding
                }
                .padding(.horizontal, 5)
                .diagnosticBorder(.pink, width: 1, label: "ZONE4:BTN")
            }
            .diagnosticBorder(.white, width: 2)
        }
        .onAppear {
            if previewCode == nil {
                previewCode = appState.userLanguagePairs.first?.target_language ?? "es"
            }
        }
    }
    
    // MARK: - Components (Precise Font Scales)
    
        private func headingBadge() -> some View {
            Text("SELECTED LANGUAGES")
                .font(.system(size: 14, weight: .black, design: .monospaced)) // Locked 14PT
                .foregroundColor(.white)
                .padding(.leading, 5) // Added 5pt leading padding
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(red: 1.0, green: 0.1, blue: 0.4))
                .diagnosticBorder(.orange, width: 0.5, label: "BDG")
        }
        
        private func dismissButton() -> some View {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .padding(.trailing, -5)
                    .diagnosticBorder(.red, width: 0.5, label: "X")
            }
        }
        
        private func previewSection() -> some View {
            let currentCode = previewCode ?? appState.userLanguagePairs.first?.target_language ?? "es"
            let names = LanguageMapping.shared.getDisplayNames(for: currentCode)
            
            return HStack(alignment: .center, spacing: 20) {
                // Task: Dynamic Vertical Line (15pt width)
                Rectangle()
                    .fill(ThemeColors.primaryAccent) // Changed to ThemeColors.primaryAccent
                    .frame(width: 15)
                    .frame(maxHeight: .infinity) // Stretches to match stack height
                    .diagnosticBorder(.yellow, width: 0.5, label: "V-LINE")
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(names.english.uppercased())
                        .font(.system(size: 55, weight: .black)) // Updated to 55PT
                        .foregroundColor(.white)
                        .padding(.leading, 5) // Added 5pt leading padding
                        .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                        .diagnosticBorder(.blue, width: 0.5, label: "ENG")
                    
                    Text(names.native)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                        .diagnosticBorder(.purple, width: 0.5, label: "NAT")
                }
                .frame(maxWidth: .infinity, alignment: .leading) // FILL REMAINING WIDTH
                .diagnosticBorder(.green, width: 0.5, label: "TXT-STK")
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Ensure the whole block fills width
            .fixedSize(horizontal: false, vertical: true) // Forces HStack to fit content height
        }
        
        private func instructionText() -> some View {
            Text("CHOOSE THE LANGUAGE YOU WANT TO MASTER TODAY")
                .font(.system(size: 14, weight: .black, design: .monospaced)) // Task: 14PT
                .foregroundColor(Color(red: 1.0, green: 0.1, blue: 0.4))
                .padding(.vertical, 5)
                .diagnosticBorder(.yellow, width: 0.5, label: "INSTR")
        }

    private func verticalGrid() -> some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(LanguageMapping.shared.availableLanguageCodes.filter { $0.lowercased() != "hi" }, id: \.self) { code in
                languageCard(code: code)
            }
        }
        .padding(.vertical, 8)
        .diagnosticBorder(.indigo, width: 0.5, label: "GRID-VERT")
    }

    private func continueButton() -> some View {
        let currentCode = previewCode ?? appState.userLanguagePairs.first?.target_language ?? "es"
        let targetName = LanguageMapping.shared.getDisplayNames(for: currentCode).english.uppercased()
        
        return Button(action: { saveSelection(code: currentCode) }) {
            Text("CONTINUE WITH \(targetName)")
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(Color(red: 1.0, green: 0.1, blue: 0.4))
                .padding(.vertical, 12)
                .diagnosticBorder(.mint, width: 0.5, label: "BTN-TXT")
        }
        .disabled(isLoading)
    }
    
    private func languageCard(code: String) -> some View {
        let name = LanguageMapping.shared.getDisplayNames(for: code).english.uppercased()
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
            .frame(width: 120, height: 120) // LOCKED BOX SIZE
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
        isLoading = true; let names = LanguageMapping.shared.getDisplayNames(for: code)
        if mode == .addLearning {
            appState.addLanguagePair(nativeLanguage: appState.nativeLanguage, targetLanguage: names.english) { success in
                DispatchQueue.main.async { isLoading = false; if success { appState.loadAvailableLanguagePairs { _ in }; dismiss() } }
            }
        } else {
            appState.updateNativeLanguage(newNativeLanguage: names.english) { success in
                DispatchQueue.main.async { isLoading = false; if success { dismiss() } }
            }
        }
    }
}
