//
//  GetStudiedPlacesModels.swift
//  locian
//
//  Models for Get Studied Places Endpoint
//  Pure data structures - no parsing logic
//

import Foundation

// MARK: - Request Model

struct GetStudiedPlacesRequest: Codable {
    let time: String
    let latitude: Double?
    let longitude: Double?
    let limit: Int?
    let date: String?
}

// MARK: - Response Models

struct GetStudiedPlacesResponse: Codable {
    let success: Bool
    let data: GetStudiedPlacesData?
    let message: String?
    let error: String?
}

struct GetStudiedPlacesData: Codable {
    let dates: [DateGroup]?
    let total_dates: Int?
    let total_moments: Int?
    let input_time: String?
    let user_intent: UserIntent?
    let time_span: String?
    
    // For backwards compatibility, we expose a flat "places" array
    var places: [MicroSituationData] {
        return dates?.flatMap { $0.moments } ?? []
    }
}

struct DateGroup: Codable {
    let date: String
    let moments: [MicroSituationData]
}

struct UserIntent: Codable {
    let movement: String?
    let waiting: String?
    let consume_fast: String?
    let consume_slow: String?
    let errands: String?
    let browsing: String?
    let rest: String?
    let social: String?
    let emergency: String?
    let suggested_needs: String?
}

// MARK: - Domain Models

struct MicroSituationData: Equatable, Identifiable, Codable {
    let place_name: String?
    let latitude: Double?
    let longitude: Double?
    let time: String?
    let hour: Int?
    let created_at: String?
    let context_description: String?
    var micro_situations: [UnifiedMomentSection]?
    let priority_score: Double?
    var distance_meters: Double?
    
    // Heritage Hierarchy Fields
    let time_span: String?      // Bucket: Morning/Afternoon/Evening
    let type: String?           // Source: image_analysis/custom
    
    let profession: String?
    let updated_at: String?
    let target_language: String?
    var document_id: String?
    
    var id: String { document_id ?? "\(place_name ?? "unknown")_\(created_at ?? "")" }
}

struct UnifiedMomentSection: Equatable, Hashable, Codable {
    let category: String
    let moments: [UnifiedMoment]
    
    var name: String { category }
}

struct UnifiedMoment: Equatable, Hashable, Codable {
    let text: String
    let keywords: [String]?
    var embedding: [Double]?
}
