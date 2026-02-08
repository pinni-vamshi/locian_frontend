//
//  LessonSessionManager.swift
//  locian
//
//  The Brain of the Lesson Engine.
//  Manages the Card Queue, Progression Logic, and Neural Validation.
//  NOW POWERED BY: Dynamic Lesson Engine
//

import Foundation
import Combine
import SwiftUI
import Speech

// MARK: - Validation Strategy
/// Defines how answer validation should be performed
enum ValidationStrategy {
    case auto  // Manager validates based on drill type
    case preValidated(isCorrect: Bool)  // View already validated
    case skip  // For conceptIntro, always pass
}

class LessonSessionManager: ObservableObject {
    
    // MARK: - Published State
    @Published var activeState: DrillState?
    @Published var isSessionComplete: Bool = false
    @Published var currentProgress: Double = 0.0
    
    // Feedback Triggers
    // @Published var shakeCurrentCard removed per user request
    @Published var showSuccessConfetti: Bool = false
    @Published var lastAnswerCorrect: Bool? = nil 
    @Published var activeValidationState: ValidationResult? = nil
    @Published var validationFeedbackMessage: String? = nil
    
    // Pressure System
    @Published var timerManager = TimerManager()
    @Published var pressureMode: PressureMode = .learning
    
    // MARK: - Active User Input (Centralized for Layout Refactor)
    @Published var activeInput: String = ""
    @Published var activeComponents: [String] = []
    
    // Ghost Sub-flow State
    @Published var ghostStep: Int = 0 // 0: None, 1: Refresh, 2: Test
    
    // MARK: - Lesson Data
    private(set) var lessonData: GenerateSentenceData?
    
    // MARK: - The ENGINE
    let engine = LessonEngine()
    
    // Generalization (Locale Support)
    @Published var targetLocale: Locale = Locale(identifier: "en-US") 
    
    // AI Validators
    var neuralValidator = NeuralValidator()
    var speechRecognizer = SpeechRecognizer()
    
    // Communication Subject for centralized button
    let submitRequest = PassthroughSubject<Void, Never>()
    
    var audioManager = AudioManager.shared
    var patternTracker = PatternMasteryTracker()
    
    
    enum PressureMode {
        case learning    
        case awareness   
        case mastery     
    }
    
