//
//  ShieldActionExtension.swift
//  shieldaction
//
//  Handles the shield's button taps. There is no supported way to deep-link
//  from here into the main app — ShieldActionResponse only offers
//  .none/.defer/.close, and .defer does not open the host app. The shield's
//  own copy (ShieldConfigurationExtension) is where the "go find Studlok
//  yourself" instruction has to live, not here.
//
//  What this file CAN do instead: fire a real local notification and keep
//  the shield up (ShieldActionResponse.none, not .close) rather than
//  dismissing it. Notifications support a tap handler (see AppDelegate), so
//  that's the actual workaround to the deep-link limitation above — not
//  from the shield itself, but from what appears a couple seconds after it.
//  ShieldConfigurationExtension reads the timestamp this file writes to
//  swap in "check your notification" copy once the button's been pressed.
//

import ManagedSettings
import UserNotifications

class ShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        respond(completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        respond(completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        respond(completionHandler: completionHandler)
    }

    /// Best-effort reconciliation — this extension process may or may not
    /// reliably execute before the OS proceeds, same caveat as
    /// DeviceActivityMonitor (see SessionReconciler). There's no secondary
    /// button in this shield's configuration, so both button-press cases
    /// converge on the same outcome: reconcile if there's anything stale,
    /// schedule the quiz-prompt notification, record when we did, then
    /// respond .none — the shield stays up rather than closing, so the user
    /// isn't dropped back to wherever they were with no explanation.
    private func respond(completionHandler: @escaping (ShieldActionResponse) -> Void) {
        SessionReconciler.reconcileIfNeeded()
        scheduleQuizPrompt()
        recordDismissRequested()
        completionHandler(.none)
    }

    private func recordDismissRequested() {
        var state = SharedStore.load()
        state.shieldDismissRequestedAt = Date()
        SharedStore.save(state)
    }

    /// Fire-and-forget: `.add`'s own completion runs after this extension
    /// has likely already returned, which is fine — nothing here depends on
    /// the notification actually having been scheduled by the time we close.
    /// Fixed identifier so rapid repeated dismisses (someone bouncing off a
    /// locked app a few times in a row) replace the pending request rather
    /// than stacking duplicates.
    private func scheduleQuizPrompt() {
        let content = UNMutableNotificationContent()
        content.title = "Locked out?"
        content.body = "Take a quiz to earn scroll time right now."
        content.sound = .default
        content.userInfo = ["deepLink": "quiz"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: StudlokNotificationIdentifiers.shieldDismissQuizPrompt,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[ShieldActionExtension] scheduleQuizPrompt failed: \(error.localizedDescription)")
            }
        }
    }
}
