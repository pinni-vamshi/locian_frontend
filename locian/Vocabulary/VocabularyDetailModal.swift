import SwiftUI
import AVFoundation
import NaturalLanguage

struct VocabularyDetailModal: View {
    let item: VocabularyItem
    @ObservedObject var appState: AppStateManager
    @ObservedObject private var localizationManager = LocalizationManager.shared
    let isImageSelected: Bool
    let selectedColor: Color
    @State private var showingSimilarWords: Bool = false
    @State private var showingWordTenses: Bool = false
    @State private var showingWordDecomposition: Bool = false
    @State private var similarWordsItems: [SimilarWordItem] = []
    @State private var wordTensesItems: [WordTenseItem] = []
    @State private var currentDetent: PresentationDetent = .medium
    @State private var similarWordPositions: [UUID: CGFloat] = [:]
    @State private var selectedSimilarWordId: UUID? = nil
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - Helper Functions
    private func getSceneContext() -> String {
        if isImageSelected {
            return appState.imageAnalysisResult ?? ""
        } else {
            return ""
        }
    }
    
    private var descriptionText: String {
        if appState.isLoadingWordDecomposition {
            return "Loading..."
        } else if showingWordDecomposition {
            return "Tap the words to hide the breakdown"
        } else {
            return "Tap the words to see its breakdown"
        }
    }
    
    // Detect language from text using NaturalLanguage framework
    private func detectLanguage(from text: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        // Get the dominant language
        if let dominantLanguage = recognizer.dominantLanguage {
            let languageCode = dominantLanguage.rawValue
            print("🔊 [SPEECH] Auto-detected language from text: '\(languageCode)'")
            return languageCode
        }
        
        // Get all hypotheses if dominant is not available
        let hypotheses = recognizer.languageHypotheses(withMaximum: 3)
        if let bestLanguage = hypotheses.keys.first {
            let languageCode = bestLanguage.rawValue
            print("🔊 [SPEECH] Auto-detected language (from hypotheses): '\(languageCode)'")
            return languageCode
        }
        
        return nil
    }
    
    // Get target language code for speech synthesis (language code only, no region)
    private func getTargetLanguageCode() -> String {
        // First, try to auto-detect language from target_text
        if let detectedCode = detectLanguage(from: item.target_text) {
            print("🔊 [SPEECH] Using auto-detected language code: '\(detectedCode)'")
            return detectedCode
        }
        
        // Fallback: Use default language pair
        if let defaultPair = appState.userLanguagePairs.first(where: { $0.is_default }) {
            print("🔊 [SPEECH] Auto-detection failed, using default pair")
            print("🔊 [SPEECH] Default pair found - native: '\(defaultPair.native_language)', target: '\(defaultPair.target_language)'")
            print("🔊 [SPEECH] Vocabulary item - native_text: '\(item.native_text)', target_text: '\(item.target_text)'")
            
            // target_text is in the target language (the language being learned)
            let targetLanguageName = defaultPair.target_language
            let languageCode = getLanguageCode(for: targetLanguageName)
            print("🔊 [SPEECH] Using target language from pair: '\(targetLanguageName)' -> code: '\(languageCode)'")
            return languageCode
        }
        
        // Final fallback to English
        print("⚠️ [SPEECH] No language detected and no default pair found, using English")
        return "en"
    }
    
    // Convert language name to AVSpeech language code (ISO 639-1 format)
    private func getLanguageCode(for languageName: String) -> String {
        let mapping: [String: String] = [
            "English": "en",
            "Spanish": "es",
            "French": "fr",
            "German": "de",
            "Italian": "it",
            "Portuguese": "pt",
            "Russian": "ru",
            "Japanese": "ja",
            "Korean": "ko",
            "Chinese": "zh",
            "Arabic": "ar",
            "Hindi": "hi",
            "Telugu": "te",
            "Tamil": "ta",
            "Bengali": "bn",
            "Gujarati": "gu",
            "Kannada": "kn",
            "Malayalam": "ml",
            "Marathi": "mr",
            "Punjabi": "pa",
            "Urdu": "ur",
            "Turkish": "tr",
            "Dutch": "nl",
            "Swedish": "sv"
        ]
        return mapping[languageName] ?? "en"
    }
    
