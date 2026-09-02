import 'package:flutter/foundation.dart';

import '../auth/auth_service.dart';
import '../purchases/purchases_config.dart';
import 'pass_threshold_store.dart';

/// Tracks the state Settings displays but doesn't own: sign-in state, Pro
/// status, and the user-adjustable pass threshold. Sign-in/Pro can change
/// from elsewhere (AccountScreen, the paywall), so this exposes a [refresh]
/// the View calls whenever it's plausible either changed, rather than
/// caching stale values.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({PassThresholdStore? passThresholdStore}) : _passThresholdStore = passThresholdStore ?? PassThresholdStore();

  final PassThresholdStore _passThresholdStore;

  String? userEmail;
  bool isPremium = false;
  int passThresholdPercent = PassThresholdStore.defaultPercent;
  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> refresh() async {
    userEmail = AuthService.instance.currentUser?.email;
    isPremium = await PurchasesConfig.isPremium();
    passThresholdPercent = await _passThresholdStore.load();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setPassThreshold(int percent) async {
    passThresholdPercent = percent;
    notifyListeners();
    await _passThresholdStore.save(percent);
  }
}
