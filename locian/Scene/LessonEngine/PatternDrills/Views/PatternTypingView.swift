import SwiftUI

struct PatternTypingView: View {
    @StateObject private var logic: PatternTypingLogic
    @FocusState private var isFocused: Bool
    var lessonDrillLogic: LessonDrillLogic?
    
    init(state: DrillState, engine: LessonEngine, lessonDrillLogic: LessonDrillLogic? = nil) {
        _logic = StateObject(wrappedValue: PatternTypingLogic(state: state, engine: engine, lessonDrillLogic: lessonDrillLogic))
        self.lessonDrillLogic = lessonDrillLogic
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // 1. Header
                LessonPromptHeader(
                    instruction: "TYPE THE TRANSLATION",
                    prompt: logic.prompt,
                    targetLanguage: logic.targetLanguage,
                    backgroundColor: .white,
                    textColor: .black,
                    modeLabel: (lessonDrillLogic?.state.id.contains("ghost") == true) ? "GHOST REHEARSAL" : nil
                )
                
                // 2. Body
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("YOUR ANSWER")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.top, 20) // Spacing
                        
                            TypingInputArea(
                                text: $logic.userInput,
                                placeholder: "Type here...",
                                isCorrect: logic.isCorrect,
                                isDisabled: logic.isCorrect != nil
                            )
                            .focused($isFocused)
                        }
                        
                        // Show Correction if wrong
                        if let isCorrect = logic.isCorrect, !isCorrect {
                            TypingCorrectionView(
                                correctAnswer: logic.state.drillData.target,
                                phonetic: logic.state.drillData.phonetic
                            )
                        }
                        
                        // Explore Similar Words (After Check)
                        if logic.isCorrect != nil {
                            ExploreSimilarWordsSection(logic: logic)
                                .padding(.top, 24)
                        }
                    }
                    .padding(.top, 0)
                    .padding(.bottom, 120)
                }
            }
            
            // 3. Footer
            // ✅ Only use Wrapper (Continue) if we are in CHECK mode
            if let wrapper = lessonDrillLogic, logic.isCorrect != nil {
                DrillFooterWrapper(logic: wrapper)
            } else {
                // Otherwise show Local Footer (Check Button)
                footer
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear { isFocused = true }
    }
    
    private var footer: some View {
        VStack(spacing: 0) {
            if !logic.userInput.isEmpty || logic.isCorrect != nil {
                Divider().background(Color.white.opacity(0.1))
                
                Group {
                    if let isCorrect = logic.isCorrect {
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
