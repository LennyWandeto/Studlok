//
//  SharedStore.swift
//  Shared
//
//  Compiled into Runner, monitor, shieldconfig, and shieldaction so every
//  process reads/writes the same App Group state.
//

import Foundation

enum SessionType: String, Codable {
    case none
    case deepWork
    case quiz
}

struct StudlokSharedState: Codable, Equatable {
    var scrollBankMinutes: Int
    var activeSessionType: SessionType
    var activeSessionEndDate: Date?
    var activeSessionLabel: String
    var currentStreak: Int
    var dailyGoalMinutes: Int
    var dailyProgressMinutes: Int
    var onboardingComplete: Bool

    static let empty = StudlokSharedState(
        scrollBankMinutes: 0,
        activeSessionType: .none,
        activeSessionEndDate: nil,
        activeSessionLabel: "",
        currentStreak: 0,
        dailyGoalMinutes: 0,
        dailyProgressMinutes: 0,
        onboardingComplete: false
    )
}

enum SharedStore {
    static let appGroupID = "group.com.studlokapp.studlok"
    private static let stateKey = "state"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func load() -> StudlokSharedState {
        guard
            let defaults,
            let data = defaults.data(forKey: stateKey),
            let state = try? JSONDecoder().decode(StudlokSharedState.self, from: data)
        else {
            return .empty
        }
        return state
    }

    static func save(_ state: StudlokSharedState) {
        guard let defaults, let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: stateKey)
    }
}
