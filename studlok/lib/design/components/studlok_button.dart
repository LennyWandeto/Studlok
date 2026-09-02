import 'package:flutter/material.dart';

import '../studlok_colors.dart';
import '../studlok_radius.dart';
import 'studlok_press_feedback.dart';

enum StudlokButtonTier { primary, secondary, tertiary }

/// The app's three button tiers — primary (filled accent, dark text),
/// secondary (accent outline), tertiary (text-only) — sharing one press
/// treatment via [StudlokPressFeedback]. Exactly one [primary] button
/// should be visible per screen at a time; that's a call-site discipline
/// this widget can't enforce on its own, only make easy to follow.
class StudlokButton extends StatelessWidget {
  const StudlokButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tier = StudlokButtonTier.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final StudlokButtonTier tier;
  final IconData? icon;

  bool get _disabled => onPressed == null;

  @override
  Widget build(BuildContext context) {
    return StudlokPressFeedback(
      onTap: onPressed,
      child: switch (tier) {
        StudlokButtonTier.primary => _filled(),
        StudlokButtonTier.secondary => _outlined(),
        StudlokButtonTier.tertiary => _text(),
      },
    );
  }

  Widget _content(Color color) {
    final style = TextStyle(
      color: color,
      fontFamily: 'ClashDisplay',
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: 0.4,
    );
    if (icon == null) return Text(label, style: style);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(label, style: style),
      ],
    );
  }

  Widget _filled() {
    final background = _disabled ? StudlokColors.accent.withValues(alpha: 0.4) : StudlokColors.accent;
    final foreground = _disabled ? Colors.black.withValues(alpha: 0.6) : Colors.black;
    return Container(
      width: double.infinity,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, borderRadius: StudlokRadius.buttonRadius),
      child: _content(foreground),
    );
  }

  Widget _outlined() {
    final color = _disabled ? StudlokColors.accent.withValues(alpha: 0.4) : StudlokColors.accent;
    return Container(
      width: double.infinity,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: StudlokRadius.buttonRadius,
      ),
      child: _content(color),
    );
  }

  Widget _text() {
    final color = _disabled ? StudlokColors.accent.withValues(alpha: 0.4) : StudlokColors.accent;
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: _content(color),
    );
  }
}
