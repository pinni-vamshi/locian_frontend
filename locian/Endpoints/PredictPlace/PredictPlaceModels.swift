//
//  PredictPlaceModels.swift
//  locian
//

import Foundation

// MARK: - Request

struct PredictPlaceRequest: Codable {
    let places: [String]
    let time: String?
    let previous_places: [TimelinePlaceContext]?
    let future_places: [TimelinePlaceContext]?
    let native_language: String?
    let target_language: String?
    let level: String?
    let latitude: Double?
    let longitude: Double?
    let date: String?
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
    let micro_situations: [UnifiedMomentSection]?
    let latitude: Double?
    let longitude: Double?
    let time: String?
    let hour: Int?
    let time_span: String?      // Hierarchy Bucket
    let type: String?           // image_analysis/custom
    let created_at: String?
    let document_id: String?
    let total_count: Int?
}

// MARK: - Handover Extension
extension PredictPlaceData {
    /// Converts predicted context data into the common MicroSituationData format for UI consumption.
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
            priority_score: 1.0, // Baseline for predicted context
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
