import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../design/components/studlok_button.dart';
import '../design/components/studlok_option_card.dart';
import '../design/components/studlok_press_feedback.dart';
import '../design/components/studlok_surface.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../design/studlok_typography.dart';
import 'course_material_repository.dart';
import 'course_material_upload_screen.dart';
import 'quiz_screen.dart';

/// Pro-only entry point shown instead of jumping straight into [QuizScreen]:
/// lets a Pro user pick the hardcoded practice bank or one of their own
/// AI-generated quizzes, or upload new notes. Free users never see this —
/// the home screen routes them straight into [QuizScreen] unchanged.
class QuizSourceScreen extends StatefulWidget {
  const QuizSourceScreen({super.key});

  @override
  State<QuizSourceScreen> createState() => _QuizSourceScreenState();
}

class _QuizSourceScreenState extends State<QuizSourceScreen> {
  final _repository = CourseMaterialRepository.instance;

  List<GeneratedQuiz>? _quizzes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final quizzes = await _repository.listGeneratedQuizzes();
      if (!mounted) return;
      setState(() => _quizzes = quizzes);
    } on QuizGenerationException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  void _openPracticeBank() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuizScreen()));
  }

  void _openGeneratedQuiz(GeneratedQuiz quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(questions: quiz.questions, generatedQuizId: quiz.id),
      ),
    );
  }

  Future<void> _openUpload() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CourseMaterialUploadScreen()),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudlokColors.background,
      appBar: AppBar(title: const Text('CHOOSE A QUIZ')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: StudlokColors.accent,
          backgroundColor: StudlokColors.surface,
          child: ListView(
            padding: const EdgeInsets.all(StudlokSpacing.xl),
            children: [
              StudlokOptionCard(
                icon: LucideIcons.libraryBig,
                title: 'PRACTICE BANK',
                subtitle: 'A quick mixed-subject set — always available.',
                onTap: _openPracticeBank,
              ),
              const SizedBox(height: StudlokSpacing.xxl),
              const Text(
                'YOUR QUIZZES',
                style: TextStyle(color: StudlokColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: 1.1, fontSize: 13),
              ),
              const SizedBox(height: StudlokSpacing.md),
              ..._buildYourQuizzesSection(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildYourQuizzesSection() {
    if (_error != null) {
      return [
        Text(_error!, style: const TextStyle(color: StudlokColors.warning, fontSize: 14)),
        const SizedBox(height: StudlokSpacing.md),
        StudlokButton(label: 'TRY AGAIN', tier: StudlokButtonTier.secondary, onPressed: _load),
      ];
    }

    final quizzes = _quizzes;
    if (quizzes == null) {
      return const [Padding(padding: EdgeInsets.all(StudlokSpacing.xl), child: Center(child: CircularProgressIndicator(color: StudlokColors.accent)))];
    }

    if (quizzes.isEmpty) {
      return [
        StudlokOptionCard(
          icon: LucideIcons.brain,
          title: 'UPLOAD YOUR NOTES',
          subtitle: "We'll turn a photo or PDF into a quiz.",
          onTap: _openUpload,
        ),
      ];
    }

    return [
      for (final quiz in quizzes) _GeneratedQuizTile(quiz: quiz, onTap: () => _openGeneratedQuiz(quiz)),
      const SizedBox(height: StudlokSpacing.sm),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(LucideIcons.plus, color: StudlokColors.accent),
        title: Text('Upload new notes', style: StudlokTypography.bodyEmphasis.copyWith(color: StudlokColors.textPrimary, fontSize: 15)),
        onTap: _openUpload,
      ),
    ];
  }
}

class _GeneratedQuizTile extends StatelessWidget {
  const _GeneratedQuizTile({required this.quiz, required this.onTap});

  final GeneratedQuiz quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: StudlokSpacing.sm),
      child: StudlokPressFeedback(
        onTap: onTap,
        child: StudlokSurface(
          child: Row(
            children: [
              const Icon(LucideIcons.bookOpen, color: StudlokColors.accent),
              const SizedBox(width: StudlokSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      overflow: TextOverflow.ellipsis,
                      style: StudlokTypography.bodyEmphasis.copyWith(color: StudlokColors.textPrimary, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(_formatDate(quiz.createdAt), style: StudlokTypography.caption.copyWith(color: StudlokColors.textSecondary)),
                  ],
                ),
              ),
              Text(
                '${quiz.questions.length}Q',
                style: StudlokTypography.bodyEmphasis.copyWith(color: StudlokColors.accent, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
