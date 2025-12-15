import SwiftUI

struct ImageAnalysisLoadingAnimationView: View {
    let selectedColor: Color
    
    @State private var currentStep: Int = 0
    @State private var iconOpacity: Double = 0
    @State private var iconScale: Double = 0.5
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var photoIconScale: Double = 1.0
    @State private var eyeIconScale: Double = 1.0
    @State private var brainIconScale: Double = 1.0
    @State private var calculatedFontSize: CGFloat = 60
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    let steps = [
        (
            icon: "photo.fill",
            text: "Analyzing image",
            words: ["Analyzing", "image"]
        ),
        (
            icon: "eye.fill",
            text: "Understanding scene",
            words: ["Understanding", "scene"]
        ),
        (
            icon: "brain.head.profile",
            text: "Extracting details",
            words: ["Extracting", "details"]
        )
    ]
    
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
                        photoStepView
                    } else if currentStep == 1 {
                        eyeStepView
                    } else {
                        brainStepView
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
        .toolbar(.hidden, for: .tabBar) // Hide tab bar during image loading
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Step Views
    private var photoStepView: some View {
        Image(systemName: "photo.fill")
            .font(.system(size: 120, weight: .bold))
            .foregroundColor(selectedColor)
            .scaleEffect(photoIconScale)
    }
    
    private var eyeStepView: some View {
        Image(systemName: "eye.fill")
            .font(.system(size: 120, weight: .bold))
            .foregroundColor(selectedColor)
            .scaleEffect(eyeIconScale)
    }
    
    private var brainStepView: some View {
        Image(systemName: "brain.head.profile")
            .font(.system(size: 120, weight: .bold))
            .foregroundColor(selectedColor)
            .scaleEffect(brainIconScale)
    }
    
    // MARK: - Font Size Calculation
    private func calculateFontSize() {
        let maxFontSize: CGFloat = 60
        let minFontSize: CGFloat = 30
        let availableWidth = screenWidth - 80 // Account for horizontal padding (40 * 2)
        
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
        photoIconScale = 1.0
        eyeIconScale = 1.0
        brainIconScale = 1.0
        
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
            // Photo: pulse
            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                photoIconScale = 1.15
            }
            
        case 1:
            // Eye: pulse
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                eyeIconScale = 1.12
            }
            
        case 2:
            // Brain: pulse
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                brainIconScale = 1.12
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
    ImageAnalysisLoadingAnimationView()
        .preferredColorScheme(.dark)
}