    // Convert language code to locale code for AVSpeechSynthesizer
    private func getLocaleCode(from languageCode: String) -> String {
        // Map common language codes to their most common locale codes
        let localeMapping: [String: [String]] = [
            "hi": ["hi-IN"],
            "te": ["te-IN"],
            "ta": ["ta-IN"],
            "bn": ["bn-IN"],
            "gu": ["gu-IN"],
            "kn": ["kn-IN"],
            "ml": ["ml-IN"],
            "mr": ["mr-IN"],
            "pa": ["pa-IN"],
            "ur": ["ur-PK"],
            "es": ["es-ES", "es-MX"],
            "pt": ["pt-PT", "pt-BR"],
            "en": ["en-US", "en-GB"],
            "fr": ["fr-FR", "fr-CA"],
            "de": ["de-DE", "de-AT"],
            "zh": ["zh-CN", "zh-TW"],
            "ja": ["ja-JP"],
            "ko": ["ko-KR"],
            "ar": ["ar-SA"],
            "ru": ["ru-RU"],
            "it": ["it-IT"],
            "nl": ["nl-NL"],
            "sv": ["sv-SE"],
            "tr": ["tr-TR"]
        ]
        
        // If it's already a locale code (contains hyphen), return as is
        if languageCode.contains("-") {
            return languageCode
        }
        
        // Otherwise, try to get locale code from mapping
        if let locales = localeMapping[languageCode.lowercased()] {
            return locales.first ?? languageCode
        }
        
        // Return as is if no mapping found
        return languageCode
    }
    
    // Speak the target word (only target_text, not transliteration)
    private func speakTargetWord() {
        // Stop any current speech
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        // Create utterance with ONLY the target text (no transliteration, no other text)
        let textToSpeak = item.target_text
        print("🔊 [SPEECH] Speaking target text only: '\(textToSpeak)'")
        let utterance = AVSpeechUtterance(string: textToSpeak)
        
        // Get language code (auto-detected or from pair)
        let languageCode = getTargetLanguageCode()
        print("🔊 [SPEECH] Target language code: '\(languageCode)'")
        
        // Convert to locale code for AVSpeechSynthesizer
        let localeCode = getLocaleCode(from: languageCode)
        print("🔊 [SPEECH] Locale code: '\(localeCode)'")
        
        // Try to get voice for the locale, with fallback
        if let voice = AVSpeechSynthesisVoice(language: localeCode) {
            utterance.voice = voice
            print("🔊 [SPEECH] Using voice: \(voice.name) (\(voice.language))")
        } else {
            print("🔊 [SPEECH] Primary voice not found for '\(localeCode)', trying fallback codes...")
            
            // Fallback: try language code without region first
            let baseLanguageCode = localeCode.components(separatedBy: "-").first ?? localeCode
            if let voice = AVSpeechSynthesisVoice(language: baseLanguageCode) {
                utterance.voice = voice
                print("🔊 [SPEECH] Using voice with base language code: \(voice.name) (\(voice.language))")
            } else {
                // Try alternative locale codes
                let fallbackCodes: [String: [String]] = [
                    "hi": ["hi-IN"],
                    "te": ["te-IN"],
                    "ta": ["ta-IN"],
                    "bn": ["bn-IN"],
                    "gu": ["gu-IN"],
                    "kn": ["kn-IN"],
                    "ml": ["ml-IN"],
                    "mr": ["mr-IN"],
                    "pa": ["pa-IN"],
                    "ur": ["ur-PK"],
                    "es": ["es-ES", "es-MX"],
                    "pt": ["pt-PT", "pt-BR"],
                    "en": ["en-US", "en-GB"],
                    "fr": ["fr-FR", "fr-CA"],
                    "de": ["de-DE", "de-AT"],
                    "zh": ["zh-CN", "zh-TW"]
                ]
                
                if let fallbackList = fallbackCodes[baseLanguageCode] {
                    for fallbackCode in fallbackList {
                        if let voice = AVSpeechSynthesisVoice(language: fallbackCode) {
                            utterance.voice = voice
                            print("🔊 [SPEECH] Using fallback voice: \(voice.name) (\(voice.language))")
                            break
                        }
                    }
                }
                
                // Final fallback to default voice if still no voice found
                if utterance.voice == nil {
                    if let defaultVoice = AVSpeechSynthesisVoice(language: "en-US") {
                        utterance.voice = defaultVoice
                        print("🔊 [SPEECH] Using default English voice: \(defaultVoice.name)")
                    } else {
                        print("⚠️ [SPEECH] No voice found, using system default")
                    }
                }
            }
        }
        
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.volume = 1.0
        
        print("🔊 [SPEECH] Starting speech...")
        speechSynthesizer.speak(utterance)
    }
    