    // MARK: - Initialization
    init() {
        
        // CRITICAL: Link engine changes to this manager so UI reflects state (like transitionReady)
        engine.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Session Builder
    // MARK: - Session Builder
    func startSession(with data: GenerateSentenceData) {
        print("🚀 [LessonFlow] [SessionManager] Starting Dynamic Session")
        print("   - Target Language: \(data.target_language ?? "Unknown")")
        print("   - Patterns: \(data.patterns?.count ?? 0)")
        if let patterns = data.patterns {
            let preview = patterns.prefix(3).map { $0.pattern_id }.joined(separator: ", ")
            print("   - Loaded Patterns (Preview): [\(preview)...]")
        }
        
        self.lessonData = data
        
        // Initialize AI Validator
        if let langName = data.target_language {
            self.targetLocale = TargetLanguageMapping.shared.getLocale(for: langName)
            self.neuralValidator.updateLocale(self.targetLocale)
            
            // Re-initialize Speech Recognizer with specific locale
            self.speechRecognizer = SpeechRecognizer(locale: self.targetLocale)
            print("   - Locale: \(self.targetLocale.identifier)")
        }
        
        
        // Initialize The Engine
        engine.validator = self.neuralValidator
        engine.initialize(with: data)
        
        loadNextState()
    }
    
    // MARK: - Core Flow
    
    private func loadNextState() {
        self.ghostStep = 0
        print("\n🔄 [LessonFlow] [loadNextState] Called")
        print("   🔍 Checking engine state:")
        print("      - isTransitionReady: \(engine.isTransitionReady)")
        
        print("   📞 Calling engine.getNextState()...")
        guard let nextState = engine.getNextState() else {
            print("   ⚠️ engine.getNextState() returned nil")
            print("   🏁 [LessonFlow] Session Complete (No more patterns)")
            finishSession()
            return
        }
        
        // Detailed State Logging
        print("   📥 [SessionManager] Raw State from Engine:")
        print("      - ID: \(nextState.id)")
        print("      - Mode (Pre-Resolve): \(nextState.currentMode?.rawValue ?? "nil")")
        print("      - IsBrick: \(nextState.isBrick)")
        print("      - PatternId: \(nextState.patternId)")
        
        print("   ✅ [SessionManager] Loaded State: \(nextState.id) (isBrick: \(nextState.isBrick))")
        
        // Setup Pressure Mode
        let mode = nextState.currentMode ?? .mcq
        if mode == .mastery {
            pressureMode = .mastery
        } else if mode == .voiceTyping || mode == .voiceNativeTyping {
             pressureMode = .awareness
        } else {
            pressureMode = .learning
        }
        
        timerManager.reset()
        if pressureMode != .learning {
            timerManager.start()
        }
        
        print("\n⏳ [SessionManager] Presenting State: \(nextState.id)")
        
        
        withAnimation(.spring()) {
            self.activeState = stabilizedState
            self.resetActiveInput()
            self.showSuccessConfetti = false
        }
        print("   🎭 [SessionManager] Presentation Ready: Mode=\(resolvedMode), InputLength=\(activeInput.count)")
    }
    
    private func convertDrillIfNeeded(_ state: DrillState) -> DrillState {
        // Use the centralized service for status check
        let hasMic = AVAudioApplication.shared.recordPermission == .granted
        guard !hasMic else { return state }
        
        var converted = state
        switch state.currentMode {
        case .speaking, .voiceTyping, .voiceNativeTyping:
            converted.currentMode = .typing
            return converted
        default:
            return state
        }
    }
    

    

    
    func playStateAudio(_ state: DrillState) {
        let text = state.drillData.target
        let language = lessonData?.target_language ?? "es-ES"
        audioManager.speak(text: text, language: language)
    }
    


    // Centralized Trigger for Fixed Footer
    func triggerSubViewSubmit() {
        submitRequest.send()
    }
    
    func resetActiveInput() {
        activeInput = ""
        activeComponents = []
        speechRecognizer.recognizedText = ""
        activeValidationState = nil
        validationFeedbackMessage = nil
    }
    
    // MARK: - Interaction Handlers
    
    /// Pure UI Side-Effect Handler (Confetti, TTS, Haptics)
    func handleValidationResult(isCorrect: Bool, targetContent: String, isMeaningCorrect: Bool = false) {
        print("\n🏁 [SessionFlow] [ValidationResult] Received from Validator:")
        print("   - Result: \(isCorrect ? "✅ SUCCESS" : "❌ FAILURE")")
        print("   - Target Content: '\(targetContent)'")
        print("   - Secondary (Meaning) Match: \(isMeaningCorrect)")
        
        DispatchQueue.main.async {
            self.lastAnswerCorrect = isCorrect
            
            if isCorrect {
                if isMeaningCorrect {
                    print("   💡 [SessionFlow] [Validation] Triggering 'Correction Needed' feedback (Meaning correct but form is off)")
                    self.activeValidationState = .meaningCorrect
                    self.validationFeedbackMessage = "Meaning is right. Fix the grammar or word form."
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                } else {
                    print("   ✨ [SessionFlow] [Validation] Perfect Match! Triggering confetti and success state.")
                    self.activeValidationState = .correct
                    self.validationFeedbackMessage = "Correct!"
                    self.showSuccessConfetti = true
                }
            } else {
                print("   🚫 [SessionFlow] [Validation] Wrong. Triggering error state.")
                self.activeValidationState = .wrong
                self.validationFeedbackMessage = "Incorrect"
            }
        }
    }
    
    // MARK: - Continue Logic
    
    func continueToNext() {
        print("\n➡️ [SessionFlow] [continueToNext] Transition Triggered")
        
        // GHOST SUB-FLOW: Interject between Intro and Target Drill
        // This is a "Rehearsal Sequence" (usually 2 steps)
        if ghostStep > 0 {
            if ghostStep < 2 {
                ghostStep += 1
                print("   👻 [SessionFlow] [GhostStage] Advancing Rehearsal -> Step \(ghostStep)/2")
                
                withAnimation(.spring()) {
                    self.resetActiveInput()
                    self.lastAnswerCorrect = nil
                    self.objectWillChange.send()
                }
                return
            } else {
                print("   ✅ [SessionFlow] [GhostStage] Rehearsal sequence complete. Transitioning back to Flow...")
                self.ghostStep = 0
                // Fall through to loadNextState or just refresh view
                withAnimation(.spring()) {
                    self.resetActiveInput()
                    self.lastAnswerCorrect = nil
                    self.objectWillChange.send()
                }
                return
            }
        }
        
        lastAnswerCorrect = nil
        currentProgress = engine.calculateOverallProgress()
        print("   📊 [SessionFlow] Current Progress: \(String(format: "%.1f%%", currentProgress * 100))")
        loadNextState()
    }
    
    private func finishSession() {
        isSessionComplete = true
        print("🏆 Session Complete!")
    }
}
