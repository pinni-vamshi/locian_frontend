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
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Text(languageManager.onboarding.selectAppLanguage)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(languageManager.onboarding.selectLanguageDescription)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 30)
            
            // Language list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Button(action: {
                            HapticFeedback.selection()
                            languageManager.currentLanguage = language
                            // Mark that language has been selected
                            UserDefaults.standard.set(true, forKey: "hasSelectedAppLanguage")
                            // Close the modal
                            appState.showFirstLaunchLanguageModal = false
                        }) {
                            HStack {
                                Text(language.displayName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if languageManager.currentLanguage == language {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(appState.selectedColor)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(languageManager.currentLanguage == language ? appState.selectedColor.opacity(0.1) : Color.gray.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(languageManager.currentLanguage == language ? appState.selectedColor : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .buttonPressAnimation()
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(true) // Prevent dismissing without selection
    }
}

