import SwiftUI
import Combine
import NaturalLanguage

struct SentenceGenerationLoadingModal: View {
    @ObservedObject var appState: AppStateManager
    @ObservedObject var state: LearnTabState
    
    // Internal state for UI animation
    @State private var phase: Int = 0
    @State private var typingSteps: [Bool] = [false, false, false, false]
    @State private var ticks: [Bool] = [false, false, false, false]
    @State private var reveals: [Bool] = [false, false, false, false] // Place, Moment, Time, Loading Text
    @State private var statusText: String = "GENERATING"
    @State private var dotCount: Int = 0
    @State private var finalReveals: [Bool] = [false, false, false]
    @State private var animationFinished: Bool = false
    @State private var waitingForData: Bool = false
    @State private var dataReady: Bool = false
    
    // Cyberpunk Colors
    private let neonCyan = ThemeColors.primaryAccent
    private let neonPink = ThemeColors.secondaryAccent
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @State private var isTargetLoaded: Bool = false
    @State private var isNativeLoaded: Bool = false
    
    // Computed Properties for Logic
    private var activePair: LanguagePair? {
        appState.userLanguagePairs.first(where: { $0.is_default }) ?? appState.userLanguagePairs.first
    }
    
    private var targetCode: String {
        let name = activePair?.target_language ?? LocalizationManager.shared.currentLanguage.rawValue
        return AppLanguage(rawValue: name.capitalized)?.code ?? AppLanguage.fromCode(name)?.code ?? name
    }
    
    private var nativeCode: String {
        let name = activePair?.native_language ?? (!appState.nativeLanguage.isEmpty ? appState.nativeLanguage : appState.appLanguage)
        return AppLanguage(rawValue: name.capitalized)?.code ?? AppLanguage.fromCode(name)?.code ?? name
    }
    
    private var placeName: String {
        state.recommendedPlaces.first?.place_name ?? "Unknown"
    }
    
    private var moment: String {
        state.activeGeneratingMoment ?? "Analysis in Progress"
    }
    
    private var isReady: Bool {
        state.currentLesson != nil
    }
    
    private var time: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: Date())
    }
    
    private func checkModelStatus() {
        self.isTargetLoaded = NLEmbedding.sentenceEmbedding(for: NLLanguage(rawValue: targetCode)) != nil
        self.isNativeLoaded = NLEmbedding.wordEmbedding(for: NLLanguage(rawValue: nativeCode)) != nil
        
        // Trigger downloads if missing
        if !isTargetLoaded {
            EmbeddingService.downloadModel(for: targetCode) { success in
                DispatchQueue.main.async {
                    self.isTargetLoaded = NLEmbedding.sentenceEmbedding(for: NLLanguage(rawValue: targetCode)) != nil
                }
            }
        }
        
        if !isNativeLoaded {
            EmbeddingService.downloadModel(for: nativeCode) { success in
                DispatchQueue.main.async {
                    self.isNativeLoaded = NLEmbedding.wordEmbedding(for: NLLanguage(rawValue: nativeCode)) != nil
                }
            }
        }
    }

    
    private func onFinish() {
        if state.currentLesson != nil {
            withAnimation {
                state.showLessonView = true
                state.generationState = .idle
                state.activeGeneratingMoment = nil
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            GridBackground().opacity(0.1)
            
            VStack(alignment: .leading, spacing: 30) {
                // Header Diagnostics
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TypingTextView(text: "CALLING AI...", isTyping: typingSteps[0])
                        if ticks[0] { TickIcon().transition(.scale.combined(with: .opacity)) }
                    }
                    HStack {
                        TypingTextView(text: "CALLING LLM...", isTyping: typingSteps[1])
                        if ticks[1] { TickIcon().transition(.scale.combined(with: .opacity)) }
                    }
                    .opacity(phase >= 1 ? 1.0 : 0.0)
                    
                    HStack {
                        TypingTextView(text: "CHECKING NATIVE [\(nativeCode.uppercased())]...", isTyping: typingSteps[2])
                        if ticks[2] {
                            StatusIcon(isSuccess: isNativeLoaded)
                            Text(isNativeLoaded ? "[LOADED]" : "[FAILED]")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(isNativeLoaded ? neonCyan : neonPink)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .opacity(phase >= 1 ? 1.0 : 0.0)
                    
                    HStack {
                        TypingTextView(text: "CHECKING TARGET [\(targetCode.uppercased())]...", isTyping: typingSteps[3])
                        if ticks[3] {
                            StatusIcon(isSuccess: isTargetLoaded)
                            Text(isTargetLoaded ? "[LOADED]" : "[DOWNLOADING...]")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(isTargetLoaded ? neonCyan : .yellow)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .opacity(phase >= 1 ? 1.0 : 0.0)
                }
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(neonCyan)
                .frame(height: 95, alignment: .topLeading)
                
                // Synthesis Section
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 2) {
                        Text(statusText)
                        Text(String(repeating: ".", count: dotCount)).frame(width: 30, alignment: .leading)
                    }
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .foregroundColor(neonPink)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        RevealRow(label: "PLACE:", value: placeName.uppercased(), isVisible: reveals[0])
                        RevealRow(label: "MOMENT:", value: moment.uppercased(), isVisible: reveals[1])
                        RevealRow(label: "TIME:", value: time.uppercased(), isVisible: reveals[2])
                        Text("LOADING TEXT DATA...").font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray).padding(.top, 10).opacity(reveals[3] ? 1.0 : 0.0)
                    }
                }
                .opacity(phase >= 2 ? 1.0 : 0.0)
                .frame(height: 140, alignment: .topLeading)
                
                // Materialization Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("TEXT DATA RECEIVED...").font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(neonCyan)
                    Text("PREPARING YOUR LESSON").font(.system(size: 16, weight: .black, design: .monospaced)).foregroundColor(.white)
                    VStack(alignment: .leading, spacing: 15) {
                        BrickAnalysisRow(title: "CREATING EMBEDDINGS", isAnimating: finalReveals[0])
                        BrickAnalysisRow(title: "ANALYZING PATTERNS", isAnimating: finalReveals[1])
                        BrickAnalysisRow(title: "MATERIALIZING MOMENTS", isAnimating: finalReveals[2])
                    }
                }
                .opacity(phase >= 3 ? 1.0 : 0.0)
                
                Spacer()
                
                HStack {
                    Text("SYSTEM_STATUS: ")
                    Text(statusLabel).foregroundColor(statusColor)
                    Spacer()
                    Text("v4.0.2")
                }
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.gray.opacity(0.5))
            }
            .padding(30)
        }
        .onReceive(timer) { _ in if phase == 2 { dotCount = (dotCount + 1) % 4 } }
        .onAppear {
            dataReady = isReady
            checkModelStatus()
            startAnimationSequence()
        }
        .onChange(of: isReady) { _, newValue in
            dataReady = newValue
            if newValue && animationFinished {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { onFinish() }
            }
            if newValue && waitingForData { transitionToPhase3() }
        }
    }
    
    private var statusLabel: String { (phase == 3 && animationFinished) ? (isReady ? "READY" : "WAITING_FOR_SERVER") : "PROCESSING" }
    private var statusColor: Color { (phase == 3 && animationFinished) ? (isReady ? neonCyan : .yellow) : neonPink }
    
    private func startAnimationSequence() {
        typingSteps[0] = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            ticks[0] = true; phase = 1; typingSteps[1] = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                ticks[1] = true; typingSteps[2] = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    ticks[2] = true; typingSteps[3] = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        ticks[3] = true; phase = 2; revealNextData(index: 0)
                    }
                }
            }
        }
    }
    
    private func revealNextData(index: Int) {
        let delayTime = dataReady ? 0.3 : 3.0
        let revealTimes = [0.0, delayTime, delayTime, delayTime]
        guard index < reveals.count else {
            if dataReady { transitionToPhase3() } else { waitingForData = true }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + revealTimes[index]) {
            withAnimation(.easeOut(duration: 0.5)) { reveals[index] = true }
            revealNextData(index: index + 1)
        }
    }
    
    private func startFinalPhase() {
        for i in 0..<finalReveals.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.0) {
                withAnimation { finalReveals[i] = true }
                if i == finalReveals.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        animationFinished = true
                        if dataReady { onFinish() }
                    }
                }
            }
        }
    }
    
    private func transitionToPhase3() {
        waitingForData = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring()) { phase = 3; statusText = "SYNTHESIZED"; dotCount = 0 }
            startFinalPhase()
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

