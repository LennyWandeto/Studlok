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

import ManagedSettings

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
    /// then close.
    private func respond(completionHandler: @escaping (ShieldActionResponse) -> Void) {
        SessionReconciler.reconcileIfNeeded()
        completionHandler(.close)
    }
}
