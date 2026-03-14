//
//  DiscoverMomentsModels.swift
//  locian
//
//  Models for the V3.0 Discover Moments Endpoint
//

import Foundation

// MARK: - Request
struct DiscoverMomentsRequest: Codable {
    let time: String
    let date: String
    let latitude: Double?
    let longitude: Double?
    let places: [DiscoverPlaceInput]?
    let velocity: String?
    let audio_db: Double?
    let light_level: Double?
    let altitude: Double?
    let explicit_request: String?
    let image_base64: String?
    let weather: String?
    let pressure: Double?
    let user_language: String?
    let target_language: String?
    let wifi_ssid: String?
}

struct DiscoverPlaceInput: Codable {
    let name: String
    let category: String
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
    let grounding: String?
    var patterns: [RecommendationPattern]?
}

struct RecommendationPattern: Codable, Identifiable {
    var id: String { target ?? UUID().uuidString }
    let target: String?
    let meaning: String?
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
