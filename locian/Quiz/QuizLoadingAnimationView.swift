import SwiftUI

struct QuizLoadingAnimationView: View {
    let selectedColor: Color
    
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var currentStep: Int = 0
    @State private var iconOpacity: Double = 0
    @State private var iconScale: Double = 0.5
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var brainIconScale: Double = 1.0
    @State private var folderIconScale: Double = 1.0
    @State private var wordsIconScale: Double = 1.0
    @State private var listIconScale: Double = 1.0
    @State private var puzzleIconScale: Double = 1.0
    @State private var calculatedFontSize: CGFloat = 60
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
        private var steps: [(icon: String, text: String, words: [String])] {
        [
            (
                icon: "brain.head.profile",
                text: languageManager.vocabulary.analyzingVocabulary,
                words: [languageManager.vocabulary.analyzingVocabulary, languageManager.vocabulary.your, languageManager.vocabulary.vocabulary]
            ),
            (
                icon: "folder.fill",
                text: languageManager.vocabulary.analyzingCategories,
                words: [languageManager.vocabulary.analyzingCategories, languageManager.vocabulary.interested, languageManager.vocabulary.categories]
            ),
            (
                icon: "text.word.spacing",
                text: languageManager.vocabulary.analyzingWords,
                words: [languageManager.vocabulary.analyzingWords, languageManager.vocabulary.words, languageManager.vocabulary.interested]
            ),
            (
                icon: "list.bullet.rectangle",
                text: languageManager.vocabulary.creatingQuiz,
                words: [languageManager.vocabulary.creatingQuiz, languageManager.vocabulary.quiz]
            ),
            (
                icon: "puzzlepiece.fill",
                text: languageManager.vocabulary.organizingContent,
                words: [languageManager.vocabulary.organizingContent, languageManager.vocabulary.content]
            )
        ]
    }
    
    init(selectedColor: Color = Color(red: 0.0, green: 1.0, blue: 0.5)) {
        self.selectedColor = selectedColor
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Top section - Large animation/logo
            VStack(spacing: 0) {
                Spacer()
                
                // Large icon container at top
                ZStack {
                    if currentStep == 0 {
                        brainStepView
                    } else if currentStep == 1 {
                        folderStepView
                    } else if currentStep == 2 {
                        wordsStepView
                    } else if currentStep == 3 {
                        listStepView
                    } else {
                        puzzleStepView
                    }
                }
                .frame(width: 200, height: 200)
                .opacity(iconOpacity)
                .scaleEffect(iconScale)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * 0.45)
            
            // Bottom section - Text with wrapping
            VStack(spacing: 0) {
                // Text - each word on its own line, fixed 30pt font size
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(steps[currentStep].words, id: \.self) { word in
                        Text(word)
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.white)
                            .opacity(textOpacity)
                    }
                }
                .offset(y: textOffset)
                .frame(maxWidth: .infinity, alignment: .leading)
                
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
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Step Views
    private var brainStepView: some View {
        Image(systemName: "brain.head.profile")
            .font(.system(size: 120, weight: .bold))
            .foregroundColor(selectedColor)
            .scaleEffect(brainIconScale)
    }
    
    private var folderStepView: some View {
        Image(systemName: "folder.fill")
            .font(.system(size: 120, weight: .bold))
            .foregroundColor(selectedColor)
            .scaleEffect(folderIconScale)
    }
    
    private var wordsStepView: some View {
        Image(systemName: "text.word.spacing")
            .font(.system(size: 120, weight: .bold))
            .foregroundColor(selectedColor)
            .scaleEffect(wordsIconScale)
    }
    
    private var listStepView: some View {
        Image(systemName: "list.bullet.rectangle")
            .font(.system(size: 120, weight: .bold))
            .foregroundColor(selectedColor)
            .scaleEffect(listIconScale)
    }
    
    private var puzzleStepView: some View {
        Image(systemName: "puzzlepiece.fill")
            .font(.system(size: 120, weight: .bold))
            .foregroundColor(selectedColor)
            .scaleEffect(puzzleIconScale)
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
        currentStep = 0
        animateStep(stepIndex: 0)
    }
    
    private func animateStep(stepIndex: Int) {
        currentStep = stepIndex
        
        // Reset states
        iconOpacity = 0
        iconScale = 0.5
        textOpacity = 0
        textOffset = 20
        brainIconScale = 1.0
        folderIconScale = 1.0
        wordsIconScale = 1.0
        listIconScale = 1.0
        puzzleIconScale = 1.0
        
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
        
        // Start step-specific animations
        switch stepIndex {
        case 0:
            // Brain: subtle pulse
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                brainIconScale = 1.12
            }
            
        case 1:
            // Folder: pulse
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                folderIconScale = 1.12
            }
            
        case 2:
            // Words: pulse
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                wordsIconScale = 1.12
            }
            
        case 3:
            // List: pulse
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                listIconScale = 1.12
            }
            
        case 4:
            // Puzzle: pulse
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                puzzleIconScale = 1.12
            }
            
        default:
            break
        }
        
        // Fade out and move to next step after delay
        let stepDuration: TimeInterval = 4.5  // Increased from 3.5 to 4.5 seconds (1 second more)
        
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
                let nextStep = (stepIndex + 1) % steps.count
                animateStep(stepIndex: nextStep)
            }
        }
    }
}

#Preview {
    QuizLoadingAnimationView()
        .preferredColorScheme(.dark)
}

