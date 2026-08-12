import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../debug/bridge_debug_page.dart';
import '../native/studlok_native_bridge.dart';
import '../purchases/purchases_config.dart';
import '../theme/studlok_theme.dart';

/// Simple settings screen — no Profile tab exists yet, so this is where
/// "Manage locked apps" lives per Phase 7. Also hosts the debug harness
/// entry point (moved off the app's main entry in this phase).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _bridge = StudlokNativeBridge();

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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t restore purchases: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline, color: StudlokColors.accent),
            title: const Text('Manage locked apps'),
            subtitle: const Text('Change which apps and categories are shielded'),
            onTap: _manageLockedApps,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined, color: StudlokColors.accent),
            title: const Text('Upgrade to Premium'),
            subtitle: const Text('Unlimited Deep Work and Quiz sessions'),
            onTap: _upgrade,
          ),
          ListTile(
            leading: const Icon(Icons.restore, color: StudlokColors.dimWhite),
            title: const Text('Restore purchases'),
            onTap: _restorePurchases,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined, color: StudlokColors.dimWhite),
            title: const Text('Debug tools'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BridgeDebugPage()),
            ),
          ),
        ],
      ),
    );
  }
}
