import Flutter
import UIKit
import FamilyControls

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    #if DEBUG
    logSharedStoreRoundTrip()
    #endif
    observeDidBecomeActiveForSessionReconciliation()
    // Must register before this method returns, and exactly once per launch.
    StudlokBackgroundRefresh.register()
    StudlokBackgroundRefresh.scheduleNext()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
