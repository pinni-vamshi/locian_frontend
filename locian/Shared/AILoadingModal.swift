import SwiftUI
import Combine

struct AILoadingModal: View {
    // Dynamic Data
    let placeName: String
    let moment: String
    let time: String
    // NEW: Real Neural Status
    let targetLangCode: String
    let isTargetLoaded: Bool
    let isNativeLoaded: Bool
    let isReady: Bool // External signal that data is ready
    var onFinish: () -> Void = {}
    
    @State private var phase: Int = 0
    // Updated Steps: AI, LLM, Native Check, Target Check
    @State private var typingSteps: [Bool] = [false, false, false, false]
    @State private var ticks: [Bool] = [false, false, false, false]
    @State private var reveals: [Bool] = [false, false, false, false] // Place, Moment, Time, Loading Text
    @State private var statusText: String = "GENERATING"
    @State private var dotCount: Int = 0
    @State private var finalReveals: [Bool] = [false, false, false] // Embeddings, Patterns, Moments
    @State private var animationFinished: Bool = false // New flag to track animation completion
    @State private var waitingForData: Bool = false // Flag to pause animation until API responds
    
    // Cyberpunk Colors
    // Cyberpunk Colors (Now using Global Theme)
    private let neonCyan = ThemeColors.primaryAccent
    private let neonPink = ThemeColors.secondaryAccent
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Background Grid Effect
            GridBackground()
                .opacity(0.1)
            
