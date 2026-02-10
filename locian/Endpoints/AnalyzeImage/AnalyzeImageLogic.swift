//
//  AnalyzeImageLogic.swift
//  locian
//
//  Logic layer for Analyze Image Endpoint
//  Parses raw response data
//

import Foundation

class AnalyzeImageLogic {
    static let shared = AnalyzeImageLogic()
    
    private init() {}
    
    // MARK: - Response Parsing
    
    /// Parse raw JSON data into structured response
    nonisolated func parseResponse(
        data: Data,
        completion: @escaping (Result<AnalyzeImageResponse, Error>) -> Void
    ) {
        Task.detached { @Sendable in
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw NSError(domain: "DecodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])
                }
                
                let success = jsonObject["success"] as? Bool ?? false
                let message = jsonObject["message"] as? String
                let error = jsonObject["error"] as? String
                
                var dataDict: AnalyzeImageData? = nil
                if let dataObj = jsonObject["data"] as? [String: Any] {
                    let placeName = dataObj["place_name"] as? String ?? ""
                    
                    // Parse micro_situations
                    let sectionsArray = dataObj["micro_situations"] as? [[String: Any]] ?? []
                    let sections = sectionsArray.compactMap { self.parseSection($0) }
                    
                    // Parse hour from time string if needed
                    var hour = dataObj["hour"] as? Int
                    if hour == nil, let timeStr = dataObj["time"] as? String {
                        hour = self.parseHourFromTimeString(timeStr)
                    }
                    
                    dataDict = AnalyzeImageData(
                        place_name: placeName,
                        document_id: dataObj["document_id"] as? String,
                        latitude: dataObj["latitude"] as? Double,
                        longitude: dataObj["longitude"] as? Double,
                        time: dataObj["time"] as? String,
                        hour: hour,
                        time_span: dataObj["time_span"] as? String,
                        type: dataObj["type"] as? String,
                        created_at: dataObj["created_at"] as? String,
                        micro_situations: sections,
                        moments_count: dataObj["moments_count"] as? Int ?? 0
                    )
                }
                
                let decodedResponse = AnalyzeImageResponse(
                    success: success,
                    message: message,
                    data: dataDict,
                    error: error
                )
                
                await MainActor.run { completion(.success(decodedResponse)) }
            } catch {
                await MainActor.run { completion(.failure(error)) }
            }
        }
    }
    
    // MARK: - Private Parsing Helpers
    
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