    // Speak any text (for similar words and tenses)
    private func speakText(_ text: String) {
        // Stop any current speech
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        print("🔊 [SPEECH] Speaking text: '\(text)'")
        let utterance = AVSpeechUtterance(string: text)
        
        // Get language code (auto-detect from text, then fallback to default pair)
        let languageCode = getTargetLanguageCode(from: text)
        print("🔊 [SPEECH] Target language code: '\(languageCode)'")
        
        // Convert to locale code for AVSpeechSynthesizer
        let localeCode = getLocaleCode(from: languageCode)
        print("🔊 [SPEECH] Locale code: '\(localeCode)'")
        
        // Try to get voice for the locale, with fallback
        if let voice = AVSpeechSynthesisVoice(language: localeCode) {
            utterance.voice = voice
            print("🔊 [SPEECH] Using voice: \(voice.name) (\(voice.language))")
        } else {
            print("🔊 [SPEECH] Primary voice not found for '\(localeCode)', trying fallback codes...")
            
            // Fallback: try language code without region first
            let baseLanguageCode = localeCode.components(separatedBy: "-").first ?? localeCode
            if let voice = AVSpeechSynthesisVoice(language: baseLanguageCode) {
                utterance.voice = voice
                print("🔊 [SPEECH] Using voice with base language code: \(voice.name) (\(voice.language))")
            } else {
                // Try alternative locale codes
                let fallbackCodes: [String: [String]] = [
                    "hi": ["hi-IN"],
                    "te": ["te-IN"],
                    "ta": ["ta-IN"],
                    "bn": ["bn-IN"],
                    "gu": ["gu-IN"],
                    "kn": ["kn-IN"],
                    "ml": ["ml-IN"],
                    "mr": ["mr-IN"],
                    "pa": ["pa-IN"],
                    "ur": ["ur-PK"],
                    "es": ["es-ES", "es-MX"],
                    "pt": ["pt-PT", "pt-BR"],
                    "en": ["en-US", "en-GB"],
                    "fr": ["fr-FR", "fr-CA"],
                    "de": ["de-DE", "de-AT"],
                    "zh": ["zh-CN", "zh-TW"]
                ]
                
                if let fallbackList = fallbackCodes[baseLanguageCode] {
                    for fallbackCode in fallbackList {
                        if let voice = AVSpeechSynthesisVoice(language: fallbackCode) {
                            utterance.voice = voice
                            print("🔊 [SPEECH] Using fallback voice: \(voice.name) (\(voice.language))")
                            break
                        }
                    }
                }
                
                // Final fallback to default voice if still no voice found
                if utterance.voice == nil {
                    if let defaultVoice = AVSpeechSynthesisVoice(language: "en-US") {
                        utterance.voice = defaultVoice
                        print("🔊 [SPEECH] Using default English voice: \(defaultVoice.name)")
                    } else {
                        print("⚠️ [SPEECH] No voice found, using system default")
                    }
                }
            }
        }
        
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.volume = 1.0
        
        print("🔊 [SPEECH] Starting speech...")
        speechSynthesizer.speak(utterance)
    }
    
    private func getTargetLanguageCode(from text: String) -> String {
        // Auto-detect language from text first
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        if let dominantLanguage = recognizer.dominantLanguage {
            let detectedCode = dominantLanguage.rawValue
            print("🔊 [SPEECH] Auto-detected language: \(detectedCode)")
            return detectedCode
        }
        
        // Fallback to default language pair's target language
        return getTargetLanguageCode()
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)
                
                wordHeaderSection
                targetWordSection
                
                Spacer()
                
                // Buttons always visible
                iconButtonsSection
                
                // Similar words section (appears below buttons)
                if showingSimilarWords {
                    similarWordsSection
                }
                
                // Word tenses section (appears below buttons)
                if showingWordTenses {
                    wordTensesSection
                }
                
