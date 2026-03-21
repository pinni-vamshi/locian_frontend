//
//  LearnTabState.swift
//  locian
//
//  V3.0 "Context Intelligence" State Management
//

import SwiftUI
import Combine
import AVFoundation

// MARK: - Enums
enum SentenceGenerationState {
    case idle
    case callingAI      
    case generating     
    case preparing      
}

// ✅ NEW: Scored Brick for UI display
struct ScoredBrick: Identifiable {
    var id: String { brick.word }
    let brick: RecommendationBrickItem
    let score: Double
}

// MARK: - Main State
class LearnTabState: ObservableObject {
    
    // MARK: - V3 Context Intelligence State
    @Published var recommendations: [PlaceRecommendation] = []
    @Published var selectedRecommendationIndex: Int = 0
    @Published var selectedPatternIndex: Int = 0
    
    @Published var activeGeneratingMoment: String? = nil
    @Published var isGeneratingSentence: Bool = false
    
    // UI State
    @Published var generationState: SentenceGenerationState = .idle {
        didSet {
            isGeneratingSentence = (generationState != .idle)
        }
    }
    
    @Published var isTextInputMode: Bool = false
    @Published var manualInputText: String = ""
    @Published var showingCamera: Bool = false
    
    @Published var currentLesson: GenerateSentenceData? = nil
    @Published var showLessonView: Bool = false
    
    // Environment Telemetry (Developer Mode)
    @Published var telemetry = EnvironmentTelemetry()
    
    // Nearby Section State
    @Published var nearbyPlaces: [LocationManager.NearbyAmbience] = []
    @Published var isNearbyLoading: Bool = false
    
    // MARK: - Computed Properties
    var activeRecommendation: PlaceRecommendation? {
        guard selectedRecommendationIndex < recommendations.count else { return nil }
        return recommendations[selectedRecommendationIndex]
    }
    
    var activePattern: RecommendationPattern? {
        guard let rec = activeRecommendation,
              let patterns = rec.patterns,
              selectedPatternIndex < patterns.count else { return nil }
        return patterns[selectedPatternIndex]
    }
    
    var isFetchingData: Bool {
        return DiscoverMomentsService.shared.isLoading
    }
    
    var activeBricks: [ScoredBrick] {
        guard let pattern = activePattern, let target = pattern.target else { return [] }
        
        let langCode = appState.userLanguagePairs.first(where: { $0.is_default })?.target_language ?? "es"
        
        // 1. Get the aggregate pool of all bricks the AI considered in this session
        let pool = aggregatedBricksPool
        
        // 2. Use the "Construction Laser" (ContentAnalyzer) to scan the sentence against the pool
        // This finds words/phrases locally and assigns neural similarity scores.
        let matches = ContentAnalyzer.findRelevantBricksWithSimilarity(
            in: target,
            meaning: pattern.meaning ?? "",
            bricks: pool,
            targetLanguage: langCode
        )
        
        // 3. Map matches to ScoredBrick for UI, sorting by similarity
        return matches.compactMap { match -> ScoredBrick? in
            // Find the original RecommendationBrickItem in the aggregate pool
            if let brick = findBrickInPool(id: match.id) {
                return ScoredBrick(brick: brick, score: match.score)
            }
            return nil
        }
        .sorted(by: { $0.score > $1.score })
    }
    
    // MARK: - Laser Helpers
    
    /// Aggregates every unique brick from across all recommendations/patterns in the response
    /// to create a temporary "Local Dictionary" for the ContentAnalyzer to scan.
    private var aggregatedBricksPool: BricksData? {
        var allConstants: [BrickItem] = []
        var allVariables: [BrickItem] = []
        var allStructural: [BrickItem] = []
        var seenWords = Set<String>()
        
        for rec in recommendations {
            for pattern in rec.patterns ?? [] {
                guard let rb = pattern.bricks else { continue }
                
                func process(_ list: [RecommendationBrickItem]?, into target: inout [BrickItem], type: String) {
                    for item in list ?? [] {
                        let lowerWord = item.word.lowercased()
                        if !seenWords.contains(lowerWord) {
                            seenWords.insert(lowerWord)
                            target.append(BrickItem(
                                id: item.word, // In this context, word serves as ID
                                word: item.word,
                                meaning: item.meaning,
                                phonetic: item.phonetic,
                                type: type,
                                vector: nil,
                                mastery: nil
                            ))
                        }
                    }
                }
                
                process(rb.constants, into: &allConstants, type: "constant")
                process(rb.variables, into: &allVariables, type: "variable")
                process(rb.structural, into: &allStructural, type: "structural")
            }
        }
        
        if allConstants.isEmpty && allVariables.isEmpty && allStructural.isEmpty { return nil }
        return BricksData(constants: allConstants, variables: allVariables, structural: allStructural)
    }
    
