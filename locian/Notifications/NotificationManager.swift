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
        
        // Initial Refresh
        refreshIfNecessary()
        
        // Monitor for significant location changes only (optional, but keep it light)
        LocationManager.shared.$currentLocation
            .compactMap { $0 }
            .throttle(for: .seconds(300), scheduler: DispatchQueue.main, latest: true) // 5 mins throttle
            .sink { [weak self] location in
                guard let self = self, self.isNotificationsEnabled else { return }
                self.refreshIfNecessary()
            }
            .store(in: &cancellables)
    }
    
    func refreshIfNecessary() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let smartRequests = requests.filter({ $0.identifier.hasPrefix("smart_") })
            
            // If we have 0 pending smart notifications, it means either:
            // 1. We haven't scheduled any.
            // 2. All 3 have been delivered.
            if smartRequests.count == 0 {
                print("🛰️ [NotificationManager] No pending smart notifications. Resetting count and scheduling new batch...")
                DispatchQueue.main.async {
                    AppStateManager.shared.completedNotificationCount = 0
                    self.scheduleNextBatch()
                }
            } else {
                print("🛰️ [NotificationManager] Batch still pending (\(smartRequests.count) items). Skipping refresh.")
            }
        }
    }
    
    func scheduleNextBatch() {
        guard isNotificationsEnabled else { return }
        
        // Hierarchy 1: Location Check
        let hasLocationAccess = LocationManager.shared.authorizationStatus == .authorizedAlways || LocationManager.shared.authorizationStatus == .authorizedWhenInUse
        
        // 1. Get History and Intent
        guard let timeline = AppStateManager.shared.timeline,
              let intent = AppStateManager.shared.userIntent else {
            print("⚠️ [NotificationManager] Cannot schedule batch: Data missing.")
            // Fallback to fetching data if missing
            if let token = AppStateManager.shared.authToken, !token.isEmpty {
                self.fetchTimelineAndRetry(at: LocationManager.shared.currentLocation ?? CLLocation(latitude: 0, longitude: 0))
            }
            return
        }
        
        // 2. Prepare Intent Vectors
        let nativeName = AppStateManager.shared.nativeLanguage
        let nativeCode = NativeLanguageMapping.shared.getCode(for: nativeName) ?? "en"
        let intentVectors = intentToVectors(intent, languageCode: nativeCode)
        
        if intentVectors.isEmpty {
            print("⚠️ [NotificationManager] No intent vectors. Cannot refine smartly.")
            return
        }
        
        // 3. Pick 3 Time Slots
        let slots = [10, 14, 18] // Typical study hours (10 AM, 2 PM, 6:30-ish PM)
        var scheduledCount = 0
        var batch: [(hour: Int, moment: UnifiedMoment, placeName: String)] = []
        let notifiedIDs = AppStateManager.shared.notifiedMomentIDs
        
        // Search through history for best matches
        // Prioritize Location-based matches if location is available
        var allScoredMoments: [ScoredPlace] = []
        for place in timeline.places {
            // Using ScoringEngine which already incorporates GPS boost if location is passed
            let currentLoc = hasLocationAccess ? LocationManager.shared.currentLocation : nil
            let scored = ScoringEngine.shared.score(place: place, intentVectors: intentVectors, userLocation: currentLoc, languageCode: nativeCode)
            allScoredMoments.append(contentsOf: scored)
        }
        
        // Sort by score (which includes GPS boost if Hierarchy 1 is enabled)
        allScoredMoments.sort { $0.score > $1.score }
        
        // Pick 3 unique high quality matches
        for slotHour in slots {
            if scheduledCount >= 3 { break }
            
            if let bestMatch = allScoredMoments.first(where: { !notifiedIDs.contains($0.place.id) }) {
                if let moment = bestMatch.place.micro_situations?.first?.moments.first {
                    batch.append((hour: slotHour, moment: moment, placeName: bestMatch.extractedName))
                    AppStateManager.shared.notifiedMomentIDs.insert(bestMatch.place.id)
                    
                    // Remove from pool to avoid internal batch duplication
                    allScoredMoments.removeAll(where: { $0.place.id == bestMatch.place.id })
                    scheduledCount += 1
                }
            }
        }
        
        // Fallback: If we couldn't find 3 smart moments, use Routine Defaults
        if scheduledCount < 3 {
            print("⚠️ [NotificationManager] Only found \(scheduledCount) smart moments. Using Routine fallbacks.")
            let profession = AppStateManager.shared.profession
            for slotHour in slots {
                if batch.contains(where: { $0.hour == slotHour }) { continue }
                if scheduledCount >= 3 { break }
                
                let fallbacks = UserRoutineManager.getPlaces(for: profession, hour: slotHour)
                if let firstFallback = fallbacks.first {
                    let fallbackMoment = UnifiedMoment(text: "Ready for a session?", keywords: nil)
                    batch.append((hour: slotHour, moment: fallbackMoment, placeName: firstFallback))
                    scheduledCount += 1
                }
            }
        }
        
        // 4. Schedule the batch
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // Strict clear
        for item in batch {
            scheduleNotification(for: item.hour, moment: item.moment.text, placeName: item.placeName)
        }
        
        AppStateManager.shared.lastNotificationRefreshDate = Date()
        print("✅ [NotificationManager] Successfully scheduled batch of \(scheduledCount) notifications based on hierarchy (Location/Time).")
    }
    
    private func scheduleNotification(for hour: Int, moment: String, placeName: String) {
        let content = UNMutableNotificationContent()
        let username = AppStateManager.shared.username.isEmpty ? "Learner" : AppStateManager.shared.username
        
        content.title = "\(getGreeting(for: hour)), \(username)! 👋"
        
        // Smart Body Logic: "If you are at [Place], read about this place!"
        let localizedBody = LocalizationManager.shared.string(.smartNotificationExactPlace)
        content.body = String(format: localizedBody, placeName) + "\n\"\(moment)\""
        
        content.sound = .default
        content.userInfo = ["place_name": placeName, "hour": hour]
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "smart_\(hour)_\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ [NotificationManager] Error scheduling: \(error)")
            } else {
                self.saveLogEntry(placeName: placeName, hour: hour, moment: moment)
            }
        }
    }
    
    private func intentToVectors(_ intent: UserIntent, languageCode: String) -> [String: [Double]] {
        var vectors: [String: [Double]] = [:]
        
        let fields: [(name: String, value: String?)] = [
            ("Movement", intent.movement),
            ("Waiting", intent.waiting),
            ("Consume Fast", intent.consume_fast),
            ("Consume Slow", intent.consume_slow),
            ("Errands", intent.errands),
            ("Browsing", intent.browsing),
            ("Rest", intent.rest),
            ("Social", intent.social),
            ("Emergency", intent.emergency),
            ("Suggested Needs", intent.suggested_needs)
        ]
        
        for field in fields {
            if let val = field.value, !val.isEmpty,
               let vec = EmbeddingService.getVector(for: val, languageCode: languageCode) {
                vectors[field.name] = vec
            }
        }
        return vectors
    }
    
    private func getGreeting(for hour: Int? = nil) -> String {
        let h = hour ?? Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Hello"
        }
    }
    
    private func fetchTimelineAndRetry(at location: CLLocation) {
        guard !isFetchingTimeline, let token = AppStateManager.shared.authToken, !token.isEmpty else { return }
        
        isFetchingTimeline = true
        print("🛰️ [NotificationManager] Data missing. Fetching silently...")
        
        GetStudiedPlacesService.shared.fetchStudiedPlaces(sessionToken: token) { [weak self] result in
            DispatchQueue.main.async {
                self?.isFetchingTimeline = false
                if case .success(let response) = result {
                    if let data = response.data {
                        AppStateManager.shared.timeline = TimelineData(places: data.places, inputTime: data.input_time)
                        if let intent = data.user_intent {
                            AppStateManager.shared.userIntent = intent
                        }
                    }
                    AppStateManager.shared.hasInitialHistoryLoaded = true
                    self?.scheduleNextBatch()
                }
            }
        }
    }
    
    func cancelAllNotifications(completion: (() -> Void)? = nil) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        DispatchQueue.main.async { completion?() }
    }
    
    // MARK: - Logging
    
    private func saveLogEntry(placeName: String, hour: Int, moment: String) {
        var logs = getLogs()
        let newEntry = NotificationLogEntry(
            placeName: placeName,
            points: AppStateManager.shared.totalStudyPoints,
            latitude: 0,
            longitude: 0,
            timestamp: Date()
        )
        
        logs.insert(newEntry, at: 0)
        if logs.count > logLimit {
            logs = Array(logs.prefix(logLimit))
        }
        
        if let encoded = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encoded, forKey: logKey)
            print("🛰️ [NotificationManager] Logged notification: \(placeName) at \(hour)")
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
