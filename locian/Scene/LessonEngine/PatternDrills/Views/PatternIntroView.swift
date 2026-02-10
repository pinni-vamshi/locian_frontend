import SwiftUI

/// A lightweight Pattern Intro View that doesn't need a heavy Logic file.
/// Used for the "Recap" phase of a pattern.
struct PatternIntroView: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    @ObservedObject var logic: PatternIntroLogic
    
    @State private var isHintExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header (Pattern Context)
            LessonPromptHeader(
                instruction: "PATTERN RECAP",
                prompt: drill.drillData.meaning,
                targetLanguage: TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english,
                hintText: "REVEAL TARGET",
                meaningText: drill.drillData.target,
                contextSentence: nil,
                isHintExpanded: $isHintExpanded,
                backgroundColor: .white,
                textColor: .black
            )
            
            // 2. Dynamic Horizontal Selector (Meanings/L1)
            if !logic.brickDrills.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(logic.brickDrills.enumerated()), id: \.offset) { index, brickState in
                                    let isActive = logic.currentBrickIndex == index
                                    let meaning = brickState.drillData.meaning
                                    
                                    Text(meaning)
                                        .font(.system(size: 14, weight: .black, design: .monospaced))
                                        .foregroundColor(isActive ? .black : .white.opacity(0.4))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(isActive ? CyberColors.neonCyan : Color.white.opacity(0.05))
                                        .overlay(
                                            Rectangle()
                                                .stroke(isActive ? Color.white : Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                        .id(index)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .onChange(of: logic.currentBrickIndex) { _, newIndex in
                            withAnimation {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
                .background(Color.black)
            }
            
            // 3. Dynamic Interaction Zone (L2 Focus)
            ScrollView {
                VStack(spacing: 0) {
                    if let brickState = logic.currentDrill {
                        // Using the specialized interaction dispatcher
                        // This will show MCQ, Typing, or Voice based on the pre-resolved mode
                        BrickModeSelector.interactionView(
                            for: brickState, 
                            engine: engine, 
                            showPrompt: false,
                            onComplete: { logic.advance() }
                        )
                        .id("brick-interaction-\(brickState.id)")
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                              removal: .move(edge: .leading).combined(with: .opacity)))
                    }
                }
                .padding(.bottom, 100)
            }
            
            // 4. Footer Logic
            footer
        }
        .background(Color.black.ignoresSafeArea())
        // .onChange(of: engine.lastAnswerCorrect) { ... } Removed deprecated logic
    }
    
    private var footer: some View {
        VStack(spacing: 0) {
            // TODO: Refactor Footer to not use deprecated engine.lastAnswerCorrect
            /*
            if let isCorrect = engine.lastAnswerCorrect {
                Divider().background(Color.white.opacity(0.1))
                
                let color: Color = isCorrect ? CyberColors.neonPink : .red
                let title = isCorrect ? "CORRECT!" : "INCORRECT"
                
                CyberProceedButton(
                    action: { 
                        logic.advance()
                        engine.lastAnswerCorrect = nil
                    },
                    label: "NEXT_COMPONENT",
                    title: title,
                    color: color,
                    systemImage: "arrow.right",
                    isEnabled: true
                )
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.black)
            }
            */
        }
    }
}
