import 'package:flutter/material.dart';

import 'app_router.dart';
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
  runApp(const StudlokApp());
}

class StudlokApp extends StatelessWidget {
  const StudlokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studlok',
      theme: buildStudlokTheme(),
      home: const AppRouter(),
    );
  }
}
