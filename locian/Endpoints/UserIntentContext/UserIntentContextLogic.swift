//
//  UserIntentContextLogic.swift
//  locian
//
//  Logic for loading and writing user intent context
//

import Foundation
import Combine
import CoreLocation

class UserIntentContextLogic: ObservableObject {
    static let shared = UserIntentContextLogic()

    @Published var isLoading = false
    @Published var isPinning = false
    @Published var timeline: [IntentTimelineDay] = []
    @Published var geoContext: [IntentGeoContext] = []
    @Published var userInterests: [String: [IntentUserPlace]] = [:]
    @Published var lastPinResult: IntentPinResult?

    /// Last time intent context was successfully hydrated from the backend.
    private(set) var lastSyncedAt: Date?
    private let lastSyncedKey = "user_intent_context_last_synced"

    private init() {
        if let raw = UserDefaults.standard.object(forKey: lastSyncedKey) as? TimeInterval {
            lastSyncedAt = Date(timeIntervalSince1970: raw)
        }
    }

    /// Refreshes intent context only if the cache is older than `maxAge` seconds.
    /// Cheap enough to call from app foregrounding / significant-change events.
    func refreshIfStale(maxAge: TimeInterval, completion: @escaping (Bool) -> Void = { _ in }) {
        if let last = lastSyncedAt, Date().timeIntervalSince(last) < maxAge {
            completion(false)
            return
        }
        discoverDailyIntent(completion: completion)
    }
    
    // MARK: - Read
    
    /// Main entry point to load the daily intent map (read-only).
    func discoverDailyIntent(completion: @escaping (Bool) -> Void = { _ in }) {
        let startedAt = ISO8601DateFormatter().string(from: Date())
        print("🧭 [UserIntentContextLogic] discoverDailyIntent() called at \(startedAt)")
        
        guard !isLoading else {
            print("⚠️ [UserIntentContextLogic] Already loading intent context. Skipping.")
            completion(false)
            return
        }
        
        if Thread.isMainThread {
            self.isLoading = true
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = true
            }
        }
        
        UserIntentContextService.shared.unifyIntentContext(
            timelineLimit: 30,
            pin: nil
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.applyResponse(result: result, completion: completion)
            }
        }
    }
    
    // MARK: - Pin
    
    /// Writes a pin to `user_interests` on the backend and refreshes local state.
    /// - Parameters:
    ///   - category: Ontology id (e.g. `home`, `cafe`).
    ///   - placeName: Human-readable label (e.g. `Anvi Nilayam`).
    ///   - latitude/longitude: Coordinates.
    ///   - nearbyPlaces: Optional nearby POIs from MapKit (same shape as discover).
    ///   - includeWifi: If true, attach current WiFiService snapshot.
    func pinPlace(
        category: String,
        placeName: String,
        latitude: Double,
        longitude: Double,
        nearbyPlaces: [DiscoverPlaceInput]? = nil,
        includeWifi: Bool = true,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        guard !isPinning else {
            print("⚠️ [UserIntentContextLogic] Pin already in progress. Skipping.")
            completion(false)
            return
        }
        if Thread.isMainThread {
            self.isPinning = true
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.isPinning = true
            }
        }
        
        let (dateString, timeString) = currentDateTimeStrings()
        let wifi = includeWifi ? buildWifiDict() : nil
        
        let pin = IntentPinRequest(
            category: category.lowercased(),
            place_name: placeName,
            latitude: latitude,
            longitude: longitude,
            date: dateString,
            time: timeString,
            timestamp: nil,
            wifi_info: wifi,
            places: nearbyPlaces
        )
        
        print("📌 [UserIntentContextLogic] Pinning place: category=\(category), name=\(placeName), lat=\(latitude), lon=\(longitude), wifi=\(wifi?.count ?? 0) fields, nearby=\(nearbyPlaces?.count ?? 0)")
        
        UserIntentContextService.shared.unifyIntentContext(
            timelineLimit: 30,
            pin: pin
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isPinning = false
                self?.applyResponse(result: result, completion: completion)
            }
        }
    }
    
    // MARK: - Shared response application
    
    private func applyResponse(
        result: Result<UserIntentContextResponse, Error>,
        completion: @escaping (Bool) -> Void
    ) {
        switch result {
        case .success(let response):
            if response.success, let data = response.data {
                let timeline = data.timeline ?? []
                let geoContext = data.geo_context ?? []
                let userInterests = data.user_interests ?? [:]
                
                self.timeline = timeline
                self.geoContext = geoContext
                self.userInterests = userInterests
                self.lastPinResult = data.pin_result

                self.lastSyncedAt = Date()
                UserDefaults.standard.set(self.lastSyncedAt!.timeIntervalSince1970, forKey: self.lastSyncedKey)

                let categoryCount = userInterests.count
                let totalPlaces = userInterests.values.reduce(0) { $0 + $1.count }
                print("✅ [UserIntentContextLogic] Timeline days: \(timeline.count), GeoContexts: \(geoContext.count), UserInterests categories: \(categoryCount), places: \(totalPlaces)")
                
                if let pin = data.pin_result {
                    print("📌 [UserIntentContextLogic] Pin echo: success=\(pin.success ?? false), category=\(pin.category ?? "-"), name=\(pin.place_name ?? "-"), id=\(pin.place_id ?? "-")")
                }
                
                completion(true)
            } else {
                print("⚠️ [UserIntentContextLogic] Response marked as unsuccessful: \(response.message ?? "No message")")
                completion(false)
            }
        case .failure(let error):
            print("❌ [UserIntentContextLogic] Failed request: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Helpers
    
    private func currentDateTimeStrings() -> (date: String, time: String) {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat = "HH:mm"
        return (dateFormatter.string(from: now), timeFormatter.string(from: now))
    }
    
    private func buildWifiDict() -> [String: String]? {
        var dict: [String: String] = [:]
        if let s = WiFiService.shared.currentSSID { dict["ssid"] = s }
        if let b = WiFiService.shared.currentBSSID { dict["bssid"] = b }
        let conn = WiFiService.shared.connectionType
        if !conn.isEmpty { dict["connection_type"] = conn }
        if let ip = WiFiService.shared.internalIP { dict["internal_ip"] = ip }
        if let gw = WiFiService.shared.gatewayIP { dict["gateway_ip"] = gw }
        return dict.isEmpty ? nil : dict
    }
}
