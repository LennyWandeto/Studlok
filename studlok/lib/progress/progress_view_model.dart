import 'package:flutter/foundation.dart';

import '../history/session_history_store.dart';
import '../native/studlok_native_bridge.dart';
import '../quiz/question_stats_store.dart';
import '../quiz/quiz_bank.dart';

/// Backs the Progress tab: local session history (already newest-first,
/// capped at 20 entries — same store Home's "Recent Protocols" reads), the
/// native streak count, and per-pack mastery counts — reshaped into a
/// day→count map for the heatmap.
class ProgressViewModel extends ChangeNotifier {
  ProgressViewModel({SessionHistoryStore? historyStore, StudlokNativeBridge? bridge, QuestionStatsStore? statsStore})
      : _historyStore = historyStore ?? SessionHistoryStore(),
        _bridge = bridge ?? StudlokNativeBridge(),
        _statsStore = statsStore ?? QuestionStatsStore() {
    refresh();
  }

  final SessionHistoryStore _historyStore;
  final StudlokNativeBridge _bridge;
  final QuestionStatsStore _statsStore;

  List<SessionHistoryEntry> history = const [];
  int currentStreak = 0;
  bool loaded = false;

  /// (pack, mastered count) for every hardcoded pack, in the app's default
  /// order — no subject-match reordering here, unlike the pack picker;
  /// Progress is a straight status report, not a "pick one" moment.
  List<(QuestionPack, int)> packMastery = const [];

  int get totalSessions => history.length;
  int get totalMinutesEarned => history.fold(0, (sum, e) => sum + e.minutesEarned);

  Map<DateTime, int> get dailyCounts {
    final map = <DateTime, int>{};
    for (final entry in history) {
      final day = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      map[day] = (map[day] ?? 0) + 1;
    }
    return map;
  }

  Future<void> refresh() async {
    history = await _historyStore.load();
    final state = await _bridge.getSharedState();
    currentStreak = state.currentStreak;
    final stats = await _statsStore.loadAll();
    packMastery = [
      for (final pack in studlokQuestionPacks) (pack, _statsStore.masteredCount(pack, stats)),
    ];
    loaded = true;
    notifyListeners();
  }
}
