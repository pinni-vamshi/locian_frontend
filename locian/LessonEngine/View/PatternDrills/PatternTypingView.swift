import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: - PatternTypingView (self-contained — logic feeds data in)
// ─────────────────────────────────────────────────────────────

struct PatternTypingView: View {
    @StateObject private var logic: PatternTypingLogic
    @EnvironmentObject var appState: AppStateManager
    @FocusState private var isFocused: Bool
    @Environment(\.compactDrillZone) private var compactDrillZone
    var onComplete: ((Bool) -> Void)?
    
    init(
        state: DrillState, 
        engine: LessonEngine, 
        practiceLogic: PatternPracticeLogic? = nil, 
        ghostLogic: GhostModeLogic? = nil, 
        onComplete: ((Bool) -> Void)? = nil
    ) {
        let logic = PatternTypingLogic(
            state: state, 
            engine: engine, 
            onComplete: onComplete
        )
        logic.practiceLogic = practiceLogic
        logic.ghostLogic = ghostLogic
        _logic = StateObject(wrappedValue: logic)
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. Header
                if !compactDrillZone {
                    patternTypingHeader
                        .diagnosticBorder(.orange)
                }
                
                // 2. Body
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            patternTypingInputArea
                                .focused($isFocused)
                                .diagnosticBorder(.cyan)
                        }
                        .diagnosticBorder(.green)
                        
                        // Show Correction if wrong
                        if let isCorrect = logic.isCorrect, !isCorrect {
                            patternTypingCorrectionView
                                .diagnosticBorder(.green)
                        }
                        
