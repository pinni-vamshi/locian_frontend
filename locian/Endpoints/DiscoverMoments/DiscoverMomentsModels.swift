//
//  DiscoverMomentsModels.swift
//  locian
//
//  Models for the V3.0 Discover Moments Endpoint
//

import Foundation

// MARK: - Request
struct DiscoverMomentsRequest: Codable {
    let user_id: String?
    let latitude: Double?
    let longitude: Double?
    let user_language: String?
    let target_language: String?
    let time: String?      // HH:MM
    let date: String?      // YYYY-MM-DD
    let places: [DiscoverPlaceInput]?
    let image_base64: String?
    let explicit_request: String?
    let session_token: String?
    let current_velocity: String?
    let weather: String?
}

struct DiscoverPlaceInput: Codable {
    let name: String
    let category: String
    let distance: Double
}

// MARK: - Response
struct DiscoverMomentsResponse: Codable {
    let success: Bool?
    let message: String?
    let data: DiscoverMomentsData?
}

// MARK: - Data
struct DiscoverMomentsData: Codable {
    let success: Bool?
    let recommendations: [PlaceRecommendation]?
    let probabilities: [String: Double]?
}

// MARK: - V3 Recommendation System
struct PlaceRecommendation: Codable, Identifiable {
    var id: String { place_id }
    let place_id: String
    let confidence: Double
    let grounding: String
    let patterns: [RecommendationPattern]?
}

struct RecommendationPattern: Codable, Identifiable {
    var id: String { target }
    let target: String
    let meaning: String
    let phonetic: String?
    let bricks: RecommendationBricks?
}

struct RecommendationBricks: Codable {
    let constants: [RecommendationBrickItem]?
    let variables: [RecommendationBrickItem]?
    let structural: [RecommendationBrickItem]?
}

struct RecommendationBrickItem: Codable, Identifiable, Equatable {
    var id: String { word }
    let word: String
    let meaning: String
    let phonetic: String?
}
