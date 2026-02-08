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

// MARK: - Timeline Data (App-level wrapper)
struct TimelineData {
    let places: [MicroSituationData]
}

// MARK: - Main State
class LearnTabState: ObservableObject {
    @Published var activeGeneratingMoment: String? = nil
    @Published var isGeneratingMoments: Bool = false
    @Published var isLoadingMoments: Bool = false
    @Published var isAnalyzingImage: Bool = false

    @Published var recentHistory: [StudiedPlaceWithSituations] = []
    @Published var isLoadingHistory: Bool = false
    @Published var hasAnyStudiedPlaces: Bool = false

    
    // Unified Timeline Data
    @Published var allTimelinePlaces: [MicroSituationData] = []
    
    // Recommended Context Data (Predicted/Analyzed)
    @Published var recommendedPlaces: [MicroSituationData] = []
    
    // Error State
    @Published var showingNoDataError: Bool = false
    
    // Global Recommendations (Flat View Models)
    struct RecommendedMomentViewModel: Identifiable, Equatable {
        let id: String
        let moment: String
        let time: String
        let category: String
        let placeName: String
    }
    
    struct RecommendationSection: Identifiable {
        let id = UUID()
        let title: String // ADDED: To show "Most Likely" vs "Likely"
        let items: [RecommendedMomentViewModel]
    }
    
    @Published var globalRecommendations: [RecommendationSection] = []
    @Published var selectedRecommendedCategory: String? = nil
    
