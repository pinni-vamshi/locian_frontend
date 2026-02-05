//
//  GenerateMomentsModels.swift
//  locian
//
//  Models for Generate Moments Endpoint
//  Pure data structures - no parsing logic
//

import Foundation

// MARK: - Request Model

struct GenerateMomentsRequest: Codable {
    let place_name: String
    let place_detail: String?
    let time: String?
    let profession: String?
    let previous_places: [TimelinePlaceContext]?
    let future_places: [TimelinePlaceContext]?
    let weather: String?
    let activity_duration: String?
    let latitude: Double?
    let longitude: Double?
    let user_language: String?
    let level: String?
    let remember: Bool?
}

// MARK: - Response Models

struct GenerateMomentsResponse: Codable {
    let success: Bool
    let message: String?
    let data: GenerateMomentsData?
    let error: String?
}

struct GenerateMomentsData: Codable {
    let place_name: String
    let document_id: String?
    let latitude: Double?
    let longitude: Double?
    let time: String?
    let hour: Int?
    let type: String?
    let created_at: String?
    let micro_situations: [UnifiedMomentSection]
    let total_count: Int
}