struct TypingTextView: View {
    let text: String
    let isTyping: Bool
    @State private var displayedText: String = ""
    var body: some View {
        ZStack(alignment: .leading) {
            Text(text).opacity(0)
            Text(displayedText)
        }
        .onChange(of: isTyping) { _, newValue in if newValue { typeOut() } }
    }
    private func typeOut() {
        displayedText = ""
        for (index, character) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) { displayedText.append(character) }
        }
    }
}

struct TickIcon: View {
    var body: some View {
        Image(systemName: "checkmark").font(.system(size: 12, weight: .black)).foregroundColor(Color(red: 0, green: 1, blue: 0.5))
    }
}

struct StatusIcon: View {
    let isSuccess: Bool
    var body: some View {
        Image(systemName: isSuccess ? "checkmark" : "xmark").font(.system(size: 12, weight: .black))
            .foregroundColor(isSuccess ? Color(red: 0, green: 1, blue: 0.5) : Color.red)
    }
}

struct RevealRow: View {
    let label: String; let value: String; let isVisible: Bool
    var body: some View {
        HStack(spacing: 10) {
            Text(label).font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.gray)
            TypingTextView(text: value, isTyping: isVisible).font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(.white)
        }
        .frame(height: 15, alignment: .leading)
    }
}

struct BrickAnalysisRow: View {
    let title: String; let isAnimating: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.gray.opacity(0.8))
            HStack(spacing: 4) { ForEach(0..<9) { i in BrickView(isAnimating: isAnimating, index: i) } }
        }
        .opacity(isAnimating ? 1.0 : 0.2)
        .animation(.easeIn(duration: 0.3), value: isAnimating)
    }
}

struct BrickView: View {
    let isAnimating: Bool; let index: Int
    @State private var opacity: Double = 0.1
    var body: some View {
        Rectangle().fill(Color(red: 0, green: 1, blue: 1)).frame(width: 12, height: 12)
            .opacity(isAnimating ? opacity : 0.05)
            .onAppear { if isAnimating { startAnimation() } }
            .onChange(of: isAnimating) { _, newVal in if newVal { startAnimation() } }
    }
    private func startAnimation() {
        let duration = Double.random(in: 0.4...0.8); let delay = Double(index) * 0.1
        withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true).delay(delay)) { opacity = Double.random(in: 0.4...1.0) }
    }
}
