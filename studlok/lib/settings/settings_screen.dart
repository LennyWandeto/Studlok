import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/account_screen.dart';
import '../debug/bridge_debug_page.dart';
import '../design/components/studlok_surface.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';
import '../native/studlok_native_bridge.dart';
import '../purchases/purchases_config.dart';
import '../quiz/course_material_upload_screen.dart';
import 'pass_threshold_store.dart';
import 'settings_view_model.dart';

const _privacyPolicyUrl = 'https://studlok.vercel.app/privacy';

/// Profile — tab 4. Grouped sections rather than one flat list, per the
/// design revamp: Account, Studlok, Subscription, About, and (debug builds
/// only) Debug tools.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _bridge = StudlokNativeBridge();
  late final SettingsViewModel _viewModel = SettingsViewModel()..refresh();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openAccount() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountScreen()));
    _viewModel.refresh();
  }

  Future<void> _openUpload() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CourseMaterialUploadScreen()));
  }

  Future<void> _manageLockedApps() async {
    try {
      final result = await _bridge.presentActivityPicker();
      if (!mounted) return;
      final total = result.applicationCount + result.categoryCount;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$total app${total == 1 ? '' : 's'} now locked.')),
      );
    } on StudlokNativeBridgeException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t update locked apps: ${e.message}')),
      );
    }
  }

  Future<void> _upgrade() async {
    await RevenueCatUI.presentPaywall();
    _viewModel.refresh();
  }

  Future<void> _restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      await PurchasesConfig.refreshCustomerInfo();
      if (!mounted) return;
      final isPremium = info.entitlements.active.containsKey(PurchasesConfig.premiumEntitlementId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isPremium ? 'Premium restored.' : 'No previous purchase found.')),
      );
      _viewModel.refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t restore purchases: $e')),
      );
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(_privacyPolicyUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open the Privacy Policy.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<SettingsViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: StudlokColors.background,
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(StudlokSpacing.xl),
                children: [
                  Text('PROFILE', style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary, fontSize: 28)),
                  const SizedBox(height: StudlokSpacing.xxl),
                  _SettingsGroup(
                    label: 'ACCOUNT',
                    children: [
                      _SettingsRow(
                        icon: LucideIcons.user,
                        title: 'Account',
                        subtitle: viewModel.userEmail ?? 'Not signed in',
                        subtitleColor: viewModel.userEmail != null ? StudlokColors.accent : StudlokColors.textSecondary,
                        onTap: _openAccount,
                      ),
                      if (viewModel.userEmail != null && viewModel.isPremium)
                        _SettingsRow(icon: LucideIcons.upload, title: 'Upload your notes', onTap: _openUpload),
                    ],
                  ),
                  const SizedBox(height: StudlokSpacing.xl),
                  _SettingsGroup(
                    label: 'STUDLOK',
                    children: [
                      _SettingsRow(
                        icon: LucideIcons.shield,
                        title: 'Manage locked apps',
                        subtitle: 'Change which apps and categories are shielded',
                        onTap: _manageLockedApps,
                      ),
                      _PassThresholdRow(
                        percent: viewModel.passThresholdPercent,
                        onChanged: viewModel.setPassThreshold,
                      ),
                    ],
                  ),
                  const SizedBox(height: StudlokSpacing.xl),
                  _SettingsGroup(
                    label: 'SUBSCRIPTION',
                    children: [
                      if (viewModel.loaded && viewModel.isPremium)
                        _SettingsRow(icon: LucideIcons.crown, title: 'Studlok Pro', subtitle: 'Active', subtitleColor: StudlokColors.accent)
                      else
                        _SettingsRow(
                          icon: LucideIcons.crown,
                          title: 'Upgrade to Premium',
                          subtitle: 'Unlimited Deep Work and Quiz sessions',
                          onTap: _upgrade,
                        ),
                      _SettingsRow(icon: LucideIcons.rotateCcw, title: 'Restore purchases', onTap: _restorePurchases),
                    ],
                  ),
                  const SizedBox(height: StudlokSpacing.xl),
                  _SettingsGroup(
                    label: 'ABOUT',
                    children: [
                      _SettingsRow(icon: LucideIcons.fileText, title: 'Privacy Policy', onTap: _openPrivacyPolicy),
                    ],
                  ),
                  // Debug tools call bridge.startSession() directly, bypassing
                  // the paywall/daily cap entirely — must never be reachable
                  // in a release build (App Store / TestFlight).
                  if (kDebugMode) ...[
                    const SizedBox(height: StudlokSpacing.xl),
                    _SettingsGroup(
                      label: 'DEBUG',
                      children: [
                        _SettingsRow(
                          icon: LucideIcons.bug,
                          title: 'Debug tools',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const BridgeDebugPage()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: StudlokColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.0),
        ),
        const SizedBox(height: StudlokSpacing.sm),
        StudlokSurface(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const Divider(height: 1, color: StudlokColors.background),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The one settings row that isn't a plain tappable ListTile — an inline
/// slider, matching onboarding's weekly-hours slider styling but condensed
/// to fit alongside the plain rows in the same group.
class _PassThresholdRow extends StatelessWidget {
  const _PassThresholdRow({required this.percent, required this.onChanged});

  final int percent;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.target, color: StudlokColors.accent),
              const SizedBox(width: StudlokSpacing.md),
              Expanded(
                child: Text('Pass threshold', style: StudlokTypography.bodyEmphasis.copyWith(color: StudlokColors.textPrimary, fontSize: 15)),
              ),
              Text('$percent%', style: StudlokTypography.bodyEmphasis.copyWith(color: StudlokColors.accent, fontSize: 15)),
            ],
          ),
          Text(
            'How many correct answers a quiz needs to unlock scroll time.',
            style: StudlokTypography.caption.copyWith(color: StudlokColors.textSecondary),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: StudlokColors.accent,
              inactiveTrackColor: StudlokColors.surfaceElevated,
              thumbColor: StudlokColors.accent,
              overlayColor: StudlokColors.accent.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: percent.toDouble(),
              min: PassThresholdStore.minPercent.toDouble(),
              max: PassThresholdStore.maxPercent.toDouble(),
              divisions: (PassThresholdStore.maxPercent - PassThresholdStore.minPercent) ~/ 5,
              onChanged: (value) => onChanged(value.round()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.title, this.subtitle, this.subtitleColor, this.onTap});

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: StudlokColors.accent),
      title: Text(title, style: StudlokTypography.bodyEmphasis.copyWith(color: StudlokColors.textPrimary, fontSize: 15)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: StudlokTypography.body.copyWith(color: subtitleColor ?? StudlokColors.textSecondary, fontSize: 13)),
      trailing: onTap == null ? null : const Icon(LucideIcons.chevronRight, size: 18, color: StudlokColors.textSecondary),
      onTap: onTap,
    );
  }
}
