import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../design/components/studlok_surface.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';
import 'session_history_store.dart';

/// A single completed-session row — shared by Home's "Recent Protocols" and
/// the Progress tab's full history list, so the two never visually drift.
class ProtocolCard extends StatelessWidget {
  const ProtocolCard({super.key, required this.entry});

  final SessionHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final isQuiz = entry.type == 'quiz';
    return Padding(
      padding: const EdgeInsets.only(bottom: StudlokSpacing.sm),
      child: StudlokSurface(
        padding: const EdgeInsets.all(StudlokSpacing.md),
        child: Row(
          children: [
            Icon(isQuiz ? LucideIcons.bookOpen : LucideIcons.zap, color: StudlokColors.accent),
            const SizedBox(width: StudlokSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.label, style: StudlokTypography.bodyEmphasis.copyWith(color: StudlokColors.textPrimary, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(_formatTimestamp(entry.timestamp), style: StudlokTypography.caption.copyWith(color: StudlokColors.textSecondary)),
                ],
              ),
            ),
            Text('+${entry.minutesEarned}m', style: StudlokTypography.bodyEmphasis.copyWith(color: StudlokColors.accent, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Shared empty state for anywhere a protocol list can be empty.
class EmptyProtocolHistory extends StatelessWidget {
  const EmptyProtocolHistory({super.key, this.message = 'Start a session to see it here.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return StudlokSurface(
      padding: const EdgeInsets.all(StudlokSpacing.xl),
      child: Column(
        children: [
          const Icon(LucideIcons.target, size: 32, color: StudlokColors.textSecondary),
          const SizedBox(height: StudlokSpacing.md),
          Text('Nothing locked in yet', style: StudlokTypography.bodyEmphasis.copyWith(color: StudlokColors.textPrimary)),
          const SizedBox(height: StudlokSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
