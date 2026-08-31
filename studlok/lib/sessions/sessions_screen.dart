import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../deep_work/deep_work_screen.dart';
import '../design/components/studlok_press_feedback.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_radius.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';
import '../purchases/paywall_gate.dart';
import '../purchases/purchases_config.dart';
import '../quiz/quiz_screen.dart';
import '../quiz/quiz_source_screen.dart';

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

  Future<void> _openQuiz() async {
    if (!await ensureSessionAllowed(context)) return;
    if (!mounted) return;
    final isPremium = await PurchasesConfig.isPremium();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => isPremium ? const QuizSourceScreen() : const QuizScreen()),
    );
  }

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
              _SessionPathCard(
                icon: LucideIcons.zap,
                title: 'DEEP WORK',
                subtitle: 'A focused, timed block. Pick a duration and lock in.',
                onTap: _openDeepWork,
              ),
              const SizedBox(height: StudlokSpacing.lg),
              _SessionPathCard(
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

class _SessionPathCard extends StatelessWidget {
  const _SessionPathCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

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