            VStack(alignment: .leading, spacing: 30) {
// ... (skip down to startAnimationSequence) ...


                // Header Section - Fixed height to prevent LLM line from pushing synthesis down
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TypingTextView(text: "CALLING AI...", isTyping: typingSteps[0])
                        if ticks[0] {
                            TickIcon()
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    HStack {
                        TypingTextView(text: "CALLING LLM...", isTyping: typingSteps[1])
                        if ticks[1] {
                            TickIcon()
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .opacity(phase >= 1 ? 1.0 : 0.0)
                    
                    // NEW: Native Engine Check
                    HStack {
                        TypingTextView(text: "CHECKING NATIVE [EN]...", isTyping: typingSteps[2])
                        if ticks[2] {
                            StatusIcon(isSuccess: isNativeLoaded)
                            Text(isNativeLoaded ? "[LOADED]" : "[FAILED]")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(isNativeLoaded ? neonCyan : neonPink)
                                .padding(.leading, 4)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .opacity(phase >= 1 ? 1.0 : 0.0)
                    
                    // NEW: Target Engine Check
                    HStack {
                        TypingTextView(text: "CHECKING TARGET [\(targetLangCode)]...", isTyping: typingSteps[3])
                        if ticks[3] {
                            StatusIcon(isSuccess: isTargetLoaded)
                            Text(isTargetLoaded ? "[LOADED]" : "[DOWNLOADING...]")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(isTargetLoaded ? neonCyan : .yellow)
                                .padding(.leading, 4)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .opacity(phase >= 1 ? 1.0 : 0.0)
                }
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(neonCyan)
                .frame(height: 95, alignment: .topLeading) // Increased height for new lines
                
                // Synthesis Section - Fixed container to prevent Materialization from jumping
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 2) {
                        Text(statusText)
                        Text(String(repeating: ".", count: dotCount))
                            .frame(width: 30, alignment: .leading)
                    }
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .foregroundColor(neonPink)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        RevealRow(label: "PLACE:", value: placeName.uppercased(), isVisible: reveals[0])
                        RevealRow(label: "MOMENT:", value: moment.uppercased(), isVisible: reveals[1])
                        RevealRow(label: "TIME:", value: time.uppercased(), isVisible: reveals[2])
                        
                        // Reserve space for loading text data
                        Text("LOADING TEXT DATA...")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                            .opacity(reveals[3] ? 1.0 : 0.0)
                    }
                }
                .opacity(phase >= 2 ? 1.0 : 0.0)
                .frame(height: 140, alignment: .topLeading) // Stable synthesis area
                
                // Materialization Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("TEXT DATA RECEIVED...")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(neonCyan)
                    
                    Text("PREPARING YOUR LESSON")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        BrickAnalysisRow(title: "CREATING EMBEDDINGS", isAnimating: finalReveals[0])
                        BrickAnalysisRow(title: "ANALYZING PATTERNS", isAnimating: finalReveals[1])
                        BrickAnalysisRow(title: "MATERIALIZING MOMENTS", isAnimating: finalReveals[2])
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .opacity(phase >= 3 ? 1.0 : 0.0)
                
                Spacer()
                
                // Bottom Status
                HStack {
                    Text("SYSTEM_STATUS: ")
                    // Status depends on both animation and data readiness
                    Text(statusLabel)
                        .foregroundColor(statusColor)
                    Spacer()
                    Text("v4.0.2")
                }
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.gray.opacity(0.5))
            }
            .padding(30)
        }
        .onReceive(timer) { _ in
            if phase == 2 {
                dotCount = (dotCount + 1) % 4
            }
        }
        .onAppear {
            // SYNC STATE: Ensure we capture initial readiness
            dataReady = isReady
            startAnimationSequence()
        }
        // WATCHER: If data becomes ready AFTER animation finished, trigger finish
        .onChange(of: isReady) { oldValue, newValue in
            // SYNC STATE: Keep local state updated for closures
            dataReady = newValue
            
            // Case 1: Animation finished long ago, just waiting for data
            if newValue && animationFinished {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onFinish()
                }
            }
            // Case 2: Animation paused at Phase 2, waiting for data
            if newValue && waitingForData {
                transitionToPhase3()
            }
        }
    }
    
    private var statusLabel: String {
        if phase == 3 && animationFinished {
            return isReady ? "READY" : "WAITING_FOR_SERVER"
        }
        return "PROCESSING"
    }
    
    private var statusColor: Color {
        if phase == 3 && animationFinished {
            return isReady ? neonCyan : .yellow
        }
        return neonPink
    }
    
    private func startAnimationSequence() {
        // Step 1: Calling AI
        typingSteps[0] = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            ticks[0] = true
            phase = 1
            
            // Step 2: Calling LLM
            typingSteps[1] = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                ticks[1] = true
                
                // Step 3: Checking Native Engine (EN)
                typingSteps[2] = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    ticks[2] = true
                    
                    // Step 4: Checking Target Engine (Dynamic)
                    typingSteps[3] = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        ticks[3] = true
                        phase = 2 // Move to Phase 2
                        revealNextData(index: 0)
                    }
                }
            }
        }
    }
    
// ... (SKIP TO BODY)
    
    // State to hold valid data status accessiable inside closures
    @State private var dataReady: Bool = false
    
    private func revealNextData(index: Int) {
        // FAST FORWARD LOGIC: If data is ready, speed up the animation significantly
        // This solves the issue where users wait 9 seconds even if API returns instantly
        let delayTime = dataReady ? 0.3 : 3.0
        
        let revealTimes = [0.0, delayTime, delayTime, delayTime]
        
        guard index < reveals.count else {
            // End of Phase 2, Start Phase 3
            // CRITICAL FIX: Check local state `dataReady` instead of captured `isReady`
            if dataReady {
                transitionToPhase3()
            } else {
                print("⏳ [UI] Animation Phase 2 complete. Waiting for API data...")
                waitingForData = true
            }
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + revealTimes[index]) {
            withAnimation(.easeOut(duration: 0.5)) {
                reveals[index] = true
            }
            revealNextData(index: index + 1)
        }
    }
    
    private func startFinalPhase() {
        for i in 0..<finalReveals.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.0) {
                withAnimation {
                    finalReveals[i] = true
                }
                
                // If it's the last one, mark animation as finished
                if i == finalReveals.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        animationFinished = true
                        // Only finish if data is ready
                        if dataReady {
                            onFinish()
                        }
                    }
                }
            }
        }
    }
    private func transitionToPhase3() {
        print("🚀 [UI] API Data Ready. Starting Phase 3 (Materialization)...")
        waitingForData = false // Reset flag
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring()) {
                phase = 3
                statusText = "SYNTHESIZED"
                dotCount = 0
            }
            startFinalPhase()
        }
    }
}

