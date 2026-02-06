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
}

// MARK: - Response Models

struct GetStudiedPlacesResponse: Codable {
    let success: Bool
    let data: GetStudiedPlacesData?
    let message: String?
    let error: String?
}

struct GetStudiedPlacesData: Codable {
    let places: [MicroSituationData]
    let input_time: String?
    let count: Int?
    let user_intent: UserIntent?
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
    let type: String?
    let created_at: String?
    let context_description: String?
    var micro_situations: [UnifiedMomentSection]?
    let priority_score: Double?
    var distance_meters: Double?
    
    let time_span: String?
    let profession: String?
    let updated_at: String?
    let target_language: String?
    let document_id: String?
    
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
}
