import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../design/components/studlok_press_feedback.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';
import 'onboarding_view_model.dart';
import 'widgets/curved_gpa_picker.dart';

/// Content only — no Scaffold, no CTA button. Each of these is one page in
/// OnboardingFlowScreen's PageView; the shared shell owns the progress
/// dots and the single, consistently-positioned CTA below.
///
/// Copy discipline: every screen leads with what it wants in the headline,
/// not buried in the body. Body text stays short — a permission screen in
/// particular should be legible in a glance, not read like a paragraph.
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
            'Distracting apps lock. Finish a session, earn them back.',
            textAlign: TextAlign.center,
            style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

const _howItWorks = [
  ('01', 'Pick what to lock', 'Choose the apps that eat your time.'),
  ('02', 'Earn your way back in', 'Finish a Deep Work session or a Quiz.'),
  ('03', 'Unlock, then re-lock', 'Apps open, then lock again automatically.'),
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

class PersonalizationBasicsContent extends StatelessWidget {
  const PersonalizationBasicsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: StudlokSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: StudlokSpacing.xl),
          Text('WHERE ARE YOU\nSTARTING FROM?', style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary)),
          const SizedBox(height: StudlokSpacing.xxl),
          _GpaStepper(label: 'Current GPA', value: viewModel.currentGpa, onChanged: viewModel.setCurrentGpa),
          const SizedBox(height: StudlokSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hours a week you want to lock in',
                style: StudlokTypography.subhead.copyWith(color: StudlokColors.textPrimary, fontSize: 16),
              ),
              Text(
                '${viewModel.weeklyStudyHours.round()}h',
                style: StudlokTypography.headline.copyWith(color: StudlokColors.accent, fontSize: 22),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: StudlokColors.accent,
              inactiveTrackColor: StudlokColors.surface,
              thumbColor: StudlokColors.accent,
              overlayColor: StudlokColors.accent.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: viewModel.weeklyStudyHours,
              min: 1,
              max: 40,
              divisions: 39,
              onChanged: viewModel.setWeeklyStudyHours,
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalizationTargetContent extends StatelessWidget {
  const PersonalizationTargetContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: StudlokSpacing.xl),
          child: Column(
            children: [
              Text('DREAM BIG.', style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary)),
              const SizedBox(height: StudlokSpacing.sm),
              Text(
                'What GPA are you chasing?',
                textAlign: TextAlign.center,
                style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
              ),
            ],
          ),
        ),
        // Unpadded — the ruler wants the full screen width, not the
        // screen's usual text margins.
        CurvedGpaPicker(
          min: viewModel.currentGpa,
          value: viewModel.targetGpa,
          onChanged: viewModel.setTargetGpa,
        ),
      ],
    );
  }
}

class PersonalizationRevealContent extends StatelessWidget {
  const PersonalizationRevealContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();
    final gap = (viewModel.targetGpa - viewModel.currentGpa).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StudlokSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.sparkles, size: 56, color: StudlokColors.accent),
          const SizedBox(height: StudlokSpacing.xl),
          Text(
            'GAINING +$gap IS NOT\nUNREALISTIC AT ALL.',
            textAlign: TextAlign.center,
            style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary),
          ),
          const SizedBox(height: StudlokSpacing.lg),
          Text(
            'Show up daily and let Studlok hold the line.',
            textAlign: TextAlign.center,
            style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _GpaStepper extends StatelessWidget {
  const _GpaStepper({required this.label, required this.value, required this.onChanged});

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  static const _min = 0.0;
  static const _max = 4.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: StudlokTypography.subhead.copyWith(color: StudlokColors.textPrimary, fontSize: 18)),
        ),
        _StepperButton(icon: Icons.remove, onTap: value > _min ? () => onChanged(value - 0.1) : null),
        SizedBox(
          width: 64,
          child: Text(
            value.toStringAsFixed(1),
            textAlign: TextAlign.center,
            style: StudlokTypography.headline.copyWith(color: StudlokColors.accent, fontSize: 26),
          ),
        ),
        _StepperButton(icon: Icons.add, onTap: value < _max ? () => onChanged(value + 0.1) : null),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return StudlokPressFeedback(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: StudlokColors.surface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, size: 18, color: disabled ? StudlokColors.textSecondary.withValues(alpha: 0.4) : StudlokColors.textPrimary),
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
            'ALLOW SCREEN TIME\nACCESS.',
            textAlign: TextAlign.center,
            style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary),
          ),
          const SizedBox(height: StudlokSpacing.lg),
          Text(
            "This is what lets Studlok lock and unlock apps. It never sees "
            'what you do inside them.',
            textAlign: TextAlign.center,
            style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class NotificationPrimingContent extends StatelessWidget {
  const NotificationPrimingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StudlokSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.bell, size: 64, color: StudlokColors.accent),
          const SizedBox(height: StudlokSpacing.xl),
          Text(
            'ALLOW\nNOTIFICATIONS.',
            textAlign: TextAlign.center,
            style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary),
          ),
          const SizedBox(height: StudlokSpacing.lg),
          Text(
            "We'll let you know when a session ends and your apps re-lock.",
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
            'Choose the apps that eat your time. They lock immediately.',
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
            'Finish a session to unlock them.',
            textAlign: TextAlign.center,
            style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
