import Foundation
import MapKit

class SemanticSnappingService {
    static let shared = SemanticSnappingService()
    
    private init() {}
    
    // MARK: - Supported Backend Categories
    private let targetCategories = [
        "airport", "bank", "barbershop", "bus_stop", "cafe", "food_market", "gym",
        "home", "hospital", "hotel", "local_shop", "museum", "office", "park",
        "petrol_bunk", "pharmacy", "railway_station", "restaurant", "school",
        "shopping_mall", "supermarket", "travelling", "university"
    ]
    
    // MARK: - Semantic Clusters (Expanding the vector target)
    private let semanticClusters = [
        "airport": "international airport terminal departures arrivals flight gate air travel",
        "bank": "bank financial institution atm vault finance branch banking",
        "barbershop": "barbershop hair salon haircut stylist grooming barber beauty parlor",
        "bus_stop": "bus stop transit station shelter commuting public transport",
        "cafe": "cafe coffee shop espresso bakery breakfast bistro starbucks",
        "food_market": "food market grocery store convenience mart bodega market",
        "gym": "gym fitness center health club workout exercise weightlifting crossfit yoga studio",
        "home": "home residence apartment house dwelling residential building",
        "hospital": "hospital medical center clinic emergency room healthcare doctor",
        "hotel": "hotel resort lodging inn accommodation stay suite",
        "local_shop": "local shop retail store boutique showroom outlet merchant dealer repair center",
        "museum": "museum art gallery exhibition heritage cultural center",
        "office": "office workplace business headquarter corporate agency",
        "park": "park garden green space playground meadow nature reserve national park",
        "petrol_bunk": "petrol bunk gas station fuel station ev charger filling station",
        "pharmacy": "pharmacy drugstore medical supplies chemist apothecary",
        "railway_station": "railway station train platform metro tube subway rail transit",
        "restaurant": "restaurant dining eatery bistro buffet grill steakhouse pizzeria",
        "school": "school elementary middle high school academy education",
        "shopping_mall": "shopping mall plaza center complex retail hub department store",
        "supermarket": "supermarket hypermarket big box store grocer wholesale",
        "travelling": "travelling travel tourism sightseeing landmark attraction viewpoint",
        "university": "university college campus academy institute higher education"
    ]
    
    // MARK: - Keyword Anchors (High Signal Boosters)
    private let keywordAnchors: [String: [String]] = [
        "food_market": ["market", "grocery", "mart", "bodega", "convenience"],
        "local_shop": ["store", "shop", "boutique", "showroom", "outlet", "dealer", "retail", "decor", "interior", "depot", "tailor"],
        "office": ["associates", "consultancy", "systems", "tech", "office", "agency"],
        "home": ["nilayam", "residenc", "apart", "villa", "home", "house"],
        "gym": ["gym", "fitness", "workout", "club", "studio", "yoga"],
        "railway_station": ["station", "platform", "railway", "train", "metro"],
        "petrol_bunk": ["gas", "petrol", "fuel", "bunk"],
        "cafe": ["coffee", "cafe", "espresso", "bakery"],
        "restaurant": ["restaurant", "dining", "eatery", "food court", "grill", "pizzeria"],
        "airport": ["airport", "terminal", "gate", "flight"]
    ]

    /// V4.2: Advanced Multi-Vector Semantic Fusion
    /// Uses clusters for target expansion and anchors/metadata for signal boosting.
    func resolveSemanticCategory(name: String, rawCategory: String?, url: String?, tags: [String]?) -> String {
        let cleanName = name.lowercased()
        let cleanedRaw = rawCategory?.replacingOccurrences(of: "MKPointOfInterestCategory", with: "")
            .replacingOccurrences(of: "MKPOICategory", with: "")
            .lowercased() ?? ""
        
        let urlClean = url?.lowercased() ?? ""
        let combinedTags = (tags ?? []).map { $0.lowercased() }.joined(separator: " ")
        
        print("🧠 [SemanticSnapping] Resolving V4.2: '\(name)' | Raw: '\(cleanedRaw)'")
        
        var matches: [(target: String, score: Double)] = []
        
        for target in targetCategories {
            let clusterText = semanticClusters[target] ?? target
            
            // 1. Base Embedding Signal (Name vs Cluster)
            var score = EmbeddingService.compare(textA: cleanName, textB: clusterText, languageCode: "en")
            
            // 2. Apple Category Signal (Weighted Priority)
            if !cleanedRaw.isEmpty {
                let catScore = EmbeddingService.compare(textA: cleanedRaw, textB: clusterText, languageCode: "en")
                score = (score * 0.6) + (catScore * 0.4)
            }
            
            // 3. Keyword Anchoring (The Multiplier)
            if let anchors = keywordAnchors[target] {
                for anchor in anchors {
                    // Check Name
                    if cleanName.contains(anchor) { 
                        score += 0.15 
                        print("⚓️ [SemanticSnapping] Name Anchor: '\(anchor)' -> \(target) (+0.15)")
                    }
                    // Check URL
                    if urlClean.contains(anchor) { 
                        score += 0.20 
                        print("🔗 [SemanticSnapping] URL Anchor: '\(anchor)' -> \(target) (+0.20)")
                    }
                    // Check Tags
                    if combinedTags.contains(anchor) { 
                        score += 0.15 
                        print("🏷️ [SemanticSnapping] Tag Anchor: '\(anchor)' -> \(target) (+0.15)")
                    }
                }
            }
            
            // 4. Exact Match Protection (Force high score for direct hits)
            let normalizedTarget = target.replacingOccurrences(of: "_", with: " ")
            if cleanName.contains(normalizedTarget) || cleanedRaw == normalizedTarget || cleanedRaw == target {
                score = max(score, 1.0)
                print("🎯 [SemanticSnapping] Direct Match: '\(target)' (1.0)")
            }
            
            matches.append((target: target, score: score))
        }
        
        matches.sort { $0.score > $1.score }
        guard let topMatch = matches.first else { return "unknown" }
        
        // Lowered threshold to 0.75 (V4.2a)
        if topMatch.score >= 0.75 {
            print("✅ [SemanticSnapping] MATCH: '\(topMatch.target)' (\(String(format: "%.2f", topMatch.score)))")
            return topMatch.target
        } else {
            let fallback = cleanedRaw.isEmpty ? "unknown" : cleanedRaw
            print("⚠️ [SemanticSnapping] LOW CONFIDENCE (\(String(format: "%.2f", topMatch.score))). Tentative: '\(topMatch.target)'. Fallback: '\(fallback)'")
            return fallback
        }
    }
}
