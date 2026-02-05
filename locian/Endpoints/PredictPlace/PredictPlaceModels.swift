//
//  PredictPlaceModels.swift
//  locian
//

import Foundation

// MARK: - Request

struct PredictPlaceRequest: Codable {
    let places: [String]
    let time: String?
    let previous_places: [PlaceContext]?
    let future_places: [PlaceContext]?
    let native_language: String?
    let target_language: String?
    let level: String?
    let latitude: Double?
    let longitude: Double?
}

struct PlaceContext: Codable {
    let place_name: String
    let time: String
}

// MARK: - Response

struct PredictPlaceResponse: Codable {
    let success: Bool
    let message: String?
    let data: PredictPlaceData?
    let error: String?
}

struct PredictPlaceData: Codable {
    let place_name: String
    let document_id: String?
    let latitude: Double?
    let longitude: Double?
    let time: String?
    let hour: Int?
    let type: String?
    let created_at: String?
    let micro_situations: [UnifiedMomentSection]?
    let total_count: Int?
}
