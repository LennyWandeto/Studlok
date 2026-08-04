import 'package:flutter/services.dart';

/// Mirrors the native `SessionType` enum (ios/Shared/SharedStore.swift).
enum SessionType {
  none,
  deepWork,
  quiz;

  String get _wireValue => switch (this) {
        SessionType.none => 'none',
        SessionType.deepWork => 'deepWork',
        SessionType.quiz => 'quiz',
      };

  static SessionType _fromWire(String value) => switch (value) {
        'deepWork' => SessionType.deepWork,
        'quiz' => SessionType.quiz,
        _ => SessionType.none,
      };
}

/// Mirrors Apple's `AuthorizationStatus` (FamilyControls).
enum FamilyControlsAuthorizationStatus {
  notDetermined,
  denied,
  approved,
  unknown;

  static FamilyControlsAuthorizationStatus _fromWire(String value) => switch (value) {
        'notDetermined' => FamilyControlsAuthorizationStatus.notDetermined,
        'denied' => FamilyControlsAuthorizationStatus.denied,
        'approved' => FamilyControlsAuthorizationStatus.approved,
        _ => FamilyControlsAuthorizationStatus.unknown,
      };
}

class AuthorizationResult {
  const AuthorizationResult({required this.success, required this.status, this.error});

  final bool success;
  final FamilyControlsAuthorizationStatus status;
  final String? error;
}

class ActivityPickerResult {
  const ActivityPickerResult({required this.applicationCount, required this.categoryCount});

  final int applicationCount;
  final int categoryCount;
}

class StudlokSharedState {
  const StudlokSharedState({
    required this.scrollBankMinutes,
    required this.activeSessionType,
    required this.activeSessionEndDate,
    required this.activeSessionLabel,
    required this.currentStreak,
    required this.dailyGoalMinutes,
    required this.dailyProgressMinutes,
    required this.onboardingComplete,
  });

  factory StudlokSharedState._fromWire(Map<Object?, Object?> map) {
    final endDateMillis = map['activeSessionEndDate'] as num?;
    return StudlokSharedState(
      scrollBankMinutes: (map['scrollBankMinutes'] as num).toInt(),
      activeSessionType: SessionType._fromWire(map['activeSessionType'] as String),
      activeSessionEndDate:
          endDateMillis == null ? null : DateTime.fromMillisecondsSinceEpoch(endDateMillis.toInt()),
      activeSessionLabel: map['activeSessionLabel'] as String,
      currentStreak: (map['currentStreak'] as num).toInt(),
      dailyGoalMinutes: (map['dailyGoalMinutes'] as num).toInt(),
      dailyProgressMinutes: (map['dailyProgressMinutes'] as num).toInt(),
      onboardingComplete: map['onboardingComplete'] as bool? ?? false,
    );
  }

  final int scrollBankMinutes;
  final SessionType activeSessionType;
  final DateTime? activeSessionEndDate;
  final String activeSessionLabel;
  final int currentStreak;
  final int dailyGoalMinutes;
  final int dailyProgressMinutes;
  final bool onboardingComplete;
}

/// Thrown for any failure talking to the native Family Controls bridge —
/// wraps [PlatformException] so Flutter UI code doesn't need to know about
/// method channels at all.
class StudlokNativeBridgeException implements Exception {
  StudlokNativeBridgeException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'StudlokNativeBridgeException($code): $message';
}

