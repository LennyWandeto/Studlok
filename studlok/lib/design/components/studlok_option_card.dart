import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../studlok_colors.dart';
import '../studlok_radius.dart';
import '../studlok_spacing.dart';
import '../studlok_typography.dart';
import 'studlok_press_feedback.dart';

/// A tappable "pick one of these paths" card — icon badge, title, subtitle,
/// chevron. Originated on the Sessions screen (Deep Work vs. Quiz) and
/// reused anywhere else the app presents a distinct-paths choice (the
/// practice-bank-vs-your-quizzes picker), so those decisions all look and
/// feel like the same kind of choice.
class StudlokOptionCard extends StatelessWidget {
  const StudlokOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StudlokPressFeedback(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(StudlokSpacing.lg),
        decoration: BoxDecoration(
          color: StudlokColors.surface,
          borderRadius: BorderRadius.circular(StudlokRadius.card),
          border: Border.all(color: StudlokColors.accentMuted, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: StudlokColors.accent, borderRadius: BorderRadius.circular(StudlokRadius.button)),
              child: Icon(icon, color: Colors.black, size: 26),
            ),
            const SizedBox(width: StudlokSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: StudlokTypography.subhead.copyWith(color: StudlokColors.textPrimary, fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: StudlokColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
