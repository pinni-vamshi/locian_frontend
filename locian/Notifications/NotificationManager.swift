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
import UIKit
import SwiftUI

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
    private let globalMinGap: TimeInterval = 6 * 3600
    private let dailyCap: Int = 2
    
    // Configuration
    
    private let anchorsKey = "notification_universal_anchors"
    
    @Published var intentTimeline: [String: TimeSpanSnapshot]? // Mirrors AppStateManager for local monitoring
    
    private override init() {
        self.isNotificationsEnabled = (UserDefaults.standard.object(forKey: "isNotificationsEnabled") as? Bool) ?? true
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    private var currentLanguageCode: String {
        let nativeName = AppStateManager.shared.nativeLanguage
        return NativeLanguageMapping.shared.getCode(for: nativeName) ?? "en"
    }
    
    
    // MARK: - Harvesting (Retired)
    // harvest(from timeline: TimelineData) removed as studied-places endpoint is retired.
    
    // harvestIntent removed - using AppStateManager.intentTimeline for notifications now.
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        let userInfo = response.notification.request.content.userInfo
        
        // Start cooling period upon interaction
        AppStateManager.shared.lastNotificationFireDate = Date()
        
        // Resolve Deep Link Context
        if let placeName = userInfo["place_name"] as? String,
           let id = userInfo["place_id"] as? String {
            print("📱 [NotificationManager] Engagement: \(placeName) (\(id))")
            
            DispatchQueue.main.async {
                AppStateManager.shared.pendingDeepLinkPlace = placeName
                // If it's a smart habit, extract hour from ID (e.g., Library_10 -> 10)
                if identifier.hasPrefix("smart_time_"), let hourStr = id.split(separator: "_").last, let hour = Int(hourStr) {
                    AppStateManager.shared.pendingDeepLinkHour = hour
                }
                
                self.handleNotificationEngagement(for: identifier)
                self.refreshIfNecessary()
            }
        } else {
            handleNotificationEngagement(for: identifier)
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let identifier = notification.request.identifier
        
        // Removed ignore streak tracking for simpler state
        
        // Start cooling period upon delivery
        AppStateManager.shared.lastNotificationFireDate = Date()
        
        // Foreground delivery should not trigger immediate rediscovery; this was
        // creating rapid notification loops when the app was open.
        if identifier.hasPrefix("smart_time_") {
            AppStateManager.shared.notifiedMomentIDs.insert(identifier.replacingOccurrences(of: "smart_time_", with: ""))
        }
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
        
        // Interaction no longer triggers immediate re-discovery to reduce churn;
        // natural triggers (App Open/Location Change) will handle planning.
    }
    
    // MARK: - Autonomous Alert Bridge (UIKit)
    private func showSettingsAlert() {
        DispatchQueue.main.async {
            guard let topVC = self.getTopViewController() else { return }
            
            let alert = UIAlertController(title: "Notifications Required", message: "Please enable notifications in Settings to receive study reminders.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            
            topVC.present(alert, animated: true)
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
        
        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    // MARK: - Permissions
    
    func ensureNotificationAccess(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    completion(true)
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async { 
                            self.isNotificationsEnabled = granted
                            completion(granted) 
                        }
                    }
                case .denied:
                    self.showSettingsAlert()
                    completion(false)
                @unknown default:
                    completion(false)
                }
            }
        }
    }
    
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
        cleanupNotifiedIDs()
        guard canScheduleNow() else { return }
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
        guard isNotificationsEnabled, canScheduleNow() else { return }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            // Keep already pending smart notifications to avoid destructive churn.
            let hasPendingSmart = requests.contains { $0.identifier.hasPrefix("smart_") }
            if hasPendingSmart {
                return
            }

            // Clear current pending smart notifications before re-calculating the best window
            let toRemove = requests.filter { $0.identifier.hasPrefix("smart_") }.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: toRemove)
            
            DispatchQueue.main.async {
                self.scheduleSmartNotification()
            }
        }
    }
    
    private func scheduleSmartNotification() {
        guard canScheduleNow() else { return }
        
        // 1. Get Intent Timeline from AppStateManager
        guard let timeline = AppStateManager.shared.intentTimeline, !timeline.isEmpty else {
            print("⚠️ [NotificationManager] No Intent Timeline available. Skipping scheduling.")
            return
        }
        
        // 2. Determine Best Time and Content from Timeline
        // We look for the "current" or "next" most confident intent
        
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        
        // Helper to convert span string to hour range
        func getStartHour(from span: String) -> Int? {
            let parts = span.components(separatedBy: "-")
            guard let first = parts.first else { return nil }
            let hourStr = first.lowercased().replacingOccurrences(of: "am", with: "").replacingOccurrences(of: "pm", with: "").trimmingCharacters(in: .whitespaces)
            guard var hour = Int(hourStr) else { return nil }
            if first.lowercased().contains("pm") && hour != 12 { hour += 12 }
            if first.lowercased().contains("am") && hour == 12 { hour = 0 }
            return hour
        }
        
        // Find next relevant spans (current + future)
        let sortedSpans = timeline.keys.sorted { (s1, s2) -> Bool in
            let h1 = getStartHour(from: s1) ?? 0
            let h2 = getStartHour(from: s2) ?? 0
            return h1 < h2
        }
        
        var bestSpan: String?
        var bestTag: UserIntentTag?
        
        // First try to find current span
        if let currentSpan = AppStateManager.shared.currentTimeSpan, let snapshot = timeline[currentSpan], let topTag = snapshot.active_context.first {
             bestSpan = currentSpan
             bestTag = topTag
        } else {
            // Fallback to next upcoming span
            for span in sortedSpans {
                let startHour = getStartHour(from: span) ?? 0
                if startHour >= currentHour {
                    if let snapshot = timeline[span], let topTag = snapshot.active_context.first {
                        bestSpan = span
                        bestTag = topTag
                        break
                    }
                }
            }
        }
        
        guard let span = bestSpan, let tag = bestTag else {
            print("⚠️ [NotificationManager] Could not find suitable span/tag in timeline.")
            return
        }
        
        // 3. Calculate Fire Time
        // If current span, fire in 30 mins. If future span, fire at start of span.
        var fireDate = now.addingTimeInterval(3600) // Default 1 hour
        if let startHour = getStartHour(from: span) {
            if startHour > currentHour {
                fireDate = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: now) ?? now.addingTimeInterval(3600)
            } else {
                fireDate = now.addingTimeInterval(1800) // 30 mins from now if in current span
            }
        }
        
        // Ensure fireDate is in the future
        if fireDate <= now { fireDate = now.addingTimeInterval(600) }
        
        let delay = fireDate.timeIntervalSince(now)
        
        print("🧠 [NotificationManager] Scheduling Intent Notification: '\(tag.tag)' for Span: \(span) in \(Int(delay))s")
        
        self.performSurgicalSchedule(
            id: "intent_\(span)", 
            name: tag.tag, 
            lat: 0, 
            lon: 0, 
            delay: delay
        )
    }
    
        // Dead math removed
    
    
    private func performSurgicalSchedule(id: String, name: String, lat: Double, lon: Double, delay: TimeInterval = 1) {
        let username = AppStateManager.shared.username.isEmpty ? "Learner" : AppStateManager.shared.username
        let content = UNMutableNotificationContent()
        content.title = "\(getGreeting()), \(username)! 👋"
        
        if id.hasPrefix("global_") {
            // Global recommendations are situational moments, not physical places
            content.body = "Ready to practice: \"\(name)\"?"
        } else {
            content.body = "You are nearby \(name). Try to learn here!"
        }
        
        content.sound = .default
        content.userInfo = ["place_name": name, "place_id": id]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: "smart_time_\(id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { _ in
            print("🕒 [NotificationManager] Scheduled ID: \(id) in \(Int(delay))s")
            self.saveLogEntry(placeName: name, lat: lat, lon: lon)
        }
    }

    private func nextAllowedByGlobalGap() -> Date {
        let lastFire = AppStateManager.shared.lastNotificationFireDate ?? .distantPast
        return lastFire.addingTimeInterval(globalMinGap)
    }

    private func notificationsSentToday() -> Int {
        let calendar = Calendar.current
        return getLogs().filter { calendar.isDateInToday($0.timestamp) }.count
    }

    private func canScheduleNow() -> Bool {
        if notificationsSentToday() >= dailyCap {
            return false
        }
        if Date() < nextAllowedByGlobalGap() {
            return false
        }
        return true
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
