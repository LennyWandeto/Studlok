import 'package:flutter/material.dart';

import '../theme/studlok_theme.dart';
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
      appBar: AppBar(title: const Text('CHOOSE A QUIZ')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ElevatedButton(onPressed: _openPracticeBank, child: const Text('PRACTICE BANK')),
              const SizedBox(height: 4),
              const Text(
                'A quick mixed-subject set — always available.',
                style: TextStyle(color: StudlokColors.dimWhite, fontSize: 13),
              ),
              const SizedBox(height: 32),
              const Text(
                'YOUR QUIZZES',
                style: TextStyle(color: StudlokColors.white, fontWeight: FontWeight.w900, letterSpacing: 1.1),
              ),
              const SizedBox(height: 12),
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
        Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _load, child: const Text('Try again')),
      ];
    }

    final quizzes = _quizzes;
    if (quizzes == null) {
      return const [Center(child: CircularProgressIndicator(color: StudlokColors.accent))];
    }

    if (quizzes.isEmpty) {
      return [
        const Text(
          'Upload a photo or PDF of your notes and we\'ll turn it into a quiz.',
          style: TextStyle(color: StudlokColors.dimWhite, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: _openUpload, child: const Text('UPLOAD YOUR NOTES')),
      ];
    }

    return [
      for (final quiz in quizzes) _GeneratedQuizTile(quiz: quiz, onTap: () => _openGeneratedQuiz(quiz)),
      const SizedBox(height: 8),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.add_circle_outline, color: StudlokColors.accent),
        title: const Text('Upload new notes', style: TextStyle(color: StudlokColors.white, fontWeight: FontWeight.w700)),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        tileColor: StudlokColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: const Icon(Icons.quiz_outlined, color: StudlokColors.accent),
        title: Text(
          quiz.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: StudlokColors.white, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(_formatDate(quiz.createdAt), style: const TextStyle(color: StudlokColors.dimWhite)),
        trailing: Text(
          '${quiz.questions.length}Q',
          style: const TextStyle(color: StudlokColors.accent, fontWeight: FontWeight.w800),
        ),
        onTap: onTap,
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
