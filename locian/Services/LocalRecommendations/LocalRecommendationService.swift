//
//  LocalRecommendationService.swift
//  locian
//
//  Orchestrator for Local Recommendations.
//  Matches User Intent + GPS to Historical Data to provide instant suggestions.
//

import Foundation
import CoreLocation

class LocalRecommendationService {
    static let shared = LocalRecommendationService()
    
    private init() {}
    
    // MARK: - Main API
    
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
        // Optimization: Discard irrelevant times before scoring
        print("   ⏳ [LocalRec] Filtering history by time window (±1.5h)...")
        let totalHistory = history.count
        let filteredHistory = history.filter { isWithinTimeWindow(place: $0) }
        print("      - Original: \(totalHistory)")
        print("      - Kept:     \(filteredHistory.count)")
        print("      - Dropped:  \(totalHistory - filteredHistory.count)")
        
        if filteredHistory.isEmpty {
            print("   ⚠️ [LocalRec] No history matches current time window. Aborting.")
            return LocalRecommendationResult(sections: [], suggestedPlaceName: "Recommended", hasHighQualityMatches: false)
        }
        
        print("   🔹 [LocalRec] Scoring \(filteredHistory.count) candidates against \(intentVectors.count) active intent fields...")
        
        // 3. Score all historical places (Returns list of Scored Moments per Place)
        // flatMap ensures we get a single list of all matched moments across all history
        let scoredPlaces = filteredHistory.flatMap { place in
            ScoringEngine.shared.score(place: place, intentVectors: intentVectors, userLocation: location, languageCode: nativeCode)
        }
        
        print("   ✅ [LocalRec] Scoring Complete. Found \(scoredPlaces.count) potential matches.")
        
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
        
        if let h = place.hour {
            placeTime = Double(h)
        } else if let timeStr = place.time {
            placeTime = parseTimeStr(timeStr)
        } else if let createdStr = place.created_at {
            placeTime = parseISOStr(createdStr)
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
