import SwiftUI

struct BrickModeSelector: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    
    static func needsDrill(brickId: String, engine: LessonEngine) -> Bool {
        let score = engine.getDecayedMastery(for: brickId)
        let needs = score < 0.85
        print("   🧱 [BrickMode] Checking [\(brickId)]: Mastery \(String(format: "%.2f", score)) | Needs Drill: \(needs)")
        return needs // Bricks < 0.85 need intervention
    }
    
    static func resolveMode(for drill: DrillState, engine: LessonEngine) -> DrillMode {
        if let mode = drill.currentMode { return mode }
        
        let rawId = drill.id
        let brickId = rawId.replacingOccurrences(of: "INT-", with: "")
            .split(separator: "-").first.map(String.init) ?? rawId
            
        print("   🧱 [BrickLogic] Resolving Mode for Drill: '\(rawId)'")
        print("      - Clean ID: '\(brickId)'")
        
        let score = engine.getDecayedMastery(for: brickId)
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
    static func interactionView(for drill: DrillState, engine: LessonEngine, showPrompt: Bool = true, onComplete: (() -> Void)? = nil) -> some View {
        let mode = resolveMode(for: drill, engine: engine)
        
        switch mode {
        case .componentMcq:
            BrickMCQInteraction(drill: drill, engine: engine, showPrompt: showPrompt, onComplete: onComplete)
        case .cloze:
            BrickClozeInteraction(drill: drill, engine: engine, showPrompt: showPrompt, onComplete: onComplete)
        case .componentTyping:
            BrickTypingInteraction(drill: drill, engine: engine, showPrompt: showPrompt, onComplete: onComplete)
        case .speaking:
            BrickVoiceInteraction(drill: drill, engine: engine, showPrompt: showPrompt, onComplete: onComplete)
        default:
            BrickMCQInteraction(drill: drill, engine: engine, showPrompt: showPrompt, onComplete: onComplete)
        }
    }
    
    var body: some View {
        // ...Existing body logic...
        let brickId = drill.id.replacingOccurrences(of: "INT-", with: "")
            .split(separator: "-").first.map(String.init) ?? drill.id
        
        if !BrickModeSelector.needsDrill(brickId: brickId, engine: engine) {
            EmptyView()
        } else {
            let mode = drill.currentMode ?? BrickModeSelector.resolveMode(for: drill, engine: engine)
            switch mode {
            case .componentMcq:     BrickMCQLogic.view(for: drill, mode: mode, engine: engine)
            case .cloze:            BrickClozeLogic.view(for: drill, mode: mode, engine: engine)
            case .componentTyping:  BrickTypingLogic.view(for: drill, mode: mode, engine: engine)
            case .speaking:         BrickVoiceLogic.view(for: drill, mode: mode, engine: engine)
            default:                BrickMCQLogic.view(for: drill, mode: mode, engine: engine)
            }
        }
    }
}

// MARK: - Specialized Interaction Wrappers

struct BrickMCQInteraction: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    let showPrompt: Bool
    @StateObject var logic: BrickMCQLogic
    
    let onComplete: (() -> Void)?
    
    init(drill: DrillState, engine: LessonEngine, showPrompt: Bool = true, onComplete: (() -> Void)? = nil) {
        self.drill = drill
        self.engine = engine
        self.showPrompt = showPrompt
        self.onComplete = onComplete
        
        let logic = BrickMCQLogic(state: drill, engine: engine)
        logic.onComplete = onComplete
        self._logic = StateObject(wrappedValue: logic)
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
    }
}

struct BrickClozeInteraction: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    let showPrompt: Bool
    @StateObject var logic: BrickClozeLogic
    @FocusState private var isFocused: Bool
    
    let onComplete: (() -> Void)?
    
    init(drill: DrillState, engine: LessonEngine, showPrompt: Bool = true, onComplete: (() -> Void)? = nil) {
        self.drill = drill
        self.engine = engine
        self.showPrompt = showPrompt
        self.onComplete = onComplete
        
        let logic = BrickClozeLogic(state: drill, engine: engine)
        logic.onComplete = onComplete
        self._logic = StateObject(wrappedValue: logic)
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
        }
    }
}

struct BrickTypingInteraction: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    let showPrompt: Bool
    @StateObject var logic: BrickTypingLogic
    @FocusState private var isFocused: Bool
    
    let onComplete: (() -> Void)?
    
    init(drill: DrillState, engine: LessonEngine, showPrompt: Bool = true, onComplete: (() -> Void)? = nil) {
        self.drill = drill
        self.engine = engine
        self.showPrompt = showPrompt
        self.onComplete = onComplete
        
        let logic = BrickTypingLogic(state: drill, engine: engine)
        logic.onComplete = onComplete
        self._logic = StateObject(wrappedValue: logic)
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
        }
    }
}

struct BrickVoiceInteraction: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    let showPrompt: Bool
    @StateObject var logic: BrickVoiceLogic
    
    let onComplete: (() -> Void)?
    
    init(drill: DrillState, engine: LessonEngine, showPrompt: Bool = true, onComplete: (() -> Void)? = nil) {
        self.drill = drill
        self.engine = engine
        self.showPrompt = showPrompt
        self.onComplete = onComplete
        
        let logic = BrickVoiceLogic(state: drill, engine: engine)
        logic.onComplete = onComplete
        self._logic = StateObject(wrappedValue: logic)
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
    }
}
