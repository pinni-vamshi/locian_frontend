//
//  LearnTabState.swift
//  locian
//
//  Consolidated Logic for Learn Tab (State, Service, Parsing)
//

import SwiftUI
import Combine
import CoreLocation
import NaturalLanguage

// MARK: - Enums
enum SentenceGenerationState {
    case idle
    case callingAI      // New: 0-3 seconds
    case generating     // New: 3s until response
    case preparing      // New: Response received, preparing lesson
}


// MARK: - Main State
class LearnTabState: ObservableObject {
    @Published var activeGeneratingMoment: String? = nil
    
    @Published var recentHistory: [StudiedPlaceWithSituations] = []
    @Published var isLoadingHistory: Bool = false
    @Published var hasAnyStudiedPlaces: Bool = false
    
    
    // Unified Timeline Data
    @Published var allTimelinePlaces: [MicroSituationData] = []
    
    // Recommended Context Data (Predicted/Analyzed)
    @Published var recommendedPlaces: [MicroSituationData] = []
    
    // Error State
    @Published var showingNoDataError: Bool = false
    
    @Published var selectedRecommendedCategory: String? = nil
    
    // UI-Ready Properties (Pure Data for Views)
    @Published var uiStreakText: String = ""
    
    // Teaching Flow Properties
    @Published var rawLessonResponse: String? = nil
    @Published var generationState: SentenceGenerationState = .idle
    @Published var currentLesson: GenerateSentenceData? = nil
    @Published var showLessonView: Bool = false

    
    var isGeneratingSentence: Bool {
        return generationState != .idle
    }
    
    // UNIFIED LOADING STATE: Aggregates all data fetch activities
    var isFetchingData: Bool {
        return PredictPlaceService.shared.isLoading ||
               AnalyzeImageService.shared.isLoading ||
               GenerateMomentsService.shared.isLoading ||
               LocalRecommendationService.shared.isLoading ||
               appState.isLoadingTimeline ||
               isLoadingHistory
    }
    
    let appState: AppStateManager
    var cancellables = Set<AnyCancellable>()
    
    init(appState: AppStateManager) {
        self.appState = appState
        

        
        if appState.hasInitialHistoryLoaded {
             print("♻️ [LearnTabState] Global load complete. Restoring local state from AppStateManager...")
             if let persistedTimeline = appState.timeline {
                 self.allTimelinePlaces = persistedTimeline.places
                 self.hasAnyStudiedPlaces = !persistedTimeline.places.isEmpty
             } else {
                 self.hasAnyStudiedPlaces = false
             }
        }
        
        setupObservers()
    }
    
