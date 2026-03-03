//
//  TimelineContextModels.swift
//  locian
//
//  Models for Timeline Context
//

import Foundation

struct NearbyPlaceData: Codable, Sendable {
    let place_name: String
    let distance: Double
    let type: String?
}
