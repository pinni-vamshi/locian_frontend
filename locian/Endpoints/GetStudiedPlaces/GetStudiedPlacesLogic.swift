//
//  GetStudiedPlacesLogic.swift
//  locian
//
//  Logic layer for Get Studied Places Endpoint
//  Parses raw response data and converts to required formats
//

import Foundation

class GetStudiedPlacesLogic {
    static let shared = GetStudiedPlacesLogic()
    
    private init() {}
    
    // MARK: - Response Parsing
    
    /// Parse raw JSON data into structured response
    nonisolated func parseResponse(
        data: Data,
        completion: @escaping (Result<GetStudiedPlacesResponse, Error>) -> Void
    ) {
        Task.detached { @Sendable in
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw NSError(domain: "DecodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])
                }
                
                let success = jsonObject["success"] as? Bool ?? false
                let message = jsonObject["message"] as? String
                let error = jsonObject["error"] as? String
                
                var dataDict: GetStudiedPlacesData? = nil
                if let dataObj = jsonObject["data"] as? [String: Any] {
                    let placesArray = dataObj["places"] as? [[String: Any]] ?? []
                    print("📦 [GetStudiedPlacesLogic] Starting decoding of \(placesArray.count) places...")
                    
                    let places = placesArray.compactMap { self.parseMicroSituation($0) }
                    print("📦 [GetStudiedPlacesLogic] Successfully decoded \(places.count) / \(placesArray.count) places.")
                    
                    dataDict = GetStudiedPlacesData(
                        places: places,
                        input_time: dataObj["input_time"] as? String ?? "",
                        count: dataObj["count"] as? Int ?? 0
                    )
                }
                
                let decodedResponse = GetStudiedPlacesResponse(
                    success: success,
                    data: dataDict,
                    message: message,
                    error: error
                )
                
                await MainActor.run { completion(.success(decodedResponse)) }
            } catch {
                await MainActor.run { completion(.failure(error)) }
            }
        }
    }
    
    // MARK: - Private Parsing Helpers
    
    private nonisolated func parseMicroSituation(_ dict: [String: Any]) -> MicroSituationData? {
        // Parse hour from time string if needed
        var hour = dict["hour"] as? Int
        if hour == nil, let timeStr = dict["time"] as? String {
            hour = self.parseHourFromTimeString(timeStr)
        }
        
        // Parse micro_situations
        let sectionsArray = dict["micro_situations"] as? [[String: Any]] ?? []
        let sections = sectionsArray.compactMap { sectionDict -> UnifiedMomentSection? in
            let title = (sectionDict["category"] as? String) ?? (sectionDict["name"] as? String) ?? (sectionDict["section_title"] as? String)
            let momentsAny = sectionDict["moments"]
            let moments = self.parseUnifiedMoments(momentsAny)
            return UnifiedMomentSection(category: title ?? "Details", moments: moments)
        }
        
        if let name = dict["place_name"] as? String {
            print("📦 [GetStudiedPlacesLogic] Decoded place: '\(name)' at Hour: \(hour ?? -1)")
        }
        
        return MicroSituationData(
            place_name: dict["place_name"] as? String,
            latitude: dict["latitude"] as? Double,
            longitude: dict["longitude"] as? Double,
            time: dict["time"] as? String,
            hour: hour,
            type: dict["type"] as? String,
            created_at: dict["created_at"] as? String ?? "",
            context_description: dict["context_description"] as? String,
            micro_situations: sections,
            priority_score: dict["priority_score"] as? Double,
            distance_meters: dict["distance_meters"] as? Double,
            time_span: dict["time_span"] as? String,
            profession: dict["profession"] as? String,
            updated_at: dict["updated_at"] as? String,
            target_language: dict["target_language"] as? String,
            document_id: dict["document_id"] as? String
        )
    }
    
    private nonisolated func parseUnifiedMoments(_ momentsAny: Any?) -> [UnifiedMoment] {
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
        print("🕒 [GetStudiedPlacesLogic] Attempting to parse time: '\(timeStr)'")
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let formats = ["h:mm a", "h:mma", "HH:mm", "h:mm"]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: timeStr) {
                let hour = Calendar.current.component(.hour, from: date)
                print("   ✅ Parsed with format '\(format)' -> Hour: \(hour)")
                return hour
            }
        }
        
        // Fallback: Regex parsing
        print("   ⚠️ Decoder failing for '\(timeStr)'. Trying Regex.")
        let pattern = #"^(\d{1,2}):(\d{2})\s*([AP]M)"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: timeStr, range: NSRange(timeStr.startIndex..., in: timeStr)) {
                
            let hourStr = String(timeStr[Range(match.range(at: 1), in: timeStr)!])
            let ampmStr = String(timeStr[Range(match.range(at: 3), in: timeStr)!])
            
            if let hVal = Int(hourStr) {
                var h = hVal
                if ampmStr.uppercased() == "PM" && h < 12 { h += 12 }
                if ampmStr.uppercased() == "AM" && h == 12 { h = 0 }
                print("   ✅ Regex Fixed -> Hour: \(h)")
                return h
            }
        }
        
        print("   ❌ Parsing FAILED for '\(timeStr)'")
        return nil
    }
}
