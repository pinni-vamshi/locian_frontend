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
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                headerSection
                horizontalSelectorSection
                interactionZoneSection
            }
            
            footer
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    @ViewBuilder
    private var headerSection: some View {
        LessonPromptHeader(
            instruction: "PATTERN RECAP",
            prompt: drill.drillData.meaning,
            targetLanguage: TargetLanguageMapping.shared.getDisplayNames(for: engine.lessonData?.target_language ?? "en").english,
            hintText: "REVEAL TARGET",
            meaningText: drill.drillData.target,
            contextSentence: nil,
            isHintExpanded: $isHintExpanded,
            backgroundColor: .white,
            textColor: .black,
            phonetic: drill.drillData.phonetic,
            showPhoneticOnPrompt: false
        )
    }
    
    @ViewBuilder
    private var horizontalSelectorSection: some View {
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
    }
    
    @ViewBuilder
    private var interactionZoneSection: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let brickState = logic.currentDrill {
                    // ✅ RESTORED: Using BrickModeSelector as the universal gateway.
                    // The BrickLogic view methods will "sense" the patternIntroLogic sensor.
                    BrickModeSelector(
                        drill: brickState,
                        engine: engine,
                        patternIntroLogic: logic,
                        onComplete: { logic.advance() }
                    )
                }
            }
            .id(logic.currentBrickIndex)  // ✅ Force view refresh when brick changes
            .padding(.bottom, 120)  // Extra padding for footer
        }
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

