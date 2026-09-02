import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../design/components/studlok_surface.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';
import '../history/protocol_card.dart';
import 'progress_view_model.dart';
import 'session_heatmap.dart';

/// Tab 3 — a glanceable heatmap of daily consistency up top (the discipline
/// view Streak already promises, made visible), then the full session/quiz
/// history underneath for detail the heatmap alone can't carry.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final ProgressViewModel _viewModel = ProgressViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ProgressViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: StudlokColors.background,
            body: SafeArea(
              child: !viewModel.loaded
                  ? const Center(child: CircularProgressIndicator(color: StudlokColors.accent))
                  : RefreshIndicator(
                      onRefresh: viewModel.refresh,
                      color: StudlokColors.accent,
                      backgroundColor: StudlokColors.surface,
                      child: ListView(
                        padding: const EdgeInsets.all(StudlokSpacing.xl),
                        children: [
                          Text(
                            'PROGRESS',
                            style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary, fontSize: 28),
                          ),
                          const SizedBox(height: StudlokSpacing.xxl),
                          Row(
                            children: [
                              const Icon(LucideIcons.flame, size: 14, color: StudlokColors.textSecondary),
                              const SizedBox(width: 6),
                              const Text(
                                'CURRENT STREAK',
                                style: TextStyle(color: StudlokColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.0),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${viewModel.currentStreak}',
                                style: StudlokTypography.display.copyWith(color: StudlokColors.accent, fontSize: 44),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                viewModel.currentStreak == 1 ? 'day' : 'days',
                                style: StudlokTypography.bodyEmphasis.copyWith(color: StudlokColors.textSecondary, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: StudlokSpacing.xxl),
                          SessionHeatmap(dailyCounts: viewModel.dailyCounts),
                          const SizedBox(height: StudlokSpacing.xxl),
                          Row(
                            children: [
                              Expanded(child: _StatTile(label: 'SESSIONS', value: '${viewModel.totalSessions}')),
                              const SizedBox(width: StudlokSpacing.md),
                              Expanded(child: _StatTile(label: 'MINUTES EARNED', value: '${viewModel.totalMinutesEarned}')),
                            ],
                          ),
                          const SizedBox(height: StudlokSpacing.xxxl),
                          const Text(
                            'PACK MASTERY',
                            style: TextStyle(color: StudlokColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: 1.1, fontSize: 13),
                          ),
                          const SizedBox(height: StudlokSpacing.md),
                          for (final (pack, mastered) in viewModel.packMastery) ...[
                            _PackMasteryRow(name: pack.name, mastered: mastered, total: pack.questions.length),
                            const SizedBox(height: StudlokSpacing.sm),
                          ],
                          const SizedBox(height: StudlokSpacing.xxxl),
                          const Text(
                            'ALL PROTOCOLS',
                            style: TextStyle(color: StudlokColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: 1.1, fontSize: 13),
                          ),
                          const SizedBox(height: StudlokSpacing.md),
                          if (viewModel.history.isEmpty)
                            const EmptyProtocolHistory()
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

class _PackMasteryRow extends StatelessWidget {
  const _PackMasteryRow({required this.name, required this.mastered, required this.total});

  final String name;
  final int mastered;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : mastered / total;
    return StudlokSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: StudlokTypography.bodyEmphasis.copyWith(color: StudlokColors.textPrimary, fontSize: 14)),
              Text(
                '$mastered/$total mastered',
                style: StudlokTypography.caption.copyWith(color: StudlokColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: StudlokSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: StudlokColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation(StudlokColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return StudlokSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: StudlokColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.0),
          ),
          const SizedBox(height: 4),
          Text(value, style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary, fontSize: 24)),
        ],
      ),
    );
  }
}
