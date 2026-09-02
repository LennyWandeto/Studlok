import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../design/components/studlok_button.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';
import '../history/protocol_card.dart';
import '../native/studlok_native_bridge.dart';
import 'home_view_model.dart';

/// Dashboard — tab 1 of the main shell. Pure View: all state comes from
/// [HomeViewModel]. [onStartSession] switches to the Sessions tab; Home
/// itself never navigates directly to a session type.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onStartSession});

  final VoidCallback onStartSession;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel = HomeViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          final state = viewModel.state;
          return Scaffold(
            backgroundColor: StudlokColors.background,
            body: SafeArea(
              child: state == null
                  ? const Center(child: CircularProgressIndicator(color: StudlokColors.accent))
                  : RefreshIndicator(
                      onRefresh: viewModel.refresh,
                      color: StudlokColors.accent,
                      backgroundColor: StudlokColors.surface,
                      child: ListView(
                        padding: const EdgeInsets.all(StudlokSpacing.xl),
                        children: [
                          Text(
                            'STUDLOK',
                            style: TextStyle(color: StudlokColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 2, fontSize: 13),
                          ),
                          const SizedBox(height: StudlokSpacing.xxl),
                          _HeroNumbers(state: state),
                          const SizedBox(height: StudlokSpacing.xxl),
                          _DailyGoalBar(state: state),
                          const SizedBox(height: StudlokSpacing.xxl),
                          StudlokButton(label: 'START NEW SESSION', onPressed: widget.onStartSession),
                          const SizedBox(height: StudlokSpacing.xxxl),
                          Text(
                            'RECENT PROTOCOLS',
                            style: const TextStyle(color: StudlokColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: 1.1, fontSize: 13),
                          ),
                          const SizedBox(height: StudlokSpacing.md),
                          if (viewModel.history.isEmpty)
                            const EmptyProtocolHistory(message: 'Start a session below to earn your first minutes.')
                          else
                            for (final entry in viewModel.history) ProtocolCard(entry: entry),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroNumbers extends StatelessWidget {
  const _HeroNumbers({required this.state});

  final StudlokSharedState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _HeroStat(
            icon: LucideIcons.flame,
            label: 'STREAK',
            value: '${state.currentStreak}',
            unit: state.currentStreak == 1 ? 'day' : 'days',
          ),
        ),
        const SizedBox(width: StudlokSpacing.lg),
        Expanded(
          child: _HeroStat(icon: LucideIcons.zap, label: 'SCROLL BANK', value: '${state.scrollBankMinutes}', unit: 'min'),
        ),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.icon, required this.label, required this.value, required this.unit});

  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: StudlokColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: StudlokColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.0),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: StudlokTypography.display.copyWith(color: StudlokColors.accent, fontSize: 40)),
            const SizedBox(width: 4),
            Text(unit, style: StudlokTypography.bodyEmphasis.copyWith(color: StudlokColors.textSecondary, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}

class _DailyGoalBar extends StatelessWidget {
  const _DailyGoalBar({required this.state});

  final StudlokSharedState state;

  @override
  Widget build(BuildContext context) {
    final goal = state.dailyGoalMinutes;
    final progress = state.dailyProgressMinutes;
    final fraction = goal > 0 ? (progress / goal).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'DAILY GOAL',
              style: TextStyle(color: StudlokColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.0),
            ),
            Text(
              goal > 0 ? '$progress / $goal min' : 'Not set',
              style: StudlokTypography.body.copyWith(color: StudlokColors.textPrimary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: StudlokSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: StudlokColors.surface,
            valueColor: const AlwaysStoppedAnimation(StudlokColors.accent),
          ),
        ),
      ],
    );
  }
}

