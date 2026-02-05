import SwiftUI
import Combine

class NotificationLogic: ObservableObject {
    @ObservedObject var appState: AppStateManager
    @Published var customTimes: [String] = []
    
    init(appState: AppStateManager) {
        self.appState = appState
        loadCustomTimes()
    }
    
    private func loadCustomTimes() {
        if let data = UserDefaults.standard.data(forKey: "customNotificationTimes"),
           let times = try? JSONDecoder().decode([String].self, from: data) {
            customTimes = times.sorted()
        } else {
            customTimes = ["10:00", "14:00", "18:30"]
            saveCustomTimes()
        }
    }
    
    private func saveCustomTimes() {
        if let encoded = try? JSONEncoder().encode(customTimes) {
            UserDefaults.standard.set(encoded, forKey: "customNotificationTimes")
            appState.updateNotificationSchedulesWithCustomTimes(customTimes: customTimes)
        }
    }
    
    func addTime(_ time: String) {
        if !customTimes.contains(time) {
            customTimes.append(time)
            customTimes.sort()
            saveCustomTimes()
        }
    }
    
    func removeTime(_ time: String) {
        customTimes.removeAll { $0 == time }
        saveCustomTimes()
    }
}
