import 'package:flutter/material.dart';

import '../design/studlok_colors.dart';
import '../design/studlok_typography.dart';

/// Shown while [AppRouterViewModel] decides where a cold launch lands. Picks
/// up visually where the native launch screen (same background, same mark)
/// leaves off, so there's no jarring handoff — then adds the one thing a
/// static launch image can't: a single deliberate entrance. No artificial
/// minimum delay is added; this is on screen for exactly as long as the
/// real routing decision takes, per Apple's own guidance against padded
/// fake-loading splash screens.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudlokColors.background,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(scale: 0.92 + (0.08 * t), child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/app_icon-removebg.png', width: 96, height: 96),
              const SizedBox(height: 20),
              Text(
                'STUDLOK',
                style: StudlokTypography.headline.copyWith(
                  color: StudlokColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
