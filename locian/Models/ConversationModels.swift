//
//  ConversationModels.swift
//  locian
//
//  Models for conversation generation API
//

import Foundation

// MARK: - Timeline Context
struct TimelinePlaceContext: Codable {
    let place_name: String
    let time: String
}

// MARK: - Generate Moments (New Spec)
struct GenerateMomentsRequest: Codable {
    let place_name: String
    let place_detail: String?
    let time: String
    let profession: String?
    let previous_places: [TimelinePlaceContext]?
    let future_places: [TimelinePlaceContext]?
    let weather: String?
    let activity_duration: String?
    let user_language: String
    let level: String? // Added: BEGINNER, INTERMEDIATE, ADVANCED
    let remember: Bool?
}

struct GenerateMomentsResponse: Codable {
    let success: Bool
    let data: GenerateMomentsData?
    let message: String?
}

struct GenerateMomentsData: Codable {
    let place_name: String
    let total_count: Int
    let categories: [UnifiedMomentSection]
}
