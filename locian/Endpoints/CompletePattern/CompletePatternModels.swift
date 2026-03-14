//
//  CompletePatternModels.swift
//  locian
//
//  Models for the Pattern Completion endpoint.
//

import Foundation

// MARK: - Request
struct CompletePatternRequest: Codable {
    let place_id: String
    let pattern_id: String?
    let time: String
    let date: String
    let latitude: Double?
    let longitude: Double?
    let places: [DiscoverPlaceInput]?
}

// MARK: - Response
struct CompletePatternResponse: Codable {
    let success: Bool
    let message: String?
    let data: CompletePatternData?
    let error: String?
    let error_code: String?
    let request_id: String?
    let timestamp: String?
}

struct CompletePatternData: Codable {
    let pattern_id: String
    let place_id: String
}
