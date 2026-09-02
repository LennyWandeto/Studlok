import 'package:flutter/foundation.dart';

import '../history/session_history_store.dart';
import '../native/studlok_native_bridge.dart';

/// Backs the Progress tab: local session history (already newest-first,
/// capped at 20 entries — same store Home's "Recent Protocols" reads) plus
/// the native streak count, reshaped into a day→count map for the heatmap.
class ProgressViewModel extends ChangeNotifier {
  ProgressViewModel({SessionHistoryStore? historyStore, StudlokNativeBridge? bridge})
      : _historyStore = historyStore ?? SessionHistoryStore(),
        _bridge = bridge ?? StudlokNativeBridge() {
    refresh();
  }

  final SessionHistoryStore _historyStore;
  final StudlokNativeBridge _bridge;

  List<SessionHistoryEntry> history = const [];
  int currentStreak = 0;
  bool loaded = false;

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
    loaded = true;
    notifyListeners();
  }
}
