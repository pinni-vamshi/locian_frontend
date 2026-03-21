import Foundation
import MapKit
import NaturalLanguage

class SemanticSnappingService {
    static let shared = SemanticSnappingService()
    
    private init() {}
    
    // MARK: - Supported Backend Categories
    private let targetCategories = [
        "airport", "bakery", "bank", "barbershop", "beach", "bus_stop", "cafe", "clinic",
        "coaching_center", "fast_food_outlet", "food_court", "general_store", "gym",
        "home", "hospital", "hotel", "library", "metro_station",
        "movie_theatre", "museum", "office", "park", "petrol_bunk", "pharmacy",
        "police", "railway_station", "religious_site", "restaurant", "school", "shopping_mall",
        "supermarket", "university", "yoga_studio"
    ]
    
    // MARK: - Category Definitions (Keyword Anchors)
    private let categoryDefinitions: [String: [String]] = [
        "airport": ["airport", "terminal", "gate", "flight"],
        "bakery": ["bakery", "bake", "bread", "pastry", "cake", "puff"],
        "bank": ["bank", "atm", "financial", "vault", "finance"],
        "barbershop": ["barber", "salon", "hair", "grooming", "stylist", "parlour", "beard"],
        "beach": ["beach", "coast", "sea", "shore", "ocean"],
        "bus_stop": ["bus stop", "bus stand", "transit", "shelter", "depot", "terminal", "rtc", "stage", "bus point"],
        "cafe": ["coffee", "cafe", "espresso", "tea cafe", "tea stall", "chai", "sip", "brew"],
        "clinic": ["clinic", "medical center", "dental", "eye care", "physio"],
        "coaching_center": ["coaching", "tuition", "institute", "classes", "academy", "training", "study"],
        "fast_food_outlet": ["fast food", "burger", "pizza", "snack", "takeaway", "shawarma", "curry point"],
        "food_court": ["food court", "dining plaza", "food hall", "dhaba", "tiffin"],
        "general_store": ["kirana", "provisions", "general store", "grocery", "mart", "shop", "store", "hardware", "electrician", "mechanic", "technician", "decor", "interior", "timber", "depot", "aluminium", "materials", "furniture", "plywood", "electrical", "paint", "complex", "malls", "ladies tailors", "fancy", "mobile point", "service center"],
        "gym": ["gym", "fitness", "workout", "club", "studio", "yoga", "crossfit"],
        "home": ["nilayam", "residenc", "apart", "villa", "home", "house", "bhavan", "residency", "enclave", "gardens", "complex", "sovereign", "vilas"],
        "hospital": ["hospital", "medical", "emergency", "health center"],
        "hotel": ["hotel", "resort", "inn", "stay", "suite", "lodge"],
        "library": ["library", "books", "reading room"],
        "metro_station": ["metro", "underground"],
        "movie_theatre": ["cinema", "theatre", "multiplex", "movies", "imax"],
        "museum": ["museum", "gallery", "exhibition", "heritage"],
        "office": ["associates", "consult", "systems", "tech", "office", "agency", "solution", "technologies", "enterprise", "group", "hq", "corp", "infra", "infotech", "engineering", "technopolis"],
        "park": ["park", "garden", "playground", "nature reserve"],
        "petrol_bunk": ["gas", "petrol", "fuel", "bunk", "filling station", "ev charger"],
        "pharmacy": ["pharmacy", "medical store", "chemist", "apothecary", "medicals"],
        "police": ["police", "station", "thana", "chowki"],
        "railway_station": ["railway", "train"],
        "religious_site": ["temple", "church", "mosque", "shrine", "gurudwara", "cathedral", "chapel", "mandir", "masjid", "ashram", "statu", "monument"],
        "restaurant": ["restaurant", "dining", "eatery", "bistro", "buffet", "kitchen", "caterer"],
        "school": ["school", "elementary", "middle", "high school", "academy"],
        "shopping_mall": ["mall", "plaza", "center", "complex", "retail hub"],
        "supermarket": ["supermarket", "hypermarket", "wholesale"],
        "university": ["university", "college", "campus"],
        "yoga_studio": ["yoga", "meditation"]
    ]

