import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../deep_work/deep_work_screen.dart';
import '../design/components/studlok_option_card.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';
import '../purchases/paywall_gate.dart';
import '../quiz/quiz_launch.dart';

/// Tab 2 — the entry point for starting a session. Deep Work and Quiz are
/// deliberately two distinct cards (different icon, different framing,
/// different color badge), not two identical buttons with different text.
/// Carries over the daily-cap/paywall gate that used to live on Home.
class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  Future<void> _openDeepWork() async {
    if (!await ensureSessionAllowed(context)) return;
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeepWorkScreen()));
  }

  Future<void> _openQuiz() => openQuizFlow(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudlokColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(StudlokSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: StudlokSpacing.lg),
              Text('START A SESSION.', style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary)),
              const SizedBox(height: StudlokSpacing.sm),
              Text(
                'Finish either to earn scroll time.',
                style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
              ),
              const SizedBox(height: StudlokSpacing.xxl),
              StudlokOptionCard(
                icon: LucideIcons.zap,
                title: 'DEEP WORK',
                subtitle: 'A focused, timed block. Pick a duration and lock in.',
                onTap: _openDeepWork,
              ),
              const SizedBox(height: StudlokSpacing.lg),
              StudlokOptionCard(
                icon: LucideIcons.bookOpen,
                title: 'QUIZ',
                subtitle: 'Answer a set of questions to earn your time back.',
                onTap: _openQuiz,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
