import 'package:shared_preferences/shared_preferences.dart';

/// The GPA goal set during onboarding (PersonalizationTargetContent) —
/// local only. Previously this lived only in the onboarding flow's own
/// ViewModel and was discarded the moment onboarding finished; this store
/// is what lets Home reference it afterward.
class GpaGoal {
  const GpaGoal({required this.currentGpa, required this.targetGpa});

  final double currentGpa;
  final double targetGpa;
}

class GpaGoalStore {
  static const _currentKey = 'studlok_gpa_current';
  static const _targetKey = 'studlok_gpa_target';

  Future<GpaGoal?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getDouble(_currentKey);
    final target = prefs.getDouble(_targetKey);
    if (current == null || target == null) return null;
    return GpaGoal(currentGpa: current, targetGpa: target);
  }

  Future<void> save(GpaGoal goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_currentKey, goal.currentGpa);
    await prefs.setDouble(_targetKey, goal.targetGpa);
  }
}
