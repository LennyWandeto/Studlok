import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The app's one standard tap-feedback: a subtle scale-down (100-150ms)
/// plus haptic feedback. [StudlokButton] wraps every tier in this so every
/// tappable action feels the same, rather than each screen inventing its
/// own press treatment.
class StudlokPressFeedback extends StatefulWidget {
  const StudlokPressFeedback({super.key, required this.child, required this.onTap, this.haptic});

  final Widget child;
  final VoidCallback? onTap;

  /// Defaults to [HapticFeedback.lightImpact]. Pass a heavier impact for
  /// higher-stakes actions (starting a session, completing a quiz).
  final Future<void> Function()? haptic;

  @override
  State<StudlokPressFeedback> createState() => _StudlokPressFeedbackState();
}

class _StudlokPressFeedbackState extends State<StudlokPressFeedback> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap == null
          ? null
          : () {
              (widget.haptic ?? HapticFeedback.lightImpact)();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
