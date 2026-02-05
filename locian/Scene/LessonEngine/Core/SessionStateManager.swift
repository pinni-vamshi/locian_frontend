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
    
    // Mic Permission State
    @Published var showPermissionAlert: Bool = false
    @Published var permissionAlertMessage: String = ""
    @Published var hasMicrophonePermission: Bool = false
    
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
            self.targetLocale = LocaleMapper.getLocale(for: langName)
            self.neuralValidator.updateLocale(self.targetLocale)
            
            // Re-initialize Speech Recognizer with specific locale
            self.speechRecognizer = SpeechRecognizer(locale: self.targetLocale)
            print("   - Locale: \(self.targetLocale.identifier)")
        }
        
        // PRE-COMPUTE EMBEDDINGS (Performance Optimization)
        // Collect all potential targets (Drills + Bricks)
        var targetsToCache: [String] = []
        
        // 1. Drills (Both Target and Meaning)
        if let patterns = data.patterns {
            for p in patterns {
                targetsToCache.append(p.target)
                targetsToCache.append(p.meaning)
            }
        }
        
        // 2. Bricks (Both Word and Meaning)
        if let bricks = data.bricks {
            if let constants = bricks.constants {
                targetsToCache.append(contentsOf: constants.map { $0.word })
                targetsToCache.append(contentsOf: constants.map { $0.meaning })
            }
            if let variables = bricks.variables {
                targetsToCache.append(contentsOf: variables.map { $0.word })
                targetsToCache.append(contentsOf: variables.map { $0.meaning })
            }
            if let structural = bricks.structural {
                 targetsToCache.append(contentsOf: structural.map { $0.word })
                 targetsToCache.append(contentsOf: structural.map { $0.meaning })
            }
        }
        
        print("   - Pre-computing embeddings for \(targetsToCache.count) targets...")
        
        // 3. Trigger Pre-computation
        // Run on background if huge, but usually fast enough for on-device embedding
        self.neuralValidator.printEmbeddingDiagnostics() // User Request: Check existence
        print("🧠 [LessonFlow] [Neural] Converting API response data to vectors immediately...")
        print("   📝 [LessonFlow] [Neural] Targets to embed: \(targetsToCache)")
        self.neuralValidator.precomputeTargets(targetsToCache)
        
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
        
        // STABILIZATION: Resolve mode and options before presenting
        var stabilizedState = nextState
        let resolvedMode = resolveMode(for: stabilizedState)
        stabilizedState.currentMode = resolvedMode
        
        if resolvedMode == .mcq || resolvedMode == .componentMcq {
            generateMCQOptionsIfNeeded(for: &stabilizedState)
        }
        
        withAnimation(.spring()) {
            self.activeState = stabilizedState
            self.resetActiveInput()
            self.showSuccessConfetti = false
        }
        print("   🎭 [SessionManager] Presentation Ready: Mode=\(resolvedMode), InputLength=\(activeInput.count)")
    }
    
    // MARK: - Mic Permissions
    
    func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.hasMicrophonePermission = (status == .authorized)
                completion(status == .authorized)
            }
        }
    }
    
    func showMicrophonePermissionAlert() {
        permissionAlertMessage = "Microphone access is required for speaking drills. Please enable it in Settings."
        showPermissionAlert = true
    }
    
    private func convertDrillIfNeeded(_ state: DrillState) -> DrillState {
        guard !hasMicrophonePermission else { return state }
        var converted = state
        switch state.currentMode {
        case .speaking, .voiceTyping, .voiceNativeTyping:
            converted.currentMode = .typing
            return converted
        default:
            return state
        }
    }
    
    func resolveMode(for state: DrillState) -> DrillMode {
        if let existing = state.currentMode { return existing }
        
        // 1. Resolve ID
        let id: String
        let isBrick = state.isBrick
        
        if isBrick {
            id = state.id.replacingOccurrences(of: "INT-", with: "")
        } else {
            id = state.id
        }
            
        // 2. Get Score
        // NOTE: Already uses getDecayedMastery internally via getBlendedMastery extension
        let score = engine.getBlendedMastery(for: id)
        
        print("   🧠 [ResolveMode] Inspecting [\(id)] (isBrick: \(isBrick))...")
        print("      - Blended Mastery: \(String(format: "%.3f", score))")
        
        // 3. Determine Mode
        let result: DrillMode
        
        if state.id.hasPrefix("BATCH-INTRO-") {
            print("      - Decision: Intro Batch -> .vocabIntro")
            result = .vocabIntro
        } else if isBrick {
            if score >= 0.55 { 
                print("      - Decision: Score >= 0.55 -> Typing")
                result = .componentTyping 
            } else if score >= 0.30 { 
                print("      - Decision: Score >= 0.30 -> Cloze")
                result = .cloze 
            } else { 
                print("      - Decision: Score < 0.30 -> MCQ")
                result = .componentMcq 
            }
        } else {
            if score >= 0.85 {
                print("      - Decision: Score >= 0.85 -> Speaking")
                result = .speaking
            } else if score >= 0.55 {
                print("      - Decision: Score >= 0.55 -> Typing")
                result = .typing
            } else if score >= 0.25 {
                print("      - Decision: Score >= 0.25 -> Builders")
                result = .sentenceBuilder
            } else {
                print("      - Decision: Score < 0.25 -> MCQ")
                result = .mcq
            }
        }
        
        print("   🧠 [ResolveMode] Final Decision: \(result)")
        return result
    }
    
    private func generateMCQOptionsIfNeeded(for state: inout DrillState) {
        guard state.mcqOptions == nil else { return }
        
        print("   🎲 [SessionManager] Generating stable options for \(state.id)")
        
        let candidates: [String]
        if state.id.hasPrefix("INT-") || state.isBrick {
            // Brick Pool
            let allBricks = (lessonData?.bricks?.constants ?? []) + 
                           (lessonData?.bricks?.variables ?? []) + 
                           (lessonData?.bricks?.structural ?? [])
            candidates = allBricks.map { $0.meaning }
            print("      - Candidate Pool (Bricks): \(candidates.count) items")
        } else {
            // Pattern Pool (JIT safe)
            candidates = engine.rawPatterns.map { $0.meaning }
             print("      - Candidate Pool (Patterns): \(candidates.count) items")
        }
        
        let options = MCQOptionGenerator.generateNativeOptions(
            targetMeaning: state.drillData.meaning,
            candidates: candidates,
            validator: neuralValidator
        )
        
        state.mcqOptions = options
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
        DispatchQueue.main.async {
            self.lastAnswerCorrect = isCorrect
            
            if isCorrect {
                if isMeaningCorrect {
                    self.activeValidationState = .meaningCorrect
                    self.validationFeedbackMessage = "Meaning is right. Fix the grammar or word form."
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                } else {
                    self.activeValidationState = .correct
                    self.validationFeedbackMessage = "Correct!"
                    self.showSuccessConfetti = true
                }
            } else {
                self.activeValidationState = .wrong
                self.validationFeedbackMessage = "Incorrect"
            }
        }
    }
    
    // MARK: - Continue Logic
    
    func continueToNext() {
        print("\n➡️ [continueToNext] Transitioning to next state...")
        
        // GHOST SUB-FLOW: Interject between Intro and Target Drill
        // This is a "Rehearsal Sequence" (usually 2 steps)
        if ghostStep > 0 {
            if ghostStep < 2 {
                ghostStep += 1
                print("   👻 [Session] Advancing Rehearsal Step to: \(ghostStep)")
                
                withAnimation(.spring()) {
                    self.resetActiveInput()
                    self.lastAnswerCorrect = nil
                    self.objectWillChange.send()
                }
                return
            } else {
                print("   ✅ [Session] Rehearsal sequence complete. Moving to Target Drill.")
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
        loadNextState()
    }
    
    private func finishSession() {
        isSessionComplete = true
        print("🏆 Session Complete!")
    }
}

// MARK: - Locale Helper
struct LocaleMapper {
    static func getLocale(for languageName: String) -> Locale {
        // Map common names to ISO codes supported by Apple Neural Engine
        let normalized = languageName.lowercased()
        
        switch normalized {
        // Romance Languages
        case "spanish", "español", "es": return Locale(identifier: "es-ES")
        case "french", "français", "fr": return Locale(identifier: "fr-FR")
        case "italian", "italiano", "it": return Locale(identifier: "it-IT")
        case "portuguese", "português", "pt": return Locale(identifier: "pt-BR")
        case "romanian", "română", "ro": return Locale(identifier: "ro-RO")
        
        // Germanic Languages
        case "german", "deutsch", "de": return Locale(identifier: "de-DE")
        case "dutch", "nederlands", "nl": return Locale(identifier: "nl-NL")
        case "swedish", "svenska", "sv": return Locale(identifier: "sv-SE")
        case "norwegian", "norsk", "no": return Locale(identifier: "no-NO")
        case "danish", "dansk", "da": return Locale(identifier: "da-DK")
        
        // Asian Languages
        case "japanese", "日本語", "ja": return Locale(identifier: "ja-JP")
        case "chinese", "中文", "zh": return Locale(identifier: "zh-CN")
        case "korean", "한국어", "ko": return Locale(identifier: "ko-KR")
        case "thai", "ไทย", "th": return Locale(identifier: "th-TH")
        case "vietnamese", "tiếng việt", "vi": return Locale(identifier: "vi-VN")
        
        // Indian Languages
        case "hindi", "हिन्दी", "hi": return Locale(identifier: "hi-IN")
        case "tamil", "தமிழ்", "ta": return Locale(identifier: "ta-IN")
        case "telugu", "తెలుగు", "te": return Locale(identifier: "te-IN")
        case "bengali", "বাংলা", "bn": return Locale(identifier: "bn-IN")
        case "marathi", "मराठी", "mr": return Locale(identifier: "mr-IN")
        
        // Other Major Languages
        case "russian", "русский", "ru": return Locale(identifier: "ru-RU")
        case "arabic", "العربية", "ar": return Locale(identifier: "ar-SA")
        case "turkish", "türkçe", "tr": return Locale(identifier: "tr-TR")
        case "polish", "polski", "pl": return Locale(identifier: "pl-PL")
        case "ukrainian", "українська", "uk": return Locale(identifier: "uk-UA")
        case "greek", "ελληνικά", "el": return Locale(identifier: "el-GR")
        case "hebrew", "עברית", "he": return Locale(identifier: "he-IL")
        
        default: 
            print("⚠️ [LocaleMapper] Unknown language '\(languageName)', defaulting to en-US")
            return Locale(identifier: "en-US")
        }
    }
}
