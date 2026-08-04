//
//  SessionReconciler.swift
//  Shared
//
//  Single source of truth for "a session's unlock window has ended": re-shields
//  the saved selection and clears the active session fields. Used by both the
//  DeviceActivityMonitor extension (the ideal, OS-scheduled path) and Runner's
//  foreground/launch fallback — DeviceActivityMonitor's intervalDidEnd is
//  documented to be unreliable specifically for short, non-repeating schedules
//  used for temporary unlocks: https://developer.apple.com/forums/thread/820956
//  Also used by ShieldActionExtension as its best-effort reconciliation on
//  button tap, for the same reliability caveat.
//  Compiled into Runner, monitor, and shieldaction.
//

import Foundation
import FamilyControls
import ManagedSettings

enum SessionReconciler {
    /// If a session was active and its end date has passed, re-shields and
    /// clears it. No-op otherwise. Safe to call from anywhere, anytime.
    @discardableResult
    static func reconcileIfNeeded() -> Bool {
        var state = SharedStore.load()
        guard
            state.activeSessionType != .none,
            let endDate = state.activeSessionEndDate,
            endDate <= Date()
        else {
            return false
        }

        let selection = FamilyActivitySelectionStore.load()
        let store = ManagedSettingsStore(named: .studlok)
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)

        state.activeSessionType = .none
        state.activeSessionEndDate = nil
        state.activeSessionLabel = ""
        SharedStore.save(state)
        return true
    }
}
