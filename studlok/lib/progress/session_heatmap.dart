import 'package:flutter/material.dart';

import '../design/studlok_colors.dart';

/// A GitHub-style contribution grid — columns are weeks, rows are days
/// (Sunday-Saturday), ending on the current week. Cell intensity steps with
/// session count that day; days in the future (the tail end of the current
/// week) render invisible rather than as an empty day, since they haven't
/// happened yet.
class SessionHeatmap extends StatelessWidget {
  const SessionHeatmap({super.key, required this.dailyCounts, this.weeks = 12});

  final Map<DateTime, int> dailyCounts;
  final int weeks;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final daysSinceSunday = todayDay.weekday % 7; // Mon=1..Sat=6, Sun=7%7=0
    final gridEnd = todayDay.add(Duration(days: 6 - daysSinceSunday)); // Saturday of this week
    final gridStart = gridEnd.subtract(Duration(days: weeks * 7 - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var w = 0; w < weeks; w++)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var d = 0; d < 7; d++) _cell(gridStart.add(Duration(days: w * 7 + d)), todayDay),
            ],
          ),
      ],
    );
  }

  Widget _cell(DateTime day, DateTime today) {
    final isFuture = day.isAfter(today);
    final count = dailyCounts[day] ?? 0;
    final color = isFuture
        ? Colors.transparent
        : switch (count) {
            0 => StudlokColors.surface,
            1 => StudlokColors.accentMuted,
            2 => StudlokColors.accent.withValues(alpha: 0.55),
            _ => StudlokColors.accent,
          };
    return Container(
      width: 11,
      height: 11,
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
    );
  }
}
