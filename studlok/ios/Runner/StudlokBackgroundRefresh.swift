//
//  StudlokBackgroundRefresh.swift
//  Runner
//
//  Best-effort secondary layer on top of the session-end notification
//  (StudlokNotifications) — the system gives no timing guarantees for
//  BGAppRefreshTask, so this is not relied on to be prompt or reliable, only
//  to occasionally catch a stale session the user hasn't reopened Studlok
//  for yet. Fire count is recorded in the App Group so real-world
//  reliability can be observed over time via debugStatus, the same pattern
//  StudlokWatchdog uses.
//
//  Runner-only: BGTaskScheduler registration must happen in the main app
//  process.
//

import BackgroundTasks
import Foundation

enum StudlokBackgroundRefresh {
    static let taskIdentifier = "com.studlokapp.studlok.sessionRefresh"
    private static let earliestBeginOffset: TimeInterval = 15 * 60

    /// Must be called synchronously during didFinishLaunchingWithOptions,
    /// before it returns, and exactly once per process launch.
    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handle(task: refreshTask)
        }
    }

    static func scheduleNext() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: earliestBeginOffset)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("[StudlokBackgroundRefresh] scheduleNext failed: \(error.localizedDescription)")
        }
    }

    private static func handle(task: BGAppRefreshTask) {
        // Reschedule immediately so coverage continues even if this run gets
        // cut short by the expiration handler below.
        scheduleNext()

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        let reconciled = SessionReconciler.reconcileIfNeeded()
        recordFired()
        print("[StudlokBackgroundRefresh] fired, reconciled=\(reconciled)")
        task.setTaskCompleted(success: true)
    }

    // MARK: - fire-recording (log-independent verification, mirrors StudlokWatchdog)

    private static let fireCountKey = "studlokBackgroundRefreshFireCount"
    private static let lastFiredDateKey = "studlokBackgroundRefreshLastFiredDate"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: SharedStore.appGroupID)
    }

    private static func recordFired() {
        let count = (defaults?.integer(forKey: fireCountKey) ?? 0) + 1
        defaults?.set(count, forKey: fireCountKey)
        defaults?.set(ISO8601DateFormatter().string(from: Date()), forKey: lastFiredDateKey)
    }

    static func debugStatus() -> [String: Any] {
        [
            "fireCount": defaults?.integer(forKey: fireCountKey) ?? 0,
            "lastFiredDate": defaults?.string(forKey: lastFiredDateKey) ?? "never",
        ]
    }
}
