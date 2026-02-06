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
            self.appState.isLoadingTimeline = false
            
            switch result {
            case .success(let data):
                self.appState.timeline = data.timeline
                self.allTimelinePlaces = data.places
                self.hasAnyStudiedPlaces = !data.places.isEmpty
                
                // 🚀 Local Intent-Based Recommendations
                if let intent = data.intent {
                    print("\n🟢 [LearnTabState] START: Processing Recommendations")
                    print("   - Intent Received: '\(intent)'")
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
                    
                    // If we have a strong local match (Most Likely), we could potentially use it immediately
                    if let bestMatch = localResult.mostLikely.first {
                        print("   🏆 Best Match Found: '\(bestMatch.extractedName)' (Score: \(bestMatch.score))")
                        
                        // 🚀 UPDATE UI WITH GENERIC SECTIONS
                        // STRICT STATE: Just maps whatever the Service provided.
                        
                        print("\n   📥 [STEP: Mapping Service -> ViewModels]")
                        for (i, sec) in localResult.sections.enumerated() {
                             print("      🔸 Section \(i) Input: '\(sec.title)' (\(sec.items.count) items)")
                        }
                        
                        let transformer: (ScoredPlace) -> RecommendedMomentViewModel? = { scoredPlace in
                            let place = scoredPlace.place
                            guard let moment = place.micro_situations?.first?.moments.first,
                                  let category = place.micro_situations?.first?.category else {
                                print("         ⚠️ [SKIP] Missing data for place: \(place.id)")
                                return nil
                            }
                            
                            // Log transformation for first item of each batch to avoid spamming too much, 
                            // but user asked for detail so maybe spam is okay? 
                            // User said "1000 hundred more", so I will log everything.
                            print("         transforming -> [RAW] '\(moment.text)' -> [VM] '\(moment.text)'")
                            
                            return RecommendedMomentViewModel(
                                id: place.document_id ?? UUID().uuidString,
                                moment: moment.text,
                                time: place.time ?? "--:--",
                                category: category,
                                placeName: scoredPlace.extractedName
                            )
                        }
                        
                        self.globalRecommendations = localResult.sections.compactMap { resultSection in
                            print("      ⚡️ Mapping Section: '\(resultSection.title)'")
                            let viewModels = resultSection.items.compactMap { transformer($0) }
                            
                            if viewModels.isEmpty {
                                print("         ❌ Section Empty after mapping. Dropping.")
                                return nil
                            }
                            
                            print("         ✅ Section Mapped: \(viewModels.count) ViewModels created.")
                            return RecommendationSection(items: viewModels)
                        }
                        
                        print("\n   📤 [STEP: Final UI Publication]")
                        print("   - Global Recommendations Array: \(self.globalRecommendations.count) Sections")
                        for (i, sec) in self.globalRecommendations.enumerated() {
                            print("      displaying -> Section \(i): \(sec.items.count) items")
                        }
                        print("--------------------------------------------------\n")
                        
                        // Legacy compatibility (optional)
                        self.recommendedPlaces = localResult.mostLikely.map { $0.place } + localResult.likely.map { $0.place }
                        
                        self.isShowingGlobalRecommendations = true
                        self.selectedRecommendedCategory = nil // Reset filter
                    }
                }
                // 🚀 Sync UI
                self.syncUIProperties()
                self.appState.hasInitialHistoryLoaded = true
            case .failure(let error):
                print("⚠️ [Timeline] Service failed: \(error.localizedDescription)")
                self.clearState()
                self.appState.hasInitialHistoryLoaded = true
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



    func forceRefreshHistory() async {
        return await withCheckedContinuation { continuation in
            guard let sessionToken = appState.authToken, !sessionToken.isEmpty else {
                continuation.resume()
                return
            }
            if isLoadingHistory { continuation.resume(); return }
            isLoadingHistory = true
            
            LearnTabService.shared.fetchAndLoadContent(sessionToken: sessionToken) { [weak self] result in
                guard let self = self else { continuation.resume(); return }
                DispatchQueue.main.async {
                    self.isLoadingHistory = false
                    self.appState.hasInitialHistoryLoaded = true
                    switch result {
                    case .success(let data):
                        self.appState.timeline = data.timeline
                        self.allTimelinePlaces = data.places
                        self.hasAnyStudiedPlaces = !data.places.isEmpty
                    case .failure: 
                        self.clearState()
                    }
                    continuation.resume()
                }
            }
        }
    }

    private func syncUIProperties() {
        let streak = appState.userLanguagePairs.first(where: { $0.is_default }).map { 
            "\(calculateCurrentStreak(practiceDates: $0.practice_dates)) " + LocalizationManager.shared.string(.daysLabel)
        } ?? ""

        DispatchQueue.main.async {
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
                    self.isAnalyzingImage = false
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
                    print("   Fallback: Setting Custom Active Place.")
                    self.setCustomActivePlace(name: name)
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
                    self.clearRecommendedPlaces()
                }
            }
        }
    }
    
    // MARK: - Selection & Deep Links

    
    func handleDeepLink(placeName: String, hour: Int) {
        self.setCustomActivePlace(name: placeName)
    }

    func setCustomActivePlace(name: String, situations: [UnifiedMomentSection]? = nil) {
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
        allTimelinePlaces.removeAll { $0.place_name == name }
        allTimelinePlaces.insert(customPlace, at: 0)
        
        DispatchQueue.main.async {
            self.recommendedPlaces = [customPlace]
            if let firstCat = situations?.first?.category {
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
        GetStudiedPlacesService.shared.fetchStudiedPlaces(sessionToken: sessionToken) { result in
            switch result {
            case .success(let response):
                if let data = response.data {
                    let timeline = TimelineData(places: data.places)
                    completion(.success((timeline, data.places, data.user_intent)))
                } else {
                    completion(.failure(NSError(domain: "StudiedPlaces", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message ?? "No data returned"])))
                }
            case .failure(let error):
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
            self.recommendedPlaces = [customPlace]
            if let firstCat = situations?.first?.category {
                self.selectedRecommendedCategory = firstCat
            }
            self.isShowingGlobalRecommendations = false
        }
    }
    
    func clearRecommendedPlaces() {
        DispatchQueue.main.async {
            self.recommendedPlaces = []
        }
    }
}
