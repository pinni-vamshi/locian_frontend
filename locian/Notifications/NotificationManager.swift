//
//  NotificationManager.swift
//  locian
//
//  Simple daily notifications — three times a day (9am / 1pm / 7pm).
//

import Foundation
import Combine
import UserNotifications

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    @Published var isNotificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isNotificationsEnabled, forKey: "isNotificationsEnabled")
            if isNotificationsEnabled {
                scheduleDailyNotifications()
            } else {
                cancelAllNotifications()
            }
        }
    }

    private override init() {
        self.isNotificationsEnabled = (UserDefaults.standard.object(forKey: "isNotificationsEnabled") as? Bool) ?? true
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Permissions

    func ensureNotificationAccess(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    self.scheduleDailyNotifications()
                    completion(true)
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async {
                            self.isNotificationsEnabled = granted
                            if granted { self.scheduleDailyNotifications() }
                            completion(granted)
                        }
                    }
                case .denied:
                    completion(false)
                @unknown default:
                    completion(false)
                }
            }
        }
    }

    // MARK: - Scheduling

    /// Schedules three repeating daily notifications at 9:00, 13:00, 19:00.
    func scheduleDailyNotifications() {
        guard isNotificationsEnabled else { return }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let username = AppStateManager.shared.username.isEmpty ? "Learner" : AppStateManager.shared.username
        let slots: [(hour: Int, id: String)] = [
            (9,  "morning"),
            (13, "afternoon"),
            (19, "evening")
        ]

        for slot in slots {
            let content = UNMutableNotificationContent()
            content.title = "\(greeting(for: slot.hour)), \(username)!"
            content.body = "Time to practice your language."
            content.sound = .default

            var components = DateComponents()
            components.hour = slot.hour
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "daily_\(slot.id)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    // MARK: - Cancel

    func cancelAllNotifications(completion: (() -> Void)? = nil) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        DispatchQueue.main.async { completion?() }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    // MARK: - Helpers

    private func greeting(for hour: Int) -> String {
        switch hour {
        case 5..<12:  return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default:      return "Hello"
        }
    }
}
