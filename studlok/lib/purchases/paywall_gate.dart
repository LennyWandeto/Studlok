import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import 'purchases_config.dart';
import 'session_gate.dart';

/// Checks the daily session cap and, if it's been hit, shows RevenueCat's
/// hosted paywall. Returns true if the caller is clear to start a session
/// (either under the cap already, or the user just purchased/restored
/// premium).
Future<bool> ensureSessionAllowed(BuildContext context) async {
  final gate = await SessionGate().check();
  if (gate.allowed) return true;

  if (!context.mounted) return false;
  final result = await RevenueCatUI.presentPaywallIfNeeded(PurchasesConfig.premiumEntitlementId);
  if (result == PaywallResult.purchased || result == PaywallResult.restored) {
    // Don't rely solely on the passive CustomerInfo listener — it isn't
    // reliably notified of purchases completed through this native paywall
    // screen. Force a fresh fetch now so the *next* gate check sees it too.
    await PurchasesConfig.refreshCustomerInfo();
    return true;
  }

  if (!context.mounted) return false;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Free plan: ${PurchasesConfig.freeDailySessionCap} sessions a day. Upgrade for unlimited.',
      ),
    ),
  );
  return false;
}
