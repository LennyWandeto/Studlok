import 'package:flutter/foundation.dart';

import '../auth/auth_service.dart';
import '../purchases/purchases_config.dart';

/// Tracks the two pieces of state Settings displays but doesn't own: sign-in
/// state and Pro status. Both can change from elsewhere (AccountScreen, the
/// paywall), so this exposes a [refresh] the View calls whenever it's
/// plausible either changed, rather than caching stale values.
class SettingsViewModel extends ChangeNotifier {
  String? userEmail;
  bool isPremium = false;
  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> refresh() async {
    userEmail = AuthService.instance.currentUser?.email;
    isPremium = await PurchasesConfig.isPremium();
    _loaded = true;
    notifyListeners();
  }
}
