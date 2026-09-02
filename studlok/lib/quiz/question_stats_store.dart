import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_bank.dart';

/// Local-only, per-question attempt history — the shared data source behind
/// two features: drawing questions weighted toward recent misses (spaced
/// repetition) and counting how many of a pack's questions are "mastered"
/// (Progress tab, pack picker). No backend involved; keyed by
/// [QuizQuestion.id] so it survives content batches being reordered.
///
/// Each question keeps at most the last 3 attempt results (oldest dropped
/// first) — enough to judge "recently missed" or "mastered" without the
/// store growing unbounded over a long history of retakes.
class QuestionStatsStore {
  static const _key = 'studlok_question_stats';
  static const _maxHistory = 3;

  Future<Map<String, List<bool>>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, Object?>;
    return decoded.map((key, value) => MapEntry(key, (value as List).cast<bool>()));
  }

  Future<void> recordAttempt(String questionId, bool correct) async {
    final all = await loadAll();
    final history = List<bool>.from(all[questionId] ?? const []);
    history.add(correct);
    if (history.length > _maxHistory) history.removeAt(0);
    all[questionId] = history;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(all));
  }

  /// ~3x draw weight when the most recent recorded attempt was wrong;
  /// neutral (1x) otherwise — mastered, correct-last-time, or never
  /// attempted are all treated the same way, so the pool keeps circulating
  /// rather than only ever re-drilling past misses.
  double weightFor(Map<String, List<bool>> stats, String questionId) {
    final history = stats[questionId];
    if (history == null || history.isEmpty) return 1.0;
    return history.last ? 1.0 : 3.0;
  }

  /// At least 2 correct within the last (up to 3) recorded attempts, and no
  /// more than 1 miss in that same window.
  bool isMastered(Map<String, List<bool>> stats, String questionId) {
    final history = stats[questionId];
    if (history == null) return false;
    final correct = history.where((result) => result).length;
    final missed = history.length - correct;
    return correct >= 2 && missed <= 1;
  }

  int masteredCount(QuestionPack pack, Map<String, List<bool>> stats) {
    return pack.questions.where((q) => isMastered(stats, q.id)).length;
  }

  /// Weighted random sample without replacement (Efraimidis-Spirakis
  /// A-Res): each item gets a key `u^(1/weight)` for a fresh uniform `u`;
  /// higher weight pushes the key closer to 1, so taking the top [count]
  /// keys favors higher-weight items while still leaving everything else a
  /// real chance — a simple approach, deliberately not a more elaborate
  /// scheduling algorithm.
  List<QuizQuestion> drawWeighted(
    List<QuizQuestion> pool,
    int count,
    Map<String, List<bool>> stats, {
    Random? random,
  }) {
    final rng = random ?? Random();
    if (pool.length <= count) return List<QuizQuestion>.from(pool);
    final keyed = pool.map((q) {
      final u = rng.nextDouble().clamp(1e-9, 1.0);
      final weight = weightFor(stats, q.id);
      final key = pow(u, 1 / weight).toDouble();
      return (key, q);
    }).toList();
    keyed.sort((a, b) => b.$1.compareTo(a.$1));
    return keyed.take(count).map((entry) => entry.$2).toList();
  }
}
