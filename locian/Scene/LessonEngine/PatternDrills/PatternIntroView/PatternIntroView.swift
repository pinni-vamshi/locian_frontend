import SwiftUI

/// A lightweight Pattern Intro View that doesn't need a heavy Logic file.
/// Used for the "Recap" phase of a pattern.
struct PatternIntroView: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    @ObservedObject var logic: PatternIntroLogic
    
    @State private var isHintExpanded: Bool = false
    @State private var isBrickAnswered: Bool = false
    @State private var lastBrickResult: Bool?  // true = correct, false = incorrect
    
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
                            // Reset answer state when brick changes
                            isBrickAnswered = false
                            lastBrickResult = nil
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
                        // Create brick interaction with patternIntroLogic reference
                        let mode = brickState.currentMode ?? BrickModeSelector.resolveMode(for: brickState, engine: engine)
                        
                        switch mode {
                        case .componentMcq:
                            PatternIntroBrickMCQ(drill: brickState, engine: engine, patternIntroLogic: logic)
                        case .cloze:
                            BrickModeSelector.interactionView(for: brickState, engine: engine, showPrompt: true, patternIntroLogic: logic, onComplete: { logic.advance() })
                        case .componentTyping:
                            BrickModeSelector.interactionView(for: brickState, engine: engine, showPrompt: true, patternIntroLogic: logic, onComplete: { logic.advance() })
                        case .speaking:
                            BrickModeSelector.interactionView(for: brickState, engine: engine, showPrompt: true, patternIntroLogic: logic, onComplete: { logic.advance() })
                        default:
                            PatternIntroBrickMCQ(drill: brickState, engine: engine, patternIntroLogic: logic)
                        }
                    }
                }
                .id(logic.currentBrickIndex)  // ✅ Force view refresh when brick changes
                .padding(.bottom, 120)  // Extra padding for footer
            }
            
            // 4. Footer Logic
            footer
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    private var footer: some View {
        VStack(spacing: 0) {
            if logic.currentBrickAnswered {
                Divider().background(Color.white.opacity(0.1))
                
                let color: Color = logic.currentBrickCorrect ? CyberColors.neonPink : .red
                let title = logic.currentBrickCorrect ? "CORRECT!" : "INCORRECT"
                let isLastBrick = logic.currentBrickIndex == (logic.brickDrills.count - 1)
                let buttonLabel = isLastBrick ? "CONTINUE" : "NEXT_COMPONENT"
                
                CyberProceedButton(
                    action: { 
                        logic.advance()
                    },
                    label: buttonLabel,
                    title: title,
                    color: color,
                    systemImage: "arrow.right",
                    isEnabled: !logic.isAudioPlaying
                )
               .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.black)
            }
        }
    }
}

// ✅ Custom brick MCQ interaction for Pattern Intro
// Passes patternIntroLogic reference so brick can notify when answered
struct PatternIntroBrickMCQ: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    @ObservedObject var patternIntroLogic: PatternIntroLogic
    
    @StateObject private var logic: BrickMCQLogic
    
    init(drill: DrillState, engine: LessonEngine, patternIntroLogic: PatternIntroLogic) {
        self.drill = drill
        self.engine = engine
        self.patternIntroLogic = patternIntroLogic
        
        _logic = StateObject(wrappedValue: BrickMCQLogic(
            state: drill,
            engine: engine,
            patternIntroLogic: patternIntroLogic  // ✅ Pass reference
        ))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            MCQSelectionGrid(
                options: logic.options,
                selectedOption: logic.selectedOption,
                correctOption: (logic.isCorrect != nil) ? logic.correctOption : nil,
                isAnswered: logic.isCorrect != nil,
                onSelect: { option in logic.selectOption(option) }
            )
        }
    }
}
