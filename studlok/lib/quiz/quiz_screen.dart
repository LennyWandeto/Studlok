import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../history/session_history_store.dart';
import '../native/studlok_native_bridge.dart';
import '../theme/studlok_theme.dart';
import 'quiz_bank.dart';

const int _questionsPerQuiz = 5;
const int _secondsPerQuestion = 20;
const int _quizSessionMinutes = 15;
const double _passThreshold = 0.7;

/// Draws a fresh random set of questions from the hardcoded bank each time.
List<QuizQuestion> _drawQuestions() {
  final pool = List<QuizQuestion>.from(studlokQuizBank)..shuffle(Random());
  return pool.take(_questionsPerQuiz).toList();
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<QuizQuestion> _questions = _drawQuestions();
  int _index = 0;
  int _correctCount = 0;
  int? _selectedOption;
  int _secondsLeft = _secondsPerQuestion;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startQuestionTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startQuestionTimer() {
    _timer?.cancel();
    _secondsLeft = _secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        if (_selectedOption == null) _lockAnswer(null);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  void _lockAnswer(int? optionIndex) {
    if (_selectedOption != null) return;
    _timer?.cancel();
    final question = _questions[_index];
    final isCorrect = optionIndex != null && optionIndex == question.correctIndex;
    setState(() {
      _selectedOption = optionIndex ?? -1;
      if (isCorrect) _correctCount += 1;
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (_index + 1 < _questions.length) {
        setState(() {
          _index += 1;
          _selectedOption = null;
        });
        _startQuestionTimer();
      } else {
        _finish();
      }
    });
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(correctCount: _correctCount, total: _questions.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_index];
    return Scaffold(
      appBar: AppBar(title: Text('QUIZ — QUESTION ${_index + 1}/${_questions.length}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: _secondsLeft / _secondsPerQuestion,
                backgroundColor: StudlokColors.surface,
                color: StudlokColors.accent,
                minHeight: 4,
              ),
              const SizedBox(height: 8),
              Text('$_secondsLeft s', style: const TextStyle(color: StudlokColors.dimWhite, fontSize: 13)),
              const SizedBox(height: 24),
              Text(
                question.subject.toUpperCase(),
                style: const TextStyle(color: StudlokColors.accent, fontWeight: FontWeight.w900, letterSpacing: 1.1),
              ),
              const SizedBox(height: 8),
              Text(
                question.question,
                style: const TextStyle(color: StudlokColors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              for (var i = 0; i < question.options.length; i++) ...[
                _OptionButton(
                  text: question.options[i],
                  state: _optionState(i, question.correctIndex),
                  onTap: () => _lockAnswer(i),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _OptionVisualState _optionState(int optionIndex, int correctIndex) {
    if (_selectedOption == null) return _OptionVisualState.neutral;
    if (optionIndex == correctIndex) return _OptionVisualState.correct;
    if (optionIndex == _selectedOption) return _OptionVisualState.incorrect;
    return _OptionVisualState.neutral;
  }
}

enum _OptionVisualState { neutral, correct, incorrect }

class _OptionButton extends StatelessWidget {
  const _OptionButton({required this.text, required this.state, required this.onTap});

  final String text;
  final _OptionVisualState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background = switch (state) {
      _OptionVisualState.correct => StudlokColors.accent,
      _OptionVisualState.incorrect => Colors.redAccent,
      _OptionVisualState.neutral => StudlokColors.surface,
    };
    final Color foreground = state == _OptionVisualState.correct ? Colors.black : StudlokColors.white;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          minimumSize: const Size.fromHeight(52),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
        child: Text(text),
      ),
    );
  }
}

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key, required this.correctCount, required this.total});

  final int correctCount;
  final int total;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  final _bridge = StudlokNativeBridge();
  final _historyStore = SessionHistoryStore();

  bool get _passed => widget.correctCount / widget.total >= _passThreshold;

  bool _claiming = false;
  bool _claimed = false;
  String? _error;

  Future<void> _claim() async {
    setState(() => _claiming = true);
    try {
      final label = 'Quiz: ${widget.correctCount}/${widget.total} correct';
      await _bridge.startSession(
        durationMinutes: _quizSessionMinutes,
        sessionType: SessionType.quiz,
        label: label,
      );
      await _historyStore.addEntry(SessionHistoryEntry(
        type: 'quiz',
        label: label,
        minutesEarned: _quizSessionMinutes,
        timestamp: DateTime.now(),
      ));
      if (!mounted) return;
      setState(() => _claimed = true);
    } on StudlokNativeBridgeException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  void _retry() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RESULTS')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                _passed ? Icons.check_circle_outline : Icons.close,
                size: 72,
                color: _passed ? StudlokColors.accent : Colors.redAccent,
              ),
              const SizedBox(height: 24),
              Text(
                '${widget.correctCount}/${widget.total} CORRECT',
                textAlign: TextAlign.center,
                style: const TextStyle(color: StudlokColors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.1),
              ),
              const SizedBox(height: 12),
              Text(
                _passed
                    ? 'You passed. Claim your scroll time.'
                    : 'Need ${(_passThreshold * 100).round()}% to earn scroll time — give it another go.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: StudlokColors.dimWhite, fontSize: 15),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
              ],
              const Spacer(),
              if (_passed) ...[
                if (_claimed)
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('BACK TO HOME'),
                  )
                else
                  ElevatedButton(
                    onPressed: _claiming ? null : _claim,
                    child: _claiming
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text('CLAIM SCROLL TIME'),
                  ),
              ] else ...[
                ElevatedButton(onPressed: _retry, child: const Text('TRY AGAIN')),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('BACK TO HOME'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
