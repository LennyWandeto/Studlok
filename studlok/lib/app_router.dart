import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'native/studlok_native_bridge.dart';
import 'onboarding/onboarding_screens.dart';

enum _InitialRoute { permissionPriming, appPicker, home }

/// Decides where a launch lands: onboarding (not yet authorized), straight
/// to the picker step (authorized but nothing selected), or Home (both
/// already done — onboarding never re-triggers).
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  final _bridge = StudlokNativeBridge();
  late final Future<_InitialRoute> _decision = _decideRoute();

  Future<_InitialRoute> _decideRoute() async {
    final status = await _bridge.getAuthorizationStatus();
    if (status != FamilyControlsAuthorizationStatus.approved) {
      return _InitialRoute.permissionPriming;
    }

    final hasSelection = await _bridge.hasSelectedApps();
    if (!hasSelection) {
      return _InitialRoute.appPicker;
    }

    // Both real conditions are satisfied — record that so future launches
    // have an explicit record of onboarding having been completed at least
    // once, even though this routing decision itself is always derived
    // from live state, not this flag.
    await _bridge.completeOnboarding();
    return _InitialRoute.home;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_InitialRoute>(
      future: _decision,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return switch (snapshot.data!) {
          _InitialRoute.permissionPriming => const PermissionPrimingScreen(),
          _InitialRoute.appPicker => const AppPickerStepScreen(),
          _InitialRoute.home => const HomeScreen(),
        };
      },
    );
  }
}
