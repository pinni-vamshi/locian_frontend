import SwiftUI

struct BrickModeSelector: View {
    let drill: DrillState
    @ObservedObject var session: LessonSessionManager
    
    static func needsDrill(brickId: String, session: LessonSessionManager) -> Bool {
        let score = session.engine.getDecayedMastery(for: brickId)
        let needs = score < 0.85
        print("   🧱 [BrickMode] Checking [\(brickId)]: Mastery \(String(format: "%.2f", score)) | Needs Drill: \(needs)")
        return needs // Bricks < 0.85 need intervention
    }
    
    static func resolveMode(for drill: DrillState, session: LessonSessionManager) -> DrillMode {
        if let mode = drill.currentMode { return mode }
        
        let rawId = drill.id
        let brickId = rawId.replacingOccurrences(of: "INT-", with: "")
            .split(separator: "-").first.map(String.init) ?? rawId
            
        print("   🧱 [BrickLogic] Resolving Mode for Drill: '\(rawId)'")
        print("      - Clean ID: '\(brickId)'")
        
        let score = session.engine.getDecayedMastery(for: brickId)
        print("      - Current Mastery: \(String(format: "%.3f", score))")
        
        let result: DrillMode
        if score >= 0.70 {
            print("      - Decision: Score >= 0.70 -> Voice")
            result = .speaking
        } else if score >= 0.45 { 
            print("      - Decision: Score >= 0.45 -> Typing")
            result = .componentTyping 
        } else if score >= 0.20 { 
            print("      - Decision: Score >= 0.20 -> Cloze")
            result = .cloze 
        } else { 
            print("      - Decision: Score < 0.20 -> MCQ (Foundation)")
            result = .componentMcq 
        }
        
        print("   🧱 [BrickLogic] Final Mode: \(result)")
        return result
    }

    @ViewBuilder
    static func interactionView(for drill: DrillState, session: LessonSessionManager, showPrompt: Bool = true) -> some View {
        let mode = resolveMode(for: drill, session: session)
        
        switch mode {
        case .componentMcq:
            BrickMCQInteraction(drill: drill, session: session, showPrompt: showPrompt)
        case .cloze:
            BrickClozeInteraction(drill: drill, session: session, showPrompt: showPrompt)
        case .componentTyping:
            BrickTypingInteraction(drill: drill, session: session, showPrompt: showPrompt)
        case .speaking:
            BrickVoiceInteraction(drill: drill, session: session, showPrompt: showPrompt)
        default:
            BrickMCQInteraction(drill: drill, session: session, showPrompt: showPrompt)
        }
    }
    
    @ViewBuilder
    var body: some View {
        // ...Existing body logic...
        let brickId = drill.id.replacingOccurrences(of: "INT-", with: "")
            .split(separator: "-").first.map(String.init) ?? drill.id
        
        if !BrickModeSelector.needsDrill(brickId: brickId, session: session) {
            EmptyView()
        } else {
            let mode = drill.currentMode ?? BrickModeSelector.resolveMode(for: drill, session: session)
            switch mode {
            case .componentMcq:     BrickMCQLogic.view(for: drill, mode: mode, session: session)
            case .cloze:            BrickClozeLogic.view(for: drill, mode: mode, session: session)
            case .componentTyping:  BrickTypingLogic.view(for: drill, mode: mode, session: session)
            case .speaking:         BrickVoiceLogic.view(for: drill, mode: mode, session: session)
            default:                BrickMCQLogic.view(for: drill, mode: mode, session: session)
            }
        }
    }
}

// MARK: - Specialized Interaction Wrappers

struct BrickMCQInteraction: View {
    let drill: DrillState
    @ObservedObject var session: LessonSessionManager
    let showPrompt: Bool
    @StateObject var logic: BrickMCQLogic
    
    init(drill: DrillState, session: LessonSessionManager, showPrompt: Bool = true) {
        self.drill = drill
        self.session = session
        self.showPrompt = showPrompt
        self._logic = StateObject(wrappedValue: BrickMCQLogic(state: drill, session: session))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if showPrompt {
                Text(logic.prompt)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.top)
            }
            
