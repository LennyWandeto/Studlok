//
//  StudlokNotifications.swift
//  Runner
//
//  Local notification fired at a session's scheduled end, so the user has a
//  reason to reopen Studlok (which is what actually re-shields apps, via
//  AppDelegate's didBecomeActiveNotification -> SessionReconciler). This is
//  the mechanism Phase 8 is meant to make reliable — DeviceActivityMonitor's
//  intervalDidEnd has been confirmed unreliable on both physical device and
//  Simulator (see SessionReconciler and StudlokWatchdog comments).
//
//  Runner-only: scheduling only happens from startSession.
//

import Foundation
import UserNotifications

enum StudlokNotifications {
    /// Fixed identifier so a new session's notification replaces any pending
    /// one from a previous session rather than stacking duplicates.
    static let sessionEndIdentifier = "studlok.session.end"

    static func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("[StudlokNotifications] requestAuthorization error: \(error.localizedDescription)")
            }
            print("[StudlokNotifications] requestAuthorization granted=\(granted)")
            completion?(granted)
        }
    }

    static func scheduleSessionEnd(at date: Date) {
        cancelSessionEnd()
        guard date > Date() else {
            print("[StudlokNotifications] scheduleSessionEnd: \(date) is already in the past, skipping")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Session's over"
        content.body = "Studlok is locking back up — earn your next scroll."
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: sessionEndIdentifier,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[StudlokNotifications] scheduleSessionEnd failed: \(error.localizedDescription)")
            } else {
                print("[StudlokNotifications] scheduleSessionEnd: scheduled for \(date)")
            }
        }
    }

    static func cancelSessionEnd() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [sessionEndIdentifier])
    }

    /// Debug check for Phase 8: confirms scheduling actually took effect
    /// (permission status + whether a pending request exists and when it'll
    /// fire) without needing to wait around for the notification itself.
    static func debugStatus(completion: @escaping ([String: Any]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let pending = requests.first { $0.identifier == sessionEndIdentifier }
            let triggerDescription: String
            if let trigger = pending?.trigger as? UNCalendarNotificationTrigger,
               let nextDate = trigger.nextTriggerDate() {
                triggerDescription = ISO8601DateFormatter().string(from: nextDate)
            } else {
                triggerDescription = "none pending"
            }
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                completion([
                    "authorizationStatus": settings.authorizationStatus.rawValue,
                    "pendingSessionEndTrigger": triggerDescription,
                ])
            }
        }
    }
}
