//
//  locianApp.swift
//  locian
//
//  Created by vamshi krishna pinni on 23/10/25.
//

import SwiftUI
import UIKit
import UserNotifications
import BackgroundTasks

final class AppDelegate: NSObject, UIApplicationDelegate {
    /// Matches `BGTaskSchedulerPermittedIdentifiers` in Info.plist.
    static let intentRefreshTaskId = "com.locian.intent.refresh"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Warm up early so data is ready before first API call.
        _ = WiFiService.shared

        registerBackgroundTasks()
        Self.scheduleIntentRefresh()

        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            Self.scheduleIntentRefresh()
        }

        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: - Background Task Registration

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.intentRefreshTaskId,
            using: nil
        ) { task in
            Self.handleIntentRefresh(task: task as! BGAppRefreshTask)
        }
    }

    private static func handleIntentRefresh(task: BGAppRefreshTask) {
        // Always schedule the next refresh first so the chain continues even if we return early.
        scheduleIntentRefresh()

        let work = DispatchWorkItem {
            UserIntentContextLogic.shared.refreshIfStale(maxAge: 45 * 60) { success in
                task.setTaskCompleted(success: success)
            }
        }

        task.expirationHandler = {
            work.cancel()
            task.setTaskCompleted(success: false)
        }

        DispatchQueue.global(qos: .utility).async(execute: work)
    }

    private static func scheduleIntentRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: intentRefreshTaskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // ~1 hour
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("🔔 [locianApp] Failed to submit BGAppRefreshTaskRequest: \(error.localizedDescription)")
        }
    }
}

@main
struct locianApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