            MCQSelectionGrid(
                options: logic.options,
                selectedOption: logic.selectedOption,
                correctOption: (logic.isCorrect != nil) ? logic.correctOption : nil,
                isAnswered: logic.isCorrect != nil,
                onSelect: { option in logic.selectOption(option) }
            )
        }
        .onAppear {
            logic.session.playStateAudio(logic.state)
        }
    }
}

struct BrickClozeInteraction: View {
    let drill: DrillState
    @ObservedObject var session: LessonSessionManager
    let showPrompt: Bool
    @StateObject var logic: BrickClozeLogic
    @FocusState private var isFocused: Bool
    
    init(drill: DrillState, session: LessonSessionManager, showPrompt: Bool = true) {
        self.drill = drill
        self.session = session
        self.showPrompt = showPrompt
        self._logic = StateObject(wrappedValue: BrickClozeLogic(state: drill, session: session))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if showPrompt {
                Text(logic.prompt)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            TypingInputArea(
                text: $logic.userInput,
                placeholder: "Fill in the blank...",
                isCorrect: logic.isCorrect,
                isDisabled: logic.isCorrect != nil
            )
            .focused($isFocused)
            
            if let isCorrect = logic.isCorrect, !isCorrect {
                TypingCorrectionView(correctAnswer: logic.state.drillData.target)
            }
            
            if logic.isCorrect == nil {
                CyberOption(text: "CHECK", index: 0, isSelected: false, action: { logic.checkAnswer() })
                    .padding(.horizontal)
            }
        }
        .onAppear {
            isFocused = true
            logic.session.playStateAudio(logic.state)
        }
    }
}

struct BrickTypingInteraction: View {
    let drill: DrillState
    @ObservedObject var session: LessonSessionManager
    let showPrompt: Bool
    @StateObject var logic: BrickTypingLogic
    @FocusState private var isFocused: Bool
    
    init(drill: DrillState, session: LessonSessionManager, showPrompt: Bool = true) {
        self.drill = drill
        self.session = session
        self.showPrompt = showPrompt
        self._logic = StateObject(wrappedValue: BrickTypingLogic(state: drill, session: session))
    }
    
    var body: some View {
        VStack(spacing: 24) {
             if showPrompt {
                 Text(logic.prompt)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
             }
                
            TypingInputArea(
                text: $logic.userInput,
                placeholder: "Type here...",
                isCorrect: logic.isCorrect,
                isDisabled: logic.isCorrect != nil
            )
            .focused($isFocused)
            
            if let isCorrect = logic.isCorrect, !isCorrect {
                TypingCorrectionView(correctAnswer: logic.state.drillData.target)
            }
            
            if logic.isCorrect == nil {
                CyberOption(text: "CHECK", index: 0, isSelected: false, action: { logic.checkAnswer() })
                    .padding(.horizontal)
            }
        }
        .onAppear {
            isFocused = true
            logic.session.playStateAudio(logic.state)
        }
    }
}

struct BrickVoiceInteraction: View {
    let drill: DrillState
    @ObservedObject var session: LessonSessionManager
    let showPrompt: Bool
    @StateObject var logic: BrickVoiceLogic
    
    init(drill: DrillState, session: LessonSessionManager, showPrompt: Bool = true) {
        self.drill = drill
        self.session = session
        self.showPrompt = showPrompt
        self._logic = StateObject(wrappedValue: BrickVoiceLogic(state: drill, session: session))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if showPrompt {
                Text(drill.drillData.meaning)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            SharedMicButton(
                isRecording: logic.isRecording,
                action: { logic.triggerSpeechRecognition() }
            )
            
            if !logic.recognizedText.isEmpty || logic.isRecording {
                Text("\"" + logic.recognizedText + "\"")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            if let isCorrect = logic.isCorrect, !isCorrect {
                TypingCorrectionView(correctAnswer: logic.state.drillData.target)
            }
            
            if logic.isCorrect == nil && logic.hasInput {
                CyberOption(text: "CHECK", index: 0, isSelected: false, action: { logic.checkAnswer() })
                    .padding(.horizontal)
            }
        }
        .onAppear {
            logic.session.playStateAudio(logic.state)
        }
    }
}
