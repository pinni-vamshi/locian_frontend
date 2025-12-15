import SwiftUI

struct LanguageSelectionModal: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject private var languageManager = LanguageManager.shared
    let mode: LanguageSelectionFlowMode
    
    private enum Stage {
        case userLanguage
        case learningLanguages
    }
    
    struct LanguageOption: Identifiable {
        let id = UUID()
        let code: String
        let english: String
        let native: String
        
        var displayName: String {
            "\(english) (\(native))"
        }
    }
    
    @State private var stage: Stage
    @State private var selectedUserLanguage: String
    @State private var selectedTargetLanguage: String = "" // Single selection for target
    @State private var isSubmitting = false
    @State private var statusMessage: String = ""
    @State private var errorMessage: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    private let availableLanguages: [LanguageOption] = [
        LanguageOption(code: "ar", english: "Arabic", native: "العربية"),
        LanguageOption(code: "zh", english: "Chinese", native: "中文"),
        LanguageOption(code: "nl", english: "Dutch", native: "Nederlands"),
        LanguageOption(code: "en", english: "English", native: "English"),
        LanguageOption(code: "fr", english: "French", native: "Français"),
        LanguageOption(code: "de", english: "German", native: "Deutsch"),
        LanguageOption(code: "hi", english: "Hindi", native: "हिन्दी"),
        LanguageOption(code: "it", english: "Italian", native: "Italiano"),
        LanguageOption(code: "ja", english: "Japanese", native: "日本語"),
        LanguageOption(code: "ko", english: "Korean", native: "한국어"),
        LanguageOption(code: "ml", english: "Malayalam", native: "മലയാളം"),
        LanguageOption(code: "pt", english: "Portuguese", native: "Português"),
        LanguageOption(code: "ru", english: "Russian", native: "Русский"),
        LanguageOption(code: "es", english: "Spanish", native: "Español"),
        LanguageOption(code: "sv", english: "Swedish", native: "Svenska"),
        LanguageOption(code: "ta", english: "Tamil", native: "தமிழ்"),
        LanguageOption(code: "te", english: "Telugu", native: "తెలుగు"),
        LanguageOption(code: "tr", english: "Turkish", native: "Türkçe")
    ]
    
    // Check if languages are available
    private var hasAvailableLanguages: Bool {
        // Check if we have native language set
        return !appState.nativeLanguage.isEmpty || !selectedUserLanguage.isEmpty
    }
    
    init(appState: AppStateManager, mode: LanguageSelectionFlowMode) {
        self.appState = appState
        self.mode = mode
        
        // Use centralized language mapping system for consistent normalization
        let languageMapping = LanguageMapping.shared
        
        // STEP 1: Normalize current native language to code
        let currentNativeCode = appState.nativeLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedCurrentNativeCode: String? = currentNativeCode.isEmpty ? nil : languageMapping.normalizeAndValidateLanguage(currentNativeCode)
        
        // STEP 2: Get default pair and normalize its native language to code
        let defaultPair = appState.userLanguagePairs.first(where: { $0.is_default })
        let defaultNativeRaw = defaultPair?.native_language ?? ""
        let normalizedDefaultNativeCode: String? = defaultNativeRaw.isEmpty ? nil : languageMapping.normalizeAndValidateLanguage(defaultNativeRaw)
        
        // STEP 3: Determine which native code is valid (prefer default, fallback to current)
        let validNativeCode: String? = normalizedDefaultNativeCode ?? normalizedCurrentNativeCode
        
        // STEP 4: Determine initial stage based on mode and native language validity
        let shouldStartWithUserLanguage: Bool
        if mode == .addLearning {
            // For addLearning mode: Check if we have a valid native code
            // If native is empty or invalid, show native selection first
            // If native is valid, we can skip to target selection
            let hasValidNative = validNativeCode != nil && languageMapping.isValidLanguageCode(validNativeCode!)
            shouldStartWithUserLanguage = !hasValidNative
            
            TraceLogger.shared.trace(.targetLanguage, step: "LanguageSelectionModal init - addLearning mode", data: [
                "valid_native_code": validNativeCode ?? "nil",
                "has_valid_native": hasValidNative,
                "should_start_with_user_language": shouldStartWithUserLanguage
            ])
        } else {
            // For other modes: Always show native if empty, or if mode requires it
            shouldStartWithUserLanguage = validNativeCode == nil || mode == .onboarding || mode == .changeUserLanguage
            
            TraceLogger.shared.trace(.targetLanguage, step: "LanguageSelectionModal init - other mode", data: [
                "mode": "\(mode)",
                "valid_native_code": validNativeCode ?? "nil",
                "should_start_with_user_language": shouldStartWithUserLanguage
            ])
        }
        
        let initialStage: Stage = shouldStartWithUserLanguage ? .userLanguage : .learningLanguages
        
        TraceLogger.shared.trace(.targetLanguage, step: "LanguageSelectionModal initial stage determined", data: [
            "initial_stage": shouldStartWithUserLanguage ? "userLanguage" : "learningLanguages",
            "will_show_target_modal": initialStage == .learningLanguages
        ])
        
        TraceLogger.shared.traceUI(.targetLanguage, component: "LanguageSelectionModal", state: [
            "stage": shouldStartWithUserLanguage ? "native" : "target",
            "mode": "\(mode)"
        ], action: "modal_initialized")
        
        _stage = State(initialValue: initialStage)
        
        // NEVER auto-select native - always start with empty selection
        // User MUST manually select the language
        let initialSelectedUserLanguage = ""  // Always empty - no auto-selection
        _selectedUserLanguage = State(initialValue: initialSelectedUserLanguage)
        
        // Always start with empty - will auto-select first available language in onAppear
        // This ensures a language is always selected when modal opens, regardless of mode
        _selectedTargetLanguage = State(initialValue: "")
    }
    
    var body: some View {
        // Show native language modal for native selection, target language modal for target selection
        // Show NativeLanguageModal when:
        // 1. Onboarding mode AND userLanguage stage, OR
        // 2. changeUserLanguage mode AND userLanguage stage (native is empty/missing)
        if stage == .userLanguage {
            // Show native language modal for native language selection
            return AnyView(
                NativeLanguageModal(
                    appState: appState,
                    selectedNativeLanguage: $selectedUserLanguage,
                    isSubmitting: $isSubmitting,
                    statusMessage: $statusMessage,
                    errorMessage: $errorMessage,
                    availableLanguages: availableLanguages,
                    languageOptions: { languageOptionsForStage() },
                    onSave: {
                        // When native language is saved, advance to target language selection
                        if !selectedUserLanguage.isEmpty {
                            if mode == .onboarding {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    stage = .learningLanguages
                                }
                            } else {
                                // For changeUserLanguage mode, save and close
                                handleSave()
                            }
                        } else {
                            errorMessage = languageManager.settings.selectNativeLanguage
                        }
                    }
                )
                .onAppear {
                    TraceLogger.shared.trace(.targetLanguage, step: "NativeLanguageModal appeared", data: [
                        "mode": "\(mode)",
                        "selected_native": selectedUserLanguage
                    ])
                    TraceLogger.shared.traceUI(.targetLanguage, component: "NativeLanguageModal", state: [
                        "mode": "\(mode)",
                        "selected": selectedUserLanguage
                    ], action: "modal_appeared")
                }
            )
        } else {
            // Show target language modal for target language selection
            return AnyView(
                TargetLanguageModal(
                    appState: appState,
                    mode: mode,
                    selectedTargetLanguage: $selectedTargetLanguage,
                    isSubmitting: $isSubmitting,
                    statusMessage: $statusMessage,
                    errorMessage: $errorMessage,
                    availableLanguages: availableLanguages,
                    languageOptions: { languageOptionsForStage() },
                    onSave: handleSave
                )
            )
        }
    }
    
    @ViewBuilder
    private func languageButton(option: LanguageOption, accentColor: Color, isSelected: Bool, isDisabled: Bool = false) -> some View {
        Button(action: {
            guard !isDisabled else { return }
            
            if stage == .userLanguage {
                selectedUserLanguage = option.english
                // Auto-advance to target selection
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        stage = .learningLanguages
                    }
                }
            } else {
                // Single selection for target - always set, don't toggle
                selectedTargetLanguage = option.english
            }
        }) {
            VStack(spacing: 4) {
                // Language name on first line
                Text(option.english)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? Color.black : Color.white)
                
                // Scripted version on second line in brackets
                Text("[\(option.native)]")
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
            .opacity(isDisabled && !isSelected ? 0.35 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled && !isSelected)
    }
    
    private func languageOptionsForStage() -> [LanguageOption] {
        if mode == .addLearning {
            // For target language modal, filter out ALL existing target languages (don't show them at all)
            let existingTargets = existingLearningTargets
            return availableLanguages.filter { option in
                !existingTargets.contains(option.english)
            }
        }
        
        // Onboarding mode
        switch stage {
        case .userLanguage:
            return availableLanguages
        case .learningLanguages:
            // Filter out existing target languages
            let existingTargets = existingLearningTargets
            return availableLanguages.filter { option in
                option.english != selectedUserLanguage && !existingTargets.contains(option.english)
            }
        }
    }
    
    private func computeIsDisabled(for option: LanguageOption) -> Bool {
        // Languages are now filtered out instead of disabled, so this should always return false
        // But keeping it for backward compatibility
        return false
    }
    
    private var existingLearningTargets: Set<String> {
        let languageMapping = LanguageMapping.shared
        
        if mode == .addLearning {
            // Normalize current native code
            let currentNativeCode = appState.nativeLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let normalizedCurrentNativeCode = languageMapping.normalizeAndValidateLanguage(currentNativeCode) else {
                return Set()
            }
            
            // Filter pairs where native language matches (normalize both sides to codes)
            let filtered = appState.userLanguagePairs.filter { pair in
                let pairNativeRaw = pair.native_language.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let normalizedPairNativeCode = languageMapping.normalizeAndValidateLanguage(pairNativeRaw) else {
                    return false
                }
                return normalizedPairNativeCode.lowercased() == normalizedCurrentNativeCode.lowercased()
            }
            
            // Convert target languages to names for comparison with availableLanguages
            return Set(filtered.compactMap { pair in
                let targetRaw = pair.target_language.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let normalizedTargetCode = languageMapping.normalizeAndValidateLanguage(targetRaw) else {
                    return nil
                }
                // Find the language name from the code
                return availableLanguages.first { option in
                    option.code.lowercased() == normalizedTargetCode.lowercased()
                }?.english
            })
        } else {
            // Normalize selected native language name to code
            let selectedNativeName = selectedUserLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let normalizedSelectedNativeCode = languageMapping.normalizeAndValidateLanguage(selectedNativeName) else {
                return Set()
            }
            
            // Filter pairs where native language matches (normalize both sides to codes)
            let filtered = appState.userLanguagePairs.filter { pair in
                let pairNativeRaw = pair.native_language.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let normalizedPairNativeCode = languageMapping.normalizeAndValidateLanguage(pairNativeRaw) else {
                    return false
                }
                return normalizedPairNativeCode.lowercased() == normalizedSelectedNativeCode.lowercased()
            }
            
            // Convert target languages to names for comparison with availableLanguages
            return Set(filtered.compactMap { pair in
                let targetRaw = pair.target_language.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let normalizedTargetCode = languageMapping.normalizeAndValidateLanguage(targetRaw) else {
                    return nil
                }
                // Find the language name from the code
                return availableLanguages.first { option in
                    option.code.lowercased() == normalizedTargetCode.lowercased()
                }?.english
            })
        }
    }
    
    @ViewBuilder
    private func saveButton(accentColor: Color) -> some View {
        Button(action: handleSave) {
            HStack(spacing: 12) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Text(LocalizationManager.shared.string(.save))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(canSave && !isSubmitting ? accentColor : accentColor.opacity(0.3))
            )
        }
        .disabled(isSubmitting || !canSave)
        .buttonStyle(PlainButtonStyle())
        .buttonPressAnimation()
    }
    
    private var canSave: Bool {
        if mode == .addLearning {
            return !selectedTargetLanguage.isEmpty
        } else {
            // Onboarding flow
            switch stage {
            case .userLanguage:
                return !selectedUserLanguage.isEmpty
            case .learningLanguages:
                return !selectedTargetLanguage.isEmpty
            }
        }
    }
    
    private func handleSave() {
        errorMessage = ""
        statusMessage = ""
        
        if mode == .addLearning {
            guard !selectedTargetLanguage.isEmpty else {
                errorMessage = languageManager.settings.selectTargetLanguage
                return
            }
            submitTargetLanguageOnly()
        } else {
            // Onboarding or changeUserLanguage flow
            if stage == .userLanguage {
                // For changeUserLanguage mode, save native language and close
                if mode == .changeUserLanguage {
                    if !selectedUserLanguage.isEmpty {
                        submitNativeLanguageOnly()
                    } else {
                        errorMessage = languageManager.settings.selectNativeLanguage
                    }
                } else {
                    // Onboarding mode - advance to target language selection
                    if !selectedUserLanguage.isEmpty {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            stage = .learningLanguages
                        }
                    } else {
                        errorMessage = languageManager.settings.selectNativeLanguage
                    }
                }
            } else {
                guard !selectedTargetLanguage.isEmpty else {
                    errorMessage = languageManager.settings.selectTargetLanguage
                    return
                }
                submitSelections()
            }
        }
    }
    
    private func submitTargetLanguageOnly() {
        guard !isSubmitting else { return }
        isSubmitting = true
        statusMessage = languageManager.settings.adding
        
        let languageMapping = LanguageMapping.shared
        let currentNativeRaw = appState.nativeLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate and normalize native language to code
        guard !currentNativeRaw.isEmpty else {
            DispatchQueue.main.async {
                self.isSubmitting = false
                self.statusMessage = ""
                self.errorMessage = "Native language not found. Please select native language first."
            }
            return
        }
        
        // Normalize to code first (handles both codes and names)
        guard let normalizedNativeCode = languageMapping.normalizeAndValidateLanguage(currentNativeRaw) else {
            DispatchQueue.main.async {
                self.isSubmitting = false
                self.statusMessage = ""
                self.errorMessage = "Native language is invalid. Please select native language first."
            }
            return
        }
        
        // Find the language name from the normalized code using availableLanguages array
        let nativeOption = availableLanguages.first { option in
            option.code.lowercased() == normalizedNativeCode.lowercased()
        }
        
        guard let nativeName = nativeOption?.english, !nativeName.isEmpty else {
            DispatchQueue.main.async {
                self.isSubmitting = false
                self.statusMessage = ""
                self.errorMessage = "Failed to find native language. Please try again."
            }
            return
        }
        
        appState.addLanguagePair(nativeLanguage: nativeName, targetLanguage: selectedTargetLanguage) { success in
            if success {
                // After target is saved, use centralized service to close modal
                LanguageCheckService.shared.onTargetLanguageSaved(appState: self.appState) {
                    self.finalizeSubmission()
                }
            } else {
                DispatchQueue.main.async {
                    self.isSubmitting = false
                    self.statusMessage = ""
                    self.errorMessage = "Failed to add target language"
                }
            }
        }
    }
    
    private func submitNativeLanguageOnly() {
        guard !isSubmitting else { return }
        isSubmitting = true
        statusMessage = languageManager.settings.adding
        
        updateNativeLanguageIfNeeded {
            DispatchQueue.main.async {
                // After native is saved, check target language using centralized service
                // LanguageCheckService will close the native modal and show target modal if needed
                LanguageCheckService.shared.onNativeLanguageSaved(appState: self.appState) { success in
                    if success {
                        // Both languages are set - LanguageCheckService already closed the modal
                        // Just reset state
                        DispatchQueue.main.async {
                            self.isSubmitting = false
                            self.statusMessage = ""
                            self.selectedTargetLanguage = ""
                        }
                    } else {
                        // Target is missing - LanguageCheckService closed native modal and will show target modal
                        // Reset submitting state (native modal is already closed)
                        DispatchQueue.main.async {
                            self.isSubmitting = false
                            self.statusMessage = ""
                        }
                    }
                }
            }
        }
    }
    
    private func submitSelections() {
        guard !isSubmitting else { return }
        isSubmitting = true
        statusMessage = languageManager.settings.adding
        
        updateNativeLanguageIfNeeded {
            self.appState.addLanguagePair(nativeLanguage: self.selectedUserLanguage, targetLanguage: self.selectedTargetLanguage) { success in
                if success {
                    // Both native and target are saved - use centralized service to close
                    LanguageCheckService.shared.onTargetLanguageSaved(appState: self.appState) {
                        self.finalizeSubmission()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isSubmitting = false
                        self.statusMessage = ""
                        self.errorMessage = "Failed to add language pair"
                    }
                }
            }
        }
    }
    
    private func updateNativeLanguageIfNeeded(completion: @escaping () -> Void) {
        let languageMapping = LanguageMapping.shared
        let currentNativeRaw = appState.nativeLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        let selectedNativeCode = appState.getLanguageCode(for: selectedUserLanguage)
        
        // Normalize both to codes for comparison
        let normalizedCurrentCode = currentNativeRaw.isEmpty ? nil : languageMapping.normalizeAndValidateLanguage(currentNativeRaw)
        let normalizedSelectedCode = languageMapping.normalizeAndValidateLanguage(selectedNativeCode)
        
        // Update if current is empty or codes don't match
        if normalizedCurrentCode == nil || normalizedCurrentCode?.lowercased() != normalizedSelectedCode?.lowercased() {
            appState.updateNativeLanguage(newNativeLanguage: selectedUserLanguage) { success in
                if success {
                    completion()
                } else {
                    DispatchQueue.main.async {
                        self.isSubmitting = false
                        self.statusMessage = ""
                        self.errorMessage = "Failed to update native language"
                    }
                }
            }
        } else {
            completion()
        }
    }
    
    private func finalizeSubmission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isSubmitting = false
            statusMessage = ""
            selectedTargetLanguage = ""
            dismiss()
            appState.hideLanguageModal()
        }
    }
}
