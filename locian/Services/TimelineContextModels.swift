//
//  TimelineContextModels.swift
//  locian
//
//  Models for Timeline Context Service
//  Defines structures for Past and Future context
//

import Foundation

struct TimelineContext {
    let pastPlaces: [PlaceAtTime]
    let futurePlaces: [PlaceAtTime]
    let mostCommonPastPlace: String?
    let mostCommonFuturePlace: String?
    
    // Fallback if no common place found
    let nearestPastPlace: PlaceAtTime?
    let nearestFuturePlace: PlaceAtTime?
}

struct PlaceAtTime {
    let placeName: String
    let time: String         // "13:00"
    let date: String         // "2026-02-09"
    let timeDifference: Int  // Minutes from current time (abs)
    let originalHour: Int?
}

// Shared Context Model for APIs
struct TimelinePlaceContext: Codable {
    let place_name: String
    let time: String
}

struct NearbyPlaceData: Codable, Sendable {
    let place_name: String
    let distance: Double
    let type: String?
}

extension PlaceAtTime {
    var toContext: TimelinePlaceContext {
        return TimelinePlaceContext(place_name: placeName, time: time)
    }
}
