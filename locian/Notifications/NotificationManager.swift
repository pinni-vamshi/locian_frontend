//
//  NotificationManager.swift
//  locian
//
//  Centralized manager for simplified, smart notifications.
//

import Foundation
import UserNotifications
import CoreLocation
import Combine

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isNotificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isNotificationsEnabled, forKey: "isNotificationsEnabled")
            if !isNotificationsEnabled {
                cancelAllNotifications()
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var lastTriggeredLocation: String?
    private var lastTriggeredTime: Date?
    
    // Notification History
    struct NotificationLogEntry: Codable {
        let placeName: String
        let points: Int
        let latitude: Double
        let longitude: Double
        let timestamp: Date
    }
    
    private let logLimit = 50
    private let logKey = "notification_log_history"
    
    // Configuration
    private let cooldownInterval: TimeInterval = 6 * 3600 // 6 hours
    private let proximityThreshold: CLLocationDistance = 100 // 100 meters
    private var isFetchingTimeline = false
    
    private override init() {
        self.isNotificationsEnabled = (UserDefaults.standard.object(forKey: "isNotificationsEnabled") as? Bool) ?? true
        super.init()
    }
    
    // MARK: - Permissions
    
    func checkPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // MARK: - Smart Monitoring
    
    func startMonitoring() {
        print("🛰️ [NotificationManager] Starting smart monitoring...")
        
        LocationManager.shared.$currentLocation
            .compactMap { $0 }
            .throttle(for: .seconds(30), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] location in
                guard let self = self, self.isNotificationsEnabled else { return }
                self.performProximityCheck(at: location)
            }
            .store(in: &cancellables)
    }
    
    private func performProximityCheck(at location: CLLocation) {
        // Only proceed if authorized
        checkPermission { [weak self] authorized in
            guard let self = self, authorized else { return }
            
            // Only proceed if timeline is hydrated
            guard let timeline = AppStateManager.shared.timeline else {
                self.fetchTimelineAndRetry(at: location)
                return
            }
            
            let hour = Calendar.current.component(.hour, from: Date())
            let profession = AppStateManager.shared.profession
            
            // 1. Check User-Defined Routines
            if let routineSelections = self.loadRoutineSelections(), let placeName = routineSelections[hour] {
                if let placeData = timeline.places.first(where: { $0.place_name?.lowercased() == placeName.lowercased() }) {
                    let placeLoc = CLLocation(latitude: placeData.latitude ?? 0, longitude: placeData.longitude ?? 0)
                    if location.distance(from: placeLoc) < self.proximityThreshold {
                        self.triggerSmartNotification(for: placeName)
                        return
                    }
                }
            }
            
            // 2. Check Profession Defaults
            let professionPlaces = UserRoutineManager.getPlaces(for: profession, hour: hour)
            for place in timeline.places {
                guard let name = place.place_name,
                      let lat = place.latitude,
                      let lon = place.longitude else { continue }
                
                if location.distance(from: CLLocation(latitude: lat, longitude: lon)) < self.proximityThreshold {
                    if professionPlaces.contains(name) {
                        self.triggerSmartNotification(for: name)
                        return
                    }
                }
            }
        }
    }
    
    private func fetchTimelineAndRetry(at location: CLLocation) {
        guard !isFetchingTimeline, let token = AppStateManager.shared.authToken, !token.isEmpty else { return }
        
        isFetchingTimeline = true
        print("🛰️ [NotificationManager] Timeline missing. Fetching silently...")
        
        GetStudiedPlacesService.shared.fetchStudiedPlaces(sessionToken: token) { [weak self] result in
            DispatchQueue.main.async {
                self?.isFetchingTimeline = false
                if case .success(let response) = result {
                    if let data = response.data {
                        AppStateManager.shared.timeline = TimelineData(places: data.places)
                    }
                    AppStateManager.shared.hasInitialHistoryLoaded = true
                    self?.performProximityCheck(at: location)
                }
            }
        }
    }
    
    func cancelAllNotifications(completion: (() -> Void)? = nil) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        DispatchQueue.main.async { completion?() }
    }
    
    private func triggerSmartNotification(for placeName: String) {
        // Cooldown
        if let lastLoc = lastTriggeredLocation, lastLoc == placeName,
           let lastTime = lastTriggeredTime, Date().timeIntervalSince(lastTime) < cooldownInterval {
            return
        }
        
        let points = AppStateManager.shared.totalStudyPoints
        let content = UNMutableNotificationContent()
        let username = AppStateManager.shared.username.isEmpty ? "Learner" : AppStateManager.shared.username
        
        content.title = "\(getGreeting()), \(username)! 👋"
        content.body = generateDynamicBody(for: placeName, points: points)
        content.sound = .default
        content.userInfo = ["place_name": placeName]
        
        // Save the log entry
        let location = LocationManager.shared.currentLocation
        saveLogEntry(placeName: placeName, points: points, location: location)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "smart_\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        lastTriggeredLocation = placeName
        lastTriggeredTime = Date()
    }
    
    // MARK: - Helpers
    
    private func getGreeting() -> String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Hello"
        }
    }
    
    private func loadRoutineSelections() -> [Int: String]? {
        let json = UserDefaults.standard.string(forKey: "routine_selections_json") ?? "{}"
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([Int: String].self, from: data)
    }
    
    // MARK: - Dynamic Messaging & Logging
    
    private func generateDynamicBody(for place: String, points: Int) -> String {
        let greetings = [
            "Ready to boost your \(points) points at \(place)?",
            "Perfect time for a session at \(place). Stack up those points!",
            "Back at \(place)? Let's get closer to your next milestone!",
            "Practice makes perfect! Ready for a quick \(place) session?",
            "You've already earned \(points) points! Let's add more at \(place)."
        ]
        
        // Milestone specific messages
        if points > 500 {
            return "A Pro Learner like you belongs at \(place). Ready to crush it?"
        } else if points > 200 {
            return "Your streak is legendary! Let's keep the momentum going at \(place)."
        } else if points < 50 {
            return "Ready for a quick session at \(place)? Every point counts!"
        }
        
        return greetings.randomElement() ?? "Ready for a session at \(place)?"
    }
    
    private func saveLogEntry(placeName: String, points: Int, location: CLLocation?) {
        var logs = getLogs()
        let newEntry = NotificationLogEntry(
            placeName: placeName,
            points: points,
            latitude: location?.coordinate.latitude ?? 0,
            longitude: location?.coordinate.longitude ?? 0,
            timestamp: Date()
        )
        
        logs.insert(newEntry, at: 0)
        if logs.count > logLimit {
            logs = Array(logs.prefix(logLimit))
        }
        
        if let encoded = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encoded, forKey: logKey)
            print("🛰️ [NotificationManager] Logged notification: \(placeName) | Points: \(points)")
        }
    }
    
    func getLogs() -> [NotificationLogEntry] {
        guard let data = UserDefaults.standard.data(forKey: logKey),
              let logs = try? JSONDecoder().decode([NotificationLogEntry].self, from: data) else {
            return []
        }
        return logs
    }
}