    // Local Recommendations
    @Published var mostLikelyPlaces: [ScoredPlace] = []
    @Published var likelyPlaces: [ScoredPlace] = []
    

    
    @Published var isShowingGlobalRecommendations: Bool = false
    
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
        return isLoadingHistory || isAnalyzingImage || appState.isLoadingTimeline
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
    }
    

    // MARK: - Fetching Logic
    
    func fetchFirstRecommendedPlace() {
        print("🟢 [LearnTabState] fetchFirstRecommendedPlace called by View/Event")
        
        guard let sessionToken = appState.authToken, !sessionToken.isEmpty else {
            print("🔴 [LearnTabState] ABORTING: No Auth Token available. User might need to login.")
            return
        }
        
        guard !appState.isLoadingTimeline else {
            print("LearnTabState: Skipping fetch - Already loading history")
            return
        }

        guard !appState.userLanguagePairs.isEmpty else {
            print("🔴 [LearnTabState] Skipping fetch - No language pairs configured.")
            self.hasAnyStudiedPlaces = false 
            return
        }
        
        self.recentHistory = []
        isLoadingHistory = true
        appState.isLoadingTimeline = true

        LearnTabService.shared.fetchAndLoadContent(sessionToken: sessionToken) { [weak self] result in
            guard let self = self else { return }
            self.isLoadingHistory = false
            // Keep appState.isLoadingTimeline = true until we set hasInitialHistoryLoaded
            // to prevent the View from seeing a "gap" where !loading && !loaded -> triggering a re-fetch.
            
            switch result {
            case .success(let data):
                print("\n🟢 [LearnTabState] fetchAndLoadContent SUCCESS")
                print("   - Places Fetched: \(data.places.count)")
                print("   - Intent Present: \(data.intent != nil ? "YES" : "NO")")
                
                self.appState.timeline = data.timeline
                self.allTimelinePlaces = data.places
                self.hasAnyStudiedPlaces = !data.places.isEmpty
                
                // Mark as loaded BEFORE clearing the loading flag
                self.appState.hasInitialHistoryLoaded = true
                self.appState.isLoadingTimeline = false
                
                // 🚀 Local Intent-Based Recommendations
                if let intent = data.intent {
                    print("\n🟢 [LearnTabState] START: Processing Recommendations")
                    print("   - Intent Received: '\(intent)'")
                } else {
                    print("\n🔴 [LearnTabState] STOP: No Intent received in data. Skipping Local Recommendations.")
                }

                if let intent = data.intent {
                    print("   - History Context: \(data.places.count) places")
                    print("   - History Context: \(data.places.count) places")
                    
                    print("   🔹 Calling LocalRecommendationService...")
                    let localResult = LocalRecommendationService.shared.recommend(
                        intent: intent, 
                        location: LocationManager.shared.currentLocation, 
                        history: data.places
                    )
                    
                    print("   ✅ Service Returned Results")
                    print("   - Sections: \(localResult.sections.count)")
                    print("   - Most Likely Count: \(localResult.mostLikely.count)")
                    print("   - Likely Count: \(localResult.likely.count)")
                    
                    self.mostLikelyPlaces = localResult.mostLikely
                    self.likelyPlaces = localResult.likely
                    
                    print("   📊 [STATE UPDATE] mostLikelyPlaces count: \(self.mostLikelyPlaces.count)")
                    print("   📊 [STATE UPDATE] likelyPlaces count: \(self.likelyPlaces.count)")
                    
                    // 🚨 QUALITY THRESHOLD CHECK: Fallback to Context Endpoint if needed
                    if !localResult.hasHighQualityMatches {
                        print("\n   ⚠️ [FALLBACK] No high-quality matches found (similarity < 0.6)")
                        print("   🔄 [FALLBACK] Calling Context Endpoint to generate new moments...")
                        
                        // TRIGGER LOADING STATE
                        DispatchQueue.main.async { self.isAnalyzingImage = true }
                        
                        // Call the context endpoint to get fresh recommendations
                        PredictPlaceService.shared.predictPlace(sessionToken: sessionToken) { [weak self] result in
                            DispatchQueue.main.async {
                                guard let self = self else { return }
                                self.isAnalyzingImage = false // STOP LOADING
                                
                                switch result {
                                case .success(let response):
                                    print("   ✅ [FALLBACK] Context Endpoint Success")
                                    if let data = response.data {
                                        print("      Predicted Place: '\(data.place_name)'")
                                        self.setRecommendedPlace(name: data.place_name, situations: data.micro_situations ?? [])
                                    } else {
                                        print("      ⚠️ [FALLBACK] Context returned no data")
                                        self.handleNoDataFallback()
                                    }
                                case .failure(let error):
                                    print("🔴 [FALLBACK] Context Endpoint Failed: \(error.localizedDescription)")
                                    self.handleNoDataFallback()
                                }
                            }
                        }
                        
                        // Early return - we're waiting for the context endpoint
                        return
                    }
                    
                    if localResult.mostLikely.isEmpty && localResult.likely.isEmpty {
                        print("   ⚠️ [WARNING] Local Recommendation Service returned ZERO places.")
                    }
                    
                    // If we have a strong local match (Most Likely), we could potentially use it immediately
                    if let bestMatch = localResult.mostLikely.first {
                        print("   🏆 Best Match Found: '\(bestMatch.extractedName)' (Score: \(bestMatch.score))")
                        
                        // 🚀 UPDATE UI WITH SIDEBAR CATEGORIES ("Most Likely", "Likely")
                        print("\n   📥 [STEP: Mapping Service -> UnifiedMomentSection]")
                        
                        var unifiedSections: [UnifiedMomentSection] = []
                        
                        for resultSection in localResult.sections {
                            print("      ⚡️ Mapping Section: '\(resultSection.title)'")
                            
                            // Convert RecommendedItems to UnifiedMoments
                            // Note: We are taking the first moment from each recommended place to represent it
                            let moments: [UnifiedMoment] = resultSection.items.compactMap { scoredPlace in
                                guard let micro = scoredPlace.place.micro_situations?.first,
                                      let firstMoment = micro.moments.first else { 
                                    print("         ⚠️ [SKIP] Missing moment data for: \(scoredPlace.extractedName)")
                                    return nil 
                                }
                                
                                // Create UnifiedMoment
                                // We preserve the original moment text.
                                // NOTE: If we want to display the place name on the card too, we might need to append it?
                                // For now, we stick to the moment text as requested ("just the moment").
                                return UnifiedMoment(
                                    text: firstMoment.text,
                                    keywords: nil
                                )
                            }
                            
                            if !moments.isEmpty {
                                let section = UnifiedMomentSection(
                                    category: resultSection.title.uppercased(), // E.g., "MOST LIKELY"
                                    moments: moments
                                )
                                unifiedSections.append(section)
                                print("         ✅ Section Mapped: '\(section.category)' with \(moments.count) moments.")
                            }
                        }
                        
                        // Create Synthetic Place to hold these sections
                        // This trick allows the existing View logic (Sidebar, Cycling) to work without modification.
                        let syntheticPlace = MicroSituationData(
                            place_name: localResult.suggestedPlaceName,
                            latitude: 0, longitude: 0,
                            time: "LIVE", 
                            hour: 0,
                            type: "synthetic",
                            created_at: "",
                            context_description: nil,
                            micro_situations: unifiedSections, // <--- The categories are here
                            priority_score: 10.0,
                            distance_meters: 0,
                            time_span: "",
                            profession: appState.profession,
                            updated_at: "",
                            target_language: nil,
                            document_id: UUID().uuidString
                        )
                        
                        print("\n   📤 [STEP: Final UI Publication]")
                        print("   - Created Synthetic Place with \(unifiedSections.count) categories.")
                        
                        // Update State
                        print("   🔹 Dispatching UI Update...")
                        self.recommendedPlaces = [syntheticPlace]
                        self.isShowingGlobalRecommendations = false // CRITICAL: Enables Sidebar View
                        
                        if let firstCat = unifiedSections.first?.category {
                            print("      - Auto-selecting category: '\(firstCat)'")
                            self.selectedRecommendedCategory = firstCat
                        } else {
                            self.selectedRecommendedCategory = nil
                        }
                    }
                }
                // 🚀 Sync UI
                self.syncUIProperties()
                self.appState.hasInitialHistoryLoaded = true
                self.appState.isLoadingTimeline = false // Ensure we clear the flag
            case .failure(let error):
                print("⚠️ [Timeline] Service failed: \(error.localizedDescription)")
                self.clearState()
                self.appState.hasInitialHistoryLoaded = true
                self.appState.isLoadingTimeline = false // Ensure we clear the flag
            }
        }
    }
    
    func clearMoments() {
        isGeneratingMoments = false
        isAnalyzingImage = false
        fetchFirstRecommendedPlace()
    }
    
    func clearState() {
        self.hasAnyStudiedPlaces = false
        self.allTimelinePlaces = []
    }

    // MARK: - Context Refresh (Manual)
    
    func refreshTokenContext() {
        print("\n🟢 [LearnTabState] refreshTokenContext called (Manual Refresh)")
        
        guard let sessionToken = appState.authToken, !sessionToken.isEmpty else {
            print("🔴 [LearnTabState] Refresh Context ABORT: No Token")
            return
        }
        
        self.isAnalyzingImage = true // Show loading indicator
        
        print("   🔹 Calling PredictPlaceService (Context API)...")
        PredictPlaceService.shared.predictPlace(sessionToken: sessionToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isAnalyzingImage = false
                
                switch result {
                case .success(let response):
                    print("   ✅ [LearnTabState] Context Refresh Success")
                    if let data = response.data {
                        print("      Predicted Place: '\(data.place_name)'")
                        
                        // Use helper to update UI - eliminates duplication
                        self.setRecommendedPlace(name: data.place_name, situations: data.micro_situations)
                        
                    } else {
                        print("      ⚠️ [LearnTabState] Success but Data is nil")
                    }
                case .failure(let error):
                    print("🔴 [LearnTabState] Context Refresh Failed: \(error.localizedDescription)")
                    self.handleNoDataFallback()
                }
            }
        }
    }



    func forceRefreshHistory() async {
        print("\n🟢 [LearnTabState] forceRefreshHistory called")
        return await withCheckedContinuation { continuation in
            guard let sessionToken = appState.authToken, !sessionToken.isEmpty else {
                print("🔴 [LearnTabState] refresh ABORT: No Token")
                continuation.resume()
                return
            }
            if isLoadingHistory { 
                print("⚠️ [LearnTabState] refresh SKIP: Already loading")
                continuation.resume(); return 
            }
            
            print("   🔹 Starting Refresh (API Call)...")
            isLoadingHistory = true
            
            LearnTabService.shared.fetchAndLoadContent(sessionToken: sessionToken) { [weak self] result in
                guard let self = self else { continuation.resume(); return }
                DispatchQueue.main.async {
                    self.isLoadingHistory = false
                    self.appState.hasInitialHistoryLoaded = true
                    switch result {
                    case .success(let data):
                        print("   ✅ [LearnTabState] Refresh Success")
                        print("      - Places: \(data.places.count)")
                        self.appState.timeline = data.timeline
                        self.allTimelinePlaces = data.places
                        self.hasAnyStudiedPlaces = !data.places.isEmpty
                    case .failure(let error):
                        print("🔴 [LearnTabState] Refresh Failed: \(error.localizedDescription)")
                        self.clearState()
                    }
                    continuation.resume()
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
    
    func generateSentence(for moment: String) {
        print("\n🟢 [LearnTabState] generateSentence called")
        print("   - Moment: '\(moment)'")
        
        guard let sessionToken = appState.authToken, !sessionToken.isEmpty,
              appState.userLanguagePairs.contains(where: { $0.is_default }) else {
            print("🔴 [LearnTabState] generateSentence ABORT: Missing Token or Language Pair")
            return
        }
        
        // Fallback to recommended place if available
        let placeName = recommendedPlaces.first?.place_name ?? "Unknown"
        print("   - Context Place: '\(placeName)'")
        
        guard generationState == .idle else {
            print("⚠️ [LearnTabState] generateSentence SKIP: State is not idle (\(generationState))")
            return
        }
        
        self.activeGeneratingMoment = moment
        generationState = .callingAI
        rawLessonResponse = nil
        self.currentLesson = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            if self?.generationState == .callingAI { self?.generationState = .generating }
        }
        
        print("   🔹 Calling GenerateSentenceService...")
        // Use the new GenerateSentenceService (gathers data internally)
        GenerateSentenceService.shared.generateSentence(
            placeName: placeName,
            microSituation: moment,
            sessionToken: sessionToken
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("   ✅ [LearnTabState] generateSentence Success")
                    self?.generationState = .preparing
                    if let data = try? JSONEncoder().encode(response), let str = String(data: data, encoding: .utf8) {
                        print("      Raw JSON Size: \(str.count) bytes")
                        self?.rawLessonResponse = str
                    }
                    self?.currentLesson = response.data
                    print("      Lesson Data Set. Ready to Show.")
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
        print("\n🟢 [LearnTabState] analyzeImageAndGenerateMoments called")
        self.isAnalyzingImage = true

        guard let sessionToken = appState.authToken else {
            print("🔴 [LearnTabState] analyzeImage ABORT: No Token")
            self.isAnalyzingImage = false
            return
        }
        
        print("   🔹 Calling AnalyzeImageService...")
        // Use the new AnalyzeImageService
        AnalyzeImageService.shared.analyzeImage(image: image, sessionToken: sessionToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    print("   ✅ [LearnTabState] Analyze Success")
                    if let data = response.data {
                        print("      Place: '\(data.place_name)'")
                        print("      Situations: \(data.micro_situations.count) categories found")
                        self.isAnalyzingImage = false
                        self.setRecommendedPlace(name: data.place_name, situations: data.micro_situations)
                    } else {
                        print("      ⚠️ [LearnTabState] Analyze Success but Data is nil")
                        self.isAnalyzingImage = false
                    }
                case .failure(let error):
                    print("🔴 [LearnTabState] Analyze Failed: \(error.localizedDescription)")
                    self.handleNoDataFallback()
                }
                
                self.appState.isAnalyzingImage = false
            }
        }
    }
    
    // MARK: - Text Analysis (Unified Flow)
    func generateMomentsForPlace(name: String) {
        print("\n🟢 [LearnTabState] generateMomentsForPlace called")
        print("   - Name: '\(name)'")
        guard !name.isEmpty else { return }
        guard let sessionToken = appState.authToken, !sessionToken.isEmpty else { return }
        
        self.isAnalyzingImage = true // Re-use loading state for UI consistency
        
        print("   🔹 Calling GenerateMomentsService...")
        // Use the new GenerateMomentsService
        GenerateMomentsService.shared.generateMoments(placeName: name, sessionToken: sessionToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isAnalyzingImage = false
                
                switch result {
                case .success(let response):
                    print("   ✅ [LearnTabState] generateMoments Success")
                    if let data = response.data {
                        let finalName = data.place_name.isEmpty ? name : data.place_name
                        print("      Final Name: '\(finalName)'")
                        print("      Situations: \(data.micro_situations.count) categories")
                        self.setRecommendedPlace(name: finalName, situations: data.micro_situations)
                    } else {
                        print("      ⚠️ Missing Data. Setting Custom Active Place.")
                        self.setCustomActivePlace(name: name)
                    }
                case .failure(let error):
                    print("🔴 [GenerateMoments] Failed: \(error.localizedDescription)")
                    self.handleNoDataFallback()
                }
            }
        }
    }
    
    // MARK: - Context-Based Place Prediction
    
    func predictPlaceFromList(places: [String]? = nil) {
        print("\n🟢 [LearnTabState] predictPlaceFromList called")
        if let p = places { print("   - Custom Places List provided: \(p)") }
        
        guard let sessionToken = appState.authToken, !sessionToken.isEmpty else { 
            print("🔴 [LearnTabState] predictPlace ABORT: No Token")
            return 
        }
        self.isAnalyzingImage = true
        
        print("   🔹 Calling PredictPlaceService...")
        PredictPlaceService.shared.predictPlace(sessionToken: sessionToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isAnalyzingImage = false
                switch result {
                case .success(let response):
                    print("   ✅ [LearnTabState] Predict Place Success")
                    if let data = response.data {
                        print("      Predicted: '\(data.place_name)'")
                        self.setRecommendedPlace(name: data.place_name, situations: data.micro_situations ?? [])
                    } else {
                        print("      ⚠️ [LearnTabState] Predict Success but Data/PlaceName is nil")
                        self.clearRecommendedPlaces()
                    }
                case .failure(let error):
                    print("🔴 [LearnTabState] Predict Failed: \(error.localizedDescription)")
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
        self.setCustomActivePlace(name: placeName)
    }

    func setCustomActivePlace(name: String, situations: [UnifiedMomentSection]? = nil) {
        print("\n🟢 [LearnTabState] setCustomActivePlace called")
        print("   - Name: '\(name)'")
        print("   - Situations Count: \(situations?.count ?? 0)")
        
        let customPlace = MicroSituationData(
            place_name: name, 
            latitude: 0, 
            longitude: 0, 
            time: "", 
            hour: 0, 
            type: "custom", 
            created_at: "", 
            context_description: nil, 
            micro_situations: situations ?? [], // INSERTED SITUATIONS
            priority_score: 2.0, 
            distance_meters: 0, 
            time_span: "", 
            profession: appState.profession, 
            updated_at: "", 
            target_language: nil, 
            document_id: UUID().uuidString
        )
        
        // Update Timeline
        print("   🔹 Updating Timeline (Removing old '\(name)', inserting new)...")
        allTimelinePlaces.removeAll { $0.place_name == name }
        allTimelinePlaces.insert(customPlace, at: 0)
        
        DispatchQueue.main.async {
            print("   ✅ [LearnTabState] Updating UI Recommendations for Custom Place")
            self.recommendedPlaces = [customPlace]
            if let firstCat = situations?.first?.category {
                print("      - Auto-selecting category: '\(firstCat)'")
                self.selectedRecommendedCategory = firstCat
            }
            self.isShowingGlobalRecommendations = false
        }
    }
}

// MARK: - Service
class LearnTabService {
    static let shared = LearnTabService(); private init() {}
    func fetchAndLoadContent(sessionToken: String, completion: @escaping (Result<(timeline: TimelineData, places: [MicroSituationData], intent: UserIntent?), Error>) -> Void) {
        print("\n🟢 [LearnTabService] fetchAndLoadContent called")
        GetStudiedPlacesService.shared.fetchStudiedPlaces(sessionToken: sessionToken) { result in
            switch result {
            case .success(let response):
                print("   ✅ [LearnTabService] fetch success")
                if let data = response.data {
                    print("      - Places: \(data.places.count)")
                    let timeline = TimelineData(places: data.places)
                    completion(.success((timeline, data.places, data.user_intent)))
                } else {
                    print("      ⚠️ [LearnTabService] Data is NIL")
                    completion(.failure(NSError(domain: "StudiedPlaces", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message ?? "No data returned"])))
                }
            case .failure(let error):
                print("🔴 [LearnTabService] fetch failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
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
}

extension LearnTabState {
    func setRecommendedPlace(name: String, situations: [UnifiedMomentSection]? = nil) {
        print("\n🟢 [LearnTabState] setRecommendedPlace called")
        print("   - Name: '\(name)'")
        print("   - Situations: \(situations?.count ?? 0)")
        
        let customPlace = MicroSituationData(
            place_name: name,
            latitude: 0,
            longitude: 0,
            time: "",
            hour: 0,
            type: "custom",
            created_at: "",
            context_description: nil,
            micro_situations: situations ?? [],
            priority_score: 2.0,
            distance_meters: 0,
            time_span: "",
            profession: appState.profession,
            updated_at: "",
            target_language: nil,
            document_id: UUID().uuidString
        )
        
        DispatchQueue.main.async {
            print("   ✅ [LearnTabState] Updating UI for Recommended Place")
            self.recommendedPlaces = [customPlace]
            if let firstCat = situations?.first?.category {
                print("      - Auto-selecting category: '\(firstCat)'")
                self.selectedRecommendedCategory = firstCat
            }
            self.isShowingGlobalRecommendations = false
        }
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
            self.isAnalyzingImage = false
            self.showingNoDataError = true
            
            // Wait 2 seconds, then revert and fetch fallback
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                print("   Time's up! Reverting to Suggested Places...")
                self?.showingNoDataError = false
                self?.fetchFirstRecommendedPlace()
            }
        }
    }
}
