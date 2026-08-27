//
//  StudlokChannel.swift
//  Runner
//
//  Registers "com.studlokapp.studlok/familycontrols" and implements every
//  method Flutter calls into: authorization, the app picker, starting a
//  session, and reading shared state. Runner-only.
//

import Flutter
import UIKit
import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

enum StudlokChannel {
    private static let channelName = "com.studlokapp.studlok/familycontrols"

    static func register(
        with messenger: FlutterBinaryMessenger,
        rootViewControllerProvider: @escaping () -> UIViewController?
    ) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        channel.setMethodCallHandler { call, result in
            handle(call, rootViewControllerProvider: rootViewControllerProvider, result: result)
        }
    }

    private static func log(_ message: String) {
        print("[StudlokChannel] \(message)")
    }

    private static func handle(
        _ call: FlutterMethodCall,
        rootViewControllerProvider: @escaping () -> UIViewController?,
        result: @escaping FlutterResult
    ) {
        log("received call: \(call.method) args=\(call.arguments ?? "nil")")
        switch call.method {
        case "requestAuthorization":
            requestAuthorization(result: result)
        case "presentActivityPicker":
            presentActivityPicker(rootViewControllerProvider: rootViewControllerProvider, result: result)
        case "startSession":
            startSession(arguments: call.arguments, result: result)
        case "getSharedState":
            let state = SharedStore.load()
            log("getSharedState -> \(state)")
            result(state.asFlutterMap)
        case "isSessionActive":
            let active = isSessionActive()
            log("isSessionActive -> \(active)")
            result(active)
        case "debugScheduleInfo":
            result(debugScheduleInfo())
        case "debugReconcileNow":
            let reconciled = SessionReconciler.reconcileIfNeeded()
            log("debugReconcileNow -> \(reconciled)")
            result(reconciled)
        case "debugWatchdogStatus":
            let status = StudlokWatchdog.debugStatus()
            log("debugWatchdogStatus -> \(status)")
            result(status)
        case "getAuthorizationStatus":
            let status = AuthorizationCenter.shared.authorizationStatus.studlokWireValue
            log("getAuthorizationStatus -> \(status)")
            result(status)
        case "hasSelectedApps":
            let selection = FamilyActivitySelectionStore.load()
            let hasSelection = !selection.applicationTokens.isEmpty
                || !selection.categoryTokens.isEmpty
                || !selection.webDomainTokens.isEmpty
            log("hasSelectedApps -> \(hasSelection)")
            result(hasSelection)
        case "completeOnboarding":
            var state = SharedStore.load()
            state.onboardingComplete = true
            SharedStore.save(state)
            log("completeOnboarding: saved")
            result(true)
        case "openSystemSettings":
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                result(false)
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
            result(true)
        case "requestNotificationAuthorization":
            StudlokNotifications.requestAuthorization { granted in
                result(granted)
            }
        case "debugNotificationStatus":
            StudlokNotifications.debugStatus { status in
                result(status)
            }
        case "debugBackgroundRefreshStatus":
            result(StudlokBackgroundRefresh.debugStatus())
        case "debugShieldStatus":
            result(debugShieldStatus())
        default:
            log("unimplemented method: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - requestAuthorization

    private static func requestAuthorization(result: @escaping FlutterResult) {
        log("requestAuthorization: requesting for .individual")
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                let status = AuthorizationCenter.shared.authorizationStatus.studlokWireValue
                log("requestAuthorization: succeeded, status=\(status)")
                StudlokWatchdog.ensureRegistered()
                result([
                    "success": true,
                    "status": status,
                ])
            } catch {
                let status = AuthorizationCenter.shared.authorizationStatus.studlokWireValue
                log("requestAuthorization: failed, status=\(status), error=\(error.localizedDescription)")
                result([
                    "success": false,
                    "status": status,
                    "error": error.localizedDescription,
                ])
            }
        }
    }

    // MARK: - presentActivityPicker

    private static func presentActivityPicker(
        rootViewControllerProvider: @escaping () -> UIViewController?,
        result: @escaping FlutterResult
    ) {
        guard let rootViewController = rootViewControllerProvider() else {
            log("presentActivityPicker: no root view controller available")
            result(FlutterError(
                code: "no_root_view_controller",
                message: "Could not find a view controller to present the picker from.",
                details: nil
            ))
            return
        }

        log("presentActivityPicker: presenting")
        var hostingController: UIHostingController<ActivityPickerContainer>?
        let container = ActivityPickerContainer(initialSelection: FamilyActivitySelectionStore.load()) { selection in
            log("presentActivityPicker: dismissed, apps=\(selection.applicationTokens.count) categories=\(selection.categoryTokens.count)")
            FamilyActivitySelectionStore.save(selection)
            applyDefaultShield(for: selection)
            log("presentActivityPicker: default shield applied")
            hostingController?.dismiss(animated: true)
            result([
                "applicationCount": selection.applicationTokens.count,
                "categoryCount": selection.categoryTokens.count,
            ])
        }
        let controller = UIHostingController(rootView: container)
        hostingController = controller
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .overFullScreen
        rootViewController.present(controller, animated: false)
    }

    /// Shields the picked apps/categories immediately, before any session has run.
    private static func applyDefaultShield(for selection: FamilyActivitySelection) {
        let store = ManagedSettingsStore(named: .studlok)
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
    }

    // MARK: - startSession

    private static func startSession(arguments: Any?, result: @escaping FlutterResult) {
        guard
            let args = arguments as? [String: Any],
            let durationMinutes = args["durationMinutes"] as? Int,
            durationMinutes > 0,
            let sessionTypeRaw = args["sessionType"] as? String,
            let sessionType = SessionType(rawValue: sessionTypeRaw),
            let label = args["label"] as? String
        else {
            log("startSession: invalid arguments: \(String(describing: arguments))")
            result(FlutterError(
                code: "invalid_arguments",
                message: "startSession requires a positive Int durationMinutes, a valid sessionType, and a label.",
                details: nil
            ))
            return
        }

        let now = Date()
        let end = now.addingTimeInterval(TimeInterval(durationMinutes * 60))
        log("startSession: duration=\(durationMinutes)m type=\(sessionType) label=\"\(label)\" end=\(end)")

        // DeviceActivitySchedule works in time-of-day DateComponents, not
        // absolute dates. This does not yet handle a window crossing midnight.
        let calendar = Calendar.current
        let schedule = DeviceActivitySchedule(
            intervalStart: calendar.dateComponents([.hour, .minute, .second], from: now),
            intervalEnd: calendar.dateComponents([.hour, .minute, .second], from: end),
            repeats: false
        )

        // Schedule the re-lock BEFORE lifting the shield. If this throws
        // (e.g. Apple's MonitoringError.intervalTooShort), nothing has been
        // unlocked yet and nothing needs to be rolled back.
        let center = DeviceActivityCenter()
        center.stopMonitoring([.studlokSession])
        do {
            try center.startMonitoring(.studlokSession, during: schedule)
            log("startSession: monitoring scheduled, waiting for intervalDidEnd in the monitor extension")
        } catch {
            // Apple enforces a minimum monitoring interval (DeviceActivityCenter.MonitoringError
            // .intervalTooShort) — very short test durations can legitimately hit this.
            log("startSession: startMonitoring threw: \(error.localizedDescription)")
            result(FlutterError(code: "schedule_failed", message: error.localizedDescription, details: nil))
            return
        }

        var state = SharedStore.load()
        state.scrollBankMinutes += durationMinutes
        state.activeSessionType = sessionType
        state.activeSessionEndDate = end
        state.activeSessionLabel = label
        SharedStore.save(state)
        log("startSession: shared state saved, scrollBankMinutes=\(state.scrollBankMinutes)")

        StudlokNotifications.scheduleSessionEnd(at: end)

        let store = ManagedSettingsStore(named: .studlok)
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        log("startSession: shield lifted")

        result(true)
    }

    // MARK: - isSessionActive

    private static func isSessionActive() -> Bool {
        let state = SharedStore.load()
        guard state.activeSessionType != .none, let endDate = state.activeSessionEndDate else {
            return false
        }
        return endDate > Date()
    }

    // MARK: - debugScheduleInfo (temporary diagnostic, not part of the Phase 5 spec)

    private static func debugScheduleInfo() -> [String: Any] {
        let center = DeviceActivityCenter()
        let activities = center.activities.map { $0.rawValue }
        let scheduleDescription: String
        if let schedule = center.schedule(for: .studlokSession) {
            scheduleDescription = "start=\(schedule.intervalStart) end=\(schedule.intervalEnd) repeats=\(schedule.repeats) nextInterval=\(String(describing: schedule.nextInterval))"
        } else {
            scheduleDescription = "no schedule registered for .studlokSession"
        }
        let watchdogDescription: String
        if let schedule = center.schedule(for: .studlokWatchdog) {
            let eventCount = center.events(for: .studlokWatchdog).count
            watchdogDescription = "registered, repeats=\(schedule.repeats) eventCount=\(eventCount) nextInterval=\(String(describing: schedule.nextInterval))"
        } else {
            watchdogDescription = "not registered"
        }
        let info: [String: Any] = [
            "activities": activities,
            "schedule": scheduleDescription,
            "watchdog": watchdogDescription,
            "now": ISO8601DateFormatter().string(from: Date()),
        ]
        log("debugScheduleInfo -> \(info)")
        return info
    }

    // MARK: - debugShieldStatus (diagnostic: what's actually configured on
    // the ManagedSettingsStore, as opposed to what's saved in
    // FamilyActivitySelectionStore — these are two different things, and a
    // selection existing doesn't guarantee the shield was actually applied)

    private static func debugShieldStatus() -> [String: Any] {
        let selection = FamilyActivitySelectionStore.load()
        let store = ManagedSettingsStore(named: .studlok)

        let categoryPolicyDescription: String
        switch store.shield.applicationCategories {
        case .none:
            categoryPolicyDescription = "nil"
        case .some(.all(except: let exceptions)):
            categoryPolicyDescription = "all except \(exceptions.count)"
        case .some(.specific(let categories, except: let exceptions)):
            categoryPolicyDescription = "specific(\(categories.count)) except \(exceptions.count)"
        case .some:
            categoryPolicyDescription = "unknown policy case"
        }

        let info: [String: Any] = [
            "authorizationStatus": AuthorizationCenter.shared.authorizationStatus.studlokWireValue,
            "selectionApplicationTokens": selection.applicationTokens.count,
            "selectionCategoryTokens": selection.categoryTokens.count,
            "selectionWebDomainTokens": selection.webDomainTokens.count,
            "shieldApplicationsCount": store.shield.applications?.count ?? 0,
            "shieldApplicationsIsNil": store.shield.applications == nil,
            "shieldApplicationCategories": categoryPolicyDescription,
        ]
        log("debugShieldStatus -> \(info)")
        return info
    }
}

