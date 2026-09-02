import 'package:flutter/material.dart';

import '../purchases/paywall_gate.dart';
import '../purchases/purchases_config.dart';
import 'pack_picker_screen.dart';
import 'quiz_source_screen.dart';

/// The one path into a quiz session, used by both the Sessions tab's Quiz
/// card and the shield-dismiss notification's deep link — so tapping a
/// notification is a shortcut to this entry point, never a bypass of the
/// same daily-cap/paywall gate every other route to a quiz goes through.
/// Free users land on the pack picker directly; Pro users get
/// QuizSourceScreen's extra choice of their own AI-generated quizzes (its
/// own "Practice Bank" option leads to the same pack picker).
Future<void> openQuizFlow(BuildContext context) async {
  if (!await ensureSessionAllowed(context)) return;
  if (!context.mounted) return;
  final isPremium = await PurchasesConfig.isPremium();
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => isPremium ? const QuizSourceScreen() : const PackPickerScreen()),
  );
}
