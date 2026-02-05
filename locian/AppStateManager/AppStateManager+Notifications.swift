import SwiftUI
import Combine

extension AppStateManager {
    // MARK: - Notification Methods
    
    func updateNotificationSchedules() {
        // Disabled - no longer using API-based notification times
        // Only custom user-added times are used
    }
    
    func promptForNotificationPermissionIfNeeded() {
        let key = "hasRequestedNotificationPermission"
        if UserDefaults.standard.bool(forKey: key) {
            return
        }
        NotificationService.shared.requestPermission { granted in
            UserDefaults.standard.set(true, forKey: key)
            if granted {
                self.refreshNotificationSchedules()
            }
        }
    }
    
    // Update notification schedules with only custom user-added times
    func updateNotificationSchedulesWithCustomTimes(customTimes: [String]) {
        // First cancel existing custom notifications, then schedule new ones
        NotificationService.shared.cancelCustomNotificationTimes {
            // Schedule only custom times (if notifications are enabled)
            let notificationsEnabled = self.notificationsMorning || self.notificationsAfternoon || self.notificationsEvening
            if notificationsEnabled && !customTimes.isEmpty {
                NotificationService.shared.scheduleCustomNotificationTimes(
                    customTimes: customTimes,
                    enabled: true
                )
            } else {
            }
        }
    }
    
}
