//
//  AnalyzeImageModels.swift
//  locian
//
//  Models for Analyze Image Endpoint
//  Pure data structures - no parsing logic
//

import Foundation

// MARK: - Request Model

struct AnalyzeImageRequest: Codable {
    let image_base64: String
    let time: String?
    let level: String?
    let latitude: Double?
    let longitude: Double?
    let user_language: String?
    let target_language: String?
    let previous_places: [TimelinePlaceContext]?
    let future_places: [TimelinePlaceContext]?
}

struct TimelinePlaceContext: Codable {
    let place_name: String
    let time: String
}

// MARK: - Response Models

struct AnalyzeImageResponse: Codable {
    let success: Bool
    let message: String?
    let data: AnalyzeImageData?
    let error: String?
}

struct AnalyzeImageData: Codable {
    let place_name: String
    let document_id: String?
    let latitude: Double?
    let longitude: Double?
    let time: String?
    let hour: Int?
    let type: String?
    let created_at: String?
    let micro_situations: [UnifiedMomentSection]
    let moments_count: Int
}
