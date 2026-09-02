import '../onboarding/subject_focus_store.dart';
import 'quiz_bank.dart';

/// Maps an onboarding subject chip to the content pack that best fits it.
/// Only the fixed chips get a match — free text (the "Other" case) has no
/// reliable mapping, so it falls through to null and the default pack order
/// (General Knowledge last, as always) stands.
String? matchingPackId(SubjectFocus? focus) {
  final category = focus?.category;
  if (category == null) return null;
  return switch (category) {
    SubjectCategory.computerScience => csCodingPack.id,
    SubjectCategory.math ||
    SubjectCategory.science ||
    SubjectCategory.history ||
    SubjectCategory.english =>
      testPrepPack.id,
  };
}

/// [studlokQuestionPacks] with the subject-matched pack (if any) moved to
/// the front — "prioritized" here means shown first, not auto-launched;
/// the user still picks. General Knowledge is already last in the default
/// order and never matches a chip, so it stays the fallback either way.
List<QuestionPack> orderedPacksFor(SubjectFocus? focus) {
  final matchedId = matchingPackId(focus);
  if (matchedId == null) return studlokQuestionPacks;
  final matched = studlokQuestionPacks.where((p) => p.id == matchedId);
  final rest = studlokQuestionPacks.where((p) => p.id != matchedId);
  return [...matched, ...rest];
}
