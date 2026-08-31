import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../theme/studlok_theme.dart';
import 'course_material_repository.dart';
import 'quiz_screen.dart';

const _allowedExtensions = CourseMaterialRepository.allowedExtensions;

const Map<String, String> _mimeByExtension = {
  'pdf': 'application/pdf',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'heic': 'image/heic',
};

enum _Stage { idle, uploading, generating, success, error }

/// Where an [_Stage.error] happened — decides what "try again" actually
/// retries, and whether "choose a different file" is offered.
enum _FailedAt { upload, generation }

class CourseMaterialUploadScreen extends StatefulWidget {
  const CourseMaterialUploadScreen({super.key});

  @override
  State<CourseMaterialUploadScreen> createState() => _CourseMaterialUploadScreenState();
}

class _CourseMaterialUploadScreenState extends State<CourseMaterialUploadScreen> {
  final _repository = CourseMaterialRepository.instance;

  _Stage _stage = _Stage.idle;
  _FailedAt? _failedAt;
  String? _errorMessage;

  PlatformFile? _pickedFile;
  Uint8List? _pickedBytes;

  // Set once the upload step succeeds, so a generation-only retry doesn't
  // re-upload the file.
  String? _courseMaterialId;

  GeneratedQuiz? _generatedQuiz;

  Future<void> _pickFile() async {
    final PlatformFile? file;
    try {
      file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: _allowedExtensions);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open the file picker. Try again.")),
      );
      return;
    }
    if (file == null) return; // user cancelled — not an error, just a no-op

    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _pickedFile = file;
      _pickedBytes = bytes;
      _stage = _Stage.idle;
    });
  }

  Future<void> _generate() async {
    final file = _pickedFile;
    final bytes = _pickedBytes;
    if (file == null || bytes == null) return;

    final title = file.name;
    final mimeType = _mimeByExtension[file.extension?.toLowerCase()] ?? 'application/octet-stream';

    setState(() => _stage = _Stage.uploading);

    String materialId;
    try {
      materialId = _courseMaterialId ?? await _repository.uploadMaterial(
        bytes: bytes,
        filename: file.name,
        mimeType: mimeType,
        title: title,
      );
    } on QuizGenerationException catch (e) {
      _showError(e.message, failedAt: _FailedAt.upload);
      return;
    }

    if (!mounted) return;
    setState(() {
      _courseMaterialId = materialId;
      _stage = _Stage.generating;
    });

    try {
      final quiz = await _repository.generateQuiz(materialId, fallbackTitle: title);
      if (!mounted) return;
      setState(() {
        _generatedQuiz = quiz;
        _stage = _Stage.success;
      });
    } on QuizGenerationException catch (e) {
      _showError(e.message, failedAt: _FailedAt.generation);
    }
  }

  void _showError(String message, {required _FailedAt failedAt}) {
    if (!mounted) return;
    setState(() {
      _stage = _Stage.error;
      _errorMessage = message;
      _failedAt = failedAt;
    });
  }

  void _chooseDifferentFile() {
    setState(() {
      _pickedFile = null;
      _pickedBytes = null;
      _courseMaterialId = null;
      _stage = _Stage.idle;
    });
    _pickFile();
  }

  void _takeQuizNow() {
    final quiz = _generatedQuiz;
    if (quiz == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizScreen(questions: quiz.questions, generatedQuizId: quiz.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UPLOAD NOTES')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (_stage) {
            _Stage.idle => _buildIdle(),
            _Stage.uploading => _buildBusy('Uploading your notes…'),
            _Stage.generating => _buildBusy('Generating your quiz…'),
            _Stage.success => _buildSuccess(),
            _Stage.error => _buildError(),
          },
        ),
      ),
    );
  }

  Widget _buildIdle() {
    final file = _pickedFile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Turn your notes into a quiz.',
          style: TextStyle(color: StudlokColors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.1),
        ),
        const SizedBox(height: 8),
        const Text(
          'A photo or PDF of your notes, turned into a set of questions you can earn scroll time with.',
          style: TextStyle(color: StudlokColors.dimWhite, fontSize: 15, height: 1.4),
        ),
        const SizedBox(height: 32),
        if (file != null) ...[
          _FileTile(file: file, sizeBytes: _pickedBytes?.length ?? 0),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _generate, child: const Text('GENERATE QUIZ')),
          const SizedBox(height: 8),
          TextButton(onPressed: _pickFile, child: const Text('Choose a different file')),
        ] else
          ElevatedButton(onPressed: _pickFile, child: const Text('CHOOSE A FILE')),
        const Spacer(),
        Text(
          'PDF, JPG, PNG, or HEIC — up to 20MB.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: StudlokColors.dimWhite, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBusy(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: StudlokColors.accent),
        const SizedBox(height: 20),
        Text(label, style: const TextStyle(color: StudlokColors.dimWhite, fontSize: 15)),
      ],
    );
  }

  Widget _buildSuccess() {
    final quiz = _generatedQuiz!;
    // The one authored motion moment in this flow: a real completion, not
    // decoration — the same reward feeling as passing a quiz.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.94 + (0.06 * t), child: child),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Icon(Icons.check_circle_outline, size: 72, color: StudlokColors.accent),
          const SizedBox(height: 24),
          Text(
            '${quiz.questions.length} QUESTIONS READY',
            textAlign: TextAlign.center,
            style: const TextStyle(color: StudlokColors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.1),
          ),
          const SizedBox(height: 8),
          Text(
            'From "${quiz.title}"',
            textAlign: TextAlign.center,
            style: const TextStyle(color: StudlokColors.dimWhite, fontSize: 15),
          ),
          const Spacer(),
          ElevatedButton(onPressed: _takeQuizNow, child: const Text('TAKE THIS QUIZ NOW')),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Done — I\'ll take it later'),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    final failedAt = _failedAt!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
        const SizedBox(height: 20),
        Text(
          _errorMessage ?? 'Something went wrong.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: StudlokColors.white, fontSize: 16, height: 1.4),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: _generate,
          child: Text(failedAt == _FailedAt.upload ? 'TRY UPLOAD AGAIN' : 'TRY AGAIN'),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: _chooseDifferentFile, child: const Text('Choose a different file')),
      ],
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({required this.file, required this.sizeBytes});

  final PlatformFile file;
  final int sizeBytes;

  IconData get _icon => switch (file.extension?.toLowerCase()) {
        'pdf' => Icons.picture_as_pdf_outlined,
        _ => Icons.image_outlined,
      };

  String get _sizeLabel {
    final kb = sizeBytes / 1024;
    if (kb < 1024) return '${kb.round()} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudlokColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_icon, color: StudlokColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: StudlokColors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(_sizeLabel, style: const TextStyle(color: StudlokColors.dimWhite, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
