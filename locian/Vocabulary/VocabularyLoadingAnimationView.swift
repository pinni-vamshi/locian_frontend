import SwiftUI

struct VocabularyLoadingAnimationView: View {
    let request: VocabularyRequest?
    let selectedColor: Color
    
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var currentStep: Int = 0
    @State private var iconOpacity: Double = 0
    @State private var iconScale: Double = 0.5
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var iconPulseScale: Double = 1.0
    @State private var calculatedFontSize: CGFloat = 60
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    // Dynamic steps based on request parameters
    private var steps: [(icon: String, words: [String])] {
        var stepsList: [(icon: String, words: [String])] = []
        
        // Step 1: Languages (if both present)
        if let userLang = request?.user_language, let targetLang = request?.target_language {
            // Get language codes/abbreviations for compact display (e.g., "English" -> "eng", "Japanese" -> "jap")
            let userLangShort = getLanguageShortCode(userLang)
            let targetLangShort = getLanguageShortCode(targetLang)
            let languagePair = "\(userLangShort) → \(targetLangShort)"
            stepsList.append((
                icon: "globe",
                words: [languageManager.vocabulary.adjustingTo, languageManager.vocabulary.to, languagePair]
            ))
        }
        
        // Step 2: Place name (if present)
        if let sceneName = request?.place_name, !sceneName.isEmpty {
            // Truncate long place names for display
            let displayPlace = sceneName.count > 20 ? String(sceneName.prefix(20)) + "..." : sceneName
            stepsList.append((
                icon: "mappin.circle.fill",
                words: [languageManager.vocabulary.settingPlace, languageManager.vocabulary.place, displayPlace]
            ))
        }
        
        // Step 3: Time (if present)
        if let time = request?.time, !time.isEmpty {
            stepsList.append((
                icon: "clock.fill",
                words: [languageManager.vocabulary.settingTime, languageManager.vocabulary.time, time]
            ))
        }
        
        // Final step: Generating vocabulary
        stepsList.append((
            icon: "brain.head.profile",
            words: [languageManager.vocabulary.generatingVocabulary, languageManager.vocabulary.vocabulary]
        ))
        
        // Fallback if no parameters
        if stepsList.isEmpty {
            stepsList.append((
                icon: "brain.head.profile",
                words: [languageManager.vocabulary.generatingVocabulary, languageManager.vocabulary.vocabulary]
            ))
        }
        
        return stepsList
    }
    
    init(request: VocabularyRequest? = nil, selectedColor: Color = Color(red: 0.0, green: 1.0, blue: 0.5)) {
        self.request = request
        self.selectedColor = selectedColor
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Top section - Large animation/logo
            VStack(spacing: 0) {
                Spacer()
                
                // Large icon container at top
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 120, weight: .bold))
                    .foregroundColor(selectedColor)
                    .opacity(iconOpacity)
                    .scaleEffect(iconScale * iconPulseScale)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * 0.45)
            
            // Bottom section - Text with wrapping
            VStack(spacing: 0) {
                // Text - each word on its own line, fixed 30pt font size
                VStack(alignment: .center, spacing: 15) {
                    ForEach(steps[currentStep].words, id: \.self) { word in
                        Text(word)
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.white)
                            .opacity(textOpacity)
                    }
                }
                .offset(y: textOffset)
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * 0.55)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
        .gesture(DragGesture(minimumDistance: 0)) // Block all swipe gestures
        .navigationBarBackButtonHidden(true) // Hide back button if in navigation
        .toolbar(.hidden, for: .tabBar) // Hide tab bar during loading
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Helper Functions
    private func getLanguageShortCode(_ language: String) -> String {
        // Convert full language names to short codes for compact display
        let mapping: [String: String] = [
            "English": "eng",
            "Spanish": "esp",
            "French": "fra",
            "German": "deu",
            "Italian": "ita",
            "Portuguese": "por",
            "Russian": "rus",
            "Japanese": "jap",
            "Korean": "kor",
            "Chinese": "chi",
            "Arabic": "ara",
            "Hindi": "hin",
            "Turkish": "tur",
            "Dutch": "nld",
            "Swedish": "swe"
        ]
        
        // Check if it's already a short code or return first 3 letters
        if mapping.values.contains(language.lowercased()) {
            return language.lowercased()
        }
        
        return mapping[language] ?? String(language.prefix(3)).lowercased()
    }
    
    // MARK: - Font Size Calculation
    private func calculateFontSize() {
        let maxFontSize: CGFloat = 60
        let minFontSize: CGFloat = 30
        let availableWidth = screenWidth // No padding - use full width
        
        // Find the minimum font size that fits all words
        var minFittingSize: CGFloat = maxFontSize
        
        for word in steps[currentStep].words {
            var fontSize: CGFloat = maxFontSize
            
            // Binary search for the largest font size that fits
            while fontSize >= minFontSize {
                let font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
                let attributes = [NSAttributedString.Key.font: font]
                let size = (word as NSString).size(withAttributes: attributes)
                
                if size.width <= availableWidth {
                    minFittingSize = min(minFittingSize, fontSize)
                    break
                } else {
                    fontSize -= 5 // Decrement by 5pt steps
                }
            }
        }
        
        // Use the minimum size for all words (so they all have same size)
        calculatedFontSize = minFittingSize
    }
    
    // MARK: - Animation Functions
    private func startAnimation() {
        guard !steps.isEmpty else { return }
        currentStep = 0
        animateStep(stepIndex: 0)
    }
    
    private func animateStep(stepIndex: Int) {
        guard stepIndex < steps.count else { return }
        
        currentStep = stepIndex
        
        // Reset states
        iconOpacity = 0
        iconScale = 0.5
        textOpacity = 0
        textOffset = 20
        iconPulseScale = 1.0
        
        // Fade in icon with pop animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            iconOpacity = 1.0
            iconScale = 1.0
        }
        
        // Text fades in after icon
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                textOpacity = 1.0
                textOffset = 0
            }
        }
        
        // Start step-specific animation (pulse)
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            iconPulseScale = 1.12
        }
        
        // Fade out and move to next step after delay
        // Check if this is the "Generating vocabulary" step (last step with brain icon)
        let isGeneratingVocabularyStep = stepIndex == steps.count - 1 || 
                                         (steps[stepIndex].icon == "brain.head.profile" && 
                                          steps[stepIndex].words.contains(languageManager.vocabulary.generatingVocabulary))
        let stepDuration: TimeInterval = isGeneratingVocabularyStep ? 5.0 : 4.5  // 5 seconds for "Generating vocabulary", 4.5 for others
        
        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
            // Fade out current step
            withAnimation(.easeOut(duration: 0.4)) {
                iconOpacity = 0
                iconScale = 0.8
                textOpacity = 0
                textOffset = -20
            }
            
            // Move to next step after fade out completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let nextStep = stepIndex + 1
                if nextStep < steps.count {
                    animateStep(stepIndex: nextStep)
                } else {
                    // Loop back to start if still generating
                    animateStep(stepIndex: 0)
                }
            }
        }
    }
}

#Preview {
    VocabularyLoadingAnimationView(
        request: VocabularyRequest(
            user_language: "English",
            target_language: "Hindi",
            place_name: "Restaurant",
            place_detail: nil,
            time: "Wednesday, November 19, 2:28 PM",
            profession: "student",
            user_name: "John",
            user_level: "INTERMEDIATE",
            previous_places: nil,
            future_places: nil,
            latitude: nil,
            longitude: nil,
            date: nil
        )
    )
    .preferredColorScheme(.dark)
}
