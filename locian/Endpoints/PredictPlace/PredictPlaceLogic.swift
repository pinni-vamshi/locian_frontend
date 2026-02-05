//
//  PredictPlaceLogic.swift
//  locian
//
//  Logic layer - parses raw response data
//

import Foundation

class PredictPlaceLogic {
    static let shared = PredictPlaceLogic()
    private init() {}
    
    // MARK: - Response Parsing
    
    /// Parse raw JSON data into structured response
    nonisolated func parseResponse(
        data: Data,
        completion: @escaping (Result<PredictPlaceResponse, Error>) -> Void
    ) {
        Task.detached { @Sendable in
            do {
                // First decode the raw JSON to inspect structure
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw NSError(domain: "PredictPlaceLogic", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])
                }
                
                let success = json["success"] as? Bool ?? false
                let message = json["message"] as? String
                let error = json["error"] as? String
                
                // Parse data if present
                var parsedData: PredictPlaceData? = nil
                if let dataDict = json["data"] as? [String: Any] {
                    parsedData = self.parsePredictPlaceData(dataDict)
                }
                
                let response = PredictPlaceResponse(
                    success: success,
                    message: message,
                    data: parsedData,
                    error: error
                )
                
                await MainActor.run { completion(.success(response)) }
            } catch {
                await MainActor.run { completion(.failure(error)) }
            }
        }
    }
    
    // MARK: - Private Parsing Helpers
    
    private nonisolated func parsePredictPlaceData(_ dict: [String: Any]) -> PredictPlaceData? {
        guard let placeName = dict["place_name"] as? String else { return nil }
        
        // Parse micro_situations
        let sectionsArray = dict["micro_situations"] as? [[String: Any]] ?? []
        let sections = sectionsArray.compactMap { parseSection($0) }
        
        // Parse hour from time string if needed
        var hour = dict["hour"] as? Int
        if hour == nil, let timeStr = dict["time"] as? String {
            hour = parseHourFromTimeString(timeStr)
        }
        
        return PredictPlaceData(
            place_name: placeName,
            document_id: dict["document_id"] as? String,
            latitude: dict["latitude"] as? Double,
            longitude: dict["longitude"] as? Double,
            time: dict["time"] as? String,
            hour: hour,
            type: dict["type"] as? String,
            created_at: dict["created_at"] as? String,
            micro_situations: sections,
            total_count: dict["total_count"] as? Int
        )
    }
    
    private nonisolated func parseSection(_ dict: [String: Any]) -> UnifiedMomentSection? {
        let category = (dict["category"] as? String) ?? (dict["name"] as? String)
        guard let validCategory = category else { return nil }
        
        let moments = parseMoments(dict["moments"])
        return UnifiedMomentSection(category: validCategory, moments: moments)
    }
    
    private nonisolated func parseMoments(_ momentsAny: Any?) -> [UnifiedMoment] {
        if let momentsObjects = momentsAny as? [[String: Any]] {
            return momentsObjects.compactMap { momentDict -> UnifiedMoment? in
                guard let text = momentDict["text"] as? String else { return nil }
                let keywords = momentDict["keywords"] as? [String]
                return UnifiedMoment(text: text, keywords: keywords)
            }
        } else if let momentsStrings = momentsAny as? [String] {
            return momentsStrings.map { UnifiedMoment(text: $0, keywords: nil) }
        }
        return []
    }
    
    private nonisolated func parseHourFromTimeString(_ rawTimeStr: String) -> Int? {
        let timeStr = rawTimeStr.replacingOccurrences(of: "\u{00A0}", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let formats = ["h:mm a", "h:mma", "HH:mm", "h:mm"]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: timeStr) {
                return Calendar.current.component(.hour, from: date)
            }
        }
        
        return nil
    }
}
