import 'dart:async';

import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../native/studlok_native_bridge.dart';
import '../theme/studlok_theme.dart';

/// Screen 1: explains what Studlok does and why it needs Screen Time access,
/// before triggering the system permission prompt (standard priming
/// practice — a bare system dialog with no context reads as suspicious and
/// gets denied more often).
class PermissionPrimingScreen extends StatefulWidget {
  const PermissionPrimingScreen({super.key});

  @override
  State<PermissionPrimingScreen> createState() => _PermissionPrimingScreenState();
}

class _PermissionPrimingScreenState extends State<PermissionPrimingScreen> {
  final _bridge = StudlokNativeBridge();
  bool _requesting = false;

  Future<void> _continue() async {
    setState(() => _requesting = true);
    try {
      final result = await _bridge.requestAuthorization();
      if (!mounted) return;
      if (result.status == FamilyControlsAuthorizationStatus.approved) {
        // Fire-and-forget: notification permission is non-critical, and
        // asking now (rather than at the first session) avoids interrupting
        // the user with a permission prompt mid-flow later.
        unawaited(_bridge.requestNotificationAuthorization());
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AppPickerStepScreen()),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PermissionDeniedScreen()),
        );
      }
    } on StudlokNativeBridgeException {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PermissionDeniedScreen()),
      );
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.lock_outline, size: 72, color: StudlokColors.accent),
              const SizedBox(height: 24),
              Text(
                'EARN YOUR SCROLL.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: StudlokColors.accent,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Studlok locks the apps that eat your time — Instagram, TikTok, '
                'whatever pulls you in — until you finish a Deep Work session or a '
                'Quiz. To do that, it needs Screen Time access from Apple. This is '
                'what actually applies and lifts the lock; Studlok never sees what '
                'you do inside those apps.',
                textAlign: TextAlign.center,
                style: TextStyle(color: StudlokColors.dimWhite, height: 1.5, fontSize: 15),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _requesting ? null : _continue,
                child: _requesting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('CONTINUE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when authorization is denied/canceled. Family Controls has no
/// supported way to re-prompt after a denial — the only path forward is
/// Settings, so this screen sends the user there and lets them come back
/// and re-check.
class PermissionDeniedScreen extends StatefulWidget {
  const PermissionDeniedScreen({super.key});

  @override
  State<PermissionDeniedScreen> createState() => _PermissionDeniedScreenState();
}

class _PermissionDeniedScreenState extends State<PermissionDeniedScreen> {
  final _bridge = StudlokNativeBridge();
  bool _checking = false;
  bool _stillNotApproved = false;

  Future<void> _openSettings() async {
    await _bridge.openSystemSettings();
  }

  Future<void> _recheck() async {
    setState(() {
      _checking = true;
      _stillNotApproved = false;
    });
    final status = await _bridge.getAuthorizationStatus();
    if (!mounted) return;
    if (status == FamilyControlsAuthorizationStatus.approved) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppPickerStepScreen()),
      );
      return;
    }
    setState(() {
      _checking = false;
      _stillNotApproved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.block, size: 72, color: StudlokColors.accent),
              const SizedBox(height: 24),
              Text(
                'STUDLOK CAN\'T WORK\nWITHOUT THIS.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: StudlokColors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Screen Time access is how Studlok actually locks and unlocks apps. '
                'Without it there\'s nothing to enforce. Turn it on in Settings, '
                'then come back here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: StudlokColors.dimWhite, height: 1.5, fontSize: 15),
              ),
              if (_stillNotApproved) ...[
                const SizedBox(height: 16),
                const Text(
                  'Still not enabled — check Settings > Screen Time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: StudlokColors.accent, fontSize: 13),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: _openSettings,
                child: const Text('OPEN SETTINGS'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _checking ? null : _recheck,
                child: _checking
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: StudlokColors.accent),
                      )
                    : const Text('I\'VE ENABLED IT — CONTINUE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen 2: launches the native app picker.
class AppPickerStepScreen extends StatefulWidget {
  const AppPickerStepScreen({super.key});

  @override
  State<AppPickerStepScreen> createState() => _AppPickerStepScreenState();
}

class _AppPickerStepScreenState extends State<AppPickerStepScreen> {
  final _bridge = StudlokNativeBridge();
  bool _picking = false;
  String? _error;

  Future<void> _pickApps() async {
    setState(() {
      _picking = true;
      _error = null;
    });
    try {
      final result = await _bridge.presentActivityPicker();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SelectionConfirmedScreen(
            applicationCount: result.applicationCount,
            categoryCount: result.categoryCount,
          ),
        ),
      );
    } on StudlokNativeBridgeException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.apps, size: 72, color: StudlokColors.accent),
              const SizedBox(height: 24),
              Text(
                'PICK WHAT TO LOCK.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: StudlokColors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose the apps or categories that eat your time. They\'ll lock '
                'immediately — you unlock them by completing a Deep Work session '
                'or a Quiz.',
                textAlign: TextAlign.center,
                style: TextStyle(color: StudlokColors.dimWhite, height: 1.5, fontSize: 15),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: _picking ? null : _pickApps,
                child: _picking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('CHOOSE APPS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectionConfirmedScreen extends StatelessWidget {
  const SelectionConfirmedScreen({
    super.key,
    required this.applicationCount,
    required this.categoryCount,
  });

  final int applicationCount;
  final int categoryCount;

  Future<void> _enterHome(BuildContext context) async {
    await StudlokNativeBridge().completeOnboarding();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = applicationCount + categoryCount;
    final label = total == 1 ? '1 app locked.' : '$total apps locked.';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.lock, size: 72, color: StudlokColors.accent),
              const SizedBox(height: 24),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: StudlokColors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 12),
              const Text(
                'EARN YOUR SCROLL.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: StudlokColors.accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Complete a session in Studlok to unlock them.',
                textAlign: TextAlign.center,
                style: TextStyle(color: StudlokColors.dimWhite, height: 1.5, fontSize: 15),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _enterHome(context),
                child: const Text('GO TO STUDLOK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
