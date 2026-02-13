//
//  GenerateMomentsModels.swift
//  locian
//
//  Models for Generate Moments Endpoint
//  Pure data structures - no parsing logic
//

import Foundation

// MARK: - Request Model

struct GenerateMomentsRequest: Codable {
    let place_name: String
    let place_detail: String?
    let time: String?
    let profession: String?
    let previous_places: [TimelinePlaceContext]?
    let future_places: [TimelinePlaceContext]?
    let nearby_places: [NearbyPlaceData]?
    let weather: String?
    let activity_duration: String?
    let latitude: Double?
    let longitude: Double?
    let user_language: String?
    let level: String?
    let remember: Bool?
}

// MARK: - Response Models

struct GenerateMomentsResponse: Codable {
    let success: Bool
    let message: String?
    let data: GenerateMomentsData?
    let error: String?
}

struct GenerateMomentsData: Codable {
    let place_name: String
    let document_id: String?
    let latitude: Double?
    let longitude: Double?
    let time: String?
    let hour: Int?
    
    // Heritage Hierarchy Fields
    let time_span: String?      // Morning/Afternoon/Evening
    let type: String?           // image_analysis/custom
    
    let created_at: String?
    let micro_situations: [UnifiedMomentSection]
    let total_count: Int
}

// MARK: - Handover Extension
extension GenerateMomentsData {
    /// Converts generated moments data into the common MicroSituationData format for UI consumption.
    func toMicroSituationData() -> MicroSituationData {
        return MicroSituationData(
            place_name: self.place_name,
            latitude: self.latitude,
            longitude: self.longitude,
            time: self.time,
            hour: self.hour,
            created_at: self.created_at,
            context_description: nil,
            micro_situations: self.micro_situations,
            priority_score: 1.2, // Boosted priority for user-requested generation
            distance_meters: nil,
            time_span: self.time_span,
            type: self.type ?? "custom",
            profession: nil,
            updated_at: nil,
            target_language: nil,
            document_id: self.document_id
        )
    }
}
