import 'package:flutter/foundation.dart';

import 'native/studlok_native_bridge.dart';

enum AppRoute { loading, permissionPriming, appPicker, home }

/// Decides where a cold launch lands — the one real piece of business logic
/// behind [AppRouter], split out as a ViewModel so that decision and its
/// visual presentation (a real splash screen, not a bare spinner) are
/// separate concerns. This is the app's first ViewModel under the MVVM
/// pass; the pattern it establishes is what every following screen follows.
class AppRouterViewModel extends ChangeNotifier {
  AppRouterViewModel({StudlokNativeBridge? bridge}) : _bridge = bridge ?? StudlokNativeBridge() {
    _decide();
  }

  final StudlokNativeBridge _bridge;

  AppRoute _route = AppRoute.loading;
  AppRoute get route => _route;

  Future<void> _decide() async {
    final status = await _bridge.getAuthorizationStatus();
    if (status != FamilyControlsAuthorizationStatus.approved) {
      _setRoute(AppRoute.permissionPriming);
      return;
    }

    final hasSelection = await _bridge.hasSelectedApps();
    if (!hasSelection) {
      _setRoute(AppRoute.appPicker);
      return;
    }

    // Both real conditions are satisfied — record that so future launches
    // have an explicit record of onboarding having been completed at least
    // once, even though this routing decision itself is always derived
    // from live state, not this flag.
    await _bridge.completeOnboarding();
    _setRoute(AppRoute.home);
  }

  void _setRoute(AppRoute value) {
    if (_route == value) return;
    _route = value;
    notifyListeners();
  }
}
