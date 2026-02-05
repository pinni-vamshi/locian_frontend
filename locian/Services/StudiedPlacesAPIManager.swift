import Foundation
import CoreLocation

class StudiedPlacesAPIManager: BaseAPIManagerProtocol {
    static let shared = StudiedPlacesAPIManager()
    
    private init() {}
    
    // MARK: - API Calls
    
    /// Add studied place
    func addStudiedPlace(request: AddStudiedPlaceRequest, sessionToken: String, completion: @escaping (Result<AddStudiedPlaceResponse, Error>) -> Void) {
        performRequest(
            endpoint: "/api/user/studied-places/add",
            method: "POST",
            body: request,
            headers: ["Authorization": "Bearer \(sessionToken)"],
            completion: completion
        )
    }
    
    /// Get studied places with moments (POST endpoint with time and limit)
    func getStudiedPlaces(request: GetStudiedPlacesRequest, sessionToken: String, extraHeaders: [String: String] = [:], completion: @escaping (Result<GetStudiedPlacesResponse, Error>) -> Void) {
        var headers = ["Authorization": "Bearer \(sessionToken)"]
        // Merge extra headers
        for (key, value) in extraHeaders {
            headers[key] = value
        }
        
        performRawRequest(
            endpoint: "/api/user/studied-places/get",
            method: "POST",
            body: request,
            headers: headers,
            timeoutInterval: 300.0, // 5 minutes timeout for studied places
            completion: { (result: Result<Data, Error>) in
                switch result {
                case .success(let data):
                    Self.decodeStudiedPlacesResponse(data: data, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    /// Legacy method for backward compatibility (deprecated)
    func getStudiedPlaces(sessionToken: String, completion: @escaping (Result<GetStudiedPlacesResponse, Error>) -> Void) {
        let now = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let timeString = timeFormatter.string(from: now)
        
        LocationManager.shared.getCurrentLocation { result in
            var latitude: Double? = LocationManager.shared.latitude
            var longitude: Double? = LocationManager.shared.longitude
            
            if case .success(let location) = result {
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
            }
            
            let request = GetStudiedPlacesRequest(
                time: timeString,
                latitude: latitude,
                longitude: longitude,
                limit: 50
            )
            self.getStudiedPlaces(request: request, sessionToken: sessionToken, completion: completion)
        }
    }
    
    // MARK: - Decoding Logic (Moved from LanguageAPIManager)
    
    nonisolated private static func decodeStudiedPlacesResponse(
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
                    print("📦 [Decoder] Starting decoding of \(placesArray.count) places...")
                    let places = placesArray.compactMap { decodeMicroSituation($0) }
                    print("📦 [Decoder] Successfully decoded \(places.count) / \(placesArray.count) places.")
                    
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
    
    nonisolated private static func decodeTimeline(_ dataObj: [String: Any]) -> TimelineData? {
        guard let timelineObj = dataObj["timeline"] as? [String: Any] else {
            return nil
        }
        
        if let placesArray = timelineObj["places"] as? [[String: Any]] {
             let places = placesArray.compactMap { decodeMicroSituation($0) }
             return TimelineData(places: places)
        }
        
        var allPlaces: [MicroSituationData] = []
        
        func extractPlaces(from sectionKey: String) -> [MicroSituationData] {
            guard let sectionObj = timelineObj[sectionKey] as? [String: Any],
                  let placesArray = sectionObj["places"] as? [[String: Any]] else {
                return []
            }
            return placesArray.compactMap { decodeMicroSituation($0) }
        }
        
        allPlaces.append(contentsOf: extractPlaces(from: "current"))
        allPlaces.append(contentsOf: extractPlaces(from: "past"))
        allPlaces.append(contentsOf: extractPlaces(from: "future"))
        
        return TimelineData(places: allPlaces)
    }
    
    nonisolated private static func decodeMicroSituation(_ dict: [String: Any]) -> MicroSituationData? {
        let sectionsArray = dict["micro_situations"] as? [[String: Any]] ?? []
        
        let sections = sectionsArray.compactMap { sectionDict -> UnifiedMomentSection? in
            let title = (sectionDict["category"] as? String) ?? (sectionDict["name"] as? String) ?? (sectionDict["section_title"] as? String)
            guard let validTitle = title else { 
                print("   ⚠️ [Decoder] Section missing title: \(sectionDict)")
                return nil 
            }
            let moments = decodeUnifiedMoments(sectionDict["moments"])
            return UnifiedMomentSection(category: validTitle, moments: moments)
        }
        
        // Parse Hour Logic
        var hour = dict["hour"] as? Int
        
        if hour == nil, let rawTimeStr = dict["time"] as? String {
            let timeStr = rawTimeStr.replacingOccurrences(of: "\u{00A0}", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            print("🕒 [Decoder] Attempting to parse time: '\(timeStr)'")
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            let formats = ["h:mm a", "h:mma", "HH:mm", "h:mm"]
            var parsed = false
            
            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: timeStr) {
                    hour = Calendar.current.component(.hour, from: date)
                    print("   ✅ Parsed with format '\(format)' -> Hour: \(hour!)")
                    parsed = true
                    break 
                }
            }
            
            if !parsed {
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
                        hour = h
                        print("   ✅ Regex Fixed -> Hour: \(h)")
                    }
                } else {
                    print("   ❌ Parsing FAILED for '\(timeStr)'")
                }
            }
        }
        
        if let name = dict["place_name"] as? String {
            print("📦 [Decoder] Decoded place: '\(name)' at Hour: \(hour ?? -1)")
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
    
    nonisolated private static func decodeUnifiedMoments(_ momentsAny: Any?) -> [UnifiedMoment] {
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
}
