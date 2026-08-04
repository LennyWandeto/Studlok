//
//  DeviceActivityMonitorExtension.swift
//  monitor
//
//  Created by Lenny Wachira on 7/29/26.
//

import DeviceActivity
import FamilyControls
import ManagedSettings

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        print("[StudlokMonitor] intervalDidStart: \(activity.rawValue)")
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        print("[StudlokMonitor] intervalDidEnd: \(activity.rawValue)")
        guard activity == .studlokSession else { return }

        // This is the ideal path, but intervalDidEnd is documented to be
        // unreliable for short, non-repeating schedules — see SessionReconciler.
        // Runner's foreground/launch fallback covers the case where this
        // callback never fires at all.
        let reconciled = SessionReconciler.reconcileIfNeeded()
        print("[StudlokMonitor] intervalDidEnd: reconciled=\(reconciled)")
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        guard activity == .studlokWatchdog, StudlokWatchdog.isWatchdogEvent(event) else { return }

        // Opportunistic check-in triggered by device usage, not tied to any
        // specific session's own (unreliable) schedule. See StudlokWatchdog.
        StudlokWatchdog.recordFired(event: event)
        let reconciled = SessionReconciler.reconcileIfNeeded()
        print("[StudlokMonitor] eventDidReachThreshold: \(event.rawValue) reconciled=\(reconciled)")
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Handle the warning before the interval starts.
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        // Handle the warning before the interval ends.
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        
        // Handle the warning before the event reaches its threshold.
    }
}
