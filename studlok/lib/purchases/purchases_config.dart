import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat wiring for Studlok's Shipaton paywall (free tier: capped
/// Deep Work/Quiz sessions per day; premium: unlimited).
class PurchasesConfig {
  PurchasesConfig._();

  /// RevenueCat public iOS API key — Project Settings > API Keys in the
  /// RevenueCat dashboard. This is the public SDK key, safe to embed
  /// client-side (not the secret key).
  static const iosApiKey = 'appl_VEgcVTPUYwzEUBXStGsfUkVAXcm';

  /// The entitlement identifier created in the RevenueCat dashboard that
  /// gates unlimited sessions. Must match the dashboard's identifier
  /// exactly (not the display name) — RevenueCat entitlement identifiers
  /// are conventionally lowercase/hyphenated slugs, so double-check this
  /// against the dashboard rather than assuming "Studlok Pro" is verbatim.
  static const premiumEntitlementId = 'Studlok Pro';

  /// Free tier: sessions earned per calendar day before the paywall shows.
  static const freeDailySessionCap = 2;

  static Future<void> initialize() async {
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);
    await Purchases.configure(PurchasesConfiguration(iosApiKey));
  }

  /// Fails closed to "not premium" (i.e. the free cap still applies) rather
  /// than throwing — a network blip or RevenueCat outage shouldn't crash the
  /// Deep Work/Quiz entry points, it should just mean the cap is enforced
  /// until the check can succeed.
  static Future<bool> isPremium() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(premiumEntitlementId);
    } catch (e) {
      debugPrint('[PurchasesConfig] isPremium check failed, defaulting to false: $e');
      return false;
    }
  }
}
