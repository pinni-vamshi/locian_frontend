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
                
                // ✅ ANIMATION SWAP
                if logic.isPlayingIntro {
                    PatternIntroAnimationView(
                        bricks: logic.brickDrills,
                        onComplete: {
                            logic.onIntroComplete()
                        },
                        targetLanguage: engine.lessonData?.target_language ?? "es",
                        userLanguage: engine.lessonData?.user_language ?? "en-US",
                        patternMeaning: drill.drillData.meaning,
                        patternTarget: drill.drillData.target
                    )
                        .transition(.opacity)
                } else {
                    horizontalSelectorSection
                    interactionZoneSection
                }
            }
            
            if !logic.isPlayingIntro {
                footer
            }
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
                                    .overlay(alignment: .topTrailing) {
                                        let isMastered = engine.getDecayedMastery(for: brickState.drillData.target) >= 0.85
                                        if isMastered {
                                            Image(systemName: "checkmark.seal.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(CyberColors.neonCyan)
                                                .padding(4)
                                                .offset(x: 4, y: -4)
                                        }
                                    }
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
                            onComplete: { _ in 
                                // Auto-advance if this was triggered natively (e.g. from mastered skip)
                                // or if child specifically signals completion
                                logic.advance()
                            }
                        )
                }
            }
            .id(logic.currentBrickIndex)  // ✅ Force view refresh when brick changes
            .padding(.bottom, 120)  // Extra padding for footer
        }
    }

    
    private var footer: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.1))
            
            if logic.currentBrickAnswered {
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
            } else if let mode = logic.currentDrill?.currentMode, mode == .mastered {
                // Hide footer entirely during Mastery Victory Lap
                EmptyView()
            } else {
                // ✅ ACtive Answering State (Pinned Footer)
                // Filter visibility based on Mode
                if let mode = logic.currentDrill?.currentMode, mode != .mcq && mode != .componentMcq && mode != .voiceMcq {
                    HStack(spacing: 12) {
                        
                        CyberProceedButton(
                            action: { logic.requestCheckAnswer?() },
                            label: "READY?",
                            title: "CHECK",
                            color: CyberColors.neonCyan,
                            systemImage: "checkmark",
                            isEnabled: logic.currentBrickHasInput && !logic.isAudioPlaying
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color.black)
    }
}

