//
//  FamilyActivitySelectionStore.swift
//  Shared
//
//  Stores the user's chosen shielded apps separately from StudlokSharedState:
//  it's a distinct Apple-defined type that changes far less often than the
//  balance/session state, so it gets its own App Group key.
//  Compiled into Runner (writes the selection when the user picks apps),
//  monitor and shieldaction (both read it via SessionReconciler to know
//  what to re-shield when a session's unlock window ends). shieldconfig
//  doesn't need it — it acts on whichever token the OS hands it for display,
//  not the full selection set.
//

import Foundation
import FamilyControls

enum FamilyActivitySelectionStore {
    private static let selectionKey = "familyActivitySelection"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: SharedStore.appGroupID)
    }

    static func load() -> FamilyActivitySelection {
        guard
            let defaults,
            let data = defaults.data(forKey: selectionKey),
            let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else {
            return FamilyActivitySelection()
        }
        return selection
    }

    static func save(_ selection: FamilyActivitySelection) {
        guard let defaults, let data = try? JSONEncoder().encode(selection) else { return }
        defaults.set(data, forKey: selectionKey)
    }
}
