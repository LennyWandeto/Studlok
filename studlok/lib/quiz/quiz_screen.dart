import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../design/components/studlok_button.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';
import '../history/session_history_store.dart';
import '../native/studlok_native_bridge.dart';
import '../settings/pass_threshold_store.dart';
import 'course_material_repository.dart';
import 'question_stats_store.dart';
import 'quiz_bank.dart';

const int _questionsPerQuiz = 5;
const int _secondsPerQuestion = 20;
const int _quizSessionMinutes = 15;

/// Draws the question set for a session. An injected [source] (a Pro user's
/// own generated quiz) is used in full, shuffled — one-off content, not
/// worth weighting since it won't be redrawn from again. With no source,
/// this draws 5 from [pack] weighted toward recently-missed questions (see
/// QuestionStatsStore) rather than a plain uniform shuffle.
Future<List<QuizQuestion>> _drawQuestions(List<QuizQuestion>? source, QuestionPack pack) async {
  if (source != null) {
    return List<QuizQuestion>.from(source)..shuffle(Random());
  }
  final stats = await QuestionStatsStore().loadAll();
  return QuestionStatsStore().drawWeighted(pack.questions, _questionsPerQuiz, stats);
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, this.questions, this.generatedQuizId, this.pack});

  /// A Pro user's own AI-generated question set. Null means "hardcoded
  /// content" — draw from [pack] instead.
  final List<QuizQuestion>? questions;

  /// The source generated_quizzes row id, carried through only so the
  /// result screen can log the attempt. Null for hardcoded content.
  final String? generatedQuizId;

  /// Which hardcoded pack to draw from when [questions] is null. Defaults
  /// to General Knowledge — the same pool every free user drew from before
  /// packs existed — so any call site that doesn't specify one keeps
  /// behaving exactly as it did.
  final QuestionPack? pack;

  QuestionPack get _resolvedPack => pack ?? generalKnowledgePack;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _statsStore = QuestionStatsStore();
  List<QuizQuestion>? _questions;
  int _index = 0;
  int _correctCount = 0;
  int? _selectedOption;
  int _secondsLeft = _secondsPerQuestion;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final questions = await _drawQuestions(widget.questions, widget._resolvedPack);
    if (!mounted) return;
    setState(() => _questions = questions);
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
    final questions = _questions;
    if (questions == null) return;
    _timer?.cancel();
    final question = questions[_index];
    final isCorrect = optionIndex != null && optionIndex == question.correctIndex;
    HapticFeedback.mediumImpact();
    if (!isCorrect) {
      // A second, heavier beat right after — makes "wrong" read distinctly
      // different from "right" by feel alone, not just by color.
      Future.delayed(const Duration(milliseconds: 90), () => HapticFeedback.heavyImpact());
    }
    // Only worth recording for hardcoded-pack content — an AI-generated
    // quiz's questions are one-off and never redrawn from, so there's
    // nothing for spaced repetition or mastery tracking to do with them.
    if (widget.generatedQuizId == null) {
      unawaited(_statsStore.recordAttempt(question.id, isCorrect));
    }
    setState(() {
      _selectedOption = optionIndex ?? -1;
      if (isCorrect) _correctCount += 1;
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (_index + 1 < questions.length) {
        setState(() {
          _index += 1;
          _selectedOption = null;
        });
        _startQuestionTimer();
      } else {
        _finish(questions.length);
      }
    });
  }

  void _finish(int total) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          correctCount: _correctCount,
          total: total,
          questions: widget.questions,
          generatedQuizId: widget.generatedQuizId,
          pack: widget.pack,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = _questions;
    if (questions == null) {
      return const Scaffold(
        backgroundColor: StudlokColors.background,
        body: Center(child: CircularProgressIndicator(color: StudlokColors.accent)),
      );
    }
    final question = questions[_index];
    final urgent = _secondsLeft <= 5 && _selectedOption == null;
    return Scaffold(
      backgroundColor: StudlokColors.background,
      appBar: AppBar(
        title: Text(
          'QUESTION ${_index + 1} OF ${questions.length}',
          style: const TextStyle(fontSize: 14, letterSpacing: 0.5),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(StudlokSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1, end: _secondsLeft / _secondsPerQuestion),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          minHeight: 6,
                          backgroundColor: StudlokColors.surface,
                          valueColor: AlwaysStoppedAnimation(urgent ? StudlokColors.warning : StudlokColors.accent),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: StudlokSpacing.md),
                  Text(
                    '${_secondsLeft}s',
                    style: StudlokTypography.bodyEmphasis.copyWith(
                      color: urgent ? StudlokColors.warning : StudlokColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: StudlokSpacing.xxl),
              Text(
                question.subject.toUpperCase(),
                style: const TextStyle(color: StudlokColors.accent, fontWeight: FontWeight.w700, letterSpacing: 1.0, fontSize: 12),
              ),
              const SizedBox(height: StudlokSpacing.sm),
              Text(
                question.question,
                style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary, fontSize: 24),
              ),
              const SizedBox(height: StudlokSpacing.xxl),
              for (var i = 0; i < question.options.length; i++) ...[
                _OptionCard(
                  text: question.options[i],
                  state: _optionState(i, question.correctIndex),
                  onTap: () => _lockAnswer(i),
                ),
                const SizedBox(height: StudlokSpacing.sm),
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
    return _OptionVisualState.dimmed;
  }
}

enum _OptionVisualState { neutral, correct, incorrect, dimmed }

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.text, required this.state, required this.onTap});

  final String text;
  final _OptionVisualState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground, Color border, IconData? icon) = switch (state) {
      _OptionVisualState.correct => (StudlokColors.accent, Colors.black, StudlokColors.accent, LucideIcons.check),
      _OptionVisualState.incorrect => (StudlokColors.warning.withValues(alpha: 0.16), StudlokColors.textPrimary, StudlokColors.warning, LucideIcons.x),
      _OptionVisualState.dimmed => (StudlokColors.surface, StudlokColors.textSecondary, Colors.transparent, null),
      _OptionVisualState.neutral => (StudlokColors.surface, StudlokColors.textPrimary, Colors.transparent, null),
    };

    return GestureDetector(
      onTap: state == _OptionVisualState.neutral ? onTap : null,
      child: AnimatedScale(
        scale: state == _OptionVisualState.correct || state == _OptionVisualState.incorrect ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: foreground,
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: StudlokSpacing.sm),
                AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.elasticOut,
                  child: Icon(icon, color: foreground, size: 20),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.correctCount,
    required this.total,
    this.questions,
    this.generatedQuizId,
    this.pack,
  });

  final int correctCount;
  final int total;

  /// Carried through so "Try again" re-enters the same source (pack or
  /// generated quiz) instead of always falling back to General Knowledge.
  final List<QuizQuestion>? questions;
  final String? generatedQuizId;
  final QuestionPack? pack;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  final _bridge = StudlokNativeBridge();
  final _historyStore = SessionHistoryStore();
  final _courseMaterialRepository = CourseMaterialRepository.instance;
  final _passThresholdStore = PassThresholdStore();

  // Starts at the original hardcoded default so this renders immediately
  // with no loading state of its own — a result screen is a completion
  // moment, not a place to show a spinner. Corrected via setState the
  // moment the real (near-instant, local) value loads, in the rare case
  // someone has actually changed it from the default.
  int _passThresholdPercent = PassThresholdStore.defaultPercent;

  bool get _passed => widget.correctCount / widget.total >= _passThresholdPercent / 100;

  bool _claiming = false;
  bool _claimed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPassThreshold();
  }

  Future<void> _loadPassThreshold() async {
    final percent = await _passThresholdStore.load();
    if (!mounted) return;
    setState(() => _passThresholdPercent = percent);
  }

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
      final generatedQuizId = widget.generatedQuizId;
      if (generatedQuizId != null) {
        unawaited(_courseMaterialRepository.recordAttempt(
          quizId: generatedQuizId,
          correctCount: widget.correctCount,
          totalCount: widget.total,
        ));
      }
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
      MaterialPageRoute(
        builder: (_) => QuizScreen(questions: widget.questions, generatedQuizId: widget.generatedQuizId, pack: widget.pack),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudlokColors.background,
      appBar: AppBar(title: const Text('RESULTS')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(StudlokSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                _passed ? LucideIcons.circleCheck : LucideIcons.circleX,
                size: 64,
                color: _passed ? StudlokColors.accent : StudlokColors.warning,
              ),
              const SizedBox(height: StudlokSpacing.xl),
              Text(
                '${widget.correctCount}/${widget.total} CORRECT',
                textAlign: TextAlign.center,
                style: StudlokTypography.headline.copyWith(color: StudlokColors.textPrimary),
              ),
              const SizedBox(height: StudlokSpacing.sm),
              Text(
                _passed
                    ? 'You passed. Claim your scroll time.'
                    : 'Need $_passThresholdPercent% to earn scroll time — give it another go.',
                textAlign: TextAlign.center,
                style: StudlokTypography.body.copyWith(color: StudlokColors.textSecondary),
              ),
              if (_error != null) ...[
                const SizedBox(height: StudlokSpacing.lg),
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: StudlokColors.warning)),
              ],
              const Spacer(),
              if (_passed) ...[
                if (_claimed)
                  StudlokButton(label: 'BACK TO HOME', onPressed: () => Navigator.of(context).pop())
                else
                  StudlokButton(label: 'CLAIM SCROLL TIME', onPressed: _claiming ? null : _claim),
              ] else ...[
                StudlokButton(label: 'TRY AGAIN', onPressed: _retry),
                const SizedBox(height: StudlokSpacing.sm),
                StudlokButton(label: 'BACK TO HOME', tier: StudlokButtonTier.tertiary, onPressed: () => Navigator.of(context).pop()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
