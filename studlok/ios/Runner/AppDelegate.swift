import Flutter
import UIKit
import FamilyControls
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  // Note: FlutterAppDelegate already conforms to UNUserNotificationCenterDelegate
  // and already implements the two methods below — that's why they're
  // `override`, and why this class doesn't redeclare the protocol itself.
  // No Flutter plugin in this app currently depends on the base
  // implementations (no firebase_messaging/flutter_local_notifications etc.),
  // so these fully replace them rather than calling super — the completion
  // handler contract only allows one call, and forwarding to an unknown
  // super implementation risks a double call if that ever changes.
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    #if DEBUG
    logSharedStoreRoundTrip()
    #endif
    observeDidBecomeActiveForSessionReconciliation()
    UNUserNotificationCenter.current().delegate = self
    // Must register before this method returns, and exactly once per launch.
    StudlokBackgroundRefresh.register()
    StudlokBackgroundRefresh.scheduleNext()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Show the banner even if Studlok happens to already be in the
  /// foreground when a notification fires — the default with no delegate
  /// set is to deliver it silently.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound])
  }

  /// The tap handler that makes the shield-dismiss notification actually
  /// deep-link somewhere, working around ShieldActionExtension's own
  /// inability to do so directly (see that file). Sets a shared-state flag;
  /// MainShell reads and clears it on launch/resume, since this fires from
  /// both a cold launch (app wasn't running) and a resume (it was
  /// backgrounded) depending on what state the app was in when tapped.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if response.notification.request.identifier == StudlokNotificationIdentifiers.shieldDismissQuizPrompt {
      var state = SharedStore.load()
      state.pendingDeepLink = "quiz"
      SharedStore.save(state)
      print("[AppDelegate] notification tapped: pendingDeepLink=quiz")
    }
    completionHandler()
  }

  /// Fallback for DeviceActivityMonitor's intervalDidEnd being unreliable for
  /// short, non-repeating schedules (see SessionReconciler). This app uses
  /// FlutterSceneDelegate (UISceneDelegateClassName in Info.plist), so
  /// AppDelegate.applicationDidBecomeActive never fires — UIKit routes scene
  /// lifecycle events to the scene delegate instead. UIApplication's
  /// didBecomeActiveNotification is posted at the app level regardless of
  /// delegate architecture, so it's the reliable hook here.
  private func observeDidBecomeActiveForSessionReconciliation() {
    NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main
    ) { _ in
      let reconciled = SessionReconciler.reconcileIfNeeded()
      if reconciled {
        print("[AppDelegate] didBecomeActiveNotification: reconciled a stale session")
      }
      if AuthorizationCenter.shared.authorizationStatus == .approved {
        StudlokWatchdog.ensureRegistered()
      }
    }
  }

  /// Debug-only sanity check for the App Group wiring: writes a marker state and
  /// reads it back, so `flutter run`'s console shows immediately whether Runner's
  /// suite("group.com.studlokapp.studlok") access is actually working on-device.
  #if DEBUG
  private func logSharedStoreRoundTrip() {
    var state = SharedStore.load()
    state.activeSessionLabel = "app-delegate-launch-check"
    SharedStore.save(state)
    let reloaded = SharedStore.load()
    print("[SharedStore] wrote+reloaded state: \(reloaded)")
  }
  #endif

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    StudlokChannel.register(
      with: engineBridge.applicationRegistrar.messenger(),
      rootViewControllerProvider: {
        // This app is Scene-based (UIApplicationSceneManifest in Info.plist),
        // so AppDelegate.window isn't reliably populated — read the key
        // window from the active UIWindowScene instead.
        UIApplication.shared.connectedScenes
          .compactMap { ($0 as? UIWindowScene)?.keyWindow }
          .first?.rootViewController
      }
    )
  }
}
