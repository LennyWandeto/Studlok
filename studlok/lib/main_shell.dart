import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'home/home_screen.dart';
import 'progress/progress_screen.dart';
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

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goToSessions() => setState(() => _index = 1);

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
