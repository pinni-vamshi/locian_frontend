//
//  UserIntentContextModels.swift
//  locian
//
//  Models for POST /api/user/intent/context
//

import Foundation

// MARK: - Response envelope
struct UserIntentContextResponse: Codable {
    let success: Bool
    let message: String?
    let data: UserIntentContextData?
}

struct UserIntentContextData: Codable {
    let timeline: [IntentTimelineDay]?
    let geo_context: [IntentGeoContext]?
    let user_interests: [String: [IntentUserPlace]]?
    let pin_result: IntentPinResult?
}

// MARK: - Timeline
struct IntentTimelineDay: Codable {
    let date: String
    let places: [IntentTimelinePlace]
}

struct IntentTimelinePlace: Codable {
    let place_id: String
    let target_language: String?
    let topic: String?
    let practiced_at: String?
    let pattern_ids: [String]?
}

// MARK: - Geo Context
struct IntentGeoContext: Codable {
    let geo_id: String
    let coordinates: IntentCoordinates?
    let updated_at: String?
    let tags: [IntentGeoTag]?
    let places: [IntentGeoPlace]?
}

struct IntentCoordinates: Codable {
    let latitude: Double?
    let longitude: Double?
}

struct IntentGeoTag: Codable {
    let tag: String
    let weight: Double
}

struct IntentGeoPlace: Codable {
    let place_doc_id: String?
    let name: String?
    let category: String?
    let grounded_weight: Double?
    let source: String?
    let last_seen: String?
}

// MARK: - User Interests (per-place memory)
/// Mirrors the aggregate place row from `data.user_interests[<category>]`.
/// Every field is optional to stay tolerant to backend changes.
struct IntentUserPlace: Codable {
    let place_id: String?
    let name: String?
    let category: String?
    let latitude: Double?
    let longitude: Double?
    let geohash: String?
    let visit_count: Int?
    /// e.g. `{"8pm-10pm": 2}`
    let peak_hours: [String: Int]?
    /// e.g. `{"fri": 1, "sat": 2}`
    let day_of_week_hist: [String: Int]?
    let ema_duration_sec: Double?
    let top_source: String?
    let top_wifi_ids: [IntentWifiId]?
    let confidence: Double?
    let pinned: Bool?
    let pinned_at: String?
    let pin_source: String?
    /// `{"YYYY-MM-DD": ["HH:MM:SS", ...]}`
    let visit_times_by_date: [String: [String]]?
}

/// Hashed Wi-Fi identity the backend stores per place.
/// Hashes are truncated hex digests (16 chars) of SSID/BSSID.
struct IntentWifiId: Codable {
    let ssid_hash: String?
    let bssid_hash: String?
    let count: Int?
}

// MARK: - Pin result (echo)
struct IntentPinResult: Codable {
    let success: Bool?
    let category: String?
    let place_name: String?
    let place_id: String?
    let latitude: Double?
    let longitude: Double?
}

// MARK: - Pin Request
struct IntentPinRequest: Codable {
    let category: String
    let place_name: String
    let latitude: Double
    let longitude: Double
    let date: String?       // "YYYY-MM-DD"
    let time: String?       // "HH:MM"
    let timestamp: String?  // ISO-8601 (used if date/time missing)
    let wifi_info: [String: String]?
    let places: [DiscoverPlaceInput]?
}

// MARK: - Unified Request (POST)
struct UnifiedIntentRequest: Codable {
    let timeline_limit: Int?
    let pin: IntentPinRequest?
}
