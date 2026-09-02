import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'home/home_screen.dart';
import 'native/studlok_native_bridge.dart';
import 'progress/progress_screen.dart';
import 'quiz/quiz_launch.dart';
import 'sessions/sessions_screen.dart';
import 'settings/settings_screen.dart';

/// The app's bottom-nav shell — Home / Sessions / Progress / Profile, per
/// the design revamp's Part 2 structure. [IndexedStack] keeps each tab's
/// own state alive across switches rather than rebuilding on every tap.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  final _bridge = StudlokNativeBridge();
  int _index = 0;

  void _goToSessions() => setState(() => _index = 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPendingDeepLink();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Covers both cases a notification tap can land in: app was fully
    // closed (this runs once at initState, right after AppRouter routes
    // here) or backgrounded (this runs on resume).
    if (state == AppLifecycleState.resumed) _checkPendingDeepLink();
  }

  Future<void> _checkPendingDeepLink() async {
    final state = await _bridge.getSharedState();
    if (state.pendingDeepLink != 'quiz') return;
    await _bridge.clearPendingDeepLink();
    if (!mounted) return;
    await openQuizFlow(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onStartSession: _goToSessions),
          const SessionsScreen(),
          const ProgressScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.house), selectedIcon: Icon(LucideIcons.house600), label: 'Home'),
          NavigationDestination(icon: Icon(LucideIcons.zap), selectedIcon: Icon(LucideIcons.zap600), label: 'Sessions'),
          NavigationDestination(icon: Icon(LucideIcons.chartColumn), selectedIcon: Icon(LucideIcons.chartColumn600), label: 'Progress'),
          NavigationDestination(icon: Icon(LucideIcons.user), selectedIcon: Icon(LucideIcons.user600), label: 'Profile'),
        ],
      ),
    );
  }
}
