import 'package:flutter/material.dart';

import '../settings/settings_screen.dart';
import '../theme/studlok_theme.dart';

/// Placeholder Home Dashboard — Phase 7 only builds the path from fresh
/// install to "apps are selected and locked." Real dashboard data wiring,
/// the Deep Work timer, and the Quiz screen come in a later phase.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STUDLOK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'You\'re set up. Home dashboard content comes in a later phase.',
            textAlign: TextAlign.center,
            style: TextStyle(color: StudlokColors.dimWhite, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
