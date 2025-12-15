//
//  QuizView.swift
//  locian
//

import SwiftUI
import UIKit
import Photos

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct QuizView: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var languageManager = LanguageManager.shared
    
    /// Sentences - empty since conversation quiz endpoint is removed
    private var sentences: [String] {
        return []
    }
    
    @State private var currentSentenceIndex: Int = 0
    @State private var editableWords: [String] = []
    @State private var editingIndex: Int? = nil
    @State private var isHintEnabled: Bool = false
    @State private var showHintMenu: Bool = false
    @State private var userInputs: [Int: String] = [:] // word index -> user input
    @State private var checkedResults: [Int: Bool] = [:] // word index -> is correct
    @FocusState private var focusedField: Int?
    @State private var showCustomModal: Bool = false
    @State private var showTemporaryDescription: Bool = false
    @State private var temporaryDescriptionTimer: Timer?
    
    // Feature flag: keep custom practice functionality, but hide/disable the button for now
    private let isCustomPracticeEnabled: Bool = false
    
    init(appState: AppStateManager) {
        self.appState = appState
    }
    
    private var currentSentenceText: String? {
        guard currentSentenceIndex < sentences.count else { return nil }
        return sentences[currentSentenceIndex]
        }
    
    private var currentSentence: [String] {
        // Always use editableWords if available, otherwise get from current sentence
        if !editableWords.isEmpty {
            return editableWords
        }
        guard let sentenceText = currentSentenceText else {
            return []
        }
        // Split text into words and clean them (remove punctuation, handle contractions)
        return cleanAndSplitText(sentenceText)
    }
    
    // Helper function to clean and split text, matching quiz_data keys
    private func cleanAndSplitText(_ text: String) -> [String] {
        // Split by whitespace first
        let words = text.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        // Process each word to handle contractions and punctuation
        var cleanedWords: [String] = []
        for word in words {
            // Remove punctuation from end (like "Yes," -> "Yes" and "notes." -> "notes")
            let cleaned = word.trimmingCharacters(in: .punctuationCharacters)
            
            // Handle contractions like "I'm" -> ["I", "m"]
            if cleaned.contains("'") {
                let parts = cleaned.components(separatedBy: "'")
                for (index, part) in parts.enumerated() {
                    if index == 0 {
                        cleanedWords.append(part)
                    } else {
                        // For parts after apostrophe, add them as separate words
                        cleanedWords.append(part)
                    }
                }
            } else {
                cleanedWords.append(cleaned)
            }
        }
        return cleanedWords
    }
    
    // Helper function to clean a single word (same logic as cleanAndSplitText)
    private func cleanWord(_ word: String) -> String {
        // Remove punctuation from end
        let cleaned = word.trimmingCharacters(in: .punctuationCharacters)
        // For contractions, just return the first part (before apostrophe)
        if cleaned.contains("'") {
            return cleaned.components(separatedBy: "'").first ?? cleaned
        }
        return cleaned
    }
    
    // Conversation quiz endpoint removed - no quiz data available
    private var currentQuizData: [String: Any]? {
        return nil
    }
    
    // Helper to find word quiz data (disabled - conversation quiz removed)
    private func findWordQuizData(for originalWord: String, in quizData: [String: Any]) -> Any? {
        return nil
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
                .onTapGesture {
                    // Dismiss keyboard when tapping on background
                    if focusedField != nil {
                        focusedField = nil
                    }
                }
            
            VStack(spacing: 0) {
                topControls
                
                // Description section
                descriptionSection

                ScrollView {
                    VStack(spacing: 32) {
                        if !sentences.isEmpty {
                        sentenceView
                                .padding(.horizontal, 2)
                        
                        Spacer(minLength: 40)
                        
                        followUpButton
                            .padding(.bottom, 40)
                        } else {
                            // Empty state - conversation quiz endpoint removed
                            VStack(spacing: 24) {
                                Text(languageManager.customPractice.custom)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Practice feature coming soon")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.top, 100)
                        }
                    }
                }
                .onAppear {
                    // Initialize editable words when view appears
                    if editableWords.isEmpty, let firstSentence = sentences.first {
                        editableWords = cleanAndSplitText(firstSentence)
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showCustomModal) {
            CustomPracticeModal(isPresented: $showCustomModal, appState: appState)
        }
        .sheet(isPresented: $showHintMenu) {
            hintSheetView
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.black)
        }
    }
    
    // MARK: - Top controls
    
    private var topControls: some View {
        HStack {
            // Reset button in top left corner
            if !sentences.isEmpty {
                Button(action: {
                    resetAndRegenerate()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Reset")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
                .buttonPressAnimation()
            }
            
            if isCustomPracticeEnabled {
            Button(action: {
                    showCustomModal = true
            }) {
                    Text(languageManager.customPractice.custom)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                                .fill(appState.selectedColor)
                    )
            }
                .buttonPressAnimation()
            }
            
            Spacer()
            
            // Follow-up questions counter with dots
            HStack(spacing: 8) {
                ForEach(0..<sentences.count, id: \.self) { index in
                    if index == currentSentenceIndex {
                        // Current question - highlighted
                        Text("\(index + 1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 24, height: 24)
                            .background(appState.selectedColor)
                            .clipShape(Circle())
                    } else {
                        // Other questions - dots
                        Circle()
                            .fill(.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                if isHintEnabled, editingIndex != nil {
                    showHintMenu = true
                }
            }) {
                Text(languageManager.customPractice.hint)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isHintEnabled ? .black : .white.opacity(0.5))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isHintEnabled ? appState.selectedColor : appState.selectedColor.opacity(0.3))
                    )
            }
            .buttonPressAnimation()
            .disabled(!isHintEnabled)
        }
        .padding(.top, 32)
        .padding(.horizontal, 2)
        .padding(.bottom, 12)
    }
    
    // MARK: - Description section
    
    private var descriptionSection: some View {
        VStack(spacing: 8) {
            if showTemporaryDescription {
                // Temporary description about underlined words
                Text("Underlined words are the ones you have learned. Tap any word in the sentence to translate to \(getTargetLanguageDisplayName()) (\(getTargetLanguageScriptName())). If you need help, use the hint button to get suggestions.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            } else {
                // Main description
            Text(languageManager.customPractice.practiceDescription)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 16)
        .onChange(of: sentences.isEmpty) { oldValue, newValue in
            if !newValue && !showTemporaryDescription {
                // Show temporary description when sentences become available
                showTemporaryDescription = true
                temporaryDescriptionTimer?.invalidate()
                temporaryDescriptionTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
                    DispatchQueue.main.async {
                        showTemporaryDescription = false
                    }
                }
            }
        }
        .onDisappear {
            temporaryDescriptionTimer?.invalidate()
            temporaryDescriptionTimer = nil
        }
    }
    
    // Helper to get target language display name
    private func getTargetLanguageDisplayName() -> String {
        guard let pair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first else { return "" }
        return displayTargetLanguage(for: pair.target_language)
    }
    
    // Helper to get target language script name (if different from display name)
    private func getTargetLanguageScriptName() -> String {
        guard let pair = appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first else { return "" }
        // For scripted languages, return the native script name
        // This is a simplified version - you may want to enhance this
        let targetLang = pair.target_language.lowercased()
        let scriptNames: [String: String] = [
            "hi": "हिंदी",
            "ja": "日本語",
            "zh": "中文",
            "ko": "한국어",
            "ru": "Русский",
            "ta": "தமிழ்",
            "te": "తెలుగు",
            "ml": "മലയാളം"
        ]
        return scriptNames[targetLang] ?? displayTargetLanguage(for: pair.target_language)
    }
    
    // MARK: - Language display helper
    
    private func displayTargetLanguage(for rawValue: String) -> String {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If it's already a long name (not just a short code), return as-is
        if value.count > 3 {
            return value
        }
        
        let mapping: [String: String] = [
            "en": "English",
            "ja": "日本語",
            "hi": "हिन्दी",
            "te": "తెలుగు",
            "ta": "தமிழ்",
            "fr": "Français",
            "de": "Deutsch",
            "es": "Español",
            "zh": "中文",
            "ko": "한국어",
            "ru": "Русский",
            "ml": "മലയാളം"
        ]
        
        return mapping[value.lowercased()] ?? value
    }
    
    // MARK: - Sentence view
    
    private var sentenceView: some View {
        VStack(alignment: .leading, spacing: 16) {
            FlowLayout(spacing: 12) {
                ForEach(currentSentence.indices, id: \.self) { index in
                    wordView(for: index)
            }
        }
        }
    }
    
    @ViewBuilder
    private func wordView(for index: Int) -> some View {
        let originalWord = currentSentence[index]
        let isEditing = (editingIndex == index)
        let userInput = userInputs[index] ?? ""
        let isChecked = checkedResults[index] != nil
        let isCorrect = checkedResults[index] ?? false
        
        // Conversation quiz removed - words are not marked as learned
        let isInUserDb: Bool = false
        
        if isEditing {
            TextField("", text: Binding(
                get: { userInputs[index] ?? "" },
                set: { userInputs[index] = $0 }
            ))
            .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 4)
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(height: 1),
                alignment: .bottom
            )
            .focused($focusedField, equals: index)
            .submitLabel(.done)
            .onSubmit {
                checkWord(at: index)
            }
            .onAppear {
                focusedField = index
                // Clear the word when starting to edit
                userInputs[index] = ""
            }
        } else {
            Button(action: {
                editingIndex = index
                isHintEnabled = true
                // Clear previous input and check result
                userInputs.removeValue(forKey: index)
                checkedResults.removeValue(forKey: index)
            }) {
                let displayText = userInput.isEmpty ? originalWord : userInput
                // If checked, show green/red, otherwise white
                let textColor: Color = isChecked ? (isCorrect ? .green : .red) : .white
                
                Text(displayText)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(textColor)
                    .underline(isInUserDb && !isChecked) // Underline if learned and not checked
            }
            .buttonStyle(.plain)
        }
    }
    
    private func checkWord(at index: Int) {
        // Conversation quiz endpoint removed - no checking available
        editingIndex = nil
        focusedField = nil
        isHintEnabled = false
    }
    
    // Helper function to check word when hint is selected
    private func checkWordFromHint(at index: Int, selectedTransliteration: String) {
        // Conversation quiz endpoint removed - no checking available
        isHintEnabled = false
    }
    
    private func fuzzyMatch(userInput: String, correct: String) -> Bool {
        let normalizedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedCorrect = correct.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Exact match
        if normalizedInput == normalizedCorrect {
            return true
        }
        
        // Check if input contains correct or vice versa (for partial matches)
        if normalizedInput.contains(normalizedCorrect) || normalizedCorrect.contains(normalizedInput) {
            return true
        }
        
        // Levenshtein distance check (simple version - if very similar, consider correct)
        let distance = levenshteinDistance(normalizedInput, normalizedCorrect)
        let maxLength = max(normalizedInput.count, normalizedCorrect.count)
        if maxLength > 0 {
            let similarity = 1.0 - (Double(distance) / Double(maxLength))
            return similarity >= 0.8 // 80% similarity threshold
        }
        
        return false
    }
    
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let m = s1Array.count
        let n = s2Array.count
        
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m {
            dp[i][0] = i
        }
        for j in 0...n {
            dp[0][j] = j
        }
        
        for i in 1...m {
            for j in 1...n {
                if s1Array[i-1] == s2Array[j-1] {
                    dp[i][j] = dp[i-1][j-1]
                } else {
                    dp[i][j] = min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1]) + 1
                }
            }
        }
        
        return dp[m][n]
    }
    
    // MARK: - Follow-up button
    
    private var followUpButton: some View {
        Button(action: {
            moveToNextSentence()
        }) {
            Text(languageManager.customPractice.practiceFollowUp)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(appState.selectedColor)
                .cornerRadius(20)
        }
        .buttonPressAnimation()
        .padding(.horizontal, 40)
    }
    
    private func moveToNextSentence() {
        editingIndex = nil
        isHintEnabled = false
        focusedField = nil
        userInputs.removeAll()
        checkedResults.removeAll()
        showHintMenu = false
        
        guard !sentences.isEmpty else { return }
        
        // Move to next sentence (one by one)
        if currentSentenceIndex < sentences.count - 1 {
            currentSentenceIndex += 1
        } else {
            // If at last sentence, cycle back to first (or you could disable button)
            currentSentenceIndex = 0
        }
        
        // Update editable words for new sentence
        if let sentenceText = currentSentenceText {
            editableWords = cleanAndSplitText(sentenceText)
        }
    }
    
    // MARK: - Reset and Regenerate
    private func resetAndRegenerate() {
        // Reset all state
        editingIndex = nil
        isHintEnabled = false
        focusedField = nil
        userInputs.removeAll()
        checkedResults.removeAll()
        showHintMenu = false
        currentSentenceIndex = 0
        editableWords.removeAll()
    }
    
    // MARK: - Hint Sheet View (medium modal)
    private var hintSheetView: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Conversation quiz endpoint removed")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 20)
                
                Spacer()
            }
            .padding(20)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(languageManager.customPractice.hint)
            .navigationBarTitleDisplayMode(.inline)
        }
        }
    }
    