    private func findBrickInPool(id: String) -> RecommendationBrickItem? {
        for rec in recommendations {
            for pattern in rec.patterns ?? [] {
                guard let rb = pattern.bricks else { continue }
                let all = (rb.constants ?? []) + (rb.variables ?? []) + (rb.structural ?? [])
                if let found = all.first(where: { $0.word == id }) {
                    return found
                }
            }
        }
        return nil
    }
    
    @Published var isRecordingVoice: Bool = false
    
    let appState: AppStateManager
    var cancellables = Set<AnyCancellable>()
    
    init(appState: AppStateManager) {
        self.appState = appState
        setupObservers()
    }
    
    private func setupObservers() {
        // Observe DiscoverMomentsService for UI loading state updates
        DiscoverMomentsService.shared.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
            
        SpeechRecognizer.shared.$recognizedText
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                guard let self = self, self.isTextInputMode else { return }
                self.manualInputText = text.uppercased()
            }
            .store(in: &cancellables)
            
        // ✅ Sync Recording Status
        SpeechRecognizer.shared.$isRecording
            .receive(on: RunLoop.main)
            .assign(to: &$isRecordingVoice)
            
        // ✅ Environment Telemetry
        EnvironmentService.shared.$telemetry
            .receive(on: RunLoop.main)
            .assign(to: &$telemetry)
    }
    
    func toggleEnvironmentSensor(_ sensor: SensorType) {
        EnvironmentService.shared.toggleSensor(sensor)
    }
    
    func toggleVoiceInput() {
        print("🔘 [LearnTabState] toggleVoiceInput called. isRecordingVoice: \(isRecordingVoice)")
        if isRecordingVoice {
            SpeechRecognizer.shared.stopRecording()
        } else {
            AmbientSoundService.shared.ensureMicrophoneAccess { granted in
                print("🎤 [LearnTabState] Mic access granted: \(granted)")
                guard granted else { return }
                do {
                    print("🎤 [LearnTabState] Triggering SpeechRecognizer.startRecording()")
                    try SpeechRecognizer.shared.startRecording()
                } catch {
                    print("❌ [LearnTabState] Failed to start voice input: \(error)")
                }
            }
        }
    }

    // MARK: - Camera & Alerts
    private func showSettingsAlert(for feature: String) {
        DispatchQueue.main.async {
            guard let topVC = self.getTopViewController() else { return }
            
            let alert = UIAlertController(title: "\(feature) Access Required", message: "Please enable \(feature.lowercased()) access in Settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            
            topVC.present(alert, animated: true)
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
        
        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    func requestCameraAccess() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            DispatchQueue.main.async { self.showingCamera = true }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { self.showingCamera = true }
                }
            }
        case .denied, .restricted:
            self.showSettingsAlert(for: "Camera")
        @unknown default:
            break
        }
    }

    // MARK: - Discovery (Unified Endpoint)
    
    func discover(explicitText: String? = nil, image: UIImage? = nil) {
        print("🔍 [LearnTabState] discover() V3 called")
        
        // 🧹 COMPLETE REFRESH: Clear existing data immediately to ensure on-demand feel
        DispatchQueue.main.async {
            self.recommendations = []
            self.nearbyPlaces = []
            self.selectedRecommendationIndex = 0
            self.selectedPatternIndex = 0
        }
        
        DiscoverMomentsService.shared.discoverMoments(explicitRequest: explicitText, image: image) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    if let rawRecs = response.data?.recommendations {
                        // V3.46: Deep Filter - Clean patterns first, then filter recommendations
                        let validRecs = rawRecs.compactMap { rec -> PlaceRecommendation? in
                            // 1. Only keep patterns that have a valid target
                            let cleanPatterns = (rec.patterns ?? []).filter { $0.target != nil }
                            
                            // 2. Reject if no valid patterns remain
                            guard !cleanPatterns.isEmpty else { return nil }
                            
                            // 3. Reject if place is "unknown"
                            guard rec.place_id.lowercased() != "unknown" else { return nil }
                            
                            // 4. Return new recommendation with clean patterns
                            var cleanRec = rec
                            cleanRec.patterns = cleanPatterns
                            return cleanRec
                        }
                        
                        if !validRecs.isEmpty {
                            print("   ✨ [LearnTabState] Discovery Filtered. Showing \(validRecs.count) valid recommendations.")
                            self.recommendations = validRecs
                            self.selectedRecommendationIndex = 0
                            self.selectedPatternIndex = 0
                        } else {
                            print("   ⚠️ [LearnTabState] Discovery returned no valid recommendations after filtering.")
                            self.recommendations = []
                        }
                    } else {
                        self.recommendations = []
                    }
                }
                
            case .failure(let error):
                print("   ❌ [LearnTabState] Discovery Failed: \(error.localizedDescription)")
            }
        }
    }
    
    /// Bridges the selected V3 context into the Lesson Engine via the hydration pipeline
    func startPractice() {
        guard let recommendation = activeRecommendation else {
            print("⚠️ [LearnTabState] startPractice BLOCKED: No active recommendation.")
            return
        }
        guard !(recommendation.patterns ?? []).isEmpty else {
            print("⚠️ [LearnTabState] startPractice BLOCKED: Recommendation has no patterns.")
            return
        }
        
        // --- 🚀 NEW: INTEREST TAP (Unified API V2) ---
        // Report spatial context to backend immediately upon clicking 'Start'
        let structuredPlaces: [DiscoverPlaceInput] = self.nearbyPlaces.prefix(10).map { place in
            return DiscoverPlaceInput(
                name: place.name,
                category: place.category ?? "unknown"
            )
        }
        
        CompletePatternService.shared.completePattern(
            patternId: nil, // Strict requirement: Do not send pattern on start button
            placeId: recommendation.place_id,
            places: structuredPlaces
        ) { result in
            // Background reporting (Success/Failure logs handled in Service)
        }
        // ---------------------------------------------
        
        print("🚀 [LearnTabState] START PRACTICE: '\(recommendation.place_id)' — routing through GenerateSentenceLogic.hydrateFromV3()")
        
        GenerateSentenceLogic.shared.hydrateFromV3(recommendation: recommendation) { [weak self] lessonData in
            guard let self = self else { return }
            self.currentLesson = lessonData
            self.showLessonView = true
        }
    }
    
    // MARK: - Deep Link Handling
    
    func handleDeepLink(placeName: String, hour: Int) {
        print("📱 [LearnTabState] Handling Deep Link: \(placeName) at \(hour):00")
        
        // V3 Logic: Trigger a fresh discovery with the deep-linked place name as an explicit request
        // This will force the API to return recommendations specifically for this context
        self.discover(explicitText: "I am at \(placeName)")
    }
    
    func submitManualDiscovery() {
        guard !manualInputText.isEmpty else { return }
        print("⌨️ [LearnTabState] Submitting Manual Discovery: \(manualInputText)")
        discover(explicitText: manualInputText)
        isTextInputMode = false
        manualInputText = ""
    }
    
    // MARK: - Nearby Section Logic
    
    func loadNearbyPlaces() {
        guard appState.isLocationTrackingEnabled else { return }
        isNearbyLoading = true
        LocationManager.shared.fetchNearbyPlaces { [weak self] places in
            DispatchQueue.main.async {
                self?.nearbyPlaces = places
                self?.isNearbyLoading = false
            }
        }
    }
    
    func selectNearbyPlace(name: String, category: String?) {
        print("📍 [LearnTabState] Selected Nearby Place: \(name)")
        discover(explicitText: name)
    }
    
    func clearState() {
        self.recommendations = []
        self.selectedRecommendationIndex = 0
        self.selectedPatternIndex = 0
        self.isTextInputMode = false
        self.manualInputText = ""
    }
}
