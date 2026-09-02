import 'package:shared_preferences/shared_preferences.dart';

/// The percentage of correct answers needed to pass a quiz and unlock
/// scroll time — user-adjustable (50-90%), local only. Defaults to the
/// app's original hardcoded 70%, so nobody's experience silently changes
/// until they actually touch the setting themselves.
class PassThresholdStore {
  static const _key = 'studlok_pass_threshold_percent';
  static const defaultPercent = 70;
  static const minPercent = 50;
  static const maxPercent = 90;

  Future<int> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_key);
    if (stored == null) return defaultPercent;
    return stored.clamp(minPercent, maxPercent);
  }

  Future<void> save(int percent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, percent.clamp(minPercent, maxPercent));
  }
}
