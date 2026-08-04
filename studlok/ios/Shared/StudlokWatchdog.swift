//
//  StudlokWatchdog.swift
//  Shared
//
//  Secondary, best-effort layer for catching a stale session without the
//  user needing to reopen Studlok specifically. DeviceActivityEvent
//  thresholds fire based on cumulative *device usage* (any app), not
//  wall-clock time — so this is not a return to usage-based tracking of the
//  Scroll Bank itself, it's purely an opportunistic "the user is actively
//  using their phone right now, good moment to check" trigger. Registering
//  a DeviceActivityEvent with empty applications/categories/webDomains
//  monitors total device activity rather than any specific app.
//
//  Primary reliability still comes from SessionReconciler running on
//  Runner's foreground (see AppDelegate). This extends coverage to "any
//  app," not just Studlok itself, since intervalDidEnd on the session's own
//  schedule is unreliable — see studlok_devicemonitor_unreliable memory.
//
//  Compiled into Runner and monitor.
//

import Foundation
import DeviceActivity

extension DeviceActivityName {
    static let studlokWatchdog = Self("studlokWatchdog")
}

enum StudlokWatchdog {
    /// Check-in roughly every 5 minutes of cumulative device usage, up to
    /// 60 minutes, resetting daily. Deliberately modest: enough check-ins
    /// to catch a stale session reasonably promptly without approaching the
    /// system's 20-activity limit or the DeviceActivityMonitor extension's
    /// 6MB memory ceiling — this only ever holds ~12 lightweight
    /// DateComponents values in memory.
    private static let stepMinutes = 5
    private static let stepCount = 12
    private static let eventNamePrefix = "studlokWatchdogCheck_"

    static func isWatchdogEvent(_ name: DeviceActivityEvent.Name) -> Bool {
        name.rawValue.hasPrefix(eventNamePrefix)
    }

    // MARK: - fire-recording (log-independent verification)

    private static let lastFiredDateKey = "studlokWatchdogLastFiredDate"
    private static let lastFiredEventKey = "studlokWatchdogLastFiredEvent"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: SharedStore.appGroupID)
    }

    /// Records that a watchdog event fired, independent of any logging
    /// mechanism (idevicesyslog isn't reliable for capturing print() from a
    /// non-debugger-attached process) — this is checkable from the app via
    /// debugWatchdogStatus regardless of whether a debugger is attached.
    static func recordFired(event: DeviceActivityEvent.Name) {
        defaults?.set(ISO8601DateFormatter().string(from: Date()), forKey: lastFiredDateKey)
        defaults?.set(event.rawValue, forKey: lastFiredEventKey)
    }

    static func debugStatus() -> [String: Any] {
        [
            "lastFiredDate": defaults?.string(forKey: lastFiredDateKey) ?? "never",
            "lastFiredEvent": defaults?.string(forKey: lastFiredEventKey) ?? "never",
        ]
    }

    private static func eventName(forStep step: Int) -> DeviceActivityEvent.Name {
        DeviceActivityEvent.Name("\(eventNamePrefix)\(step)")
    }

    private static func events() -> [DeviceActivityEvent.Name: DeviceActivityEvent] {
        var result: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
        for step in 1...stepCount {
            let totalMinutes = step * stepMinutes
            let threshold = DateComponents(hour: totalMinutes / 60, minute: totalMinutes % 60)
            result[eventName(forStep: step)] = DeviceActivityEvent(threshold: threshold)
        }
        return result
    }

    /// Registers the always-on daily watchdog schedule if it isn't already
    /// registered. Safe to call repeatedly (e.g. every app foreground) —
    /// idempotent, and requires Family Controls authorization to already be
    /// approved (silently no-ops otherwise via the thrown error being
    /// logged, not propagated).
    static func ensureRegistered() {
        let center = DeviceActivityCenter()
        guard !center.activities.contains(.studlokWatchdog) else { return }

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        do {
            try center.startMonitoring(.studlokWatchdog, during: schedule, events: events())
        } catch {
            print("[StudlokWatchdog] ensureRegistered failed: \(error.localizedDescription)")
        }
    }
}