    private func setupObservers() {
        // Observe Services to trigger UI updates for isFetchingData
        // Observe Services to trigger UI updates for isFetchingData
        
        // Note: Generic erasing is tricky in mixed array. Individual subscriptions are safer.
        
        PredictPlaceService.shared.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
            
        AnalyzeImageService.shared.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
            
        GenerateMomentsService.shared.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
            
        LocalRecommendationService.shared.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
            
        // Observe AppStateManager specifically for timeline loading
        appState.$isLoadingTimeline
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
            
        // CRITICAL: Observe when recommendations are ready
        LocalRecommendationService.shared.$hasHighQualityMatches
            .receive(on: RunLoop.main)
            .removeDuplicates() // ✅ STOP THE LOOP: Only fire when state ACTUALLY changes
            .sink { [weak self] ready in
                print("🔄 [LearnTabState] LocalRecommendationService.hasHighQualityMatches changed: \(ready)")
                if ready {
                    self?.loadRecommendations()
                }
            }
            .store(in: &cancellables)
            
        // Observe Context Fallback Results
        LocalRecommendationService.shared.$contextPlace
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] place in
                print("🔄 [LearnTabState] Context match arrived: '\(place.place_name ?? "nil")'")
                self?.setActivePlace(place: place)
            }
            .store(in: &cancellables)
    }
    

    // MARK: - Fetching Logic
    
    // MARK: - Load Recommendations
    
    /// Load recommendations from LocalRecommendationService (called when Learn Tab appears)
    func loadRecommendations() {
        print("\n🟢 [LearnTabState] loadRecommendations called")
        
        guard appState.hasInitialHistoryLoaded else {
            print("   ⚠️ [LearnTabState] Initial history not loaded yet, skipping...")
            return
        }
        
        let service = LocalRecommendationService.shared
        print("   - Service isLoading: \(service.isLoading)")
        print("   - Service hasHighQualityMatches: \(service.hasHighQualityMatches)")
        
        let data = service.latestResult?.toMicroSituationData() ?? []
        print("   - Loading recommendations via unified handover (Count: \(data.count))...")
        self.setActivePlace(places: data)
        
        if !service.hasHighQualityMatches {
            print("   ℹ️ [LearnTabState] Matches are low quality/empty. Context fallback should trigger automatically.")
        }
    }
    
    func clearMoments() {
        // No longer calling fetchFirstRecommendedPlace()
    }
    
    func clearState() {
        self.hasAnyStudiedPlaces = false
        self.allTimelinePlaces = []
    }

    // MARK: - Context Refresh (Manual)
    
    func refreshTokenContext() {
        guard let sessionToken = appState.authToken, !sessionToken.isEmpty else { return }
        
        PredictPlaceService.shared.predictPlace(sessionToken: sessionToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if case .success(let response) = result, let data = response.data {
                    self.setActivePlace(place: data.toMicroSituationData())
                } else {
                    self.handleNoDataFallback()
                }
            }
        }
    }




    private func syncUIProperties() {
        print("🟢 [LearnTabState] syncUIProperties called")
        let streak = appState.userLanguagePairs.first(where: { $0.is_default }).map { 
            "\(calculateCurrentStreak(practiceDates: $0.practice_dates)) " + LocalizationManager.shared.string(.daysLabel)
        } ?? ""

        DispatchQueue.main.async {
            print("   - Streak Updated: '\(streak)'")
            self.uiStreakText = streak
        }
    }
    
    // MARK: - Teaching Flow
    
    func generateSentence(for moment: String, fromPlace named: String? = nil) {
        // 2. Original Logic (Restored)
        print("\n🟢 [LearnTabState] generateSentence called (LEGACY ENGINE)")
        print("   - Moment: '\(moment)'")
        print("   - Override Place: '\(named ?? "nil")'")
        
        guard let sessionToken = appState.authToken, !sessionToken.isEmpty,
              appState.userLanguagePairs.contains(where: { $0.is_default }) else {
            print("🔴 [LearnTabState] generateSentence ABORT: Missing Token or Language Pair")
            return
        }
        
        // Fallback to recommended place if available
        let placeName = named ?? recommendedPlaces.first?.place_name ?? "Unknown"
        print("   - Final Context Place: '\(placeName)'")
        
        guard generationState == .idle else {
            print("⚠️ [LearnTabState] generateSentence SKIP: State is not idle (\(generationState))")
            return
        }
        
        // 1. Gather Contextual Data
        let history = allTimelinePlaces
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        
        // previous: 3 places before now
        let previousItems = history.filter { ($0.hour ?? 0) < currentHour }
            .suffix(3)
            .map { PlaceHistoryItem(place: $0.place_name ?? "Unknown", time: $0.time ?? "00:00 AM") }
        
        // future: 1 place after now
        let futureItems = history.filter { ($0.hour ?? 0) > currentHour }
            .prefix(1)
            .map { PlaceHistoryItem(place: $0.place_name ?? "Unknown", time: $0.time ?? "00:00 AM") }
            
        self.activeGeneratingMoment = moment
        generationState = .callingAI
        
        // Removed invalid learnTabViewModel reference.
        
        rawLessonResponse = nil
        self.currentLesson = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            if self?.generationState == .callingAI { self?.generationState = .generating }
        }
        
        print("   🔹 Calling GenerateSentenceService...")
        GenerateSentenceService.shared.generateSentence(
            placeName: placeName,
            microSituation: moment,
            userIntent: nil, // TODO: Pull descriptive intent
            previousPlaces: previousItems,
            futurePlaces: futureItems,
            sessionToken: sessionToken
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("   ✅ [LearnTabState] generateSentence Success")
                    self?.generationState = .preparing
                    if let data = try? JSONEncoder().encode(response), let str = String(data: data, encoding: .utf8) {
                        self?.rawLessonResponse = str
                    }
                    self?.currentLesson = response.data
                case .failure(let error):
                    print("🔴 [LearnTabState] generateSentence Failed: \(error.localizedDescription)")
                    self?.generationState = .idle
                }
            }
        }
    }
    


    // MARK: - Helpers
    

    
    // MARK: - Image Analysis
    func analyzeImageAndGenerateMoments(image: UIImage) {
        guard let sessionToken = appState.authToken else { return }
        
        AnalyzeImageService.shared.analyzeImage(image: image, sessionToken: sessionToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if case .success(let response) = result, let data = response.data {
                    self.setActivePlace(place: data.toMicroSituationData())
                } else {
                    self.handleNoDataFallback()
                }
            }
        }
    }
    
    // MARK: - Text Analysis (Unified Flow)
    func generateMomentsForPlace(name: String) {
        guard !name.isEmpty, let sessionToken = appState.authToken, !sessionToken.isEmpty else { return }
        
        GenerateMomentsService.shared.generateMoments(placeName: name, sessionToken: sessionToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if case .success(let response) = result, let data = response.data {
                    self.setActivePlace(place: data.toMicroSituationData())
                } else {
                    self.handleNoDataFallback()
                }
            }
        }
    }
    
    // MARK: - Selection & Deep Links

    
    func handleDeepLink(placeName: String, hour: Int) {
        print("\n🟢 [LearnTabState] handleDeepLink called")
        print("   - Place: '\(placeName)'")
        print("   - Hour: \(hour)")
        
        let place = MicroSituationData(
            place_name: placeName,
            latitude: 0,
            longitude: 0,
            time: "",
            hour: hour,
            created_at: "",
            context_description: nil,
            micro_situations: [],
            priority_score: 2.0,
            distance_meters: 0,
            time_span: "",
            type: "deep_link",
            profession: appState.profession,
            updated_at: "",
            target_language: nil,
            document_id: UUID().uuidString
        )
        self.setActivePlace(place: place, isPersistent: true)
    }

}


