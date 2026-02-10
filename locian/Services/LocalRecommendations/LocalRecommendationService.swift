//
//  LocalRecommendationService.swift
//  locian
//
//  Orchestrator for Local Recommendations.
//  Matches User Intent + GPS to Historical Data to provide instant suggestions.
//

import Foundation
import CoreLocation
import Combine

class LocalRecommendationService: ObservableObject {
    static let shared = LocalRecommendationService()
    
    // MARK: - Published States
    @Published var isLoading: Bool = false
    @Published var recommendations: [ScoredPlace] = []
    @Published var mostLikely: [ScoredPlace] = []
    @Published var likely: [ScoredPlace] = []
    @Published var hasHighQualityMatches: Bool = false
    @Published var contextPlace: MicroSituationData? = nil // Published result for context fallback
    
    // Store full result for UI mapping
    var latestResult: LocalRecommendationResult?
    
    private init() {}
    
    // MARK: - Main API
    
    /// Called by AppStateManager during app launch to initialize recommendations
    func initialize(timeline: TimelineData?, intent: UserIntent?) {
        print("\n🚀 [LocalRecommendationService] initialize() called")
        isLoading = true
        
        guard let places = timeline?.places, !places.isEmpty else {
            print("   ⚠️ [LocalRec] Timeline is empty, fetching context recommendations...")
            fetchContextRecommendations()
            return
        }
        
        guard let userIntent = intent else {
            print("   ⚠️ [LocalRec] No user intent available, fetching context recommendations...")
            fetchContextRecommendations()
            return
        }
        
        print("   📊 [LocalRec] Processing \(places.count) historical places...")
        
        // Process local recommendations
        let result = recommend(intent: userIntent, location: LocationManager.shared.currentLocation, history: places)
        
        if result.hasHighQualityMatches {
            print("   ✅ [LocalRec] High quality local matches found (\(result.sections.count) sections)")
            // Store recommendations
            DispatchQueue.main.async {
                self.latestResult = result
                self.recommendations = result.sections.flatMap { $0.items }
                self.mostLikely = result.mostLikely
                self.likely = result.likely
                self.hasHighQualityMatches = true
                self.isLoading = false
            }
        } else {
            print("   ⚠️ [LocalRec] Local matches quality too low, fetching context...")
            fetchContextRecommendations()
        }
    }
    
    /// Fetch context recommendations from PredictPlaceService
    private func fetchContextRecommendations() {
        guard let token = AppStateManager.shared.authToken else {
            print("   ❌ [LocalRec] No auth token, cannot fetch context")
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }
        
        print("   🔄 [LocalRec] Calling PredictPlaceService for context...")
        PredictPlaceService.shared.predictPlace(sessionToken: token) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let data = response.data {
                        print("   ✅ [LocalRec] Context data received: '\(data.place_name)'")
                        // Convert to MicroSituationData and publish for State observation
                        self.contextPlace = data.toMicroSituationData()
                        self.hasHighQualityMatches = false // Triggers fallback logic in State
                    }
                case .failure(let error):
                    print("   ❌ [LocalRec] Context fetch failed: \(error.localizedDescription)")
                }
                