// MARK: - Subviews

struct TypingTextView: View {
    let text: String
    let isTyping: Bool
    @State private var displayedText: String = ""
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Invisible placeholder to reserve space and prevent layout shifts
            Text(text)
                .opacity(0)
            
            Text(displayedText)
        }
        .onChange(of: isTyping) { oldValue, newValue in
            if newValue {
                typeOut()
            }
        }
    }
    
    private func typeOut() {
        // Reset if starting
        displayedText = ""
        for (index, character) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                displayedText.append(character)
            }
        }
    }
}

struct TickIcon: View {
    var body: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 12, weight: .black))
            .foregroundColor(Color(red: 0, green: 1, blue: 0.5))
    }
}

struct StatusIcon: View {
    let isSuccess: Bool
    
    var body: some View {
        Image(systemName: isSuccess ? "checkmark" : "xmark")
            .font(.system(size: 12, weight: .black))
            .foregroundColor(isSuccess ? Color(red: 0, green: 1, blue: 0.5) : Color.red)
    }
}

struct RevealRow: View {
    let label: String
    let value: String
    let isVisible: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            
            // USER REQUEST: TYPEWRITER ANIMATION (One by one letter)
            // Replaced sliding transition with TypingTextView
            TypingTextView(text: value, isTyping: isVisible)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .frame(height: 15, alignment: .leading)
    }
}

struct BrickAnalysisRow: View {
    let title: String
    let isAnimating: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.gray.opacity(0.8))
            
            HStack(spacing: 4) {
                ForEach(0..<9) { i in
                    BrickView(isAnimating: isAnimating, index: i)
                }
            }
        }
        .opacity(isAnimating ? 1.0 : 0.2)
        .animation(.easeIn(duration: 0.3), value: isAnimating)
    }
}

struct BrickView: View {
    let isAnimating: Bool
    let index: Int
    @State private var opacity: Double = 0.1
    
    var body: some View {
        Rectangle()
            .fill(Color(red: 0, green: 1, blue: 1))
            .frame(width: 12, height: 12)
            .opacity(isAnimating ? opacity : 0.05)
            .onChange(of: isAnimating) { oldValue, newValue in
                if newValue {
                    startAnimation()
                }
            }
            .onAppear {
                if isAnimating {
                    startAnimation()
                }
            }
    }
    
    private func startAnimation() {
        // Individual random delay and duration for organic cyber effect
        let duration = Double.random(in: 0.4...0.8)
        let delay = Double(index) * 0.1
        
        withAnimation(
            .easeInOut(duration: duration)
            .repeatForever(autoreverses: true)
            .delay(delay)
        ) {
            opacity = Double.random(in: 0.4...1.0)
        }
    }
}

struct GridBackground: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                for i in stride(from: 0, to: geo.size.width, by: 30) {
                    path.move(to: CGPoint(x: i, y: 0))
                    path.addLine(to: CGPoint(x: i, y: geo.size.height))
                }
                for i in stride(from: 0, to: geo.size.height, by: 30) {
                    path.move(to: CGPoint(x: 0, y: i))
                    path.addLine(to: CGPoint(x: geo.size.width, y: i))
                }
            }
            .stroke(Color.cyan, lineWidth: 0.5)
        }
    }
}

#Preview {
    AILoadingModal(
        placeName: "CYBER_CAFE_XR",
        moment: "ORDER_COFFEE_V1",
        time: "19:45:06_UTC",
        targetLangCode: "ES",
        isTargetLoaded: true,
        isNativeLoaded: true,
        isReady: true
    )
}
