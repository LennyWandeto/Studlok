import 'package:flutter/material.dart';

import 'app_router.dart';
import 'auth/auth_config.dart';
import 'purchases/purchases_config.dart';
import 'theme/studlok_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await PurchasesConfig.initialize();
  } catch (e) {
    // RevenueCat is an add-on (paywall gating), not core functionality —
    // a bad API key or network issue at launch shouldn't block the app
    // that actually locks/unlocks screen time from starting at all.
    debugPrint('[main] PurchasesConfig.initialize failed: $e');
  }
  try {
    await AuthConfig.initialize();
  } catch (e) {
    // Same reasoning as PurchasesConfig: auth/AI-quiz is an add-on, not
    // core functionality — a bad config or network issue at launch
    // shouldn't block the native lock/unlock mechanic from starting.
    debugPrint('[main] AuthConfig.initialize failed: $e');
  }
  runApp(const StudlokApp());
}

class StudlokApp extends StatelessWidget {
  const StudlokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studlok',
      theme: buildStudlokTheme(),
      debugShowCheckedModeBanner: false,
      home: const AppRouter(),
    );
  }
}
