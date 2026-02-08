//
//  FirstLaunchLanguageSelectionModal.swift
//  locian
//
//  Created for first launch language selection
//

import SwiftUI

struct FirstLaunchLanguageSelectionModal: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    @State private var selectedLanguage: AppLanguage
    
    init(appState: AppStateManager) {
        self.appState = appState
        _selectedLanguage = State(initialValue: LanguageManager.shared.currentLanguage)
    }
    
    var body: some View {
        let accentColor: Color = appState.selectedTheme == "Pure White" ? .white : appState.selectedColor
        
        VStack(spacing: 0) {
            // Heading section
            HStack {
                // Heading at top left
                Text(languageManager.settings.systemLanguage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading, 24)
                    .padding(.top, 50)
                
                Spacer()
            }
            
            // Selected language display
            VStack(spacing: 8) {
                // Show both English and scripted version (two lines)
                VStack(spacing: 8) {
                    Text(selectedLanguage.englishName)
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(accentColor)
                    Text("[\(selectedLanguage.nativeScript)]")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(accentColor)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
            
            // Description
            VStack(spacing: 8) {
                Text(languageManager.onboarding.selectLanguageDescription)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 20)
            
            // Scrolling section
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ]) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        appLanguageButton(
                            language: language,
                            accentColor: accentColor,
                            isSelected: selectedLanguage == language
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            
            // Done button
            doneButton(accentColor: accentColor)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea(.all)
        .interactiveDismissDisabled(true) // Prevent dismissing without selection
    }
    
    @ViewBuilder
    private func appLanguageButton(language: AppLanguage, accentColor: Color, isSelected: Bool) -> some View {
        Button(action: {
            selectedLanguage = language
        }) {
            VStack(spacing: 4) {
                // Language name on first line
                Text(language.englishName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? Color.black : Color.white)
                
                // Scripted version on second line in brackets
                Text("[\(language.nativeScript)]")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(isSelected ? accentColor : Color.white.opacity(0.18))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func doneButton(accentColor: Color) -> some View {
        Button(action: {
            // Set the app language
            languageManager.currentLanguage = selectedLanguage
            // Mark that language has been selected
            UserDefaults.standard.set(true, forKey: "hasSelectedAppLanguage")
            // Close the modal
            appState.showFirstLaunchLanguageModal = false
        }) {
            HStack(spacing: 8) {
                Spacer()
                
                Text(localizationManager.string(.done))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(accentColor)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .buttonPressAnimation()
    }
}

