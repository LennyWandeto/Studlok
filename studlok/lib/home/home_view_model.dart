import 'package:flutter/material.dart';

import '../history/session_history_store.dart';
import '../native/studlok_native_bridge.dart';
import '../onboarding/gpa_goal_store.dart';
import '../quiz/question_stats_store.dart';
import '../quiz/quiz_bank.dart';

/// Wraps the dashboard's data sources (native shared state, local session
/// history, the onboarding GPA goal, and pack mastery) as one observable
/// ViewModel, so [HomeScreen] is a pure View — no bridge calls, no
/// loading-state juggling in build().
class HomeViewModel extends ChangeNotifier with WidgetsBindingObserver {
  HomeViewModel({
    StudlokNativeBridge? bridge,
    SessionHistoryStore? historyStore,
    GpaGoalStore? gpaGoalStore,
    QuestionStatsStore? statsStore,
  })  : _bridge = bridge ?? StudlokNativeBridge(),
        _historyStore = historyStore ?? SessionHistoryStore(),
        _gpaGoalStore = gpaGoalStore ?? GpaGoalStore(),
        _statsStore = statsStore ?? QuestionStatsStore() {
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  final StudlokNativeBridge _bridge;
  final SessionHistoryStore _historyStore;
  final GpaGoalStore _gpaGoalStore;
  final QuestionStatsStore _statsStore;

  StudlokSharedState? state;
  List<SessionHistoryEntry> history = const [];

  /// Null for anyone who onboarded before this existed, or who skipped
  /// straight to Home via the Welcome-screen sign-in link — Home simply
  /// doesn't show a goal section rather than fabricating one.
  GpaGoal? gpaGoal;
  int masteredCount = 0;

  bool get isLoading => state == null;

  /// A real, backward-looking count — not a projection of GPA outcome, in
  /// the same honest spirit as the onboarding Reveal screen. Reuses the
  /// same 20-entry session history every other Home/Progress stat reads.
  int get sessionsThisWeek {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return history.where((entry) => entry.timestamp.isAfter(cutoff)).length;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  Future<void> refresh() async {
    final newState = await _bridge.getSharedState();
    final newHistory = await _historyStore.load();
    final newGoal = await _gpaGoalStore.load();
    final stats = await _statsStore.loadAll();
    state = newState;
    history = newHistory;
    gpaGoal = newGoal;
    masteredCount = studlokQuestionPacks.fold(0, (sum, pack) => sum + _statsStore.masteredCount(pack, stats));
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
