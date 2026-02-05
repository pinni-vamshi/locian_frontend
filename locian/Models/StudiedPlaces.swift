//
//  StudiedPlaces.swift
//  locian
//
//  Models for studied places API
//

import Foundation

// MARK: - API Requests & Responses

struct AddStudiedPlaceRequest: Codable {
    let place_name: String
    let place_detail: String?
    let latitude: Double?
    let longitude: Double?
    let time: String
    let date: String
}

struct StudiedPlaceData: Codable {
    let place_name: String
    let place_detail: String?
    let latitude: Double?
    let longitude: Double?
    let time: String
    let date: String
    let created_at: String
}

struct AddStudiedPlaceResponse: Codable {
    let success: Bool
    let data: AddStudiedPlaceData?
    let message: String?
    let error: String?
    let error_code: String?
}

struct AddStudiedPlaceData: Codable {
    let studied_places: [StudiedPlaceData]
}

struct GetStudiedPlacesRequest: Codable {
    let time: String
    let latitude: Double?
    let longitude: Double?
    let limit: Int?

    nonisolated init(time: String, latitude: Double? = nil, longitude: Double? = nil, limit: Int? = 50) {
        self.time = time
        self.latitude = latitude
        self.longitude = longitude
        self.limit = limit
    }
}

struct GetStudiedPlacesResponse: Codable {
    let success: Bool
    let data: GetStudiedPlacesData?
    let message: String?
    let error: String?
}

struct GetStudiedPlacesData: Codable {
    let places: [MicroSituationData]
    let input_time: String?
    let count: Int?
}

struct TimelineData: Codable {
    let places: [MicroSituationData]
}

// MARK: - Unified Moment Structure

struct UnifiedMoment: Codable, Equatable, Hashable {
    let text: String
    let keywords: [String]?
    
    nonisolated init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            self.text = try container.decode(String.self, forKey: .text)
            self.keywords = try container.decodeIfPresent([String].self, forKey: .keywords)
        } else if let singleValue = try? decoder.singleValueContainer() {
            self.text = try singleValue.decode(String.self)
            self.keywords = nil
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid UnifiedMoment"))
        }
    }
    
    nonisolated init(text: String, keywords: [String]?) {
        self.text = text
        self.keywords = keywords
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(keywords, forKey: .keywords)
    }
    
    enum CodingKeys: String, CodingKey {
        case text, keywords
    }
}

struct UnifiedMomentSection: Codable, Equatable, Hashable {
    let category: String
    let moments: [UnifiedMoment]
    
    var name: String { category }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.category = try (container.decodeIfPresent(String.self, forKey: .category) ?? container.decode(String.self, forKey: .name))
        self.moments = try container.decode([UnifiedMoment].self, forKey: .moments)
    }
    
    nonisolated init(category: String, moments: [UnifiedMoment]) {
        self.category = category
        self.moments = moments
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(category, forKey: .category)
        try container.encode(moments, forKey: .moments)
    }
    
    enum CodingKeys: String, CodingKey {
        case category, name, moments
    }
}

// MARK: - Core Domain Models

struct StudiedPlaceWithSituations: Codable, Identifiable {
    let time: String
    let place_name: String
    let latitude: Double?
    let longitude: Double?
    let date: String
    let micro_situations: [UnifiedMomentSection]
    let priority_score: Double?
    let distance_meters: Double?
    
    var id: String { "\(place_name)_\(time)" }
}

struct MicroSituationData: Codable, Equatable, Identifiable {
    let place_name: String?
    let latitude: Double?
    let longitude: Double?
    let time: String?
    let hour: Int?
    let type: String?
    let created_at: String?
    let context_description: String?
    let micro_situations: [UnifiedMomentSection]?
    let priority_score: Double?
    var distance_meters: Double?
    
    let time_span: String?
    let profession: String?
    let updated_at: String?
    let target_language: String?
    let document_id: String?
    
    var id: String { document_id ?? "\(place_name ?? "unknown")_\(created_at ?? "")" }
}