                // Word breakdown section (appears below buttons)
                if showingWordDecomposition {
                    wordDecompositionSection
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appState.selectedColor)
        .ignoresSafeArea()
        .presentationDetents([.medium, .large], selection: $currentDetent)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showingSimilarWords)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showingWordTenses)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showingWordDecomposition)
        .presentationDragIndicator(.visible)
        .onChange(of: showingSimilarWords) { _, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentDetent = (newValue || showingWordTenses || showingWordDecomposition) ? .large : .medium
            }
        }
        .onChange(of: showingWordTenses) { _, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentDetent = (showingSimilarWords || newValue || showingWordDecomposition) ? .large : .medium
            }
        }
        .onChange(of: showingWordDecomposition) { _, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentDetent = (showingSimilarWords || showingWordTenses || newValue) ? .large : .medium
            }
        }
        .alert(LocalizationManager.shared.string(.error), isPresented: $appState.showSimilarWordsError) {
            Button(LocalizationManager.shared.string(.ok), role: .cancel) {
                appState.similarWordsError = nil
            }
        } message: {
            Text(appState.similarWordsError ?? "Failed to load similar words")
        }
        .alert(LocalizationManager.shared.string(.error), isPresented: $appState.showWordTensesError) {
            Button(LocalizationManager.shared.string(.ok), role: .cancel) {
                appState.wordTensesError = nil
            }
        } message: {
            Text(appState.wordTensesError ?? "Failed to load word tenses")
        }
        .alert(LocalizationManager.shared.string(.error), isPresented: $appState.showWordDecompositionError) {
            Button(LocalizationManager.shared.string(.ok), role: .cancel) {
                appState.wordDecompositionError = nil
            }
        } message: {
            Text(appState.wordDecompositionError ?? "Failed to load word breakdown")
        }
    }
    
    // MARK: - View Sections
    private var wordHeaderSection: some View {
        VStack {
            Text(item.native_text)
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var targetWordSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Button(action: handleWordBreakdownTap) {
                    VStack(spacing: 8) {
                        Text(item.target_text)
                            .font(.system(size: 45, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                            .lineLimit(2)
                        
                        Text("[\(item.transliteration)]")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                            .lineLimit(2)
                    }
                }
                .buttonPressAnimation()
                .disabled(appState.isLoadingWordDecomposition || appState.isLoadingSimilarWords || appState.isLoadingWordTenses)
                
                // Speaker button - isolated, only speaks target_text
                Button(action: {
                    HapticFeedback.selection()
                    // Only speak the target text, nothing else
                    speakTargetWord()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(selectedColor)
                    }
                }
                .circleButtonPressAnimation() // Scale up animation for circle button
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity)
            
            Text(descriptionText)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    private var iconButtonsSection: some View {
        HStack(spacing: 15) {
            similarWordsButton
            wordTensesButton
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 50)
        .padding(.bottom, 15)
    }
    
    private var similarWordsButton: some View {
        Button(action: handleSimilarWordsTap) {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 60, height: 60)
                
                if appState.isLoadingSimilarWords {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "text.magnifyingglass")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(showingSimilarWords ? selectedColor : .white)
                }
            }
        }
        .circleButtonPressAnimation() // Scale up animation for circle button
        .disabled(appState.isLoadingSimilarWords || appState.isLoadingWordTenses || appState.isLoadingWordDecomposition)
    }
    
    private var wordTensesButton: some View {
        Button(action: handleWordTensesTap) {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 60, height: 60)
                
                if appState.isLoadingWordTenses {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "clock")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(showingWordTenses ? selectedColor : .white)
                }
            }
        }
        .circleButtonPressAnimation() // Scale up animation for circle button
        .disabled(appState.isLoadingSimilarWords || appState.isLoadingWordTenses || appState.isLoadingWordDecomposition)
    }
    
    private var similarWordsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Similar Words:")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.top, 8)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(similarWordsItems.enumerated()), id: \.element.id) { index, wordItem in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(wordItem.nativeWord)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text(wordItem.translation)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.8))
                                
                                if !wordItem.transliteration.isEmpty {
                                    Text("[\(wordItem.transliteration)]")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.black.opacity(0.6))
                                }
                            }
                            
                            Spacer()
                            
                            // Speaker button for similar word
                            Button(action: {
                                HapticFeedback.selection()
                                speakText(wordItem.translation)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(selectedColor)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .circleButtonPressAnimation()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                        
                        if index < similarWordsItems.count - 1 {
                            Divider()
                                .background(Color.black.opacity(0.2))
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }
    
    // Helper preference key for scroll offset
    private struct ScrollViewOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
    
    // Preference key for tracking word positions
    private struct SimilarWordPositionPreferenceKey: PreferenceKey {
        static var defaultValue: [UUID: CGFloat] = [:]
        static func reduce(value: inout [UUID: CGFloat], nextValue: () -> [UUID: CGFloat]) {
            value.merge(nextValue(), uniquingKeysWith: { _, new in new })
        }
    }
    
    private func similarWordCard(_ wordItem: SimilarWordItem, geometry: GeometryProxy) -> some View {
        let isSelected = selectedSimilarWordId == wordItem.id
        let cardPosition = similarWordPositions[wordItem.id] ?? 0
        let centerX = geometry.size.width / 2
        let distance = abs(cardPosition - centerX)
        let maxDistance = geometry.size.width * 0.5
        let scaleFactor = max(0.85, 1.0 - (distance / maxDistance) * 0.15)
        let fontSize = isSelected ? 32.0 : 30.0
        let translationFontSize = isSelected ? 27.0 : 25.0
        let transliterationFontSize = isSelected ? 22.0 : 20.0
        
        return VStack(spacing: 8) {
            Text(wordItem.nativeWord)
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Text(wordItem.translation)
                .font(.system(size: translationFontSize, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Text(wordItem.transliteration)
                .font(.system(size: transliterationFontSize, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .scaleEffect(scaleFactor)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedSimilarWordId)
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: SimilarWordPositionPreferenceKey.self,
                        value: [wordItem.id: geo.frame(in: .global).midX]
                    )
            }
        )
    }
    
    private var wordTensesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Word Tenses:")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.top, 8)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(wordTensesItems.enumerated()), id: \.element.id) { index, tenseItem in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(tenseItem.userForm)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text(tenseItem.targetTranslation)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.8))
                                
                                if !tenseItem.transliteration.isEmpty {
                                    Text("[\(tenseItem.transliteration)]")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.black.opacity(0.6))
                                }
                            }
                            
                            Spacer()
                            
                            // Speaker button for word tense
                            Button(action: {
                                HapticFeedback.selection()
                                speakText(tenseItem.targetTranslation)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(selectedColor)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .circleButtonPressAnimation()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                        
                        if index < wordTensesItems.count - 1 {
                            Divider()
                                .background(Color.black.opacity(0.2))
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }
    
    private func wordTenseCard(_ tenseItem: WordTenseItem) -> some View {
        VStack(spacing: 8) {
            Text(tenseItem.tenseName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Text(tenseItem.userForm)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Text(tenseItem.targetTranslation)
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Text(tenseItem.transliteration)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
    }
    
    private var wordDecompositionSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Word Breakdown:")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.top, 8)
            
            if let decomposition = appState.wordDecompositionResult {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        if !decomposition.blocks.isEmpty {
                            decompositionBlocksView(decomposition.blocks)
                        }
                    }
                    .padding(.top, 2)
                    .padding(.bottom, 10)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func decompositionBlocksView(_ blocks: [DecompositionBlock]) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                    VStack(alignment: .leading, spacing: 0) {
                        decompositionBlockCard(block)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.1), value: blocks.count)
                        
                        if index < blocks.count - 1 {
                            Divider()
                                .background(Color.black.opacity(0.2))
                                .padding(.top, 8)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
    
    private func decompositionBlockCard(_ block: DecompositionBlock) -> some View {
        let hasConsonant = !block.consonant.isEmpty
        let hasVowel = block.has_vowel && !block.vowel.isEmpty
        let hasConsonantTranslit = !block.consonant_transliteration.isEmpty
        let hasVowelTranslit = !block.vowel_transliteration.isEmpty
        let fullTranslit = (block.consonant_transliteration + (hasVowel ? block.vowel_transliteration : "")).trimmingCharacters(in: .whitespaces)
        
        return VStack(alignment: .leading, spacing: 8) {
            // Top row: Letter | Consonant | + | Vowel
            HStack(alignment: .center, spacing: 12) {
                // Full letter
                VStack(alignment: .leading, spacing: 4) {
                    Text(block.script)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(minWidth: 80, alignment: .leading)
                
                // Divider
                Divider()
                    .frame(width: 1, height: 40)
                    .background(Color.black.opacity(0.2))
                
                // Consonant (only if available)
                if hasConsonant {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(block.consonant)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(minWidth: 70, alignment: .leading)
                }
                
                // Plus sign (only if both consonant and vowel exist)
                if hasConsonant && hasVowel {
                    Text("+")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black.opacity(0.5))
                        .frame(width: 30)
                }
                
                // Vowel (only if available)
                if hasVowel {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(block.vowel)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(minWidth: 70, alignment: .leading)
                }
            }
            
            // Bottom row: [Full transliteration] | [Consonant translit] | [Vowel translit]
            HStack(alignment: .center, spacing: 12) {
                // Full transliteration
                VStack(alignment: .leading, spacing: 4) {
                    if !fullTranslit.isEmpty {
                        Text("[\(fullTranslit)]")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                    }
                }
                .frame(minWidth: 80, alignment: .leading)
                
                // Divider (only if consonant exists)
                if hasConsonant {
                    Divider()
                        .frame(width: 1, height: 30)
                        .background(Color.black.opacity(0.2))
                }
                
                // Consonant transliteration (only if available)
                if hasConsonant && hasConsonantTranslit {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("[\(block.consonant_transliteration)]")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    .frame(minWidth: 70, alignment: .leading)
                }
                
                // Spacer for plus (only if both exist)
                if hasConsonant && hasVowel {
                    Text(" ")
                        .font(.system(size: 15))
                        .foregroundColor(.clear)
                        .frame(width: 30)
                }
                
                // Vowel transliteration (only if available)
                if hasVowel && hasVowelTranslit {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("[\(block.vowel_transliteration)]")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    .frame(minWidth: 70, alignment: .leading)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func consonantView(_ block: DecompositionBlock) -> some View {
        VStack(spacing: 4) {
            if !block.consonant.isEmpty {
                Text(block.consonant)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
            } else {
                Text("—")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.black.opacity(0.3))
            }
        }
        .frame(width: 60)
    }
    
    private func vowelView(_ block: DecompositionBlock) -> some View {
        VStack(spacing: 4) {
            if block.has_vowel && !block.vowel.isEmpty {
                Text(block.vowel)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
            } else {
                Text("—")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.black.opacity(0.3))
            }
        }
        .frame(width: 60)
    }
    
    private func consonantTransliterationView(_ block: DecompositionBlock) -> some View {
        VStack(spacing: 4) {
            if !block.consonant_transliteration.isEmpty {
                Text(block.consonant_transliteration)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
            } else {
                Text("—")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.3))
            }
        }
        .frame(width: 60)
    }
    
    private func vowelTransliterationView(_ block: DecompositionBlock) -> some View {
        VStack(spacing: 4) {
            if !block.vowel_transliteration.isEmpty {
                Text(block.vowel_transliteration)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
            } else {
                Text("—")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black.opacity(0.3))
            }
        }
        .frame(width: 60)
    }
    
    // MARK: - Action Handlers
    private func handleWordBreakdownTap() {
        if showingWordDecomposition {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentDetent = .medium
            }
            showingWordDecomposition = false
            return
        }
        
        showingSimilarWords = false
        showingWordTenses = false
        
        appState.getWordDecomposition(word: item.native_text, targetWord: item.target_text) { success in
            if success {
                showingWordDecomposition = true
            }
        }
    }
    
    private func handleSimilarWordsTap() {
        if showingSimilarWords {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentDetent = .medium
            }
            showingSimilarWords = false
            return
        }
        
        showingWordTenses = false
        showingWordDecomposition = false
        
        // Send only the word, not the context
        appState.getSimilarWords(word: item.native_text) { success in
            if success {
                if let similarWords = appState.similarWordsResult {
                    similarWordsItems = similarWords.map { key, value in
                        SimilarWordItem(
                            nativeWord: key,
                            translation: value.translation,
                            transliteration: value.transliteration
                        )
                    }
                    showingSimilarWords = true
                }
            }
        }
    }
    
    private func handleWordTensesTap() {
        if showingWordTenses {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentDetent = .medium
            }
            showingWordTenses = false
            return
        }
        
        showingSimilarWords = false
        showingWordDecomposition = false
        
        // Send only the word, not the context
        appState.getWordTenses(word: item.native_text) { success in
            if success {
                if let tenses = appState.wordTensesResult {
                    // Map ALL tenses from the dictionary to WordTenseItem array
                    wordTensesItems = tenses.map { (tenseName, detail) in
                        WordTenseItem(
                            tenseName: tenseName,
                            userForm: detail.user,
                            targetTranslation: detail.target,
                            transliteration: detail.transliteration
                        )
                    }
                    print("📝 [WORD TENSES] Converted \(tenses.count) tenses to \(wordTensesItems.count) items")
                    showingWordTenses = true
                } else {
                    print("⚠️ [WORD TENSES] wordTensesResult is nil")
                }
            } else {
                print("❌ [WORD TENSES] getWordTenses failed")
            }
        }
    }
}

#Preview {
    VocabularyDetailModal(
        item: VocabularyItem(
            native_text: "order",
            target_text: "pedir",
            transliteration: "peh-DEER"
        ),
        appState: AppStateManager(),
        isImageSelected: false,
        selectedColor: AppStateManager.selectedColor
    )
}
