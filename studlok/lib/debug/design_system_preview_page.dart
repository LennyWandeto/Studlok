import 'package:flutter/material.dart';

import '../design/components/studlok_button.dart';
import '../design/components/studlok_surface.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';

/// Debug-only: a literal look at the Part 1 design-system foundation
/// (colors, type scale, button tiers, surface tiers) before any real
/// screen adopts it. Reachable from Settings → Debug tools, same as every
/// other debug-only surface — never ships in release.
class DesignSystemPreviewPage extends StatelessWidget {
  const DesignSystemPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DESIGN SYSTEM')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(StudlokSpacing.xl),
          children: [
            _sectionLabel('TYPOGRAPHY'),
            const SizedBox(height: StudlokSpacing.md),
            Text('Display 48 / Bold', style: StudlokTypography.display.copyWith(color: StudlokColors.textPrimary)),
            const SizedBox(height: StudlokSpacing.sm),
            Text('Headline 32 / Semibold', style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary)),
            const SizedBox(height: StudlokSpacing.sm),
            Text('Subhead 22 / Semibold', style: StudlokTypography.subhead.copyWith(color: StudlokColors.textPrimary)),
            const SizedBox(height: StudlokSpacing.sm),
            Text(
              'Body 16 — the quick brown fox jumps over the lazy dog.',
              style: StudlokTypography.body.copyWith(color: StudlokColors.textPrimary),
            ),
            Text(
              'Caption 13, secondary color',
              style: StudlokTypography.caption.copyWith(color: StudlokColors.textSecondary),
            ),
            const SizedBox(height: StudlokSpacing.xxl),
            _sectionLabel('SURFACES (3 elevation tiers)'),
            const SizedBox(height: StudlokSpacing.md),
            _SwatchRow(color: StudlokColors.background, label: 'background (base)'),
            const SizedBox(height: StudlokSpacing.sm),
            StudlokSurface(
              child: const Text('surface (card)', style: TextStyle(color: StudlokColors.textPrimary)),
            ),
            const SizedBox(height: StudlokSpacing.sm),
            StudlokSurface(
              tier: StudlokSurfaceTier.elevated,
              child: const Text('surfaceElevated (modal/sheet)', style: TextStyle(color: StudlokColors.textPrimary)),
            ),
            const SizedBox(height: StudlokSpacing.xxl),
            _sectionLabel('ACCENT + SEMANTIC'),
            const SizedBox(height: StudlokSpacing.md),
            _SwatchRow(color: StudlokColors.accent, label: 'accent (primary actions)'),
            const SizedBox(height: StudlokSpacing.sm),
            _SwatchRow(color: StudlokColors.accentBright, label: 'accentBright (pressed/active)'),
            const SizedBox(height: StudlokSpacing.sm),
            _SwatchRow(color: StudlokColors.accentMuted, label: 'accentMuted (borders, solid)'),
            const SizedBox(height: StudlokSpacing.sm),
            _SwatchRow(color: StudlokColors.warning, label: 'warning (errors, distinct from accent)'),
            const SizedBox(height: StudlokSpacing.xxl),
            _sectionLabel('BUTTONS (press for scale + haptic)'),
            const SizedBox(height: StudlokSpacing.md),
            StudlokButton(label: 'PRIMARY ACTION', onPressed: () {}),
            const SizedBox(height: StudlokSpacing.sm),
            StudlokButton(label: 'Secondary action', tier: StudlokButtonTier.secondary, onPressed: () {}),
            const SizedBox(height: StudlokSpacing.sm),
            StudlokButton(label: 'Tertiary action', tier: StudlokButtonTier.tertiary, onPressed: () {}),
            const SizedBox(height: StudlokSpacing.sm),
            const StudlokButton(label: 'Disabled state', onPressed: null),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: StudlokColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1.1, fontSize: 13),
    );
  }
}

class _SwatchRow extends StatelessWidget {
  const _SwatchRow({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8))),
        const SizedBox(width: StudlokSpacing.md),
        Expanded(child: Text(label, style: const TextStyle(color: StudlokColors.textPrimary))),
      ],
    );
  }
}
