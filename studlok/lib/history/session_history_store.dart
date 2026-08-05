import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One completed session, logged locally right after a successful
/// bridge.startSession call. This is v1's entire "Recent Protocols" data
/// source — no backend, just a capped local log (Phase 9).
class SessionHistoryEntry {
  const SessionHistoryEntry({
    required this.type,
    required this.label,
    required this.minutesEarned,
    required this.timestamp,
  });

  /// 'deepWork' or 'quiz' — mirrors SessionType's wire values.
  final String type;
  final String label;
  final int minutesEarned;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
        'type': type,
        'label': label,
        'minutesEarned': minutesEarned,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SessionHistoryEntry.fromJson(Map<String, Object?> json) => SessionHistoryEntry(
        type: json['type'] as String,
        label: json['label'] as String,
        minutesEarned: json['minutesEarned'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class SessionHistoryStore {
  static const _key = 'studlok_session_history';
  static const _maxEntries = 20;

  Future<List<SessionHistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    return raw
        .map((e) => SessionHistoryEntry.fromJson(jsonDecode(e) as Map<String, Object?>))
        .toList();
  }

  /// Newest first, capped at [_maxEntries] so this never grows unbounded.
  Future<void> addEntry(SessionHistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    final updated = [jsonEncode(entry.toJson()), ...raw].take(_maxEntries).toList();
    await prefs.setStringList(_key, updated);
  }
}
