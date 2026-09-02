//
//  ShieldConfigurationExtension.swift
//  shieldconfig
//
//  Renders the "Earn Your Scroll" shield. This is a STATIC SNAPSHOT the
//  system renders once each time a shield is presented — no timers, no
//  countdown, no live updates while displayed (confirmed platform
//  constraint, not worth working around). It DOES get re-queried, though,
//  when ShieldActionExtension responds .none instead of .close — that's
//  how the "check your notifications" copy below gets shown after the
//  button's been pressed, without the shield ever actually closing.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

private enum StudlokShieldStyle {
    // Exact values from lib/design/studlok_colors.dart (StudlokColors) — the
    // shield can't import that file, so these are kept numerically identical
    // by hand. background = #0D0D0F, accent = #CCFF00.
    static let background = UIColor(red: 13.0 / 255, green: 13.0 / 255, blue: 15.0 / 255, alpha: 1)
    static let accent = UIColor(red: 204.0 / 255, green: 255.0 / 255, blue: 0.0, alpha: 1)
    static let white = UIColor.white
}

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        Self.studlokShield()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        Self.studlokShield()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        Self.studlokShield()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        Self.studlokShield()
    }

    /// How long after a button press the "check your notifications" copy
    /// stays up before a freshly-shown shield reverts to the normal text.
    /// Long enough to actually go look; short enough that a shield shown
    /// minutes later (a new app tap) doesn't confusingly reference a
    /// notification from an unrelated, much-earlier tap.
    private static let dismissRequestedWindow: TimeInterval = 120

    private static func studlokShield() -> ShieldConfiguration {
        let state = SharedStore.load()

        // The brand line leads as the title (in accent, matching every
        // other screen where "EARN YOUR SCROLL." appears) instead of the
        // punitive-sounding "ACCESS DENIED" — this shield shows up many
        // times a day, and a scolding tone wears worse with repetition than
        // a motivating one.
        let title: String
        let subtitleText: String

        if state.activeSessionType != .none {
            title = "EARN YOUR SCROLL."
            subtitleText = "\(state.activeSessionLabel) in progress — open Studlok to check in."
        } else if let requestedAt = state.shieldDismissRequestedAt,
                  Date().timeIntervalSince(requestedAt) < dismissRequestedWindow {
            title = "CHECK YOUR NOTIFICATIONS."
            subtitleText = "We sent one to start a quiz. Don't see it? Make sure Do Not Disturb or Focus mode is off."
        } else {
            title = "EARN YOUR SCROLL."
            subtitleText = "Complete a session in Studlok to unlock this."
        }

        return ShieldConfiguration(
            backgroundColor: StudlokShieldStyle.background,
            // Placeholder: no bundled icon asset exists yet in this target's
            // asset catalog. Swap for a real Studlok lock mark when available.
            icon: UIImage(systemName: "lock.fill")?
                .withTintColor(StudlokShieldStyle.accent, renderingMode: .alwaysOriginal),
            title: ShieldConfiguration.Label(text: title, color: StudlokShieldStyle.accent),
            subtitle: ShieldConfiguration.Label(text: subtitleText, color: StudlokShieldStyle.white),
            // "TAKE A QUIZ" — the actual goal state, even though tapping it
            // only schedules a notification (per ShieldActionExtension,
            // which responds .none so the shield stays up); the notification
            // is what actually gets them there.
            primaryButtonLabel: ShieldConfiguration.Label(text: "TAKE A QUIZ", color: .black),
            primaryButtonBackgroundColor: StudlokShieldStyle.accent
        )
    }
}
