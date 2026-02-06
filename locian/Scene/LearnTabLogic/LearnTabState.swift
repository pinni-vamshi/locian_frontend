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
                    let localResult = LocalRecommendationService.shared.recommend(
                        intent: intent, 
                        location: LocationManager.shared.currentLocation, 
                        history: data.places
                    )
                    
                    self.mostLikelyPlaces = localResult.mostLikely
                    self.likelyPlaces = localResult.likely
                    
                    // If we have a strong local match (Most Likely), we could potentially use it immediately
                    // For now, we still allow the remote prediction to run or override if needed.
                    // If we have a strong local match (Most Likely), we could potentially use it immediately
                    if let bestMatch = localResult.mostLikely.first {
                        print("✅ [LearnTab] Local Best Match: \(bestMatch.extractedName)")
                        
                        // 🚀 UPDATE UI WITH GENERIC SECTIONS
                        // State creates the structure (2 sections).
                        // View iterates sections generically.
                        
                        let transformer: (MicroSituationData) -> RecommendedMomentViewModel? = { place in
                            guard let moment = place.micro_situations?.first?.moments.first,
                                  let category = place.micro_situations?.first?.category else { return nil }
                            
                            return RecommendedMomentViewModel(
                                id: place.document_id ?? UUID().uuidString,
                                moment: moment.text,
                                time: place.time ?? "--:--",
                                category: category,
                                placeName: place.extractedName
                            )
                        }
                        
                        // 1. Most Likely Section
                        let mostLikelyItems = localResult.mostLikely.compactMap { transformer($0.place) }
                        var sections: [RecommendationSection] = []
                        
                        if !mostLikelyItems.isEmpty {
                            sections.append(RecommendationSection(items: mostLikelyItems))
                        }
                        
                        // 2. Likely Section
                        let likelyItems = localResult.likely.compactMap { transformer($0.place) }
                        if !likelyItems.isEmpty {
                            sections.append(RecommendationSection(items: likelyItems))
                        }
                        
                        self.globalRecommendations = sections
                        
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
        guard let sessionToken = appState.authToken, !sessionToken.isEmpty,
              appState.userLanguagePairs.contains(where: { $0.is_default }) else { return }
        
        // Fallback to recommended place if available
        let placeName = recommendedPlaces.first?.place_name ?? "Unknown"
        
        guard generationState == .idle else { return }
        
        self.activeGeneratingMoment = moment
        generationState = .callingAI
        rawLessonResponse = nil
        self.currentLesson = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            if self?.generationState == .callingAI { self?.generationState = .generating }
        }
        
        // Use the new GenerateSentenceService (gathers data internally)
        GenerateSentenceService.shared.generateSentence(
            placeName: placeName,
            microSituation: moment,
            sessionToken: sessionToken
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.generationState = .preparing
                    if let data = try? JSONEncoder().encode(response), let str = String(data: data, encoding: .utf8) {
                        self?.rawLessonResponse = str
                    }
                    self?.currentLesson = response.data
                case .failure:
                    self?.generationState = .idle
                }
            }
        }
    }
    


    // MARK: - Helpers
    

    
    // MARK: - Image Analysis
    func analyzeImageAndGenerateMoments(image: UIImage) {
        self.isAnalyzingImage = true

        guard let sessionToken = appState.authToken else {
            self.isAnalyzingImage = false
            return
        }
        
        // Use the new AnalyzeImageService
        AnalyzeImageService.shared.analyzeImage(image: image, sessionToken: sessionToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if let data = response.data {
                        self.isAnalyzingImage = false
                        self.setRecommendedPlace(name: data.place_name, situations: data.micro_situations)
                    } else {
                        self.isAnalyzingImage = false
                    }
                case .failure:
                    self.isAnalyzingImage = false
                }
                
                self.appState.isAnalyzingImage = false
            }
        }
    }
    
    // MARK: - Text Analysis (Unified Flow)
    func generateMomentsForPlace(name: String) {
        guard !name.isEmpty else { return }
        guard let sessionToken = appState.authToken, !sessionToken.isEmpty else { return }
        
        self.isAnalyzingImage = true // Re-use loading state for UI consistency
        
        // Use the new GenerateMomentsService
        GenerateMomentsService.shared.generateMoments(placeName: name, sessionToken: sessionToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isAnalyzingImage = false
                
                switch result {
                case .success(let response):
                    if let data = response.data {
                        let finalName = data.place_name.isEmpty ? name : data.place_name
                        self.setRecommendedPlace(name: finalName, situations: data.micro_situations)
                    } else {
                        self.setCustomActivePlace(name: name)
                    }
                case .failure(let error):
                    print("⚠️ [GenerateMoments] Failed: \(error.localizedDescription)")
                    self.setCustomActivePlace(name: name)
                }
            }
        }
    }
    
    // MARK: - Context-Based Place Prediction
    
    func predictPlaceFromList(places: [String]? = nil) {
        guard let sessionToken = appState.authToken, !sessionToken.isEmpty else { return }
        self.isAnalyzingImage = true
        
        PredictPlaceService.shared.predictPlace(sessionToken: sessionToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isAnalyzingImage = false
                switch result {
                case .success(let response):
                    if let data = response.data {
                        self.setRecommendedPlace(name: data.place_name, situations: data.micro_situations ?? [])
                    } else {
                        self.clearRecommendedPlaces()
                    }
                case .failure:
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
