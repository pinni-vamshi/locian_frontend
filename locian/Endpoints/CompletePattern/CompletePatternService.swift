//
//  CompletePatternService.swift
//  locian
//
//  Service Layer for Pattern Completion.
//  Collects all necessary data (GPS, token) and performs the network call.
//

import Foundation

class CompletePatternService {
    static let shared = CompletePatternService()
    private init() {}
    
    /// Collects context and hits the completion endpoint
    func completePattern(
        patternId: String? = nil,
        placeId: String,
        topic: String? = nil,
        places: [DiscoverPlaceInput]? = nil,
        completion: @escaping (Result<CompletePatternResponse, Error>) -> Void
    ) {
        // 1. Capture Time (Local Context)
        let currentDate = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: currentDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: currentDate)
        
        let locationManager = LocationManager.shared

        let idLabel = patternId ?? "INTEREST-TAP"
        print("📡 [CompletePatternService] Triggered '\(idLabel)' @ '\(placeId)'. Collecting on-demand context...")

        // 2. Collect Context On-Demand (fresh nearby + fresh location snapshot)
        locationManager.fetchNearbyPlaces { freshNearbyPlaces in
            let structuredPlaces = freshNearbyPlaces.map { place in
                DiscoverPlaceInput(
                    name: place.name,
                    category: place.category ?? "unknown",
                    place_latitude: place.latitude,
                    place_longitude: place.longitude
                )
            }

            // Fallback to caller-provided places only if on-demand fetch returns none.
            let fallbackPlaces = places ?? []
            let finalPlaces = structuredPlaces.isEmpty ? fallbackPlaces : structuredPlaces

            // Read latest coordinates after on-demand location attempt.
            let lat = locationManager.latitude
            let lon = locationManager.longitude
            let activePair = AppStateManager.shared.userLanguagePairs.first(where: { $0.is_default }) ?? AppStateManager.shared.userLanguagePairs.first
            let targetLanguage = activePair?.target_language

            var wifiDict = [String: String]()
            if let ssid = WiFiService.shared.currentSSID {
                wifiDict["ssid"] = ssid
            }
            if let bssid = WiFiService.shared.currentBSSID {
                wifiDict["bssid"] = bssid
            }
            let connType = WiFiService.shared.connectionType
            if !connType.isEmpty {
                wifiDict["connection_type"] = connType
            }

            let request = CompletePatternRequest(
                place_id: placeId,
                pattern_id: patternId,
                topic: topic,
                target_language: targetLanguage,
                time: timeString,
                date: dateString,
                latitude: lat,
                longitude: lon,
                wifi_info: wifiDict.isEmpty ? nil : wifiDict,
                places: finalPlaces
            )

            print("📦 [CompletePatternService] Sending completion payload with \(finalPlaces.count) places.")

            // 3. Perform Request
            BaseAPIManager.shared.performRequest(
                endpoint: "/api/learning/complete-pattern",
                method: "POST",
                body: request,
                completion: completion
            )
        }
    }
}