/// Thin wrapper around the "com.studlokapp.studlok/familycontrols" method
/// channel. UI code should only ever talk to this class, never MethodChannel
/// directly.
class StudlokNativeBridge {
  StudlokNativeBridge({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.studlokapp.studlok/familycontrols');

  final MethodChannel _channel;

  Future<AuthorizationResult> requestAuthorization() async {
    final raw = await _invokeMap('requestAuthorization');
    return AuthorizationResult(
      success: raw['success'] as bool,
      status: FamilyControlsAuthorizationStatus._fromWire(raw['status'] as String),
      error: raw['error'] as String?,
    );
  }

  Future<ActivityPickerResult> presentActivityPicker() async {
    final raw = await _invokeMap('presentActivityPicker');
    return ActivityPickerResult(
      applicationCount: (raw['applicationCount'] as num).toInt(),
      categoryCount: (raw['categoryCount'] as num).toInt(),
    );
  }

  Future<void> startSession({
    required int durationMinutes,
    required SessionType sessionType,
    required String label,
  }) async {
    await _invoke<bool>('startSession', {
      'durationMinutes': durationMinutes,
      'sessionType': sessionType._wireValue,
      'label': label,
    });
  }

  Future<StudlokSharedState> getSharedState() async {
    final raw = await _invokeMap('getSharedState');
    return StudlokSharedState._fromWire(raw);
  }

  Future<bool> isSessionActive() async {
    return (await _invoke<bool>('isSessionActive')) ?? false;
  }

  /// Reads the current Family Controls authorization status without
  /// triggering the system consent prompt — use this for routing decisions
  /// on launch. Use [requestAuthorization] when you actually want to prompt.
  Future<FamilyControlsAuthorizationStatus> getAuthorizationStatus() async {
    final raw = await _invoke<String>('getAuthorizationStatus');
    return FamilyControlsAuthorizationStatus._fromWire(raw ?? 'unknown');
  }

  /// Whether the user has ever picked any apps/categories/domains to shield.
  Future<bool> hasSelectedApps() async {
    return (await _invoke<bool>('hasSelectedApps')) ?? false;
  }

  /// Marks onboarding as complete in shared storage, so a relaunch never
  /// re-triggers the onboarding flow once authorization + app selection are
  /// both already satisfied.
  Future<void> completeOnboarding() async {
    await _invoke<bool>('completeOnboarding');
  }

  /// Opens the Settings app (UIApplication.openSettingsURLString) — used
  /// when the user has denied Family Controls access and needs to enable it
  /// manually, since there's no supported way to re-prompt after a denial.
  Future<void> openSystemSettings() async {
    await _invoke<bool>('openSystemSettings');
  }

  /// Requests local notification permission — called during onboarding so
  /// the session-end notification (Phase 8) has a chance of being granted
  /// before the first session ever starts.
  Future<bool> requestNotificationAuthorization() async {
    return (await _invoke<bool>('requestNotificationAuthorization')) ?? false;
  }

  /// Debug check for Phase 8: whether the session-end notification is
  /// actually scheduled, and the current notification permission status.
  Future<Map<Object?, Object?>> debugNotificationStatus() => _invokeMap('debugNotificationStatus');

  /// Debug check for Phase 8: how many times the BGAppRefreshTask has
  /// actually fired on this device, and when it last did — since its timing
  /// is not something iOS guarantees, this is for observing real-world
  /// reliability over time rather than asserting correctness in a test run.
  Future<Map<Object?, Object?>> debugBackgroundRefreshStatus() => _invokeMap('debugBackgroundRefreshStatus');

  /// Temporary diagnostic (not part of the Phase 5 spec) — asks
  /// DeviceActivityCenter directly what it currently has registered, to
  /// debug why intervalDidEnd isn't firing.
  Future<Map<Object?, Object?>> debugScheduleInfo() => _invokeMap('debugScheduleInfo');

  /// Manually triggers the same reconcile-a-stale-session logic that
  /// normally runs on app foreground/launch. Returns true if a stale
  /// session was actually found and cleared.
  Future<bool> debugReconcileNow() async => (await _invoke<bool>('debugReconcileNow')) ?? false;

  /// Reads whether/when the StudlokWatchdog's eventDidReachThreshold has
  /// ever fired — recorded in shared storage independent of any logging
  /// mechanism, so it's checkable even when no debugger is attached.
  Future<Map<Object?, Object?>> debugWatchdogStatus() => _invokeMap('debugWatchdogStatus');

  Future<T?> _invoke<T>(String method, [Map<String, Object?>? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      throw StudlokNativeBridgeException(e.message ?? '$method failed', code: e.code);
    }
  }

  Future<Map<Object?, Object?>> _invokeMap(String method, [Map<String, Object?>? arguments]) async {
    final result = await _invoke<Map<Object?, Object?>>(method, arguments);
    if (result == null) {
      throw StudlokNativeBridgeException('$method returned no data');
    }
    return result;
  }
}
