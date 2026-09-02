import 'package:shared_preferences/shared_preferences.dart';

/// The fixed vocabulary offered as quick-pick chips on the subject-focus
/// onboarding step. Deliberately a closed set rather than free text for
/// everyone — it's what lets the first post-onboarding quiz reliably match
/// a hardcoded content pack later, instead of guessing at arbitrary text.
enum SubjectCategory { math, science, history, english, computerScience }

extension SubjectCategoryLabel on SubjectCategory {
  String get label => switch (this) {
        SubjectCategory.math => 'Math',
        SubjectCategory.science => 'Science',
        SubjectCategory.history => 'History',
        SubjectCategory.english => 'English',
        SubjectCategory.computerScience => 'Computer Science',
      };
}

/// What a user told onboarding they're studying for — either one of the
/// fixed chips, or their own free text (the "Other" case).
class SubjectFocus {
  const SubjectFocus({this.category, this.customText});

  final SubjectCategory? category;
  final String? customText;

  /// The label to weave into copy (the Reveal screen, eventually the Home
  /// dashboard). Returns null when there's nothing clean to reference —
  /// empty/missing text, or something too long to read naturally inside a
  /// short sentence — so callers know to fall back to generic phrasing
  /// rather than print something awkward.
  String? get displayLabel {
    if (category != null) return category!.label;
    final text = customText?.trim();
    if (text == null || text.isEmpty || text.length > 30) return null;
    return text;
  }
}

/// Local-only persistence for [SubjectFocus] — no backend involved. Read by
/// [OnboardingViewModel] to decide whether to skip the subject-focus step
/// for a returning, partially-onboarded user, and (later) by quiz launch to
/// prioritize a matching content pack.
class SubjectFocusStore {
  static const _categoryKey = 'studlok_subject_category';
  static const _customTextKey = 'studlok_subject_custom_text';

  Future<SubjectFocus?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final categoryName = prefs.getString(_categoryKey);
    final customText = prefs.getString(_customTextKey);
    if (categoryName == null && (customText == null || customText.isEmpty)) return null;
    return SubjectFocus(category: _categoryFromName(categoryName), customText: customText);
  }

  Future<void> saveCategory(SubjectCategory category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoryKey, category.name);
    await prefs.remove(_customTextKey);
  }

  Future<void> saveCustomText(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_categoryKey);
    await prefs.setString(_customTextKey, text);
  }

  SubjectCategory? _categoryFromName(String? name) {
    if (name == null) return null;
    for (final category in SubjectCategory.values) {
      if (category.name == name) return category;
    }
    return null;
  }
}
