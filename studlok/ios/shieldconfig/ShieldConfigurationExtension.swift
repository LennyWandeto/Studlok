//
//  ShieldConfigurationExtension.swift
//  shieldconfig
//
//  Renders the "Earn Your Scroll" shield. This is a STATIC SNAPSHOT the
//  system renders once each time a shield is presented — no timers, no
//  countdown, no live updates while displayed (confirmed platform
//  constraint, not worth working around).
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

private enum StudlokShieldStyle {
    // "Earn Your Scroll" brand: near-black/charcoal background, acid-green accent.
    static let background = UIColor(red: 0.05, green: 0.05, blue: 0.06, alpha: 1)
    static let accent = UIColor(red: 0.80, green: 1.0, blue: 0.0, alpha: 1)
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

    private static func studlokShield() -> ShieldConfiguration {
        let state = SharedStore.load()

        // Only one subtitle slot exists (ShieldConfiguration.Label is a
        // single string + single color), so the tagline and the
        // session-specific line share one Label, both in the accent color.
        let subtitleText: String
        if state.activeSessionType != .none {
            subtitleText = "EARN YOUR SCROLL.\n\(state.activeSessionLabel) in progress — find Studlok and open it to check in."
        } else {
            subtitleText = "EARN YOUR SCROLL.\nComplete a session in Studlok to unlock this. Find the Studlok icon and open it."
        }

        return ShieldConfiguration(
            backgroundColor: StudlokShieldStyle.background,
            // Placeholder: no bundled icon asset exists yet in this target's
            // asset catalog. Swap for a real Studlok lock mark when available.
            icon: UIImage(systemName: "lock.fill")?
                .withTintColor(StudlokShieldStyle.accent, renderingMode: .alwaysOriginal),
            title: ShieldConfiguration.Label(text: "ACCESS DENIED", color: StudlokShieldStyle.white),
            subtitle: ShieldConfiguration.Label(text: subtitleText, color: StudlokShieldStyle.accent),
            primaryButtonLabel: ShieldConfiguration.Label(text: "OPEN STUDLOK", color: .black),
            primaryButtonBackgroundColor: StudlokShieldStyle.accent
        )
    }
}