    private let categoryExclusions: [String: [String]] = [
        "petrol_bunk": ["church", "temple", "school", "nilayam", "residenc"],
        "shopping_mall": ["kirana", "medical", "general store", "tiffin"],
        "fast_food_outlet": ["tailors", "engineering", "technopolis"],
        "railway_station": ["wave", "infra", "tech"]
    ]

    func resolveSemanticCategory(name: String, rawCategory: String?, url: String?, tags: [String]?) -> String {
        let cleanName = sanitize(name)
        let nlpFeatures = extractNLPFeatures(from: name)
        
        let cleanedRaw = rawCategory?.replacingOccurrences(of: "MKPointOfInterestCategory", with: "")
            .replacingOccurrences(of: "MKPOICategory", with: "")
            .replacingOccurrences(of: "_", with: " ")
            .lowercased() ?? ""
        
        let combinedTags = (tags ?? []).map { $0.lowercased() }.joined(separator: " ")
        let primaryText = "\(cleanName) \(cleanedRaw)".lowercased()
        
        print("🧠 [SemanticSnapping v8.0] Resolving with NLP Intelligence: '\(name)'")
        print("📝 [NLP] Nouns: \(nlpFeatures.nouns), Lemmas: \(nlpFeatures.lemmas)")

        var bestMatch: (target: String, score: Double) = ("unknown", -1.0)
        
        for target in targetCategories {
            let anchors = categoryDefinitions[target] ?? [target]
            let exclusions = categoryExclusions[target] ?? []
            
            // Hard Exclusion Guard
            if exclusions.contains(where: { primaryText.contains($0) }) {
                continue
            }

            var categoryMaxScore: Double = 0
            
            for anchor in anchors {
                let anchorLower = anchor.lowercased()
                let isLiteralMatch = primaryText.contains(anchorLower)
                
                // Base Scores via Embedding
                let sName = EmbeddingService.compare(textA: cleanName, textB: anchor, languageCode: "en") * 1.0
                let sRaw = (cleanedRaw.isEmpty) ? 0 : (EmbeddingService.compare(textA: cleanedRaw, textB: anchor, languageCode: "en") * 0.7)
                let sTags = (combinedTags.isEmpty) ? 0 : (EmbeddingService.compare(textA: combinedTags, textB: anchor, languageCode: "en") * 0.3)
                
                var peakSignal = max(sName, sRaw, sTags)
                
                // NLP Boost (1.5x for Noun or Lemma matches)
                if nlpFeatures.nouns.contains(anchorLower) || nlpFeatures.lemmas.contains(anchorLower) {
                    peakSignal *= 1.5
                    print("⭐ [NLP Boost] Anchor '\(anchor)' matches Core Noun/Lemma!")
                }
                
                // Literal Guard logic
                if isLiteralMatch {
                    peakSignal *= 1.2
                } else {
                    peakSignal *= 0.4
                }
                
                categoryMaxScore = max(categoryMaxScore, peakSignal)
            }
            
            if categoryMaxScore > bestMatch.score {
                bestMatch = (target: target, score: categoryMaxScore)
            }
        }
        
        print("✅ [SemanticSnapping] SNAP: '\(bestMatch.target)' (Final Conf: \(String(format: "%.2f", bestMatch.score)))")
        return bestMatch.target
    }
    
    private func extractNLPFeatures(from text: String) -> (nouns: Set<String>, lemmas: Set<String>) {
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .lemma])
        tagger.string = text
        
        var nouns = Set<String>()
        var lemmas = Set<String>()
        
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, range in
            let token = String(text[range]).lowercased()
            if tag == .noun {
                nouns.insert(token)
            }
            return true
        }
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lemma, options: options) { tag, range in
            if let lemma = tag?.rawValue.lowercased() {
                lemmas.insert(lemma)
            }
            return true
        }
        
        return (nouns, lemmas)
    }
    
    private func sanitize(_ text: String) -> String {
        let stopWords = ["the", "and", "limited", "ltd", "inc", "of", "station", "building", "center", "centre", "tower"]
        var words = text.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted)
        words = words.filter { !stopWords.contains($0) && !$0.isEmpty }
        return words.joined(separator: " ")
    }
}
