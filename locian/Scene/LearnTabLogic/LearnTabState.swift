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
    @Published var firstRecommendedPlace: String? = nil
    @Published var firstRecommendedPlaceTimeGap: String? = nil
    @Published var firstRecommendedPlaceTime: String? = nil
    @Published var firstRecommendedPlaceDay: String? = nil
    
    @Published var activeMoments: [MicroSituationData]? = nil
    @Published var activeGeneratingMoment: String? = nil
    @Published var isGeneratingMoments: Bool = false
    @Published var isLoadingMoments: Bool = false
    @Published var isAnalyzingImage: Bool = false
    @Published var noPlacesFound: Bool = false

    @Published var selectedTimelineHour: Int = Calendar.current.component(.hour, from: Date())
    
    @Published var pastMoments: [String] = []
    
    @Published var recentHistory: [StudiedPlaceWithSituations] = []
    @Published var isLoadingHistory: Bool = false
    @Published var hasAnyStudiedPlaces: Bool = false
    @Published var currentSectionTimeSpan: String? = nil
    
    // Unified Timeline Data
    @Published var allTimelinePlaces: [MicroSituationData] = []
    
    // UI-Ready Properties (Pure Data for Views)
    @Published var uiPlaceName: String = "UNKNOWN"
    @Published var uiCategories: [UnifiedMomentSection] = []
    @Published var uiSelectedCategoryName: String? = nil
    @Published var uiMomentsInSelectedCategory: [UnifiedMoment] = []
    @Published var uiStreakText: String = ""
    
    // Teaching Flow Properties
    @Published var rawLessonResponse: String? = nil
    @Published var generationState: SentenceGenerationState = .idle
    @Published var currentLesson: GenerateSentenceData? = nil
    @Published var showLessonView: Bool = false
    @Published var isEmbeddingsReady: Bool = false
    
    var isGeneratingSentence: Bool {
        return generationState != .idle
    }
    
    let appState: AppStateManager
    var cancellables = Set<AnyCancellable>()
    
    init(appState: AppStateManager) {
        self.appState = appState
        
        setupObservers()
        
        if appState.hasInitialHistoryLoaded {
             print("♻️ [LearnTabState] Global load complete. Restoring local state from AppStateManager...")
             if let persistedTimeline = appState.timeline {
                 self.processTimeline(persistedTimeline)
                 self.hasAnyStudiedPlaces = true
             } else {
                 self.hasAnyStudiedPlaces = false
             }
        }
    }
    
    private func setupObservers() {
        // Sync UI properties whenever core state changes
        Publishers.CombineLatest($selectedTimelineHour, $allTimelinePlaces)
            .sink { [weak self] hour, places in
                self?.syncUIProperties(hour: hour)
            }
            .store(in: &cancellables)
            
        $uiSelectedCategoryName
            .sink { [weak self] categoryName in
                self?.syncUIMoments(categoryName: categoryName)
            }
            .store(in: &cancellables)
    }
    
    private func syncUIProperties(hour: Int) {
        let hourInt = hour
        let currentPlace = self.stickyPlaceForHour(hourInt)
        let name = currentPlace?.place_name ?? "UNKNOWN"
        let categories = currentPlace?.micro_situations ?? []
        let streak = appState.userLanguagePairs.first(where: { $0.is_default }).map { 
            "\(calculateCurrentStreak(practiceDates: $0.practice_dates)) " + LocalizationManager.shared.string(.daysLabel)
        } ?? ""

        print("🔄 [StateSync] Syncing UI for Hour: \(hourInt). Result: '\(name)' (\(categories.count) categories)")

        DispatchQueue.main.async {
            self.uiPlaceName = name
            self.uiCategories = categories
            self.uiStreakText = streak
            
            // Auto-select first category if needed
            if let firstCat = categories.first?.name {
                if self.uiSelectedCategoryName == nil || !categories.contains(where: { $0.name == self.uiSelectedCategoryName }) {
                    print("🔄 [StateSync] Auto-selecting category: \(firstCat)")
                    self.uiSelectedCategoryName = firstCat
                }
            } else {
                self.uiSelectedCategoryName = nil
            }
        }
    }
    
    private func syncUIMoments(categoryName: String?) {
        guard let categoryName = categoryName else {
            self.uiMomentsInSelectedCategory = []
            return
        }
        
        let moments = uiCategories.first(where: { $0.name == categoryName })?.moments ?? []
        DispatchQueue.main.async {
            self.uiMomentsInSelectedCategory = moments
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
        
        let authStatus = LocationManager.shared.authorizationStatus
        if authStatus == .notDetermined {
             PermissionsService.ensureLocationAccess { _ in
                 // Location status updated, proceed with load if status changed
             }
        }

        self.recentHistory = []
        self.firstRecommendedPlace = nil
        isLoadingHistory = true
        appState.isLoadingTimeline = true

        LearnTabService.shared.fetchAndLoadContent(sessionToken: sessionToken) { [weak self] result in
            guard let self = self else { return }
            self.isLoadingHistory = false
            self.appState.isLoadingTimeline = false
            
            switch result {
            case .success(let data):
                self.appState.timeline = data.timeline
                self.processTimeline(data.timeline)
                self.hasAnyStudiedPlaces = !self.noPlacesFound
                
                // 🚀 Sync UI immediately after processing
                self.syncUIProperties(hour: self.selectedTimelineHour)
                
                // 🚀 CRITICAL: Mark as loaded ONLY after processing all data
                self.appState.hasInitialHistoryLoaded = true
            case .failure(let error):
                print("⚠️ [Timeline] Service failed: \(error.localizedDescription)")
                self.clearState()
                self.appState.hasInitialHistoryLoaded = true // Still mark as loaded to dismiss loading screen
            }
            self.updatePastMomentsForCurrentPlace()
        }
    }
    
    func clearMoments() {
        activeMoments = nil
        isGeneratingMoments = false
        isAnalyzingImage = false
        fetchFirstRecommendedPlace()
    }
    
    func clearState() {
        self.hasAnyStudiedPlaces = false
        self.activeMoments = nil
        self.allTimelinePlaces = []
        self.currentSectionTimeSpan = nil
        self.noPlacesFound = true
    }

    func selectNextCategory() {
        guard !uiCategories.isEmpty else { return }
        guard let current = uiSelectedCategoryName,
              let currentIndex = uiCategories.firstIndex(where: { $0.name == current }) else {
            uiSelectedCategoryName = uiCategories.first?.name
            return
        }
        
        let nextIndex = (currentIndex + 1) % uiCategories.count
        uiSelectedCategoryName = uiCategories[nextIndex].name
    }
    
    func selectPreviousCategory() {
        guard !uiCategories.isEmpty else { return }
        guard let current = uiSelectedCategoryName,
              let currentIndex = uiCategories.firstIndex(where: { $0.name == current }) else {
            uiSelectedCategoryName = uiCategories.last?.name
            return
        }
        
        let prevIndex = (currentIndex - 1 + uiCategories.count) % uiCategories.count
        uiSelectedCategoryName = uiCategories[prevIndex].name
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
                        self.processTimeline(data.timeline)
                        self.hasAnyStudiedPlaces = !self.noPlacesFound
                    case .failure: self.clearState()
                    }
                    self.updatePastMomentsForCurrentPlace()
                    continuation.resume()
                }
            }
        }
    }
    
     // MARK: - Timeline Logic
    
    func processTimeline(_ timeline: TimelineData) {
        self.allTimelinePlaces = timeline.places
        self.currentSectionTimeSpan = self.allTimelinePlaces.first?.time_span ?? "Now"
        self.noPlacesFound = self.allTimelinePlaces.isEmpty
        
        if let prioritized = self.findPrioritizedPlace(in: self.allTimelinePlaces) {
            self.firstRecommendedPlace = prioritized.place_name
            self.firstRecommendedPlaceTime = prioritized.time
            // Calculate time gap using logic layer utility
            self.firstRecommendedPlaceTimeGap = prioritized.time_span ?? TimeFormattingLogic.shared.calculateTimeGap(hour: prioritized.hour, time: prioritized.time)
            self.activeMoments = self.convertStringsToMoments(from: prioritized)
        } else {
            self.firstRecommendedPlace = nil
            self.activeMoments = nil
        }
    }
    
    func stickyPlaceForHour(_ hour: Int) -> MicroSituationData? {
        if allTimelinePlaces.isEmpty { 
            print("🔍 [StickyPlace] allTimelinePlaces is EMPTY.")
            return nil 
        }
        
        let candidates = allTimelinePlaces.map { place -> (place: MicroSituationData, distance: Int) in
            let dist = distanceToHour(place.hour, target: hour)
            return (place, dist)
        }
        
        let best = candidates.min(by: { $0.distance < $1.distance })
        
        if let found = best?.place {
            print("🔍 [StickyPlace] Found best match for hour \(hour): '\(found.place_name ?? "nil")' (dist: \(best!.distance))")
            return found
        }
        
        // Fallback: If no "closeness" works (e.g. no hours parsed), return first
        print("🔍 [StickyPlace] No best match found for hour \(hour). Falling back to first place.")
        return allTimelinePlaces.first
    }
    
    private func distanceToHour(_ placeHour: Int?, target: Int) -> Int {
        guard let h = placeHour else { return 999 }
        let diff = abs(h - target); return min(diff, 24 - diff)
    }
    
    // MARK: - Teaching Flow
    
    func generateSentence(for moment: String) {
        guard let sessionToken = appState.authToken, !sessionToken.isEmpty,
              let placeName = firstRecommendedPlace,
              appState.userLanguagePairs.contains(where: { $0.is_default }) else { return }
        
        guard generationState == .idle else { return }
        
        self.activeGeneratingMoment = moment
        generationState = .callingAI
        rawLessonResponse = nil
        self.currentLesson = nil 
        self.isEmbeddingsReady = false
        
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
                    self?.precomputeEmbeddings(for: response.data)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                case .failure:
                    self?.generationState = .idle
                    self?.isEmbeddingsReady = false
                }
            }
        }
    }
    
    func precomputeEmbeddings(for data: GenerateSentenceData?) {
        guard let data = data else { self.isEmbeddingsReady = true; return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let targetCode = data.target_language ?? "es"
            let nativeCode = data.user_language ?? "en"
            var targetStrings: [String] = []
            var nativeStrings: [String] = []
            if let patterns = data.patterns {
                for p in patterns { targetStrings.append(p.target); nativeStrings.append(p.meaning) }
            }
            if let bricks = data.bricks {
                let allBricks = (bricks.constants ?? []) + (bricks.variables ?? []) + (bricks.structural ?? [])
                for b in allBricks { targetStrings.append(b.word); nativeStrings.append(b.meaning) }
            }
            let validator = NeuralValidator()
            validator.updateLocale(LocaleMapper.getLocale(for: targetCode)); validator.precomputeTargets(targetStrings)
            validator.updateLocale(LocaleMapper.getLocale(for: nativeCode)); validator.precomputeTargets(nativeStrings)
            DispatchQueue.main.async { self?.isEmbeddingsReady = true }
        }
    }

    // MARK: - Helpers
    
    private func getTimelineContext() -> (previous: [TimelinePlaceContext], future: [TimelinePlaceContext]) {
        let currentHour = self.selectedTimelineHour
        
        // Find previous places (sorted by closest to current hour)
        let previous = allTimelinePlaces
            .filter { ($0.hour ?? 0) < currentHour && $0.place_name != nil }
            .sorted(by: { ($0.hour ?? 0) > ($1.hour ?? 0) })
            .map { TimelinePlaceContext(place_name: $0.place_name!, time: $0.time ?? "") }
            
        // Find future places (sorted by closest to current hour)
        let future = allTimelinePlaces
            .filter { ($0.hour ?? 0) > currentHour && $0.place_name != nil }
            .sorted(by: { ($0.hour ?? 0) < ($1.hour ?? 0) })
            .map { TimelinePlaceContext(place_name: $0.place_name!, time: $0.time ?? "") }
            
        return (Array(previous.prefix(3)), Array(future.prefix(3)))
    }
    
    func getCurrentTimeString() -> String {
        let formatter = DateFormatter(); formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
    
    func getCurrentLocation() -> (lat: Double, long: Double) {
        if let loc = LocationManager.shared.currentLocation { return (loc.coordinate.latitude, loc.coordinate.longitude) }
        return (0.0, 0.0)
    }
    
    func getCurrentDateString() -> String {
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    func hasPlace(forHour hour: Int) -> Bool {
        return allTimelinePlaces.contains { $0.hour == hour }
    }

    func convertStringsToMoments(from place: MicroSituationData) -> [MicroSituationData] {
        let allMoments = (place.micro_situations ?? []).flatMap { $0.moments.map { $0.text } }
        return allMoments.map { situationString in
            MicroSituationData(place_name: place.place_name, latitude: place.latitude, longitude: place.longitude, time: place.time, hour: place.hour, type: place.type, created_at: place.created_at, context_description: nil, micro_situations: [], priority_score: place.priority_score, distance_meters: place.distance_meters, time_span: place.time_span, profession: place.profession, updated_at: place.updated_at, target_language: place.target_language, document_id: UUID().uuidString)
        }
    }
    
    func findPrioritizedPlace(in places: [MicroSituationData]) -> MicroSituationData? {
        if places.isEmpty { return nil }
        if let imagePlace = places.first(where: { $0.type == "image" }) { return imagePlace }
        if let customPlace = places.first(where: { $0.type == "custom" }) { return customPlace }
        return places.first
    }
    
    func updatePastMomentsForCurrentPlace() {
        guard let currentPlace = firstRecommendedPlace else { self.pastMoments = []; return }
        let normalizedCurrent = currentPlace.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let matchingSituations = allTimelinePlaces
            .filter { ($0.place_name ?? "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == normalizedCurrent }
            .flatMap { ($0.micro_situations ?? []).flatMap { $0.moments.map { $0.text } } }
        let uniqueSituations = Array(Set(matchingSituations))
        DispatchQueue.main.async { self.pastMoments = uniqueSituations }
    }
    
    // MARK: - Image Analysis
    func analyzeImageAndGenerateMoments(image: UIImage) {
        self.isAnalyzingImage = true
        self.activeMoments = nil
        self.firstRecommendedPlace = "Understanding..."
        self.firstRecommendedPlaceTimeGap = "Processing Image"
        
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
                        self.setCustomActivePlace(name: data.place_name, situations: data.micro_situations)
                    } else {
                        self.isAnalyzingImage = false
                        self.firstRecommendedPlace = "Unknown"
                    }
                case .failure:
                    self.isAnalyzingImage = false
                    self.firstRecommendedPlace = "Unknown"
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
        self.activeMoments = nil
        self.firstRecommendedPlace = name
        self.firstRecommendedPlaceTimeGap = "Generating Context..."
        
        // Use the new GenerateMomentsService
        GenerateMomentsService.shared.generateMoments(placeName: name, sessionToken: sessionToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isAnalyzingImage = false
                
                switch result {
                case .success(let response):
                    if let data = response.data {
                        let finalName = data.place_name.isEmpty ? name : data.place_name
                        self.setCustomActivePlace(name: finalName, situations: data.micro_situations)
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
    
    func predictPlaceFromList(places: [String]) {
        guard !places.isEmpty else { return }
        guard let sessionToken = appState.authToken, !sessionToken.isEmpty else { return }
        
        self.isAnalyzingImage = true // Re-use loading state
        self.activeMoments = nil
        self.firstRecommendedPlace = "Analyzing Context..."
        self.firstRecommendedPlaceTimeGap = "Predicting Place..."
        
        // Use the new PredictPlaceService
        PredictPlaceService.shared.predictPlace(
            places: places,
            sessionToken: sessionToken
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isAnalyzingImage = false
                
                switch result {
                case .success(let response):
                    if let data = response.data {
                        self.setCustomActivePlace(name: data.place_name, situations: data.micro_situations ?? [])
                    } else {
                        self.setCustomActivePlace(name: places.first ?? "Unknown")
                    }
                case .failure(let error):
                    print("⚠️ [PredictPlace] Failed: \(error.localizedDescription)")
                    self.setCustomActivePlace(name: places.first ?? "Unknown")
                }
            }
        }
    }
    
    // MARK: - Selection & Deep Links
    func selectPlace(_ place: MicroSituationData) {
        self.firstRecommendedPlace = place.place_name
        self.firstRecommendedPlaceTimeGap = (place.document_id != nil) ? (place.time_span ?? self.currentSectionTimeSpan) : (place.time_span ?? place.time)
        self.firstRecommendedPlaceTime = place.time
        self.activeMoments = self.convertStringsToMoments(from: place)
        self.pastMoments = (place.micro_situations ?? []).flatMap { $0.moments.map { $0.text } }
    }
    
    func handleDeepLink(placeName: String, hour: Int) { self.selectedTimelineHour = hour }
    
    func setCustomActivePlace(name: String, situations: [UnifiedMomentSection]? = nil) {
        let timeString = self.getCurrentTimeString(); let hour = Calendar.current.component(.hour, from: Date())
        let dateString = self.getCurrentDateString(); let loc = self.getCurrentLocation()
        
        // Create custom place with provided situations (if any)
        let customPlace = MicroSituationData(
            place_name: name, 
            latitude: loc.lat, 
            longitude: loc.long, 
            time: timeString, 
            hour: hour, 
            type: "custom", 
            created_at: dateString, 
            context_description: nil, 
            micro_situations: situations ?? [], // INSERTED SITUATIONS
            priority_score: 2.0, 
            distance_meters: 0, 
            time_span: timeString, 
            profession: appState.profession, 
            updated_at: dateString, 
            target_language: nil, 
            document_id: UUID().uuidString
        )
        
        // Update Timeline
        allTimelinePlaces.removeAll { $0.place_name == name }
        allTimelinePlaces.insert(customPlace, at: 0)
        
        // Update Selection State
        self.selectedTimelineHour = hour
        self.firstRecommendedPlace = name
        
        // POPULATE MOMENTS
        if let situations = situations, !situations.isEmpty {
            self.activeMoments = self.convertStringsToMoments(from: customPlace)
            self.pastMoments = situations.flatMap { $0.moments.map { $0.text } }
        } else {
            self.activeMoments = nil
            self.pastMoments = []
        }
    }
}

// MARK: - Service
class LearnTabService {
    static let shared = LearnTabService(); private init() {}
    func fetchAndLoadContent(sessionToken: String, completion: @escaping (Result<(timeline: TimelineData, places: [MicroSituationData]), Error>) -> Void) {
        GetStudiedPlacesService.shared.fetchStudiedPlaces(sessionToken: sessionToken) { result in
            switch result {
            case .success(let response):
                if let data = response.data {
                    let timeline = TimelineData(places: data.places)
                    completion(.success((timeline, data.places)))
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