// MARK: - Custom Practice Modal

private struct CustomPracticeModal: View {
    @Binding var isPresented: Bool
    @ObservedObject var appState: AppStateManager
    @ObservedObject var languageManager = LanguageManager.shared
    
    @State private var conversationTypeText: String = ""
    @State private var customText: String = ""
    @State private var isEditingFullText: Bool = false
    @State private var showingCamera: Bool = false
    @State private var showingGallery: Bool = false
    @State private var selectedImage: UIImage?
    @State private var isImageSelected: Bool = false
    @State private var conversationTexts: [String] = [""]
    @State private var previousImages: [UIImage] = [] // Store previous captured images
    private let previousImagesStorageKey = "com.locian.customModal.previousImages"
    
    // Computed property to check if + button should be enabled (first box has 30+ characters)
    private var canAddMoreText: Bool {
        guard !conversationTexts.isEmpty else { return false }
        return conversationTexts[0].count >= 30
    }
    
    private var defaultPair: LanguagePair? {
        appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
    }
    
    private var nativeLanguageName: String {
        guard let pair = defaultPair, !pair.native_language.isEmpty else { return "your native language" }
        return getLanguageDisplayName(pair.native_language)
    }
    
    private var targetLanguageName: String {
        guard let pair = defaultPair, !pair.target_language.isEmpty else { return "target language" }
        return getLanguageDisplayName(pair.target_language)
    }
    