extension LearnTabState {
    private func calculateCurrentStreak(practiceDates: [String]) -> Int {
        guard !practiceDates.isEmpty else { return 0 }
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let validDates = practiceDates.compactMap { formatter.date(from: $0) }
        guard !validDates.isEmpty else { return 0 }
        let uniqueDates = Set(validDates); let sortedDates = uniqueDates.sorted(by: >)
        let calendar = Calendar.current; let today = Date()
        guard let latestDate = sortedDates.first else { return 0 }
        let isToday = calendar.isDateInToday(latestDate)
        let isYesterday = calendar.isDate(latestDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today)!)
        if !isToday && !isYesterday { return 0 }
        var currentStreak = 1; var previousDate = latestDate
        for i in 1..<sortedDates.count {
            let date = sortedDates[i]
            if let expectedPrevDay = calendar.date(byAdding: .day, value: -1, to: previousDate),
               calendar.isDate(date, inSameDayAs: expectedPrevDay) {
                currentStreak += 1; previousDate = date
            } else { break }
        }
        return currentStreak
    }
    // MARK: - Centralized Selection
    
    /// Sets the active places in the Learn Tab lineup and unifies the handover from all sources.
    /// - Parameters:
    ///   - places: The MicroSituationData objects containing moments.
    ///   - isPersistent: If true, adds/moves the first place to the top of the timeline history.
    func setActivePlace(places: [MicroSituationData], isPersistent: Bool = false) {
        let name = places.first?.place_name ?? "nil"
        print("\n🟢 [LearnTabState] setActivePlace called")
        print("   - Count: \(places.count)")
        print("   - First Name: '\(name)'")
        print("   - Persistent: \(isPersistent)")
        
        if isPersistent, let firstPlace = places.first {
            print("   🔹 Updating Timeline History...")
            allTimelinePlaces.removeAll { $0.place_name == firstPlace.place_name }
            allTimelinePlaces.insert(firstPlace, at: 0)
        }
        
        DispatchQueue.main.async {
            print("   ✅ [LearnTabState] Updating UI for Active Result(s)")
            self.recommendedPlaces = places
            
            // Centralized UI Reset
            
            // Auto-select first category of the first place if available
            if let firstCat = places.first?.micro_situations?.first?.category {
                print("      - Auto-selecting category: '\(firstCat)'")
                self.selectedRecommendedCategory = firstCat
            }
        }
    }
    
    // Internal helper for single place handover
    func setActivePlace(place: MicroSituationData, isPersistent: Bool = false) {
        self.setActivePlace(places: [place], isPersistent: isPersistent)
    }
    
    func clearRecommendedPlaces() {
        print("🟡 [LearnTabState] clearRecommendedPlaces called")
        DispatchQueue.main.async {
            self.recommendedPlaces = []
        }
    }
    
    // MARK: - Centralized Error Handling
    
    private func handleNoDataFallback() {
        print("⚠️ [LearnTabState] No Data / Error -> Triggering Fallback Flow")
        DispatchQueue.main.async {
            self.showingNoDataError = true
            
            // Wait 2 seconds, then revert and load recommendations
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                print("   Time's up! Reverting to Suggested Places...")
                self?.showingNoDataError = false
                self?.loadRecommendations()
            }
        }
    }
}
