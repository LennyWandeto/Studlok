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

  /// Last known-good CustomerInfo — a safety net for isPremium(), not the
  /// primary source of truth. Updated by [Purchases.addCustomerInfoUpdateListener]
  /// (RevenueCat's passive push on purchase/restore) and by
  /// [refreshCustomerInfo] (an explicit pull we trigger right after a
  /// paywall reports a successful purchase/restore, since the passive
  /// listener isn't reliably notified of purchases completed through
  /// RevenueCat's *native* hosted paywall UI — a separate screen from our
  /// Flutter widget tree).
  static CustomerInfo? _lastKnownGoodCustomerInfo;

  static Future<void> initialize() async {
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);
    await Purchases.configure(PurchasesConfiguration(iosApiKey));
    Purchases.addCustomerInfoUpdateListener((info) {
      _lastKnownGoodCustomerInfo = info;
    });
    await refreshCustomerInfo();
  }

  /// Forces a fresh fetch and updates the cached fallback on success. Call
  /// this right after a paywall reports a purchase/restore succeeded, so
  /// the next isPremium() check reflects it immediately rather than
  /// depending on the passive listener having fired.
  static Future<void> refreshCustomerInfo() async {
    try {
      _lastKnownGoodCustomerInfo = await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('[PurchasesConfig] refreshCustomerInfo failed: $e');
    }
  }

  /// Always prefers a fresh network check (so a just-completed purchase is
  /// picked up immediately even if the cache hasn't been explicitly
  /// refreshed yet). Falls back to the last known-good cached result on
  /// error — not a hardcoded "false" — so a transient network/backend blip
  /// doesn't wrongly demote an already-paying customer back to the free
  /// cap. Only true "no cache has ever succeeded" defaults to false.
  static Future<bool> isPremium() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _lastKnownGoodCustomerInfo = info;
      return info.entitlements.active.containsKey(premiumEntitlementId);
    } catch (e) {
      debugPrint('[PurchasesConfig] isPremium fresh check failed, falling back to cache: $e');
      final cached = _lastKnownGoodCustomerInfo;
      return cached?.entitlements.active.containsKey(premiumEntitlementId) ?? false;
    }
  }
}
