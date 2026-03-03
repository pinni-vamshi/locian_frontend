//
//  UserIntentContextLogic.swift
//  locian
//
//  Logic for handling the intent discovery process
//

import Foundation
import CoreLocation
import Combine

class UserIntentContextLogic: ObservableObject {
    static let shared = UserIntentContextLogic()
    
    @Published var isLoading = false
    
    private init() {}
    
    /// Main entry point to discover or update the daily intent map
    /// - Parameters:
    ///   - overrides: Optional manual overrides to update the routine (Unified Pattern)
    func discoverDailyIntent(overrides: [String: [String]]? = nil, completion: @escaping (Bool) -> Void = { _ in }) {
        guard !isLoading else {
            print("⚠️ [UserIntentContextLogic] Already loading intent context. Skipping.")
            completion(false)
            return
        }
        
        self.isLoading = true
        
        // 1. Request fresh location (JIT)
        LocationManager.shared.getCurrentLocation { [weak self] result in
            guard let self = self else { return }
            
            let location: CLLocation?
            switch result {
            case .success(let loc):
                location = loc
            case .failure(let error):
                print("⚠️ [UserIntentContextLogic] Failed to get fresh location: \(error.localizedDescription). Using cache.")
                location = LocationManager.shared.currentLocation
            }
            
            guard let loc = location else {
                print("❌ [UserIntentContextLogic] No location available even in cache. Aborting.")
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(false)
                }
                return
            }
            
            // 2. Prepare parameters
            let lat = loc.coordinate.latitude
            let lng = loc.coordinate.longitude
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: Date())
            
            // 3. Call Unified Service
            UserIntentContextService.shared.unifyIntentContext(
                lat: lat,
                lng: lng,
                time: timeString,
                overrides: overrides
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    switch result {
                    case .success(let response):
                        if response.success, let data = response.data {
                            // 3. Update AppStateManager
                            AppStateManager.shared.intentTimeline = data.timeline
                            AppStateManager.shared.currentTimeSpan = data.current_time_span
                            
                            // Merge new geo contexts into existing map
                            if let newContexts = data.geo_contexts {
                                var currentContexts = AppStateManager.shared.geoContexts
                                newContexts.forEach { (key, value) in
                                    currentContexts[key] = value
                                }
                                AppStateManager.shared.geoContexts = currentContexts
                            }
                            
                            // globalRecommendations assignment removed as per V3 scorched earth cleanup
                            
                            print("✅ [UserIntentContextLogic] Received Daily Intent Map. Current Span: \(data.current_time_span ?? "nil"), GeoContexts: \(data.geo_contexts?.count ?? 0)")
                            
                            completion(true)
                        } else {
                            print("⚠️ [UserIntentContextLogic] Response marked as unsuccessful: \(response.message ?? "No message")")
                            completion(false)
                        }
                    case .failure(let error):
                        print("❌ [UserIntentContextLogic] Failed to fetch Daily Intent: \(error.localizedDescription)")
                        completion(false)
                    }
                }
            }
        }
    }
}