                        // Explore Similar Words (After Check)
                        if logic.isCorrect != nil {
                            ExploreSimilarWordsSection(logic: logic)
                                .padding(.top, 24)
                                .diagnosticBorder(.green)
                        }
                    }
                    .padding(.top, compactDrillZone ? 26 : 0)
                    .padding(.bottom, 120)
                    .diagnosticBorder(.yellow)
                }
                .diagnosticBorder(.orange)
            }
            .diagnosticBorder(.red)
            
            // 3. Footer (Suppressed when hosted by an orchestrator)
            patternTypingFooter
                .diagnosticBorder(.orange)

        }
        .background(compactDrillZone ? Color.clear : Color.black)
        .onAppear {
            isFocused = true
            logic.appState = appState
        }
        .diagnosticBorder(.red)
    }

    // ── Header ─────────────────────────────────────────────────
    private var patternTypingHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                // Mode Label (Ghost Mode)
                if logic.state.id.contains("ghost") == true {
                    Text("GHOST REHEARSAL")
                        .font(.caption2)
                        .tracking(2)
                        .foregroundColor(CyberColors.neonPink)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black)
                        .overlay(Rectangle().stroke(CyberColors.neonPink, lineWidth: 1))
                        .padding(.bottom, 4)
                }
                
                // 1. PROGRESS with circles and Mastery
                HStack(spacing: 8) {
                    Text("PROGRESS")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                        .tracking(1.0)
                    
                    PatternProgressRow(
                        patterns: logic.engine.rawPatterns.map { $0.id },
                        currentPatternId: logic.state.patternId,
                        engine: logic.engine
                    )
                    
                    Text(String(format: "%.0f%% Mastery", logic.engine.getBlendedMastery(for: logic.state.patternId) * 100))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.leading, 4)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(CyberColors.neonCyan)
                
                // 2. Main prompt (Meaning text usually, as user types target)
                Text(logic.prompt)
                    .font(.system(size: 38, weight: .black))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                
                // 3. TARGET Metadata
                let target = logic.targetLanguage
                if !target.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "character.bubble.fill")
                            .font(.system(size: 14))
                            .foregroundColor(CyberColors.textGray)
                        Text("TARGET: \(target.uppercased())")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(CyberColors.textGray)
                            .tracking(1)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.leading, 24)
            .overlay(
                ZStack(alignment: .topLeading) {
                    Rectangle().fill(Color.white).frame(width: 4).offset(x: 1, y: 1)
                    Rectangle().fill(CyberColors.neonPink).frame(width: 4)
                }
                .fixedSize(horizontal: true, vertical: false),
                alignment: .leading
            )
            Spacer()
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // ── Input Area ──────────────────────────────────────────────
    private var patternTypingInputArea: some View {
        let bgColor: Color = {
            if let correct = logic.isCorrect { return correct ? Color.green : Color.red }
            return Color.gray.opacity(0.2)
        }()
        
        return TextField("Type here...", text: $logic.userInput)
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .multilineTextAlignment(.leading)
            .foregroundColor(.white)
            .padding(12)
            .frame(height: 56)
            .background(bgColor)
            .overlay(
                Rectangle()
                    .frame(width: 7)
                    .foregroundColor(CyberColors.neonCyan),
                alignment: .leading
            )
            .disabled(logic.isCorrect != nil)
            .padding(.leading, 5) // To accommodate the left bar visually
            .padding(.trailing, 20)
            .padding(.horizontal, 24)
    }

    // ── Correction View ─────────────────────────────────────────
    private var patternTypingCorrectionView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("CORRECT SOLUTION")
                .font(.caption)
                .tracking(1)
                .foregroundColor(.gray)
                .padding(.leading, 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(logic.state.drillData.target)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
                
                if let ph = logic.state.drillData.phonetic, !ph.isEmpty {
                    Text(ph)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.black.opacity(0.5))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(CyberColors.neonGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    // ── Footer ──────────────────────────────────────────────────
    private var patternTypingFooter: some View {
        VStack(spacing: 0) {
            if !logic.userInput.isEmpty || logic.isCorrect != nil {
                VStack(spacing: 0) {
                    if let isCorrect = logic.isCorrect {
                        Divider().background(Color.white.opacity(0.1))
                        let color: Color = isCorrect ? CyberColors.success : .red
                        let title = isCorrect ? "CORRECT!" : "INCORRECT"
                        
                        CyberProceedButton(
                            action: { logic.continueToNext() },
                            label: "NEXT_STORY_STEP",
                            title: title,
                            color: color,
                            systemImage: "arrow.right",
                            isEnabled: true
                        )
                    } else {
                        Divider().background(Color.white.opacity(0.1))
                        
                        CyberProceedButton(
                            action: { logic.checkAnswer() },
                            label: "READY?",
                            title: "CHECK",
                            color: CyberColors.neonCyan,
                            systemImage: "checkmark",
                            isEnabled: !logic.userInput.isEmpty
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 20)
                .background(Color.black)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Local Components (Inlined decorations & sections)
// ─────────────────────────────────────────────────────────────

fileprivate struct ExploreSimilarWordsSection: View {
    @ObservedObject var logic: PatternTypingLogic
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Heading with pink background
            Text("EXPLORE SIMILAR WORDS")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(CyberColors.neonPink)
            
            // Buttons (Top 3)
            FlowLayout(data: logic.exploreWords, id: \.word, spacing: 12) { item in
                TechWordButton(
                    word: item.word,
                    meaning: item.meaning,
                    isSelected: logic.selectedExploreWord == item.word,
                    action: { logic.selectExploreWord(item.word) }
                )
            }
            
            // Search Results
            if logic.isSearching {
                ProgressView()
                .tint(CyberColors.neonCyan)
                .frame(maxWidth: .infinity)
                .padding()
            } else if !logic.searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(logic.searchResults) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.word.uppercased())
                                    .font(.system(size: 14, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                                
                                if let pron = item.pronunciation {
                                    Text("[\(pron)]")
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Text(item.translation)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            
                            if let example = item.explanation {
                                Text(example)
                                    .font(.system(size: 12, weight: .regular, design: .serif).italic())
                                    .foregroundColor(CyberColors.neonPink)
                                    .padding(.top, 2)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            Rectangle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
}

fileprivate struct TechWordButton: View {
    let word: String
    let meaning: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(word.uppercased())
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundColor(isSelected ? .black : .white)
                
                Text(meaning.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? .black.opacity(0.7) : CyberColors.neonCyan.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        CyberColors.neonPink
                    } else {
                        Color.black.opacity(0.6)
                    }
                    
                    GridPatternDecoration() // Inlined from CyberComponents
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                }
            )
            .overlay(
                TechFrameBorderDecoration(isSelected: isSelected) // Inlined
            )
        }
        .buttonStyle(.plain)
    }
}

// Inlined GridPattern for background decorations
fileprivate struct GridPatternDecoration: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 8
        for x in stride(from: 0, through: rect.maxX, by: step) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
        }
        for y in stride(from: 0, through: rect.maxY, by: step) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        return path
    }
}

// Inlined TechFrameBorder
fileprivate struct TechFrameBorderDecoration: View {
    let isSelected: Bool
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(isSelected ? .black : Color.white.opacity(0.3), lineWidth: 1)
            
            // Corner brackets
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let len: CGFloat = 6
                let color = isSelected ? Color.black : CyberColors.neonCyan
                
                Path { p in
                    // Top Left
                    p.move(to: CGPoint(x: 0, y: len))
                    p.addLine(to: CGPoint(x: 0, y: 0))
                    p.addLine(to: CGPoint(x: len, y: 0))
                    
                    // Top Right
                    p.move(to: CGPoint(x: w - len, y: 0))
                    p.addLine(to: CGPoint(x: w, y: 0))
                    p.addLine(to: CGPoint(x: w, y: len))
                    
                    // Bottom Right
                    p.move(to: CGPoint(x: w, y: h - len))
                    p.addLine(to: CGPoint(x: w, y: h))
                    p.addLine(to: CGPoint(x: w - len, y: h))
                    
                    // Bottom Left
                    p.move(to: CGPoint(x: len, y: h))
                    p.addLine(to: CGPoint(x: 0, y: h))
                    p.addLine(to: CGPoint(x: 0, y: h - len))
                }
                .stroke(color, lineWidth: 2)
            }
        }
    }
}
