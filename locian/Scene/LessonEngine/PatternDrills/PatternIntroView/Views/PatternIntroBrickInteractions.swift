import SwiftUI

// MARK: - Specialized Interaction Wrappers for Pattern Intro (Recap Phase)

struct BrickMCQInteraction: View {
    let drill: DrillState
    @ObservedObject var engine: LessonEngine
    let showPrompt: Bool
    @StateObject var logic: BrickMCQLogic
    
    let onComplete: (() -> Void)?
    
    init(drill: DrillState, engine: LessonEngine, showPrompt: Bool = true, patternIntroLogic: PatternIntroLogic? = nil, onComplete: (() -> Void)? = nil) {
        self.drill = drill
        self.engine = engine
        self.showPrompt = showPrompt
        self.onComplete = onComplete
        
        let logic = BrickMCQLogic(state: drill, engine: engine, patternIntroLogic: patternIntroLogic)
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
                optionPhonetics: logic.optionPhonetics,
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
    
    init(drill: DrillState, engine: LessonEngine, showPrompt: Bool = true, patternIntroLogic: PatternIntroLogic? = nil, onComplete: (() -> Void)? = nil) {
        self.drill = drill
        self.engine = engine
        self.showPrompt = showPrompt
        self.onComplete = onComplete
        
        let logic = BrickClozeLogic(state: drill, engine: engine, patternIntroLogic: patternIntroLogic)
        logic.onComplete = onComplete
        self._logic = StateObject(wrappedValue: logic)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if showPrompt {
                // TRADITIONAL / FALLBACK MODE
                VStack(spacing: 16) {
                    Text(logic.prompt)
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
             }
            
            TypingInputArea(
                text: $logic.userInput,
                placeholder: "Fill in the blank...",
                isCorrect: logic.isCorrect,
                isDisabled: logic.isCorrect != nil
            )
            .focused($isFocused)
            .padding(.horizontal)
            
            if let isCorrect = logic.isCorrect, !isCorrect {
                TypingCorrectionView(
                    correctAnswer: logic.state.drillData.target,
                    phonetic: logic.state.drillData.phonetic
                )
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
    
    init(drill: DrillState, engine: LessonEngine, showPrompt: Bool = true, patternIntroLogic: PatternIntroLogic? = nil, onComplete: (() -> Void)? = nil) {
        self.drill = drill
        self.engine = engine
        self.showPrompt = showPrompt
        self.onComplete = onComplete
        
        let logic = BrickTypingLogic(state: drill, engine: engine, patternIntroLogic: patternIntroLogic)
        logic.onComplete = onComplete
        self._logic = StateObject(wrappedValue: logic)
    }
    
    var body: some View {
        VStack(spacing: 24) {
             if showPrompt {
                 VStack(spacing: 8) {
                     Text(logic.prompt)
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                 }
                 .padding(.top)
             }
                
            TypingInputArea(
                text: $logic.userInput,
                placeholder: "Type here...",
                isCorrect: logic.isCorrect,
                isDisabled: logic.isCorrect != nil
            )
            .focused($isFocused)
            .padding(.horizontal)
            
            if let isCorrect = logic.isCorrect, !isCorrect {
                TypingCorrectionView(
                    correctAnswer: logic.state.drillData.target,
                    phonetic: logic.state.drillData.phonetic
                )
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
    
    init(drill: DrillState, engine: LessonEngine, showPrompt: Bool = true, patternIntroLogic: PatternIntroLogic? = nil, onComplete: (() -> Void)? = nil) {
        self.drill = drill
        self.engine = engine
        self.showPrompt = showPrompt
        self.onComplete = onComplete
        
        let logic = BrickVoiceLogic(state: drill, engine: engine, patternIntroLogic: patternIntroLogic)
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
                TypingCorrectionView(
                    correctAnswer: logic.state.drillData.target,
                    phonetic: logic.state.drillData.phonetic
                )
            }
            
            if logic.isCorrect == nil && logic.hasInput {
                CyberOption(text: "CHECK", index: 0, isSelected: false, action: { logic.checkAnswer() })
                    .padding(.horizontal)
            }
        }
    }
}
