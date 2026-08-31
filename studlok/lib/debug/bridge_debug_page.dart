import 'package:flutter/material.dart';

import '../native/studlok_native_bridge.dart';
import '../quiz/quiz_source_screen.dart';
import 'design_system_preview_page.dart';

/// Debug harness from Phase 5: exercises every StudlokNativeBridge method by
/// hand. Moved off the app's main entry point in Phase 7 (reachable from
/// Settings instead) now that onboarding/home screens are the real entry.
class BridgeDebugPage extends StatefulWidget {
  const BridgeDebugPage({super.key});

  @override
  State<BridgeDebugPage> createState() => _BridgeDebugPageState();
}

class _BridgeDebugPageState extends State<BridgeDebugPage> {
  final _bridge = StudlokNativeBridge();
  final _log = <String>[];

  void _appendLog(String line) {
    debugPrint('[StudlokDebug] $line');
    setState(() => _log.insert(0, line));
  }

  Future<void> _run(String label, Future<void> Function() action) async {
    _appendLog('→ $label...');
    try {
      await action();
    } on StudlokNativeBridgeException catch (e) {
      _appendLog(
        '✗ $label failed: ${e.message}${e.code != null ? ' (${e.code})' : ''}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Studlok — bridge debug harness')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 260,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => _run('requestAuthorization', () async {
                        final r = await _bridge.requestAuthorization();
                        _appendLog(
                          '  success=${r.success} status=${r.status}${r.error != null ? ' error=${r.error}' : ''}',
                        );
                      }),
                      child: const Text('Request Authorization'),
                    ),
                    ElevatedButton(
                      onPressed: () => _run('getAuthorizationStatus', () async {
                        final status = await _bridge.getAuthorizationStatus();
                        _appendLog('  status=$status');
                      }),
                      child: const Text('Get Auth Status'),
                    ),
                    ElevatedButton(
                      onPressed: () => _run('presentActivityPicker', () async {
                        final r = await _bridge.presentActivityPicker();
                        _appendLog(
                          '  apps=${r.applicationCount} categories=${r.categoryCount}',
                        );
                      }),
                      child: const Text('Pick Apps'),
                    ),
                    ElevatedButton(
                      onPressed: () => _run('hasSelectedApps', () async {
                        final has = await _bridge.hasSelectedApps();
                        _appendLog('  hasSelectedApps=$has');
                      }),
                      child: const Text('Has Selected Apps'),
                    ),
                    for (final minutes in [1, 2, 5, 10, 15])
                      ElevatedButton(
                        onPressed: () =>
                            _run('startSession($minutes min)', () async {
                              await _bridge.startSession(
                                durationMinutes: minutes,
                                sessionType: SessionType.deepWork,
                                label: 'Debug test session ($minutes min)',
                              );
                              _appendLog('  started');
                            }),
                        child: Text('Start ${minutes}m Session'),
                      ),
                    ElevatedButton(
                      onPressed: () => _run('getSharedState', () async {
                        final s = await _bridge.getSharedState();
                        _appendLog(
                          '  scrollBank=${s.scrollBankMinutes}m '
                          'activeType=${s.activeSessionType} '
                          'endDate=${s.activeSessionEndDate} '
                          'label="${s.activeSessionLabel}" '
                          'onboardingComplete=${s.onboardingComplete}',
                        );
                      }),
                      child: const Text('Get Shared State'),
                    ),
                    ElevatedButton(
                      onPressed: () => _run('isSessionActive', () async {
                        final active = await _bridge.isSessionActive();
                        _appendLog('  active=$active');
                      }),
                      child: const Text('Is Session Active'),
                    ),
                    ElevatedButton(
                      onPressed: () => _run('debugScheduleInfo', () async {
                        final info = await _bridge.debugScheduleInfo();
                        _appendLog('  $info');
                      }),
                      child: const Text('Debug Schedule Info'),
                    ),
                    ElevatedButton(
                      onPressed: () => _run('debugShieldStatus', () async {
                        final status = await _bridge.debugShieldStatus();
                        _appendLog('  $status');
                      }),
                      child: const Text('Shield Status'),
                    ),
                    ElevatedButton(
                      onPressed: () => _run('debugReconcileNow', () async {
                        final reconciled = await _bridge.debugReconcileNow();
                        _appendLog('  reconciled=$reconciled');
                      }),
                      child: const Text('Reconcile Now'),
                    ),
                    ElevatedButton(
                      onPressed: () => _run('debugWatchdogStatus', () async {
                        final status = await _bridge.debugWatchdogStatus();
                        _appendLog('  $status');
                      }),
                      child: const Text('Watchdog Status'),
                    ),
                    ElevatedButton(
                      onPressed: () => _run('requestNotificationAuthorization', () async {
                        final granted = await _bridge.requestNotificationAuthorization();
                        _appendLog('  granted=$granted');
                      }),
                      child: const Text('Request Notif Auth'),
                    ),
                    ElevatedButton(
                      onPressed: () => _run('debugNotificationStatus', () async {
                        final status = await _bridge.debugNotificationStatus();
                        _appendLog('  $status');
                      }),
                      child: const Text('Notification Status'),
                    ),
                    ElevatedButton(
                      onPressed: () => _run('debugBackgroundRefreshStatus', () async {
                        final status = await _bridge.debugBackgroundRefreshStatus();
                        _appendLog('  $status');
                      }),
                      child: const Text('BG Refresh Status'),
                    ),
                    // Navigation shortcut only — skips the real isPremium()
                    // check so the Pro quiz picker/upload flow can be QA'd
                    // without a real subscription. Grants nothing; unlike
                    // the buttons above it never touches startSession.
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const QuizSourceScreen()),
                      ),
                      child: const Text('Preview: Choose a Quiz (Pro)'),
                    ),
                    // Design revamp, Part 1 — literal look at the new
                    // colors/type/buttons/surfaces before any real screen
                    // adopts them.
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DesignSystemPreviewPage()),
                      ),
                      child: const Text('Preview: Design System'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: ListView.builder(
                reverse: false,
                itemCount: _log.length,
                itemBuilder: (context, index) => Text(
                  _log[index],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
