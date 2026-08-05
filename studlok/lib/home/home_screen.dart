import 'package:flutter/material.dart';

import '../deep_work/deep_work_screen.dart';
import '../history/session_history_store.dart';
import '../native/studlok_native_bridge.dart';
import '../quiz/quiz_screen.dart';
import '../settings/settings_screen.dart';
import '../theme/studlok_theme.dart';

/// Real dashboard (Phase 9) — reads bridge.getSharedState() and the local
/// session history log instead of showing mockup placeholder values.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _bridge = StudlokNativeBridge();
  final _historyStore = SessionHistoryStore();

  StudlokSharedState? _state;
  List<SessionHistoryEntry> _history = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    final state = await _bridge.getSharedState();
    final history = await _historyStore.load();
    if (!mounted) return;
    setState(() {
      _state = state;
      _history = history;
    });
  }

  Future<void> _openDeepWork() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeepWorkScreen()));
    _refresh();
  }

  Future<void> _openQuiz() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuizScreen()));
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
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
      body: state == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _ScrollBankCard(minutes: state.scrollBankMinutes),
                  const SizedBox(height: 16),
                  _StreakAndGoalRow(state: state),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _openDeepWork,
                    child: const Text('START DEEP WORK'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _openQuiz,
                    child: const Text('TAKE A QUIZ'),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'RECENT PROTOCOLS',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 12),
                  if (_history.isEmpty)
                    const Text(
                      'No sessions yet — complete a Deep Work session or Quiz to see it here.',
                      style: TextStyle(color: StudlokColors.dimWhite, fontSize: 14),
                    )
                  else
                    for (final entry in _history) _ProtocolTile(entry: entry),
                ],
              ),
            ),
    );
  }
}

class _ScrollBankCard extends StatelessWidget {
  const _ScrollBankCard({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StudlokColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SCROLL BANK', style: TextStyle(color: StudlokColors.dimWhite, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Text(
            '$minutes min',
            style: const TextStyle(color: StudlokColors.accent, fontSize: 40, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _StreakAndGoalRow extends StatelessWidget {
  const _StreakAndGoalRow({required this.state});

  final StudlokSharedState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _InfoTile(
            label: 'STREAK',
            value: state.currentStreak > 0 ? '${state.currentStreak} day${state.currentStreak == 1 ? '' : 's'}' : 'No streak yet',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _InfoTile(
            label: 'DAILY GOAL',
            value: state.dailyGoalMinutes > 0
                ? '${state.dailyProgressMinutes}/${state.dailyGoalMinutes} min'
                : 'Not set',
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudlokColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: StudlokColors.dimWhite, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: StudlokColors.white, fontSize: 17, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ProtocolTile extends StatelessWidget {
  const _ProtocolTile({required this.entry});

  final SessionHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final isQuiz = entry.type == 'quiz';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        tileColor: StudlokColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(isQuiz ? Icons.quiz_outlined : Icons.timer_outlined, color: StudlokColors.accent),
        title: Text(entry.label, style: const TextStyle(color: StudlokColors.white, fontWeight: FontWeight.w700)),
        subtitle: Text(_formatTimestamp(entry.timestamp), style: const TextStyle(color: StudlokColors.dimWhite)),
        trailing: Text('+${entry.minutesEarned}m', style: const TextStyle(color: StudlokColors.accent, fontWeight: FontWeight.w800)),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