                self.isLoading = false
            }
        }
    }
    
    func recommend(intent: UserIntent, location: CLLocation?, history: [MicroSituationData]) -> LocalRecommendationResult {
        print("\n🟢 [LocalRecommendationService] recommend() called")
        
        // 0. DETERMINE NATIVE LANGUAGE
        // The user explicitly stated: "Consider native language for the user intent."
        // We must map the stored language name (e.g. "Spanish") to a code (e.g. "es").
        let nativeName = AppStateManager.shared.nativeLanguage
        let nativeCode = NativeLanguageMapping.shared.getCode(for: nativeName) ?? "en" // Fallback to English if unknown
        
        print("   🌍 [LocalRec] User Native Language: '\(nativeName)' -> Code: '\(nativeCode)'")
        
        // 1. Convert Intent to Vectors (Field-wise Max-Sim Strategy)
        // Instead of one giant string, we get a dictionary of [Field Name: Vector]
        print("   🚀 [LocalRec] Generating Independent Vectors for each Intent Field...")
        let intentVectors = intentToVectors(intent, languageCode: nativeCode)
        
        if intentVectors.isEmpty {
             print("   ⚠️ [LocalRec] No valid intent vectors generated. Aborting.")
             return LocalRecommendationResult(sections: [], suggestedPlaceName: "Recommended", hasHighQualityMatches: false)
        }
        
        // 2. Filter by Time Window (±1.5 Hours)
        print("   ⏳ [LocalRec] FILTER STEP: Time Window (±1.5h)")
        let totalHistory = history.count
        let filteredHistory = history.filter { isWithinTimeWindow(place: $0) }
        print("      - Total History Items: \(totalHistory)")
        print("      - Items in Time Window: \(filteredHistory.count)")
        print("      - Discarded (Off-time): \(totalHistory - filteredHistory.count)")
        
        if filteredHistory.isEmpty {
            print("   ⚠️ [LocalRec] No history matches current time window. Aborting Recommendation.")
            return LocalRecommendationResult(sections: [], suggestedPlaceName: "Recommended", hasHighQualityMatches: false)
        }
        
        print("   🔹 [LocalRec] SCORING STEP: Processing \(filteredHistory.count) candidates against \(intentVectors.count) active intent fields...")
        
        // 3. Score all historical places (Returns list of Scored Moments per Place)
        let scoredPlaces = filteredHistory.flatMap { place in
            ScoringEngine.shared.score(place: place, intentVectors: intentVectors, userLocation: location, languageCode: nativeCode)
        }
        
        print("   ✅ [LocalRec] Scoring Complete. Total potential matches: \(scoredPlaces.count)")
        
        // 🚨 QUALITY THRESHOLD CHECK: Only accept moments with similarity > 0.45
        // Scores are now Raw Cosine (0-1) + Boosts (0-0.4). So valid matches > 0.45
        let highQualityThreshold = 0.45
        let highQualityMatches = scoredPlaces.filter { $0.score > highQualityThreshold }
        
        print("   🔍 [LocalRec] Quality Filter Applied (threshold: \(highQualityThreshold))")
        print("      - High Quality Matches: \(highQualityMatches.count) / \(scoredPlaces.count)")
        
        // 4. Sort by Score (High to Low)
        print("   🔹 [LocalRec] Sorting \(highQualityMatches.count) high-quality candidates by score...")
        let sortedPlaces = highQualityMatches.sorted { $0.score > $1.score }
        
        // 5. Categorize (Top 5 Most Likely, Next 5 Likely)
        // STRICT LOGIC: The Service defines the structure and headers.
        let mostLikely = Array(sortedPlaces.prefix(5))
        let likely = Array(sortedPlaces.dropFirst(5).prefix(5))
        
        print("   🔹 [LocalRec] Split Complete.")
        print("      - Most Likely: \(mostLikely.count) items")
        print("      - Likely: \(likely.count) items")
        print("      - Dropped/Ignored: \(max(0, sortedPlaces.count - 10)) items")
        
        // Logging for Debug/Verification
        // print("🔍 [LocalRec] Intent: \(intentText.prefix(30))...") // Deprecated: intentText no longer exists
        print("\n🏆 --- FINAL STAND (TOP 10 MOMENTS - SPLIT 5/5) ---")
        
        print("✅ [MOST LIKELY - TOP 5]")
        for (i, item) in mostLikely.enumerated() {
             guard let moment = item.place.micro_situations?.first?.moments.first?.text else { continue }
             print("   \(i+1). [\(String(format: "%.2f", item.score))] \(moment) (\(item.place.place_name ?? ""))")
        }
        
        print("☑️ [LIKELY - NEXT 5]")
        for (i, item) in likely.enumerated() {
             guard let moment = item.place.micro_situations?.first?.moments.first?.text else { continue }
             print("   \(i+1). [\(String(format: "%.2f", item.score))] \(moment) (\(item.place.place_name ?? ""))")
        }
        
        print("\n🔍 [DEBUG] FULL CANDIDATE LIST (Top 20):")
        for (i, item) in sortedPlaces.prefix(20).enumerated() {
             guard let moment = item.place.micro_situations?.first?.moments.first?.text else { continue }
             print("   #\(i+1) [\(String(format: "%.3f", item.score))] \(moment)")
        }
        print("----------------------------------------\n")
        
        // Construct Sections
        var resultSections: [RecommendationResultSection] = []
        if !mostLikely.isEmpty {
            resultSections.append(RecommendationResultSection(title: "MOST LIKELY", items: mostLikely))
        }
        if !likely.isEmpty {
            resultSections.append(RecommendationResultSection(title: "LIKELY", items: likely))
        }
        
        print("   ✅ [LocalRec] Final Result Constructed")
        print("      - Sections: \(resultSections.count)")
        for sec in resultSections {
            print("      - Section '\(sec.title)': \(sec.items.count) items")
        }
        
        // 🚨 MINIMUM THRESHOLD: Need at least 2 moments to avoid fallback
        let minimumMoments = 2
        let hasEnoughMatches = highQualityMatches.count >= minimumMoments
        
        if !hasEnoughMatches {
            print("   ⚠️ [LocalRec] Insufficient matches: \(highQualityMatches.count) / \(minimumMoments) required")
            print("   🔄 [LocalRec] Will trigger fallback to Context API")
        }
        
        return LocalRecommendationResult(
            sections: resultSections,
            suggestedPlaceName: "SUGGESTED MOMENTS",
            hasHighQualityMatches: hasEnoughMatches
        )
    }
    
    // MARK: - Helpers
    
    private func isWithinTimeWindow(place: MicroSituationData) -> Bool {
        // 1. Get Place Time (0-24 Scale)
        var placeTime: Double? = nil
        
        // Prioritize precise string parsing over integer 'hour'
        if let timeStr = place.time, let t = parseTimeStr(timeStr) {
            placeTime = t
        } else if let createdStr = place.created_at, let t = parseISOStr(createdStr) {
            placeTime = t
        } else if let h = place.hour {
            placeTime = Double(h)
        }
        
        guard let pTime = placeTime else {
            // Keep if we can't determine time? Or Drop?
            // "Only the time span should be filled at now" implies strict filtering.
            // If we don't know the time, it's safer to drop or keep?
            // Let's print a warning and drop it to be safe and clean similar to user request.
            // print("      ⚠️ [Filter] Time unknown for '\(place.place_name ?? "Unknown")'. Dropping.")
            return false
        }
        
        // 2. Get Current Time
        let now = Date()
        let calendar = Calendar.current
        let currentHour = Double(calendar.component(.hour, from: now))
        let currentMinute = Double(calendar.component(.minute, from: now))
        let currentTime = currentHour + (currentMinute / 60.0)
        
        // 3. Compare (Circular) using ±1.5h
        let diff = abs(currentTime - pTime)
        let normalizedDiff = min(diff, 24 - diff)
        
        return normalizedDiff <= 1.5
    }
    
    // MARK: - Parsing Helpers
    
    private func parseTimeStr(_ str: String) -> Double? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = formatter.date(from: str) {
            let c = Calendar.current
            return Double(c.component(.hour, from: date)) + (Double(c.component(.minute, from: date)) / 60.0)
        }
        return nil
    }
    
    // API sends: "2026-02-08T00:42:37.412052"
    private func parseISOStr(_ str: String) -> Double? {
        // Simple manual parse or rigorous ISO?
        // Trying ISO8601DateFormatter with fractional seconds options
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: str) {
            let c = Calendar.current
            return Double(c.component(.hour, from: date)) + (Double(c.component(.minute, from: date)) / 60.0)
        }
        // Fallback for standard ISO without fractional
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: str) {
             let c = Calendar.current
             return Double(c.component(.hour, from: date)) + (Double(c.component(.minute, from: date)) / 60.0)
        }
        return nil
    }
    
    private func intentToVectors(_ intent: UserIntent, languageCode: String) -> [String: [Double]] {
        var vectors: [String: [Double]] = [:]
        
        // Define fields to process
        let fields: [(name: String, value: String?)] = [
            ("Movement", intent.movement),
            ("Waiting", intent.waiting),
            ("Consume Fast", intent.consume_fast),
            ("Consume Slow", intent.consume_slow),
            ("Errands", intent.errands),
            ("Browsing", intent.browsing),
            ("Rest", intent.rest),
            ("Social", intent.social),
            ("Emergency", intent.emergency),
            ("Suggested Needs", intent.suggested_needs)
        ]
        
        print("   🧩 [LocalRec] Processing \(fields.count) intent fields for vectors...")
        
        for (name, value) in fields {
            guard let text = value, !text.isEmpty else { continue }
            
            // Generate vector for this specific field
            if let vector = EmbeddingService.getVector(for: text, languageCode: languageCode) {
                vectors[name] = vector
                print("      ✅ [Vector] Field '\(name)' -> Vector Valid (Dim: \(vector.count))")
            } else {
                print("      ❌ [Vector] Field '\(name)' -> Failed to generate vector")
            }
        }
        
        return vectors
    }
}
