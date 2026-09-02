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
    /// Set by AppDelegate when a notification with a deep-link payload is
    /// tapped (currently only "quiz", from the shield-dismiss prompt).
    /// Flutter reads and clears this on launch/resume — see MainShell.
    var pendingDeepLink: String?
    /// Set by ShieldActionExtension the moment it schedules the quiz-prompt
    /// notification. ShieldConfigurationExtension checks how recent this is
    /// to decide which shield text to show — see that file. A timestamp
    /// rather than a bool so it self-expires (a fresh shield shown minutes
    /// later reverts to the normal copy) without needing an explicit clear.
    var shieldDismissRequestedAt: Date?

    static let empty = StudlokSharedState(
        scrollBankMinutes: 0,
        activeSessionType: .none,
        activeSessionEndDate: nil,
        activeSessionLabel: "",
        currentStreak: 0,
        dailyGoalMinutes: 0,
        dailyProgressMinutes: 0,
        onboardingComplete: false,
        pendingDeepLink: nil,
        shieldDismissRequestedAt: nil
    )
}

/// Notification identifiers shared across targets: ShieldActionExtension
/// schedules, AppDelegate (Runner-only) checks on tap. Kept here rather than
/// in StudlokNotifications.swift (Runner-only) so both sides compile against
/// the same constant instead of hand-matched string literals.
enum StudlokNotificationIdentifiers {
    static let shieldDismissQuizPrompt = "studlok.shield.dismiss.quiz"
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
