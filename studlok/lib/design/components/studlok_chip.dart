import 'package:flutter/material.dart';

import '../studlok_colors.dart';
import 'studlok_press_feedback.dart';

/// A single tappable choice pill — duration pickers, quick-select options.
/// Shares the app's one press-feedback treatment.
class StudlokChip extends StatelessWidget {
  const StudlokChip({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StudlokPressFeedback(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? StudlokColors.accent : StudlokColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? StudlokColors.accent : Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.black : StudlokColors.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
