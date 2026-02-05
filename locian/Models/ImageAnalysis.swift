//
//  ImageAnalysis.swift
//  locian
//
//  Created by vamshi krishna pinni on 24/10/25.
//

import Foundation

// MARK: - Image Analysis Request
struct ImageAnalysisRequest: Codable {
    let session_token: String
    let image_base64: String
    let level: String? 
    let previous_places: [TimelinePlaceContext]?
    let future_places: [TimelinePlaceContext]?
    let user_language: String?
    let target_language: String?
    let time: String?  // Optional - e.g. "8:30 AM" or "14:30"
    let latitude: Double?
    let longitude: Double?
}

// MARK: - Image Analysis Response
struct ImageAnalysisResponse: Codable {
    let success: Bool
    let message: String?
    let data: ImageAnalysisData?
    let error: String?
    let timestamp: String?
    let request_id: String?
}

// MARK: - Image Analysis Data
// MARK: - Image Analysis Data
struct ImageAnalysisData: Codable {
    let place_name: String
    let situations: [UnifiedMomentSection] // Unified Structure
    let moments_count: Int
    let detail: String?
    
    // New Helper Struct for JSON (Internal)
    private struct ImageCategory: Codable {
        let name: String
        let intents: [String]
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        place_name = try container.decode(String.self, forKey: .place_name)
        
        // Handle Detail
        if let detailValue = try? container.decode(String.self, forKey: .detail) {
            // Limit to 200 characters
            if detailValue.count > 200 {
                detail = String(detailValue.prefix(200))
            } else {
                detail = detailValue
            }
        } else {
            detail = nil
        }
        
        // Handle Categories (New) vs Situations (Legacy)
        if let categories = try? container.decode([ImageCategory].self, forKey: .categories) {
            // Map new structure to legacy models
            self.situations = categories.map { cat in
                let moments = cat.intents.map { UnifiedMoment(text: $0, keywords: nil) }
                return UnifiedMomentSection(category: cat.name, moments: moments)
            }
            // Count derived from actual intents
            self.moments_count = categories.reduce(0) { $0 + $1.intents.count }
        } else {
            // Fallback to Legacy
            self.situations = try container.decode([UnifiedMomentSection].self, forKey: .situations)
            self.moments_count = try container.decode(Int.self, forKey: .moments_count)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(place_name, forKey: .place_name)
        try container.encode(situations, forKey: .situations)
        try container.encode(moments_count, forKey: .moments_count)
        try container.encode(detail, forKey: .detail)
        // We do not encode 'categories' as we normalized it into 'situations'
    }
    
    enum CodingKeys: String, CodingKey {
        case place_name
        case situations
        case moments_count
        case detail
        case categories // New key
    }
}
