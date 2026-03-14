//
//  UserIntentContextModels.swift
//  locian
//
//  Models for GET /api/user/intent/context
//

import Foundation
import Combine

struct UserIntentContextResponse: Codable {
    let success: Bool
    let message: String?
    let data: UserIntentContextData?
}

struct UserIntentContextData: Codable {
    let current_time_span: String?
    let timeline: [String: TimeSpanSnapshot]?
    let geo_contexts: [String: GeoContextData]?
}

struct TimeSpanSnapshot: Codable {
    let active_context: [UserIntentTag]
    let history: [MomentHistory]
}

struct MomentHistory: Codable {
    let date: String
    let moment_id: String
    let tags: [String]
    let pattern: PatternHistory?
    let timestamp: String
}

struct PatternHistory: Codable {
    let id: String
    let target: String
    let meaning: String
}

struct GeoContextData: Codable {
    let tags: [String: Double]?
    let nearby_places: [String]?
    let updated_at: String?
    let lat: Double?
    let lng: Double?
}

struct UserIntentTag: Codable {
    let tag: String
    let confidence: Double
    let source: String? // "manual" or "learned"
}

// MARK: - Unified Request (POST)
struct UnifiedIntentRequest: Codable {
    let lat: Double
    let lng: Double
    let time: String
    let date: String
}
