import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../design/components/studlok_press_feedback.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';
import 'onboarding_view_model.dart';

/// Content only — no Scaffold, no CTA button. Each of these is one page in
/// OnboardingFlowScreen's PageView; the shared shell owns the progress
/// dots and the single, consistently-positioned CTA below.
class Welcome1Content extends StatelessWidget {
  const Welcome1Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StudlokSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'EARN YOUR\nSCROLL.',
            textAlign: TextAlign.center,
            style: StudlokTypography.display.copyWith(color: StudlokColors.accent, fontSize: 40),
          ),
          const SizedBox(height: StudlokSpacing.lg),
          Text(
            'Studlok locks the apps that eat your time until you finish a Deep '
            'Work session or a Quiz. No willpower required — just a real reason '
            'to put your phone down.',
            textAlign: TextAlign.center,
            style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

const _howItWorks = [
  ('01', 'Pick what to lock', 'Choose the apps or categories that eat your time. They lock immediately.'),
  ('02', 'Earn your way back in', 'Complete a Deep Work session or pass a Quiz — whichever fits the moment.'),
  ('03', 'Unlock, then re-lock', 'Your apps open for exactly as long as you earned, then lock again automatically.'),
];

class Welcome2Content extends StatelessWidget {
  const Welcome2Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StudlokSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HOW IT WORKS.', style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary)),
          const SizedBox(height: StudlokSpacing.xxl),
          for (final (number, title, body) in _howItWorks) ...[
            _StepRow(number: number, title: title, body: body),
            const SizedBox(height: StudlokSpacing.xl),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.title, required this.body});

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: StudlokTypography.headline.copyWith(color: StudlokColors.surfaceElevated, fontSize: 28),
        ),
        const SizedBox(width: StudlokSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: StudlokTypography.bodyEmphasis.copyWith(color: StudlokColors.textPrimary)),
              const SizedBox(height: StudlokSpacing.xs),
              Text(body, style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

const _focusOptions = ['Exams', 'Classes', 'Research', 'Personal projects', 'General focus'];
const _hourOptions = [1, 2, 3, 4];

class PersonalizationContent extends StatelessWidget {
  const PersonalizationContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: StudlokSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: StudlokSpacing.xl),
          Text('MAKE IT YOURS.', style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary)),
          const SizedBox(height: StudlokSpacing.xxxl),
          Text(
            'What are you locking in for?',
            style: StudlokTypography.subhead.copyWith(color: StudlokColors.textPrimary, fontSize: 18),
          ),
          const SizedBox(height: StudlokSpacing.md),
          Wrap(
            spacing: StudlokSpacing.sm,
            runSpacing: StudlokSpacing.sm,
            children: [
              for (final option in _focusOptions)
                _Chip(label: option, selected: viewModel.focus == option, onTap: () => viewModel.selectFocus(option)),
            ],
          ),
          const SizedBox(height: StudlokSpacing.xxxl),
          Text(
            'How many hours a day?',
            style: StudlokTypography.subhead.copyWith(color: StudlokColors.textPrimary, fontSize: 18),
          ),
          const SizedBox(height: StudlokSpacing.md),
          Wrap(
            spacing: StudlokSpacing.sm,
            runSpacing: StudlokSpacing.sm,
            children: [
              for (final hours in _hourOptions)
                _Chip(
                  label: hours == 4 ? '4+ hrs' : '$hours hr${hours == 1 ? '' : 's'}',
                  selected: viewModel.dailyGoalHours == hours,
                  onTap: () => viewModel.selectHours(hours),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StudlokPressFeedback(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? StudlokColors.accent : StudlokColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? StudlokColors.accent : Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.black : StudlokColors.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class PermissionPrimingContent extends StatelessWidget {
  const PermissionPrimingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StudlokSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.lockKeyhole, size: 64, color: StudlokColors.accent),
          const SizedBox(height: StudlokSpacing.xl),
          Text(
            'EARN YOUR SCROLL.',
            textAlign: TextAlign.center,
            style: StudlokTypography.headline.copyWith(color: StudlokColors.accent),
          ),
          const SizedBox(height: StudlokSpacing.lg),
          Text(
            'Studlok locks the apps that eat your time — Instagram, TikTok, '
            'whatever pulls you in — until you finish a Deep Work session or a '
            'Quiz. To do that, it needs Screen Time access from Apple. This is '
            'what actually applies and lifts the lock; Studlok never sees what '
            'you do inside those apps.',
            textAlign: TextAlign.center,
            style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class AppPickerContent extends StatelessWidget {
  const AppPickerContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StudlokSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.layoutGrid, size: 64, color: StudlokColors.accent),
          const SizedBox(height: StudlokSpacing.xl),
          Text(
            'PICK WHAT TO LOCK.',
            textAlign: TextAlign.center,
            style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary),
          ),
          const SizedBox(height: StudlokSpacing.lg),
          Text(
            "Choose the apps or categories that eat your time. They'll lock "
            'immediately — you unlock them by completing a Deep Work session '
            'or a Quiz.',
            textAlign: TextAlign.center,
            style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
          ),
          if (viewModel.error != null) ...[
            const SizedBox(height: StudlokSpacing.lg),
            Text(viewModel.error!, textAlign: TextAlign.center, style: const TextStyle(color: StudlokColors.warning)),
          ],
        ],
      ),
    );
  }
}

class ConfirmedContent extends StatelessWidget {
  const ConfirmedContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();
    final total = viewModel.applicationCount + viewModel.categoryCount;
    final label = total == 1 ? '1 APP LOCKED.' : '$total APPS LOCKED.';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StudlokSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.lockKeyhole600, size: 64, color: StudlokColors.accent),
          const SizedBox(height: StudlokSpacing.xl),
          Text(
            label,
            textAlign: TextAlign.center,
            style: StudlokTypography.display.copyWith(color: StudlokColors.textPrimary, fontSize: 36),
          ),
          const SizedBox(height: StudlokSpacing.sm),
          Text(
            'EARN YOUR SCROLL.',
            textAlign: TextAlign.center,
            style: StudlokTypography.subhead.copyWith(color: StudlokColors.accent),
          ),
          const SizedBox(height: StudlokSpacing.lg),
          Text(
            'Complete a session in Studlok to unlock them.',
            textAlign: TextAlign.center,
            style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
