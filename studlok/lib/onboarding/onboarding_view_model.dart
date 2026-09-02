import 'package:flutter/foundation.dart';

import '../native/studlok_native_bridge.dart';
import 'subject_focus_store.dart';

enum OnboardingStep {
  welcome1,
  welcome2,
  subjectFocus,
  personalizationBasics,
  personalizationTarget,
  personalizationReveal,
  permissionPriming,
  notificationPriming,
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
        _stepIndex = OnboardingStep.values.indexOf(startAt) {
    _loadSubjectFocus();
  }

  final StudlokNativeBridge _bridge;
  final _subjectFocusStore = SubjectFocusStore();

  int _stepIndex;
  int get stepIndex => _stepIndex;
  OnboardingStep get step => OnboardingStep.values[_stepIndex];
  int get totalSteps => OnboardingStep.values.length;

  bool isBusy = false;
  String? error;

  // Personalization answers. `weeklyStudyHours` has a real effect (it sets
  // the Home dashboard's Daily Goal default, averaged across the week);
  // `currentGpa`/`targetGpa` power the "dream" moment and the reassurance
  // screen that follows it — a validating statement, not a fabricated
  // prediction of any kind.
  double currentGpa = 3.0;
  double targetGpa = 3.3;
  double weeklyStudyHours = 10;

  int applicationCount = 0;
  int categoryCount = 0;

  // What they're studying for — stored locally (see SubjectFocusStore), used
  // to personalize the Reveal screen's copy and, once content packs exist,
  // to prioritize a matching quiz pack. Loaded async at construction rather
  // than passed in, so a returning-but-unfinished onboarding run picks up
  // whatever was already answered without the caller having to know about it.
  SubjectFocus? subjectFocus;

  Future<void> _loadSubjectFocus() async {
    subjectFocus = await _subjectFocusStore.load();
    notifyListeners();
  }

  Future<void> setSubjectCategory(SubjectCategory category) async {
    subjectFocus = SubjectFocus(category: category);
    notifyListeners();
    await _subjectFocusStore.saveCategory(category);
  }

  Future<void> setSubjectCustomText(String text) async {
    subjectFocus = SubjectFocus(customText: text);
    notifyListeners();
    await _subjectFocusStore.saveCustomText(text);
  }

  double _roundTenth(double value) => (value * 10).round() / 10;

  void setCurrentGpa(double value) {
    currentGpa = _roundTenth(value.clamp(0.0, 4.0));
    if (targetGpa < currentGpa) targetGpa = currentGpa;
    notifyListeners();
  }

  void setTargetGpa(double value) {
    targetGpa = _roundTenth(value.clamp(currentGpa, 4.0));
    notifyListeners();
  }

  void setWeeklyStudyHours(double value) {
    weeklyStudyHours = value;
    notifyListeners();
  }

  void _goTo(OnboardingStep target) {
    _stepIndex = OnboardingStep.values.indexOf(target);
    error = null;
    notifyListeners();
  }

  /// Advances one step — except the subject-focus step gets skipped if a
  /// subject is already stored (a returning, partially-onboarded launch
  /// that already answered this earlier). Same intent as the app-picker
  /// skip in AppRouterViewModel: don't re-ask something already known. This
  /// one lives here rather than at the router level because, unlike the
  /// Screen Time/app-selection checkpoints, onboarding today always
  /// restarts a fresh run at welcome1 — there's no earlier "startAt" for a
  /// single mid-flow step to hook into.
  void next() {
    var target = OnboardingStep.values[_stepIndex + 1];
    if (target == OnboardingStep.subjectFocus && subjectFocus != null) {
      target = OnboardingStep.values[OnboardingStep.values.indexOf(target) + 1];
    }
    _goTo(target);
  }

  /// Returns true on approval (and advances). On denial/failure, returns
  /// false — the caller is responsible for showing the denied-state detour.
  Future<bool> requestPermission() async {
    isBusy = true;
    error = null;
    notifyListeners();
    try {
      final result = await _bridge.requestAuthorization();
      if (result.status == FamilyControlsAuthorizationStatus.approved) {
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

  /// Notification permission is non-critical — the result isn't checked,
  /// and the flow always advances either way. Denying it just means no
  /// re-lock/session-end notifications, not a broken app.
  Future<void> requestNotifications() async {
    isBusy = true;
    notifyListeners();
    try {
      await _bridge.requestNotificationAuthorization();
    } finally {
      isBusy = false;
      next();
    }
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

  /// Persists the daily-goal default (weekly hours, averaged to a daily
  /// figure) and marks onboarding done.
  Future<void> finish() async {
    final dailyMinutes = (weeklyStudyHours * 60 / 7).round();
    await _bridge.setDailyGoalMinutes(dailyMinutes);
    await _bridge.completeOnboarding();
  }
}
