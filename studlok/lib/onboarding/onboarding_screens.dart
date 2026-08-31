import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../design/components/studlok_button.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';
import '../native/studlok_native_bridge.dart';
import 'onboarding_view_model.dart';

/// Shown when authorization is denied/canceled. Family Controls has no
/// supported way to re-prompt after a denial — the only path forward is
/// Settings, so this screen sends the user there and lets them come back.
/// A genuine detour from the main flow (system Settings handoff), so it's
/// a real pushed route rather than another page in the PageView — but it
/// shares the same [OnboardingViewModel] instance, so a successful recheck
/// just pops back into the flow already one step further along.
class PermissionDeniedScreen extends StatefulWidget {
  const PermissionDeniedScreen({super.key, required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  State<PermissionDeniedScreen> createState() => _PermissionDeniedScreenState();
}

class _PermissionDeniedScreenState extends State<PermissionDeniedScreen> {
  final _bridge = StudlokNativeBridge();
  bool _checking = false;
  bool _stillNotApproved = false;

  Future<void> _openSettings() async {
    await _bridge.openSystemSettings();
  }

  Future<void> _recheck() async {
    setState(() {
      _checking = true;
      _stillNotApproved = false;
    });
    final approved = await widget.viewModel.recheckAuthorization();
    if (!mounted) return;
    if (approved) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _checking = false;
      _stillNotApproved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudlokColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(StudlokSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(LucideIcons.shieldOff, size: 64, color: StudlokColors.accent),
              const SizedBox(height: StudlokSpacing.xl),
              Text(
                "STUDLOK CAN'T WORK\nWITHOUT THIS.",
                textAlign: TextAlign.center,
                style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary),
              ),
              const SizedBox(height: StudlokSpacing.lg),
              Text(
                "Screen Time access is how Studlok actually locks and unlocks apps. "
                "Without it there's nothing to enforce. Turn it on in Settings, "
                'then come back here.',
                textAlign: TextAlign.center,
                style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
              ),
              if (_stillNotApproved) ...[
                const SizedBox(height: StudlokSpacing.lg),
                Text(
                  'Still not enabled — check Settings > Screen Time.',
                  textAlign: TextAlign.center,
                  style: StudlokTypography.caption.copyWith(color: StudlokColors.warning),
                ),
              ],
              const Spacer(),
              StudlokButton(label: 'OPEN SETTINGS', onPressed: _openSettings),
              const SizedBox(height: StudlokSpacing.sm),
              StudlokButton(
                label: "I'VE ENABLED IT — CONTINUE",
                tier: StudlokButtonTier.tertiary,
                onPressed: _checking ? null : _recheck,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