    private func getLanguageDisplayName(_ codeOrName: String) -> String {
        let mapping: [String: String] = [
            "en": "English",
            "ja": "日本語",
            "hi": "हिन्दी",
            "te": "తెలుగు",
            "ta": "தமிழ்",
            "fr": "Français",
            "de": "Deutsch",
            "es": "Español",
            "zh": "中文",
            "ko": "한국어",
            "ru": "Русский",
            "ml": "മലയാളം"
        ]
        let value = codeOrName.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.count > 3 { return value }
        return mapping[value.lowercased()] ?? value
    }
    
    private func formatDescription(_ template: String) -> String {
        return template
            .replacingOccurrences(of: "{native}", with: nativeLanguageName)
            .replacingOccurrences(of: "{target}", with: targetLanguageName)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed Header (exactly like language selection modal)
                HStack(alignment: .center) {
                    // Heading at top left
                    Text(languageManager.customPractice.custom)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 24)
                        .padding(.top, 0)
                    
                    Spacer()
                    
                    // Close button at top right
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                }
                    .buttonStyle(PlainButtonStyle())
                    .circleButtonPressAnimation()
                    .padding(.trailing, 10)
                    .padding(.top, 0)
                }
                .background(Color.black)
                .zIndex(1)
                
                // Scrollable content
                if isEditingFullText {
                    // Full text editor mode with dynamic text boxes - scrollable
                    ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                            Text(languageManager.customPractice.describeConversation)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            // Dynamic text boxes with + buttons
                            VStack(spacing: 12) {
                                ForEach(conversationTexts.indices, id: \.self) { index in
                                    VStack(spacing: 12) {
                                        // Text box - supports up to 4 lines, full width with 15pt padding
                                        ZStack(alignment: .topLeading) {
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(Color.white.opacity(0.08))
                                            
                                            if conversationTexts[index].isEmpty {
                                                Text(languageManager.customPractice.conversationPlaceholder)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white.opacity(0.4))
                                                    .padding(.horizontal, 12)
                                                    .padding(.top, 10)
                                            }
                                            
                                            TextEditor(text: Binding(
                                                get: { conversationTexts[index] },
                                                set: { conversationTexts[index] = $0 }
                                            ))
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .scrollContentBackground(.hidden)
                                            .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                            .frame(minHeight: 100)
                                            .lineLimit(4)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 100)
                                        
                                        // + button (same size as text box) - only for last item, enabled if first box has 30+ chars
                                        if index == conversationTexts.count - 1 {
                                            Button(action: {
                                                conversationTexts.append("")
                                            }) {
                                                Image(systemName: "plus")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(canAddMoreText ? .white : .white.opacity(0.3))
                                                    .frame(maxWidth: .infinity)
                                                    .frame(height: 100)
                                .background(
                                                        RoundedRectangle(cornerRadius: 14)
                                                            .fill(Color.white.opacity(0.08))
                                )
                        }
                                            .buttonStyle(.plain)
                                            .buttonPressAnimation()
                                            .disabled(!canAddMoreText)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    }
                    
                    // Fixed bottom button
                    HStack {
                        Spacer()
                    Button(action: {
                        // TODO: Wire to backend / quiz state using conversationTexts
                        isPresented = false
                    }) {
                        Text(languageManager.customPractice.startCustomPractice)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                                .padding(.horizontal, 24)
                            .padding(.vertical, 18)
                                .background(appState.selectedColor)
                            .cornerRadius(22)
                    }
                        .buttonPressAnimation()
                        Spacer()
                    }
                    .padding(.bottom, 32)
                    .background(Color.black)
                } else {
                    // Default mode: camera + text input with submit + full custom text button - scrollable
                    VStack(spacing: 0) {
                    ScrollView {
                            VStack(spacing: 36) {
                        // Camera section with images - grouped together with reduced spacing
                        VStack(spacing: 16) {
                        // Camera heading + description
                        VStack(alignment: .leading, spacing: 10) {
                            Text(languageManager.customPractice.camera)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(formatDescription(languageManager.customPractice.cameraDescription))
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(nil)
                    }
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                        // Camera button (full width with 15pt padding on left and right)
                                Button(action: {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showingCamera = true
                        }
                                }) {
                        HStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(languageManager.customPractice.useCamera)
                                    .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                
                                Text(languageManager.customPractice.cameraButtonDescription)
                                    .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.7))
                                    .lineLimit(2)
                        }
                        }
                            .padding(.horizontal, 2)
                        .padding(.vertical, 22)
                        .frame(maxWidth: .infinity)
                        .background(
                                Rectangle()
                                    .fill(Color(white: 0.05))
                                .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 10)
                        )
                            .overlay(
                                // Left border only
                                HStack {
                                    Rectangle()
                                        .fill(appState.selectedColor)
                                        .frame(width: 15)
                                    Spacer()
                                }
                        )
                    }
                    .buttonStyle(.plain)
                    .buttonPressAnimation()
                    .padding(.horizontal, 15)
                    
                    // Previous images scrolling section
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            if previousImages.isEmpty {
                                Text("No previous images")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                                    .frame(minWidth: 100, minHeight: 100)
                                    .padding(.leading, 15)
                            } else {
                                ForEach(Array(previousImages.enumerated()), id: \.offset) { index, image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .padding(.leading, index == 0 ? 15 : 0)
                                }
                            }
                                
                                // Gallery button at the end
                                Button(action: {
                                    requestGalleryAccess()
                                }) {
                                    VStack(spacing: 6) {
                                        Image(systemName: "photo.fill")
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text("Gallery")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.1))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.trailing, 15)
                    }
                    .frame(height: 100)
                        }
                        
                        Spacer()
                            .frame(height: 24)
                        
                        // Text input heading + description
                        VStack(alignment: .leading, spacing: 10) {
                            Text(languageManager.customPractice.typeConversation)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(formatDescription(languageManager.customPractice.typeConversationDescription))
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(nil)
                            
                            // Text input for type of conversation with Submit button
                        HStack(spacing: 10) {
                                TextField(languageManager.customPractice.conversationPlaceholder, text: $conversationTypeText)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.white.opacity(0.08))
                                    )
                                
                                Button(action: {
                                    // TODO: Submit the conversation type
                                }) {
                                    Text(languageManager.customPractice.submit)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(appState.selectedColor)
                                        .cornerRadius(14)
                                }
                                .buttonPressAnimation()
                            }
                            
                            // Example text section
                            VStack(alignment: .leading, spacing: 8) {
                                Text(languageManager.customPractice.examples)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("• \"\(languageManager.customPractice.conversationExample1)\"")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    Text("• \"\(languageManager.customPractice.conversationExample2)\"")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    Text("• \"\(languageManager.customPractice.conversationExample3)\"")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                        }
                            .padding(.top, 8)
                }
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 8)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                        }
                    
                        // Full custom text button (sticky at bottom)
                        VStack {
                            HStack {
                        Spacer()
                    Button(action: {
                            // Initialize conversationTexts with one empty string if needed
                            if conversationTexts.isEmpty {
                                conversationTexts = [""]
                            }
                            isEditingFullText = true
                    }) {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                Text(languageManager.customPractice.fullCustomText)
                                    .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            }
                                    .padding(.horizontal, 24)
                        .padding(.vertical, 18)
                                    .background(appState.selectedColor)
                            .cornerRadius(22)
                    }
                                .buttonPressAnimation()
                                Spacer()
        }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.black)
                        }
                    }
        }
    }
    }
        .fullScreenCover(isPresented: $showingCamera) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                ImagePicker(
                    sourceType: .camera,
                    selectedImage: $selectedImage,
                    isImageSelected: $isImageSelected
                ) {
                    // Handle image selection - analyze or generate sentence
                    handleImageSelected()
                }
            }
        }
        .fullScreenCover(isPresented: $showingGallery) {
            ImagePicker(
                sourceType: .photoLibrary,
                selectedImage: $selectedImage,
                isImageSelected: $isImageSelected
            ) {
                // Handle image selection - analyze or generate sentence
                handleImageSelected()
            }
        }
        .onChange(of: selectedImage) { _, newImage in
            if newImage != nil {
                // Image was selected, handle it
                handleImageSelected()
            }
        }
        .onAppear {
            loadPreviousImages()
        }
    }
    
    private func handleImageSelected() {
        guard let image = selectedImage else { return }
        
        // Save to previous images (insert at beginning for priority)
        if !previousImages.contains(where: { img in
            if let imgData = img.jpegData(compressionQuality: 0.7),
               let newImgData = image.jpegData(compressionQuality: 0.7) {
                return imgData == newImgData
            }
            return false
        }) {
            previousImages.insert(image, at: 0) // Insert at beginning
            // Keep only first 7
            if previousImages.count > 7 {
                previousImages = Array(previousImages.prefix(7))
            }
        savePreviousImages()
        }
        
        // TODO: Analyze image and generate practice sentence
        // For now, just close the modal and show the image was captured
        // You can add image analysis logic here similar to SceneView
        isPresented = false
    }
    
    // MARK: - Previous Images Persistence
    
    private func loadPreviousImages() {
        // Load saved images first (app-analyzed images get priority)
        // Use file storage instead of UserDefaults for large image data
        var loadedImages = FileStorageManager.shared.loadImageArray(forKey: previousImagesStorageKey)
        
        // Migrate from UserDefaults if exists (one-time migration)
        if let dataArray = UserDefaults.standard.array(forKey: previousImagesStorageKey) as? [Data] {
            let migratedImages = dataArray.compactMap { UIImage(data: $0) }
            if !migratedImages.isEmpty {
                _ = FileStorageManager.shared.saveImageArray(migratedImages, forKey: previousImagesStorageKey)
                UserDefaults.standard.removeObject(forKey: previousImagesStorageKey)
                loadedImages = migratedImages
            }
        }
        
        // Request photo library permission if needed, then fetch gallery images
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    self.fetchRecentGalleryImages { galleryImages in
                        self.combineImages(appImages: loadedImages, galleryImages: galleryImages)
            }
        } else {
                    // No permission, just use app images
                    DispatchQueue.main.async {
                        self.previousImages = Array(loadedImages.prefix(7))
                    }
                }
            }
        } else if status == .authorized || status == .limited {
            // Already have permission, fetch gallery images
            fetchRecentGalleryImages { galleryImages in
                self.combineImages(appImages: loadedImages, galleryImages: galleryImages)
            }
        } else {
            // No permission, just use app images
            DispatchQueue.main.async {
                self.previousImages = Array(loadedImages.prefix(7))
            }
        }
    }
    
    func combineImages(appImages: [UIImage], galleryImages: [UIImage]) {
        DispatchQueue.main.async {
            // Start with app-analyzed images (priority)
            var combinedImages: [UIImage] = []
            var seenData: Set<Data> = []
            
            // Add app images first (up to 7)
            for image in appImages {
                if let imageData = image.jpegData(compressionQuality: 0.7),
                   !seenData.contains(imageData) {
                    combinedImages.append(image)
                    seenData.insert(imageData)
                    if combinedImages.count >= 7 {
                        break
                    }
                }
            }
            
            // Fill remaining slots with gallery images
            if combinedImages.count < 7 {
                let remainingSlots = 7 - combinedImages.count
                for image in galleryImages.prefix(remainingSlots) {
                    if let imageData = image.jpegData(compressionQuality: 0.7),
                       !seenData.contains(imageData) {
                        combinedImages.append(image)
                        seenData.insert(imageData)
                        if combinedImages.count >= 7 {
                            break
                        }
                    }
                }
            }
            
            self.previousImages = combinedImages
        }
    }
    
    func fetchRecentGalleryImages(completion: @escaping ([UIImage]) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        guard status == .authorized || status == .limited else {
            completion([])
            return
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 20 // Fetch more to ensure we get enough after filtering
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var images: [UIImage] = []
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .fast
        
        let group = DispatchGroup()
        let maxCount = min(assets.count, 20)
        
        for i in 0..<maxCount {
            let asset = assets.object(at: i)
            group.enter()
            
            imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 300, height: 300),
                contentMode: .aspectFill,
                options: requestOptions
            ) { image, _ in
                if let image = image {
                    images.append(image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(images)
        }
    }
    
    private func savePreviousImages() {
        // Use file storage instead of UserDefaults for large image data
        _ = FileStorageManager.shared.saveImageArray(previousImages, forKey: previousImagesStorageKey)
    }
    
    private func requestGalleryAccess() {
        PermissionsService.requestPhotoLibraryAccess { granted in
            if granted {
                DispatchQueue.main.async {
                    self.showingGallery = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        QuizView(appState: AppStateManager())
    }
    .preferredColorScheme(.dark)
}


