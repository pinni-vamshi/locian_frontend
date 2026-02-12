import SwiftUI

struct PatternBuilderView: View {
    @StateObject private var logic: PatternBuilderLogic
    @EnvironmentObject var appState: AppStateManager
    var lessonDrillLogic: LessonDrillLogic?
    
    init(state: DrillState, engine: LessonEngine, lessonDrillLogic: LessonDrillLogic? = nil) {
        _logic = StateObject(wrappedValue: PatternBuilderLogic(state: state, engine: engine, appState: nil, lessonDrillLogic: lessonDrillLogic))
        self.lessonDrillLogic = lessonDrillLogic
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. Header (FIXED at the top)
                LessonPromptHeader(
                    instruction: "BUILD THE SENTENCE",
                    prompt: logic.prompt,
                    targetLanguage: logic.targetLanguage,
                    backgroundColor: .white,
                    textColor: .black,
                    modeLabel: (lessonDrillLogic?.state.id.contains("ghost") == true) ? "GHOST REHEARSAL" : nil
                )
                
                // 2. Body (SCROLLABLE content)
                ScrollView {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 40) // Spacing from header
                    
                        VStack(spacing: 8) {
                            Text("YOUR ANSWER")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 2)
                                .padding(.trailing, 24)
                        
                        FlowLayout(data: Array(logic.selectedTokens.enumerated()), id: \.element.id, spacing: 8) { index, token in
                            Button(action: { logic.removeToken(at: index) }) {
                                Text(token.text)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(logic.checked ? logic.getWordColor(token.text, index: index) : CyberColors.neonCyan)
                                    .foregroundColor(.black)
                            }
                            .disabled(logic.checked)
                        }
                        .padding()
                        .frame(minHeight: 140, alignment: .top)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            Rectangle()
                                .frame(width: 7)
                                .foregroundColor(CyberColors.neonCyan),
                            alignment: .leading
                        )
                        // Removed horizontal padding for edge-to-edge feel
                    }
                    
                    Color.clear.frame(height: 16) // Tightened gap
                    Divider().background(Color.white.opacity(0.2)) // Edge-to-edge divider

                    
                    // Available Area / Result Area
                    if !logic.checked {
                        Color.clear.frame(height: 16)
                        VStack(spacing: 8) {
                            Text("WORD POOL")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 2)
                                .padding(.trailing, 24)
                            
                            FlowLayout(data: Array(logic.availableTokens.enumerated()), id: \.element.id, spacing: 8) { index, token in
                                Button(action: { logic.selectToken(at: index) }) {
                                    Text(token.text)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(token.isUsed ? Color.gray.opacity(0.3) : Color.white)
                                        .foregroundColor(token.isUsed ? .clear : .black)
                                }
                                .disabled(token.isUsed || logic.checked)
                            }
                            .padding()
                        }
                    } else {
                        VStack(spacing: 40) {
                            if logic.isCorrect == false { // Only show solution if WRONG
                                CorrectSolutionView(solution: logic.state.drillData.target)
                            }
                            
                            ExploreSimilarWordsSection(logic: logic)
                        }
                    }
                    
                    Color.clear.frame(height: 200) // Huge bottom spacer for scroll safety
                }
            }
            }

            
            
            // 3. Footer (STAYS FIXED)
            // ✅ Only use Wrapper (Continue) if we are in CHECK mode
            if let wrapper = lessonDrillLogic, logic.checked {
                DrillFooterWrapper(logic: wrapper)
            } else {
                // Otherwise show Local Footer (Check Button)
                footer
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            logic.appState = appState
        }
    }
    
    private var footer: some View {

        VStack(spacing: 0) {
            if logic.checked || !logic.selectedTokens.isEmpty {
                Divider().background(Color.white.opacity(0.1))
                
                Group {
                    if logic.checked {
                        let isCorrect = logic.isCorrect ?? false
                        let color: Color = isCorrect ? CyberColors.neonPink : .red
                        let title = isCorrect ? "CORRECT!" : "INCORRECT"
                        
                        CyberProceedButton(
                            action: { lessonDrillLogic?.continueToNext() },
                            label: "NEXT_STORY_STEP",
                            title: title,
                            color: color,
                            systemImage: "arrow.right",
                            isEnabled: true
                        )
                    } else {
                        CyberProceedButton(
                            action: { logic.checkAnswer() },
                            label: "READY?",
                            title: "CHECK",
                            color: CyberColors.neonCyan,
                            systemImage: "checkmark",
                            isEnabled: true
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.black)
            }
        }
    }
}

// MARK: - Local Components

fileprivate struct CorrectSolutionView: View {
    let solution: String
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CORRECT SOLUTION")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundColor(.black.opacity(0.6))
                .padding(.horizontal, 10)
                .padding(.top, 5)
            
            Text(solution)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.bottom, 5)
        }
        .background(CyberColors.neonGreen) // Pure Neon
        .cornerRadius(0) // Sharp
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

fileprivate struct ExploreSimilarWordsSection: View {
    @ObservedObject var logic: PatternBuilderLogic
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Heading with pink background
            HStack(spacing: 8) {
                Text("EXPLORE SIMILAR WORDS")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(CyberColors.neonPink)
            }
            .padding(.horizontal, 24)
            
            // Divider - 2pt thick, pink color, moved down
            Rectangle()
                .fill(CyberColors.neonPink)
                .frame(height: 2)
                .padding(.horizontal, 24)

            
            // Buttons (Top 3)
            FlowLayout(data: logic.exploreWords, id: \.word, spacing: 12) { item in
                TechWordButton(
                    word: item.word,
                    meaning: item.meaning,
                    isSelected: logic.selectedExploreWord == item.word,
                    action: { logic.selectExploreWord(item.word) }
                )
            }
            .padding(.horizontal, 24)
            
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
                            
                            Text(item.meaning)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            
                            if let example = item.example_sentence {
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
                .padding(.horizontal, 24)
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
                    
                    GridPattern()
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                }
            )
            .overlay(
                TechFrameBorder(isSelected: isSelected)
            )
        }
        .buttonStyle(.plain)
    }
}