/// Invisible SwiftUI host that drives Apple's `.familyActivityPicker` modifier,
/// since `FamilyActivityPicker` itself is SwiftUI-only. Reports back through
/// `onFinish` once the picker is dismissed (Cancel or Done).
private struct ActivityPickerContainer: View {
    @State private var isPresented = true
    @State private var selection: FamilyActivitySelection
    private let onFinish: (FamilyActivitySelection) -> Void

    init(initialSelection: FamilyActivitySelection, onFinish: @escaping (FamilyActivitySelection) -> Void) {
        _selection = State(initialValue: initialSelection)
        self.onFinish = onFinish
    }

    var body: some View {
        Color.clear
            .familyActivityPicker(isPresented: $isPresented, selection: $selection)
            .onChange(of: isPresented) { presented in
                if !presented {
                    onFinish(selection)
                }
            }
    }
}

private extension AuthorizationStatus {
    var studlokWireValue: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .denied: return "denied"
        case .approved: return "approved"
        @unknown default: return "unknown"
        }
    }
}

private extension StudlokSharedState {
    var asFlutterMap: [String: Any] {
        [
            "scrollBankMinutes": scrollBankMinutes,
            "activeSessionType": activeSessionType.rawValue,
            "activeSessionEndDate": activeSessionEndDate.map { $0.timeIntervalSince1970 * 1000 } ?? NSNull(),
            "activeSessionLabel": activeSessionLabel,
            "currentStreak": currentStreak,
            "dailyGoalMinutes": dailyGoalMinutes,
            "dailyProgressMinutes": dailyProgressMinutes,
            "onboardingComplete": onboardingComplete,
        ]
    }
}
