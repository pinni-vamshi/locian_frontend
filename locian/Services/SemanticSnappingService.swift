import Foundation
import MapKit

class SemanticSnappingService {
    static let shared = SemanticSnappingService()
    
    private init() {}
    
    // MARK: - Supported Backend Categories
    private let targetCategories = [
        "airport", "bakery", "bar_pub", "beach", "bus_stop", "cafe", "clinic",
        "coaching_center", "fast_food_outlet", "food_court", "gym", "home",
        "hospital", "library", "metro_station", "movie_theatre", "office",
        "park", "pharmacy", "railway_station", "restaurant", "school",
        "shopping_mall", "supermarket", "university", "yoga_studio"
    ]
    
    /// V4.1: Resolves a raw MapKit place/name to a backend supported category.
    /// Confidence Score = (Name Similarity * 0.6) + (Apple Category Similarity * 0.4)
    /// Threshold: 0.90
    func resolveSemanticCategory(name: String, rawCategory: String?) -> String {
        // Aggressive Prefix Stripping
        let cleanedRaw = rawCategory?
            .replacingOccurrences(of: "MKPointOfInterestCategory", with: "")
            .replacingOccurrences(of: "MKPOICategory", with: "")
            .lowercased() ?? ""
            
        var bestMatch = "unknown"
        var highestConfidence = 0.0
        let cleanName = name.lowercased()
        
        print("🧠 [SemanticSnapping] Resolving: '\(name)' | RawCategory: '\(cleanedRaw)'")
        
        var matches: [(target: String, score: Double)] = []
        
        for target in targetCategories {
            let normalizedTarget = target.replacingOccurrences(of: "_", with: " ")
            
            // --- SIGNAL A: Literal Name Match (Force 1.0) ---
            if cleanName.contains(normalizedTarget) {
                print("✨ [SemanticSnapping] Literal Name Match: '\(target)' in '\(name)'")
                return target 
            }
            
            // --- SIGNAL B: Literal Category Match (Force 1.0) ---
            if cleanedRaw == normalizedTarget || cleanedRaw == target {
                print("🎯 [SemanticSnapping] Literal Category Match: '\(target)' == '\(cleanedRaw)'")
                return target
            }
            
            // --- SIGNAL C: Fuzzy Semantic Similarity ---
            let nameScore = EmbeddingService.compare(textA: cleanName, textB: normalizedTarget, languageCode: "en")
            let rawScore = !cleanedRaw.isEmpty ? EmbeddingService.compare(textA: cleanedRaw, textB: normalizedTarget, languageCode: "en") : 0.0
            
            let confidence = (nameScore * 0.6) + (rawScore * 0.4)
            matches.append((target: target, score: confidence))
        }
        
        matches.sort { $0.score > $1.score }
        let topMatch = matches.first!
        bestMatch = topMatch.target
        highestConfidence = topMatch.score
        
        // Logs removed for cleanliness
        
        // Strict 90% Threshold
        if highestConfidence >= 0.90 {
            return bestMatch
        } else {
            // Fallback to cleaned raw category if no match is certain enough
            let fallback = cleanedRaw.isEmpty ? "unknown" : cleanedRaw
            print("⚠️ [SemanticSnapping] Low confidence (\(String(format: "%.2f", highestConfidence))). Falling back to raw: '\(fallback)'")
            return fallback
        }
    }
}
