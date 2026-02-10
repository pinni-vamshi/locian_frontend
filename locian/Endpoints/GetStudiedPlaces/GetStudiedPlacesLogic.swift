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
        print("📦 [GetStudiedPlacesLogic] Raw Data Received (\(data.count) bytes). Parsing...")
        Task.detached { @Sendable in
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("❌ [GetStudiedPlacesLogic] JSON Serialization failed.")
                    throw NSError(domain: "DecodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])
                }
                
                let success = jsonObject["success"] as? Bool ?? false
                print("📦 [GetStudiedPlacesLogic] Success Flag: \(success)")
                let message = jsonObject["message"] as? String
                let error = jsonObject["error"] as? String
                
                var dataDict: GetStudiedPlacesData? = nil
                if let dataObj = jsonObject["data"] as? [String: Any] {
                    
                    // Parse the NEW hierarchical structure: dates → moments
                    var dateGroups: [DateGroup] = []
                    if let datesArray = dataObj["dates"] as? [[String: Any]] {
                        print("📦 [GetStudiedPlacesLogic] Found \(datesArray.count) date groups")
                        
                        for dateDict in datesArray {
                            guard let dateString = dateDict["date"] as? String else { continue }
                            let momentsArray = dateDict["moments"] as? [[String: Any]] ?? []
                            
                            print("📦 [GetStudiedPlacesLogic] Date: '\(dateString)' - Parsing \(momentsArray.count) moments...")
                            
                            var moments: [MicroSituationData] = []
                            for momentDict in momentsArray {
                                if let moment = await self.parseMicroSituation(momentDict) {
                                    moments.append(moment)
                                }
                            }
                            
                            print("📦 [GetStudiedPlacesLogic] Successfully decoded \(moments.count) / \(momentsArray.count) moments for \(dateString)")
                            
                            let dateGroup = DateGroup(date: dateString, moments: moments)
                            dateGroups.append(dateGroup)
                        }
                    }
                    
                    // Calculate totals
                    let totalDates = dateGroups.count
                    let totalMoments = dateGroups.reduce(0) { $0 + $1.moments.count }
                    print("📦 [GetStudiedPlacesLogic] Total: \(totalDates) dates, \(totalMoments) moments")
                    
                    // Parse User Intent if available
                    var userIntent: UserIntent? = nil
                    if let intentDict = dataObj["user_intent"] as? [String: Any] {
                        
                        // Handle complex suggested_needs (Array -> String)
                        var needsString: String? = nil
                        if let needsArray = intentDict["suggested_needs"] as? [[String: String]] {
                             needsString = needsArray.map { dict in
                                 let n = dict["Need"] ?? ""
                                 let r = dict["Reason"] ?? ""
                                 return "\(n) because \(r)"
                             }.joined(separator: ". ")
                        } else {
                            needsString = intentDict["suggested_needs"] as? String
                        }
                        
                        userIntent = UserIntent(
                            movement: intentDict["movement"] as? String,
                            waiting: intentDict["waiting"] as? String,
                            consume_fast: intentDict["consume_fast"] as? String,
                            consume_slow: intentDict["consume_slow"] as? String,
                            errands: intentDict["errands"] as? String,
                            browsing: intentDict["browsing"] as? String,
                            rest: intentDict["rest"] as? String,
                            social: intentDict["social"] as? String,
                            emergency: intentDict["emergency"] as? String,
                            suggested_needs: needsString
                        )
                        print("🧠 [GetStudiedPlacesLogic] Successfully parsed User Intent")
                    } else {
                        print("⚠️ [GetStudiedPlacesLogic] No User Intent found in response")
                    }
                    
                    dataDict = GetStudiedPlacesData(
                        dates: dateGroups,
                        total_dates: totalDates,
                        total_moments: totalMoments,
                        input_time: dataObj["input_time"] as? String ?? "",
                        user_intent: userIntent
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
    
    // Helper to parse individual MicroSituationData
    private func parseMicroSituation(_ dict: [String: Any]) async -> MicroSituationData? {
        // Parse hour from time string if needed
        var hour = dict["hour"] as? Int
        if hour == nil, let timeStr = dict["time"] as? String {
            hour = self.parseHourFromTimeString(timeStr)
        }
        
        // Parse micro_situations (Handle Sections)
        let sectionsArray = dict["micro_situations"] as? [[String: Any]] ?? []
        var unifiedSections: [UnifiedMomentSection] = []
        
        for sectionDict in sectionsArray {
            let title = (sectionDict["category"] as? String) ?? (sectionDict["name"] as? String) ?? (sectionDict["section_title"] as? String)
            let momentsAny = sectionDict["moments"]
            let moments = await self.parseUnifiedMoments(momentsAny)
            if !moments.isEmpty {
                unifiedSections.append(UnifiedMomentSection(category: title ?? "Details", moments: moments))
            }
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
            created_at: dict["created_at"] as? String,
            context_description: dict["context_description"] as? String,
            micro_situations: unifiedSections,
            priority_score: dict["priority_score"] as? Double,
            distance_meters: dict["distance_meters"] as? Double,
            time_span: dict["time_span"] as? String,
            type: dict["type"] as? String,
            profession: dict["profession"] as? String,
            updated_at: dict["updated_at"] as? String,
            target_language: dict["target_language"] as? String,
            document_id: dict["document_id"] as? String
        )
    }
    
    private func parseUnifiedMoments(_ momentsAny: Any?) async -> [UnifiedMoment] {
        if let momentsObjects = momentsAny as? [[String: Any]] {
            var moments: [UnifiedMoment] = []
            for momentDict in momentsObjects {
                guard let text = momentDict["text"] as? String else { continue }
                let keywords = momentDict["keywords"] as? [String]
                
                // 🚀 CREATE EMBEDDING AT THE SOURCE (Using Global EmbeddingService)
                // Using MainActor.run only because EmbeddingService.getVector assumes implicit isolation or strict concurrency checks
                let embedding = await MainActor.run { EmbeddingService.getVector(for: text, languageCode: "en") }
                
                moments.append(UnifiedMoment(text: text, keywords: keywords, embedding: embedding))
            }
            return moments
        } else if let momentsStrings = momentsAny as? [String] {
            var moments: [UnifiedMoment] = []
            for text in momentsStrings {
                let embedding = await MainActor.run { EmbeddingService.getVector(for: text, languageCode: "en") }
                moments.append(UnifiedMoment(text: text, keywords: nil, embedding: embedding))
            }
            return moments
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
