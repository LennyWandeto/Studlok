import 'dart:async';

import 'package:flutter/foundation.dart';

import '../native/studlok_native_bridge.dart';

enum OnboardingStep {
  welcome1,
  welcome2,
  personalization,
  permissionPriming,
  appPicker,
  confirmed,
}

/// The onboarding flow's one ViewModel — every step (welcome, personalization,
/// permission request, app picker, confirmation) shares this single instance
/// so the whole flow is one continuous piece of state, not five screens each
/// re-deriving it. [startAt] lets a returning, partially-onboarded launch
/// resume past the intro rather than always starting at welcome1.
class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel({required OnboardingStep startAt, StudlokNativeBridge? bridge})
      : _bridge = bridge ?? StudlokNativeBridge(),
        _stepIndex = OnboardingStep.values.indexOf(startAt);

  final StudlokNativeBridge _bridge;

  int _stepIndex;
  int get stepIndex => _stepIndex;
  OnboardingStep get step => OnboardingStep.values[_stepIndex];
  int get totalSteps => OnboardingStep.values.length;

  bool isBusy = false;
  String? error;

  // Personalization answers — both optional, never block progress. `focus`
  // is currently just shown back to the user; `dailyGoalHours` is the one
  // that has a real effect (Home dashboard's Daily Goal default).
  String? focus;
  int? dailyGoalHours;

  int applicationCount = 0;
  int categoryCount = 0;

  void selectFocus(String value) {
    focus = value;
    notifyListeners();
  }

  void selectHours(int value) {
    dailyGoalHours = value;
    notifyListeners();
  }

  void _goTo(OnboardingStep target) {
    _stepIndex = OnboardingStep.values.indexOf(target);
    error = null;
    notifyListeners();
  }

  void next() => _goTo(OnboardingStep.values[_stepIndex + 1]);

  /// Returns true on approval (and advances). On denial/failure, returns
  /// false — the caller is responsible for showing the denied-state detour.
  Future<bool> requestPermission() async {
    isBusy = true;
    error = null;
    notifyListeners();
    try {
      final result = await _bridge.requestAuthorization();
      if (result.status == FamilyControlsAuthorizationStatus.approved) {
        // Fire-and-forget: notification permission is non-critical, and
        // asking now avoids interrupting the user with a prompt later.
        unawaited(_bridge.requestNotificationAuthorization());
        next();
        return true;
      }
      return false;
    } on StudlokNativeBridgeException {
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  /// Re-checks authorization after a trip to Settings (Family Controls has
  /// no supported way to re-prompt after a denial). Returns true and
  /// advances on success.
  Future<bool> recheckAuthorization() async {
    final status = await _bridge.getAuthorizationStatus();
    if (status == FamilyControlsAuthorizationStatus.approved) {
      next();
      return true;
    }
    return false;
  }

  Future<void> pickApps() async {
    isBusy = true;
    error = null;
    notifyListeners();
    try {
      final result = await _bridge.presentActivityPicker();
      applicationCount = result.applicationCount;
      categoryCount = result.categoryCount;
      next();
    } on StudlokNativeBridgeException catch (e) {
      error = e.message;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  /// Persists the daily-goal answer (if given) and marks onboarding done.
  Future<void> finish() async {
    final hours = dailyGoalHours;
    if (hours != null) {
      await _bridge.setDailyGoalMinutes(hours * 60);
    }
    await _bridge.completeOnboarding();
  }
}
