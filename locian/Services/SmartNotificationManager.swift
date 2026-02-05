//
//  SmartNotificationManager.swift
//  locian
//
//  Created by AI Assistant on 23/01/26.
//

import Foundation
import CoreLocation
import Combine

class SmartNotificationManager {
    static let shared = SmartNotificationManager()
    
    private var cancellables = Set<AnyCancellable>()
    private var lastTriggeredLocation: String?
    private var lastTriggeredTime: Date?
    
    // Cooldown interval: 6 hours (reduced from 12 for better testing/daily use)
    private let cooldownInterval: TimeInterval = 6 * 3600
    
    // Proximity threshold: 100 meters
    private let proximityThreshold: CLLocationDistance = 100
    
    private init() {}
    
    func startMonitoring() {
        print("🛰️ [SmartNotificationManager] Starting monitoring...")
        
        LocationManager.shared.$currentLocation
            .compactMap { $0 }
            .throttle(for: .seconds(30), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] location in
                self?.performProximityCheck(at: location)
            }
            .store(in: &cancellables)
    }
    
    private var isFetchingTimeline = false

    private func performProximityCheck(at location: CLLocation) {
        // EPHEMERAL TIMELINE HANDLING
        // Since we don't persist timeline to disk, it starts as nil.
        // If nil, we must fetch it silently to have data to monitor.
        if AppStateManager.shared.timeline == nil {
            fetchTimelineAndRetry(at: location)
            return
        }
    
        let hour = Calendar.current.component(.hour, from: Date())
        let profession = AppStateManager.shared.profession
        
        // 1. Check User-Defined Routines
        if let routineSelections = loadRoutineSelections() {
            if let placeName = routineSelections[hour] {
                // If we have a place name for this hour, we could try to find its coordinates
                // from the timeline if it's a recently visited place.
                if let placeData = findPlaceInTimeline(name: placeName) {
                    let placeLoc = CLLocation(latitude: placeData.latitude ?? 0, longitude: placeData.longitude ?? 0)
                    if location.distance(from: placeLoc) < proximityThreshold {
                        triggerNotification(for: placeName, profession: profession)
                        return
                    }
                }
            }
        }
        
        // 2. Check Profession Defaults (Geo-fencing for common types if we had their locations)
        // For now, we mainly rely on "Known Places" that match the profession-based routine.
        let timelinePlaces = AppStateManager.shared.timeline?.places ?? []
        
        let professionPlaces = UserRoutineManager.getPlaces(for: profession, hour: hour)
        
        for place in timelinePlaces {
            guard let name = place.place_name, 
                  let lat = place.latitude, 
                  let lon = place.longitude else { continue }
            
            let placeLoc = CLLocation(latitude: lat, longitude: lon)
            let distance = location.distance(from: placeLoc)
            
            if distance < proximityThreshold {
                // We are at a known place. Does it match our profession routine for this hour?
                if professionPlaces.contains(name) {
                    triggerNotification(for: name, profession: profession)
                    return
                }
            }
        }
    }
    
    private func fetchTimelineAndRetry(at location: CLLocation) {
        guard !isFetchingTimeline else { return }
        
        guard let token = AppStateManager.shared.authToken, !token.isEmpty else {
            print("⚠️ [SmartNotificationManager] Cannot fetch timeline: No auth token.")
            return
        }
        
        print("🛰️ [SmartNotificationManager] Timeline is missing (ephemeral). Fetching silently...")
        isFetchingTimeline = true
        
        LearnTabService.shared.fetchAndLoadContent(sessionToken: token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isFetchingTimeline = false
                
                switch result {
                case .success(let data):
                    print("✅ [SmartNotificationManager] Silent fetch success. Hydrating AppState...")
                    AppStateManager.shared.timeline = data.timeline
                    AppStateManager.shared.hasInitialHistoryLoaded = true
                    // Retry check immediately
                    self.performProximityCheck(at: location)
                case .failure(let error):
                    print("❌ [SmartNotificationManager] Silent fetch failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func triggerNotification(for placeName: String, profession: String) {
        // Cooldown check
        if let lastLoc = lastTriggeredLocation, lastLoc == placeName,
           let lastTime = lastTriggeredTime, Date().timeIntervalSince(lastTime) < cooldownInterval {
            return
        }
        
        let greeting = getGreeting()
        let username = AppStateManager.shared.username.isEmpty ? "Learner" : AppStateManager.shared.username
        let professionTitle = profession.replacingOccurrences(of: "_", with: " ").capitalized
        
        let title = "\(greeting), \(username)! 👋"
        let body = "Ready for a quick session at \(placeName)? 📚 Being a great \(professionTitle) starts with consistent practice!"
        
        print("🔔 [SmartNotificationManager] Triggering notification for \(placeName)")
        
        let hour = Calendar.current.component(.hour, from: Date())
        NotificationService.shared.scheduleSmartLocationNotification(
            title: title,
            body: body,
            placeName: placeName,
            hour: hour
        )
        
        lastTriggeredLocation = placeName
        lastTriggeredTime = Date()
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Hello"
        }
    }
    
    private func loadRoutineSelections() -> [Int: String]? {
        let routineSelectionsJSON = UserDefaults.standard.string(forKey: "routine_selections_json") ?? "{}"
        if let data = routineSelectionsJSON.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([Int: String].self, from: data) {
            return decoded
        }
        return nil
    }
    
    private func findPlaceInTimeline(name: String) -> MicroSituationData? {
        let allPlaces = AppStateManager.shared.timeline?.places ?? []
        
        return allPlaces.first { $0.place_name?.lowercased() == name.lowercased() }
    }
}
