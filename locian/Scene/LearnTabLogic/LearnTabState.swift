//
//  LearnTabState.swift
//  locian
//
//  V3.0 "Context Intelligence" State Management
//

import SwiftUI
import Combine

// MARK: - Enums
enum SentenceGenerationState {
    case idle
    case callingAI      
    case generating     
    case preparing      
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
    }

    // MARK: - Discovery (Unified Endpoint)
    
    func discover(explicitText: String? = nil, image: UIImage? = nil) {
        print("🔍 [LearnTabState] discover() V3 called")
        
        DiscoverMomentsService.shared.discoverMoments(explicitRequest: explicitText, image: image) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    if let rawRecs = response.data?.recommendations {
                        // V3.45: Filter out fallback "unknown" places and places with zero patterns
                        let validRecs = rawRecs.filter { rec in
                            let isNotUnknown = rec.place_id.lowercased() != "unknown"
                            let hasPatterns = !(rec.patterns ?? []).isEmpty
                            return isNotUnknown && hasPatterns
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
