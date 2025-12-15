//
//  NotificationService.swift
//  locian
//
//  Created by vamshi krishna pinni on 24/10/25.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    // Request notification permissions
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    completion(true)
                } else {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        DispatchQueue.main.async {
                            if error != nil {
                                completion(false)
                            } else if granted {
                                completion(true)
                            } else {
                                completion(false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Schedule daily notification at specific time (for all days)
    func scheduleDailyNotification(
        identifier: String,
        title: String,
        body: String,
        hour: Int,
        minute: Int,
        enabled: Bool
    ) {
        let center = UNUserNotificationCenter.current()
        
        // Remove existing notification with same identifier
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        guard enabled else {
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Create date components for daily trigger
        // Only hour and minute - this makes it repeat daily at that time
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // Create trigger (repeats daily)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Verify trigger is valid
        if trigger.nextTriggerDate() == nil {
            return
        }
        
        // Create request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule notification
        center.add(request) { error in
            // Notification scheduled
        }
    }
    
    // Test notification - schedule one for 10 seconds from now
    func scheduleTestNotification() {
        requestPermission { granted in
            guard granted else {
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Test Notification 📚"
            content.body = "If you see this, notifications are working!"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                // Notification scheduled
            }
        }
    }
    
    // Schedule notification for specific day of week (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
    func scheduleWeeklyNotification(
        identifier: String,
        title: String,
        body: String,
        hour: Int,
        minute: Int,
        weekday: Int, // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
        enabled: Bool
    ) {
        let center = UNUserNotificationCenter.current()
        
        guard enabled else {
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Create date components for weekly trigger on specific weekday
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // Create trigger (repeats weekly)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request with unique identifier for this day
        let dayIdentifier = "\(identifier)_weekday_\(weekday)"
        let request = UNNotificationRequest(identifier: dayIdentifier, content: content, trigger: trigger)
        
        // Schedule notification
        center.add(request) { _ in
        }
    }
    
    // Parse time string (HH:mm format) to hour and minute
    func parseTime(_ timeString: String?) -> (hour: Int, minute: Int)? {
        guard let timeString = timeString else { return nil }
        
        // Try parsing "HH:MM AM/PM" format first (from practice time patterns)
        if let (hour, minute) = parseTimeAMPM(timeString) {
            return (hour: hour, minute: minute)
        }
        
        // Try parsing "HH:mm" format (24-hour format)
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return nil
        }
        
        guard hour >= 0 && hour < 24 && minute >= 0 && minute < 60 else {
            return nil
        }
        
        return (hour: hour, minute: minute)
    }
    
    // Parse time string in "HH:MM AM/PM" format (e.g., "9:46 AM", "2:15 PM") to hour and minute
    func parseTimeAMPM(_ timeString: String) -> (hour: Int, minute: Int)? {
        let trimmed = timeString.trimmingCharacters(in: .whitespaces).uppercased()
        
        // Check if it contains AM/PM
        guard trimmed.contains("AM") || trimmed.contains("PM") else {
            return nil
        }
        
        let isPM = trimmed.contains("PM")
        let withoutPeriod = trimmed
            .replacingOccurrences(of: "AM", with: "")
            .replacingOccurrences(of: "PM", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        let components = withoutPeriod.split(separator: ":")
        guard components.count == 2,
              let hour12 = Int(components[0]),
              let minute = Int(components[1]) else {
            return nil
        }
        
        guard hour12 >= 1 && hour12 <= 12 && minute >= 0 && minute < 60 else {
            return nil
        }
        
        // Convert to 24-hour format
        var hour24 = hour12
        if isPM && hour12 != 12 {
            hour24 = hour12 + 12
        } else if !isPM && hour12 == 12 {
            hour24 = 0
        }
        
        return (hour: hour24, minute: minute)
    }
    
    // Convert "HH:MM AM/PM" format to "HH:mm" format
    func convertTo24HourFormat(_ timeString: String) -> String? {
        guard let (hour, minute) = parseTimeAMPM(timeString) else {
            return nil
        }
        return String(format: "%02d:%02d", hour, minute)
    }
    
    // Clear all notifications with a given prefix (for per-day scheduling)
    func clearNotificationsWithPrefix(_ prefix: String) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.hasPrefix(prefix) }
                .map { $0.identifier }
            
            if !identifiersToRemove.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            }
        }
    }
    
    // Schedule custom notification times (user-added times)
    func scheduleCustomNotificationTimes(customTimes: [String], enabled: Bool) {
        // Request permission first
        requestPermission { granted in
            guard granted && enabled else {
                self.cancelCustomNotificationTimes()
                return
            }
            
            
            // Cancel existing custom notifications, then schedule new ones
            self.cancelCustomNotificationTimes {
                // Schedule each custom time as daily notifications (every day at the same time)
                var scheduledCount = 0
                for time in customTimes {
                    if let timeComponents = self.parseTime(time) {
                        let identifier = "custom_notification_\(time.replacingOccurrences(of: ":", with: "_"))"
                        let message = self.friendlyMessage(forHour: timeComponents.hour)
                        // Schedule daily notification (repeats every day at the same time)
                        self.scheduleDailyNotification(
                            identifier: identifier,
                            title: message.title,
                            body: message.body,
                            hour: timeComponents.hour,
                            minute: timeComponents.minute,
                            enabled: true
                        )
                        scheduledCount += 1
                    } else {
                    }
                }
                // Debug: List pending notifications after scheduling
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.listPendingNotifications()
                }
            }
        }
    }
    
    // Cancel custom notification times
    func cancelCustomNotificationTimes(completion: (() -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        // Get all pending requests and filter for custom notifications
        center.getPendingNotificationRequests { requests in
            let customIdentifiers = requests
                .filter { $0.identifier.hasPrefix("custom_notification_") }
                .map { $0.identifier }
            if !customIdentifiers.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: customIdentifiers)
            }
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    // Cancel all notifications
    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    private func friendlyMessage(forHour hour: Int) -> (title: String, body: String) {
        switch hour {
        case 5..<12:
            return ("Good Morning! ☀️", "Take a few minutes to practice your languages before the day gets busy.")
        case 12..<17:
            return ("Midday Motivation 🌤", "A short language session now keeps your momentum going.")
        default:
            return ("Evening Wind-down 🌙", "Reflect on your day with a quick language practice.")
        }
    }
    
    // Debug: List all pending notifications
    func listPendingNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let customNotifications = requests.filter { $0.identifier.hasPrefix("custom_notification_") }
            
            if customNotifications.isEmpty {
            } else {
                for request in customNotifications.prefix(10) {
                    if request.trigger is UNCalendarNotificationTrigger {
                        // Notification trigger processed
                    } else {
                        // Other trigger types
                    }
                }
            }
        }
    }
}

