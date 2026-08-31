import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';

/// Tab 3 — placeholder pending its own design pass (streak heatmap + a
/// detail list underneath it, per the agreed plan). Deliberately honest
/// about being unfinished rather than silently shipping a bare screen.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudlokColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(StudlokSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.chartColumn, size: 40, color: StudlokColors.textSecondary),
                const SizedBox(height: StudlokSpacing.md),
                Text('PROGRESS', style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary)),
                const SizedBox(height: StudlokSpacing.sm),
                Text(
                  'Streak history and quiz stats — designed next.',
                  textAlign: TextAlign.center,
                  style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
