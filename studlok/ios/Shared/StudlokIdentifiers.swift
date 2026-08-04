//
//  StudlokIdentifiers.swift
//  Shared
//
//  Names Runner and monitor agree on so they operate on the same
//  ManagedSettingsStore and DeviceActivity schedule.
//  Compiled into Runner, monitor, and shieldaction (shieldaction only needs
//  ManagedSettingsStore.Name.studlok via SessionReconciler; the
//  DeviceActivityName half is unused there but harmless to include).
//

import ManagedSettings
import DeviceActivity

extension ManagedSettingsStore.Name {
    static let studlok = Self("com.studlokapp.studlok.primary")
}

extension DeviceActivityName {
    static let studlokSession = Self("studlokSession")
}
