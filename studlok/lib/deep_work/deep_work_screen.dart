import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../design/components/studlok_button.dart';
import '../design/components/studlok_chip.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';
import '../history/session_history_store.dart';
import '../native/studlok_native_bridge.dart';

const List<int> _durationOptions = [15, 30, 60, 120];
const List<String> _labelOptions = ['Studying', 'Homework', 'Reading', 'Writing', 'Review'];

/// Duration/label picker, then a foreground countdown. Completion (reaching
/// 00:00 while this screen is on screen) is what actually calls
/// bridge.startSession — there's no attempt to make this work while
/// backgrounded, that's what the native session/notification system from
/// Phase 8 already handles.
///
/// The running phase is deliberately the quietest screen in the app — this
/// is what someone stares at for up to two hours, so it gets minimal chrome
/// and one slow ambient breathing glow, not a moment competing for
/// attention the way session-complete/quiz-correct do.
class DeepWorkScreen extends StatefulWidget {
  const DeepWorkScreen({super.key});

  @override
  State<DeepWorkScreen> createState() => _DeepWorkScreenState();
}

enum _Phase { setup, running, complete }

class _DeepWorkScreenState extends State<DeepWorkScreen> {
  final _bridge = StudlokNativeBridge();
  final _historyStore = SessionHistoryStore();

  _Phase _phase = _Phase.setup;
  String _label = _labelOptions.first;
  int _durationMinutes = 30;
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  String? _error;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _phase = _Phase.running;
      _totalSeconds = _durationMinutes * 60;
      _remainingSeconds = _totalSeconds;
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
    try {
      await _bridge.startSession(
        durationMinutes: _durationMinutes,
        sessionType: SessionType.deepWork,
        label: _label,
      );
      await _historyStore.addEntry(SessionHistoryEntry(
        type: 'deepWork',
        label: _label,
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
      backgroundColor: StudlokColors.background,
      appBar: _phase == _Phase.running
          ? AppBar(backgroundColor: StudlokColors.background, elevation: 0)
          : AppBar(title: const Text('DEEP WORK')),
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
      padding: const EdgeInsets.all(StudlokSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'WHAT ARE YOU WORKING ON?',
            style: TextStyle(color: StudlokColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1.0, fontSize: 12),
          ),
          const SizedBox(height: StudlokSpacing.md),
          Wrap(
            spacing: StudlokSpacing.sm,
            runSpacing: StudlokSpacing.sm,
            children: [
              for (final label in _labelOptions)
                StudlokChip(label: label, selected: _label == label, onTap: () => setState(() => _label = label)),
            ],
          ),
          const SizedBox(height: StudlokSpacing.xxl),
          const Text(
            'DURATION',
            style: TextStyle(color: StudlokColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1.0, fontSize: 12),
          ),
          const SizedBox(height: StudlokSpacing.md),
          Wrap(
            spacing: StudlokSpacing.sm,
            runSpacing: StudlokSpacing.sm,
            children: [
              for (final minutes in _durationOptions)
                StudlokChip(
                  label: '$minutes min',
                  selected: _durationMinutes == minutes,
                  onTap: () => setState(() => _durationMinutes = minutes),
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: StudlokSpacing.lg),
            Text(_error!, style: const TextStyle(color: StudlokColors.warning)),
          ],
          const Spacer(),
          StudlokButton(label: 'START SESSION', onPressed: _start),
        ],
      ),
    );
  }

  Widget _buildRunning(BuildContext context) {
    final progress = _totalSeconds == 0 ? 0.0 : _remainingSeconds / _totalSeconds;
    return Stack(
      children: [
        const Positioned.fill(child: _BreathingGlow()),
        Column(
          children: [
            const SizedBox(height: StudlokSpacing.xxl),
            Text(
              _label.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: StudlokColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 1.0, fontSize: 13),
            ),
            // The ring gets its own flexible region so it always lands on
            // the true center of the remaining space, regardless of how
            // much label/caption text sits above and below it.
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          backgroundColor: StudlokColors.surface,
                          valueColor: const AlwaysStoppedAnimation(StudlokColors.accent),
                        ),
                      ),
                      Text(
                        _formattedTime,
                        style: StudlokTypography.display.copyWith(color: StudlokColors.textPrimary, fontSize: 56, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: StudlokSpacing.xxl),
              child: Text(
                'Stay on this screen — the timer completes here.',
                style: StudlokTypography.caption.copyWith(color: StudlokColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComplete(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(StudlokSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Icon(LucideIcons.circleCheck, size: 64, color: StudlokColors.accent),
          const SizedBox(height: StudlokSpacing.xl),
          Text(
            '+$_durationMinutes MIN EARNED.',
            textAlign: TextAlign.center,
            style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary),
          ),
          const SizedBox(height: StudlokSpacing.sm),
          Text(
            'Added to your Scroll Bank.',
            textAlign: TextAlign.center,
            style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
          ),
          const Spacer(),
          StudlokButton(label: 'BACK TO HOME', onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

/// One slow, ambient pulse behind the countdown — atmosphere, not a
/// designed "moment" (that budget is spent on session-complete/quiz-correct
/// elsewhere). Kept subtle enough to sit behind 25+ minutes of staring
/// without becoming the thing you're staring at.
class _BreathingGlow extends StatefulWidget {
  const _BreathingGlow();

  @override
  State<_BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<_BreathingGlow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(_controller.value);
            return Opacity(
              opacity: 0.12 + (0.10 * t),
              child: Transform.scale(scale: 0.94 + (0.06 * t), child: child),
            );
          },
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [StudlokColors.accent.withValues(alpha: 0.35), StudlokColors.accent.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
