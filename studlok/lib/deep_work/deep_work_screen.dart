import 'dart:async';

import 'package:flutter/material.dart';

import '../history/session_history_store.dart';
import '../native/studlok_native_bridge.dart';
import '../theme/studlok_theme.dart';

const List<int> _durationOptions = [15, 30, 60, 120];

/// Duration/label picker, then a foreground countdown. Completion (reaching
/// 00:00 while this screen is on screen) is what actually calls
/// bridge.startSession — there's no attempt to make this work while
/// backgrounded, that's what the native session/notification system from
/// Phase 8 already handles.
class DeepWorkScreen extends StatefulWidget {
  const DeepWorkScreen({super.key});

  @override
  State<DeepWorkScreen> createState() => _DeepWorkScreenState();
}

enum _Phase { setup, running, complete }

class _DeepWorkScreenState extends State<DeepWorkScreen> {
  final _bridge = StudlokNativeBridge();
  final _historyStore = SessionHistoryStore();
  final _labelController = TextEditingController(text: 'Deep Work Session');

  _Phase _phase = _Phase.setup;
  int _durationMinutes = 30;
  int _remainingSeconds = 0;
  Timer? _timer;
  String? _error;

  @override
  void dispose() {
    _timer?.cancel();
    _labelController.dispose();
    super.dispose();
  }

  void _start() {
    final label = _labelController.text.trim().isEmpty ? 'Deep Work Session' : _labelController.text.trim();
    setState(() {
      _phase = _Phase.running;
      _remainingSeconds = _durationMinutes * 60;
      _labelController.text = label;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _timer?.cancel();
        setState(() => _remainingSeconds = 0);
        _onComplete();
      } else {
        setState(() => _remainingSeconds -= 1);
      }
    });
  }

  Future<void> _onComplete() async {
    final label = _labelController.text.trim().isEmpty ? 'Deep Work Session' : _labelController.text.trim();
    try {
      await _bridge.startSession(
        durationMinutes: _durationMinutes,
        sessionType: SessionType.deepWork,
        label: label,
      );
      await _historyStore.addEntry(SessionHistoryEntry(
        type: 'deepWork',
        label: label,
        minutesEarned: _durationMinutes,
        timestamp: DateTime.now(),
      ));
      if (!mounted) return;
      setState(() => _phase = _Phase.complete);
    } on StudlokNativeBridgeException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DEEP WORK')),
      body: SafeArea(
        child: switch (_phase) {
          _Phase.setup => _buildSetup(context),
          _Phase.running => _buildRunning(context),
          _Phase.complete => _buildComplete(context),
        },
      ),
    );
  }

  Widget _buildSetup(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'WHAT ARE YOU WORKING ON?',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _labelController,
            style: const TextStyle(color: StudlokColors.white),
            decoration: const InputDecoration(
              hintText: 'e.g. Organic Chemistry',
              hintStyle: TextStyle(color: StudlokColors.dimWhite),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: StudlokColors.dimWhite)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: StudlokColors.accent)),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'DURATION',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final minutes in _durationOptions)
                ChoiceChip(
                  label: Text('$minutes min'),
                  selected: _durationMinutes == minutes,
                  onSelected: (_) => setState(() => _durationMinutes = minutes),
                  selectedColor: StudlokColors.accent,
                  backgroundColor: StudlokColors.surface,
                  labelStyle: TextStyle(
                    color: _durationMinutes == minutes ? Colors.black : StudlokColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          const Spacer(),
          ElevatedButton(
            onPressed: _start,
            child: const Text('START SESSION'),
          ),
        ],
      ),
    );
  }

  Widget _buildRunning(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _labelController.text.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: StudlokColors.dimWhite, fontWeight: FontWeight.w700, letterSpacing: 1.1),
          ),
          const SizedBox(height: 24),
          Text(
            _formattedTime,
            style: const TextStyle(
              color: StudlokColors.accent,
              fontSize: 88,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Stay on this screen — the timer completes here.',
            style: TextStyle(color: StudlokColors.dimWhite, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildComplete(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Icon(Icons.check_circle_outline, size: 72, color: StudlokColors.accent),
          const SizedBox(height: 24),
          Text(
            '+$_durationMinutes MIN EARNED.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: StudlokColors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),
          const Text(
            'Added to your Scroll Bank.',
            textAlign: TextAlign.center,
            style: TextStyle(color: StudlokColors.dimWhite, fontSize: 15),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('BACK TO HOME'),
          ),
        ],
      ),
    );
  }
}
