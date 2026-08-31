import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'quiz_bank.dart';

export 'quiz_bank.dart' show QuizQuestion;

/// A quiz generated from a user's own uploaded notes (Pro feature).
class GeneratedQuiz {
  const GeneratedQuiz({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.questions,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final List<QuizQuestion> questions;
}

/// Any failure anywhere in the upload/generate pipeline, carrying a message
/// that's already safe to show directly in the UI — callers never need to
/// interpret a raw exception themselves.
class QuizGenerationException implements Exception {
  const QuizGenerationException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CourseMaterialRepository {
  CourseMaterialRepository._();
  static final CourseMaterialRepository instance = CourseMaterialRepository._();

  SupabaseClient get _client => Supabase.instance.client;

  static const _bucket = 'course-materials';

  /// Mirrors the bucket's own file_size_limit (supabase/storage.sql) so a
  /// too-large file fails immediately, not after a slow upload.
  static const maxFileSizeBytes = 20 * 1024 * 1024;
  static const allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'heic'];

  /// Uploads [bytes] to Storage and records it in course_materials. Split
  /// from [generateQuiz] so a generation-only failure can retry without
  /// re-uploading the file. Returns the new course_materials row id.
  Future<String> uploadMaterial({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    required String title,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const QuizGenerationException('You need to be signed in to do this.');
    }
    if (bytes.isEmpty) {
      throw const QuizGenerationException('That file appears to be empty.');
    }
    if (bytes.length > maxFileSizeBytes) {
      throw const QuizGenerationException('That file is too large — the limit is 20MB.');
    }

    // "<user_id>/..." — required by the storage RLS policy in storage.sql.
    final storagePath = '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$filename';

    try {
      await _client.storage.from(_bucket).uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: false),
          );
    } on StorageException catch (e) {
      throw QuizGenerationException("Couldn't upload that file: ${e.message}");
    } catch (_) {
      throw const QuizGenerationException("Couldn't upload that file. Check your connection and try again.");
    }

    try {
      final materialRow = await _client
          .from('course_materials')
          .insert({'user_id': user.id, 'title': title, 'storage_path': storagePath})
          .select()
          .single();
      return materialRow['id'] as String;
    } catch (_) {
      throw const QuizGenerationException("Uploaded the file but couldn't save it. Try again.");
    }
  }

  /// Calls the generate-quiz edge function for an already-uploaded material.
  /// [fallbackTitle] labels the questions if the server response omits a
  /// title. Every failure mode (network, daily cap, unreadable content)
  /// surfaces as a [QuizGenerationException] with a message ready to show.
  Future<GeneratedQuiz> generateQuiz(String courseMaterialId, {required String fallbackTitle}) async {
    final FunctionResponse response;
    try {
      response = await _client.functions.invoke(
        'generate-quiz',
        body: {'course_material_id': courseMaterialId},
      );
    } on FunctionException catch (e) {
      throw QuizGenerationException(_messageFor(e));
    } catch (_) {
      throw const QuizGenerationException("Couldn't reach the server. Check your connection and try again.");
    }

    final data = response.data;
    if (data is! Map) {
      throw const QuizGenerationException('Something went wrong generating your quiz.');
    }

    return _parseGeneratedQuiz(Map<String, dynamic>.from(data), fallbackTitle: fallbackTitle);
  }

  Future<List<GeneratedQuiz>> listGeneratedQuizzes() async {
    try {
      final rows = await _client
          .from('generated_quizzes')
          .select('id, created_at, questions, course_materials(title)')
          .order('created_at', ascending: false);
      return (rows as List)
          .map((row) => _parseGeneratedQuiz(Map<String, dynamic>.from(row as Map), fallbackTitle: 'Your notes'))
          .toList();
    } catch (_) {
      throw const QuizGenerationException("Couldn't load your quizzes. Check your connection and try again.");
    }
  }

  /// Best-effort attempt log — this is history, not the reward moment
  /// itself, so a failure here is swallowed rather than shown to the user.
  Future<void> recordAttempt({
    required String quizId,
    required int correctCount,
    required int totalCount,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    try {
      await _client.from('quiz_attempts').insert({
        'user_id': user.id,
        'quiz_id': quizId,
        'correct_count': correctCount,
        'total_count': totalCount,
      });
    } catch (e) {
      // ignore: avoid_print
      print('[CourseMaterialRepository] recordAttempt failed: $e');
    }
  }

  GeneratedQuiz _parseGeneratedQuiz(Map<String, dynamic> row, {required String fallbackTitle}) {
    var title = fallbackTitle;
    final materialJoin = row['course_materials'];
    if (materialJoin is Map && materialJoin['title'] is String) {
      title = materialJoin['title'] as String;
    }

    final questions = <QuizQuestion>[];
    final questionsRaw = row['questions'];
    if (questionsRaw is List) {
      for (final q in questionsRaw) {
        if (q is! Map) continue;
        final options = q['options'];
        if (options is! List) continue;
        questions.add(QuizQuestion(
          subject: title,
          question: q['question'] as String? ?? '',
          options: options.map((o) => o.toString()).toList(),
          correctIndex: q['correct_index'] as int? ?? 0,
        ));
      }
    }

    return GeneratedQuiz(
      id: row['id'] as String,
      title: title,
      createdAt: DateTime.parse(row['created_at'] as String),
      questions: questions,
    );
  }

  String _messageFor(FunctionException e) {
    final details = e.details;
    if (details is Map && details['error'] is String) {
      return details['error'] as String;
    }
    switch (e.status) {
      case 0:
        return "Couldn't reach the server. Check your connection and try again.";
      case 401:
        return 'Your session expired — sign in again.';
      case 429:
        return "You've hit today's generation limit. Try again tomorrow.";
      case 404:
        return "Couldn't find that upload. Try again.";
      case 422:
        return "Couldn't generate a clean quiz from that file. Try a clearer photo or a different file.";
      default:
        return 'Something went wrong generating your quiz.';
    }
  }
}
