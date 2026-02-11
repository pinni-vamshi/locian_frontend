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

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
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
    
    // Universal Memory (Date-Independent)
    private struct UniversalStudyAnchor: Codable {
        let id: String
        let placeName: String
        let hour: Int
        var latitude: Double?
        var longitude: Double?
        var timeSpan: String?
        var vector: [Double]?
    }
    
    private var universalAnchors: [UniversalStudyAnchor] = []
    private var latestIntentVector: [Double]?
    
    private let anchorsKey = "notification_universal_anchors"
    private let intentVectorKey = "notification_latest_intent_vector"
    
    private override init() {
        self.isNotificationsEnabled = (UserDefaults.standard.object(forKey: "isNotificationsEnabled") as? Bool) ?? true
        super.init()
        UNUserNotificationCenter.current().delegate = self
        loadUniversalAnchors()
        loadContextualMemory()
    }
    
    private var currentLanguageCode: String {
        let nativeName = AppStateManager.shared.nativeLanguage
        return NativeLanguageMapping.shared.getCode(for: nativeName) ?? "en"
    }
    
    private func loadContextualMemory() {
        if let data = UserDefaults.standard.data(forKey: intentVectorKey),
           let decoded = try? JSONDecoder().decode([Double].self, from: data) {
            self.latestIntentVector = decoded
        }
    }
    
    private func saveContextualMemory() {
        if let encoded = try? JSONEncoder().encode(latestIntentVector) {
            UserDefaults.standard.set(encoded, forKey: intentVectorKey)
        }
    }
    
    private func loadUniversalAnchors() {
        if let data = UserDefaults.standard.data(forKey: anchorsKey),
           let decoded = try? JSONDecoder().decode([UniversalStudyAnchor].self, from: data) {
            self.universalAnchors = decoded
            print("🧠 [NotificationManager] Loaded \(decoded.count) universal anchors.")
        }
    }
    
    private func saveUniversalAnchors() {
        if let encoded = try? JSONEncoder().encode(universalAnchors) {
            UserDefaults.standard.set(encoded, forKey: anchorsKey)
        }
    }
    
    func harvest(from timeline: TimelineData) {
        harvestPatterns(from: timeline)
        harvestIntent(from: timeline)
    }
    
    private func harvestPatterns(from timeline: TimelineData) {
        var updated = false
        for place in timeline.places {
            guard let micro = place.micro_situations?.first, let hour = place.hour else { continue }
            let lat = place.latitude ?? 0
            let lon = place.longitude ?? 0
            // Collision-Free ID: Coordinates + Hour
            let compositeID = "\(String(format: "%.3f", lat))_\(String(format: "%.3f", lon))_\(hour)"
            
            if let index = universalAnchors.firstIndex(where: { $0.id == compositeID }) {
                if lat != 0 && lon != 0 && (universalAnchors[index].latitude == 0 || universalAnchors[index].latitude == nil) {
                    universalAnchors[index].latitude = lat
                    universalAnchors[index].longitude = lon
                    updated = true
                }
            } else {
                let name = micro.name
                let vector = EmbeddingService.getVector(for: name, languageCode: currentLanguageCode)
                
                let newAnchor = UniversalStudyAnchor(
                    id: compositeID, placeName: name, hour: hour,
                    latitude: lat, longitude: lon,
                    timeSpan: timeline.timeSpan, vector: vector
                )
                universalAnchors.append(newAnchor)
                updated = true
                print("🧠 [NotificationManager] Harvested pattern: \(compositeID)")
            }
        }
        if updated { saveUniversalAnchors() }
    }
    
    private func harvestIntent(from timeline: TimelineData) {
        guard let intent = AppStateManager.shared.userIntent else { return }
        
        // V11: Prioritize suggested_needs as the "Master Vibe"
        let text = intent.suggested_needs ?? intent.movement ?? intent.waiting ?? ""
        guard !text.isEmpty else { return }
        
        if let vector = EmbeddingService.getVector(for: text, languageCode: currentLanguageCode) {
            latestIntentVector = vector
            saveContextualMemory()
            print("🧠 [NotificationManager] Harvested Utility Intent: \(text)")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        
        // Interaction resets ignore streak
        AppStateManager.shared.notificationIgnoreStreak = 0
        AppStateManager.shared.lastOpenedNotificationDate = Date()
        
        // Start cooling period upon interaction
        AppStateManager.shared.lastNotificationFireDate = Date()
        
        handleNotificationEngagement(for: identifier)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let identifier = notification.request.identifier
        
        // If delivered, we increment ignore streak until opened
        AppStateManager.shared.notificationIgnoreStreak += 1
        
        // Start cooling period upon delivery
        AppStateManager.shared.lastNotificationFireDate = Date()
        
        handleNotificationEngagement(for: identifier)
        completionHandler([.banner, .sound, .badge])
    }
    
    private func handleNotificationEngagement(for identifier: String) {
        // Extract the full ID (e.g. Library_10) by removing the known prefixes
        let placeID: String
        if identifier.hasPrefix("smart_time_") {
            placeID = identifier.replacingOccurrences(of: "smart_time_", with: "")
        } else {
            return // Not an alert we track for habit-completion this way
        }
        
        AppStateManager.shared.notifiedMomentIDs.insert(placeID)
        print("✅ [NotificationManager] Marked habit '\(placeID)' as notified today.")
        
        // No more partners to remove as geofencing is abolished.
        
        // Proactive Chaining: Re-run discovery to either fire now or plan the next optimal window
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.executeSemanticDiscovery()
        }
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
        
        // Harvest from existing timeline cache if available on startup
        if let currentTimeline = AppStateManager.shared.timeline {
            harvest(from: currentTimeline)
        }
        
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
        cleanupNotifiedIDs()
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            // If we have a future smart notification scheduled, we might want to keep it
            // or re-evaluate if the user moved significantly.
            // For V11, we re-evaluate every time they move or hit an interval.
            DispatchQueue.main.async { self.executeSemanticDiscovery() }
        }
    }
    
    private func cleanupNotifiedIDs() {
        let last = UserDefaults.standard.object(forKey: "last_notified_cleanup") as? Date ?? .distantPast
        if Date().timeIntervalSince(last) > 24 * 3600 {
            AppStateManager.shared.notifiedMomentIDs.removeAll()
            UserDefaults.standard.set(Date(), forKey: "last_notified_cleanup")
        }
    }
    
    func executeSemanticDiscovery() {
        guard isNotificationsEnabled, !universalAnchors.isEmpty else { return }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            // Clear current pending smart notifications before re-calculating the best window
            let toRemove = requests.filter { $0.identifier.hasPrefix("smart_") }.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: toRemove)
            
            DispatchQueue.main.async {
                self.performUtilityDiscovery()
            }
        }
    }
    
    private func performUtilityDiscovery() {
        let nearby = LocationManager.shared.nearbyPlaceAmbience
        guard !nearby.isEmpty else { return }
        
        // Find the best semantic match nearby right now
        let top5Vibes = getTopPersonalVibes(forTarget: latestIntentVector)
        guard let bestNearby = findBestNearbyVibeMatch(from: nearby, comparingTo: top5Vibes, withTarget: latestIntentVector) else {
            print("🌙 [NotificationManager] No strong vibe nearby. Standing by.")
            return
        }
        
        // Calculate the score for this match (0.0 to 1.0 range usually but let's normalize clearly)
        let intentScore = calculateMatchScore(for: bestNearby, comparingTo: top5Vibes, withTarget: latestIntentVector)
        
        // Step 1: Candidate times (next 6 hours, every 30m)
        var bestTime: Date = Date()
        var maxUtility: Double = -1.0
        
        for i in 0...12 {
            let candidateDate = Date().addingTimeInterval(Double(i) * 1800)
            let utility = calculateUtility(at: candidateDate, intentScore: intentScore)
            
            if utility > maxUtility {
                maxUtility = utility
                bestTime = candidateDate
            }
        }
        
        print("🧠 [NotificationManager] Peak Utility: \(String(format: "%.3f", maxUtility)) at \(bestTime)")
        
        // Step 4: Schedule only if above threshold
        if maxUtility > 0.75 {
            let delay = bestTime.timeIntervalSince(Date())
            self.performSurgicalSchedule(id: bestNearby.id, name: bestNearby.name, lat: bestNearby.latitude, lon: bestNearby.longitude, delay: max(1, delay))
        } else {
            print("🛡️ [NotificationManager] Utility below threshold. Waiting for better context.")
        }
    }
    
    private func calculateUtility(at date: Date, intentScore: Double) -> Double {
        let alpha = 0.4 // Weight for Intent
        let beta = 0.5  // Weight for Habit
        let lambda = 0.3 // Weight for Spam Penalty (subtractive/penalty)
        
        let h_score = calculateHabitScore(at: date)
        let s_penalty = calculateSpamPenalty(at: date)
        
        // U(t) = alpha*I + beta*H - lambda*S
        let utility = (alpha * intentScore) + (beta * h_score) - (lambda * s_penalty)
        return utility
    }
    
    private func calculateHabitScore(at date: Date) -> Double {
        let calendar = Calendar.current
        let hour = Double(calendar.component(.hour, from: date))
        let minute = Double(calendar.component(.minute, from: date))
        let t = hour + (minute / 60.0)
        
        let sigma = 1.0 // 1 hour standard deviation for Gaussian smoothing
        var totalContribution = 0.0
        
        for anchor in universalAnchors {
            let h_i = Double(anchor.hour)
            let diff = min(abs(t - h_i), 24 - abs(t - h_i)) // Circular hour difference
            totalContribution += exp(-(diff * diff) / (2 * sigma * sigma))
        }
        
        // Normalize against history size
        return totalContribution / max(1.0, Double(universalAnchors.count / 2)) // Slight boost for visibility
    }
    
    private func calculateSpamPenalty(at date: Date) -> Double {
        let lastFire = AppStateManager.shared.lastNotificationFireDate ?? .distantPast
        let deltaT = date.timeIntervalSince(lastFire) / 3600.0 // in hours
        let tau = 4.0 // 4 hours decay constant
        
        // S(t) = exp(-deltaT / tau) -> 1.0 if just fired, decays to ~0 after 12h
        return exp(-deltaT / tau)
    }
    
    private func calculateMatchScore(for place: LocationManager.NearbyAmbience, comparingTo topVibes: [PersonalVibe], withTarget target: [Double]?) -> Double {
        var intentSimilarity: Double = 0.0
        if let targetVec = target {
            intentSimilarity = EmbeddingService.cosineSimilarity(v1: place.vector, v2: targetVec)
        }
        
        var historySimilarity: Double = 0.0
        for vibe in topVibes {
            historySimilarity = max(historySimilarity, EmbeddingService.cosineSimilarity(v1: place.vector, v2: vibe.vector))
        }
        
        return max(intentSimilarity, historySimilarity)
    }
    
    private func getBestNearbyMatch(withTargetVector target: [Double]?) -> LocationManager.NearbyAmbience? {
        let nearby = LocationManager.shared.nearbyPlaceAmbience
        guard !nearby.isEmpty else { return nil }
        
        let top5Vibes = getTopPersonalVibes(forTarget: target)
        return findBestNearbyVibeMatch(from: nearby, comparingTo: top5Vibes, withTarget: target)
    }
    
    private struct PersonalVibe {
        let vector: [Double]
        let score: Double
        let name: String
    }
    
    private func getTopPersonalVibes(forTarget target: [Double]?) -> [PersonalVibe] {
        guard let targetVec = target else { return [] }
        
        // --- Score All History anchors against Target Intent ---
        var vibes: [PersonalVibe] = []
        for item in universalAnchors {
            guard let histVec = item.vector else { continue }
            let score = EmbeddingService.cosineSimilarity(v1: histVec, v2: targetVec)
            vibes.append(PersonalVibe(vector: histVec, score: score, name: item.placeName))
        }
        
        // Take Top 5 Vibes
        let top5 = Array(vibes.sorted(by: { $0.score > $1.score }).prefix(5))
        return top5
    }
    
    private func findBestNearbyVibeMatch(from nearby: [LocationManager.NearbyAmbience], comparingTo topVibes: [PersonalVibe], withTarget target: [Double]?) -> LocationManager.NearbyAmbience? {
        var bestMatch: LocationManager.NearbyAmbience?
        var bestScore: Double = -1.0
        
        for livePlace in nearby {
            let currentScore = calculateMatchScore(for: livePlace, comparingTo: topVibes, withTarget: target)
            
            if currentScore > bestScore {
                bestScore = currentScore
                bestMatch = livePlace
            }
        }
        
        if let match = bestMatch, bestScore > 0.8 {
            print("✨ [NotificationManager] Found Surgical Precision match '\(match.name)' (Score: \(bestScore))")
            return match
        }
        return nil
    }
    
    private func performSurgicalSchedule(id: String, name: String, lat: Double, lon: Double, delay: TimeInterval = 1) {
        let username = AppStateManager.shared.username.isEmpty ? "Learner" : AppStateManager.shared.username
        let content = UNMutableNotificationContent()
        content.title = "\(getGreeting()), \(username)! 👋"
        content.body = "You are nearby \(name). Try to learn here!"
        content.sound = .default
        content.userInfo = ["place_name": name, "place_id": id]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: "smart_time_\(id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { _ in
            print("🕒 [NotificationManager] Scheduled ID: \(id) in \(Int(delay))s")
            self.saveLogEntry(placeName: name, lat: lat, lon: lon)
        }
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
    
    
    func cancelAllNotifications(completion: (() -> Void)? = nil) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        DispatchQueue.main.async { completion?() }
    }
    
    // MARK: - Logging
    
    private func saveLogEntry(placeName: String, lat: Double, lon: Double) {
        var logs = getLogs()
        logs.insert(NotificationLogEntry(placeName: placeName, points: AppStateManager.shared.totalStudyPoints, latitude: lat, longitude: lon, timestamp: Date()), at: 0)
        logs = Array(logs.prefix(logLimit))
        if let encoded = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encoded, forKey: logKey)
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
