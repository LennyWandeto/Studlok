import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../design/components/studlok_option_card.dart';
import '../design/studlok_colors.dart';
import '../design/studlok_spacing.dart';
import '../onboarding/subject_focus_store.dart';
import 'question_stats_store.dart';
import 'quiz_bank.dart';
import 'quiz_screen.dart';
import 'subject_pack_match.dart';

/// The hardcoded-content entry point shared by both tiers — free users land
/// here directly from Sessions' Quiz card, Pro users via "Practice Bank" in
/// QuizSourceScreen. Packs are ordered with the onboarding-subject match (if
/// any) first; each shows how much of it is already mastered.
class PackPickerScreen extends StatefulWidget {
  const PackPickerScreen({super.key});

  @override
  State<PackPickerScreen> createState() => _PackPickerScreenState();
}

class _PackPickerScreenState extends State<PackPickerScreen> {
  List<QuestionPack>? _packs;
  Map<String, List<bool>> _stats = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final focus = await SubjectFocusStore().load();
    final stats = await QuestionStatsStore().loadAll();
    if (!mounted) return;
    setState(() {
      _packs = orderedPacksFor(focus);
      _stats = stats;
    });
  }

  void _openPack(QuestionPack pack) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuizScreen(pack: pack)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final packs = _packs;
    return Scaffold(
      backgroundColor: StudlokColors.background,
      appBar: AppBar(title: const Text('CHOOSE A PACK')),
      body: SafeArea(
        child: packs == null
            ? const Center(child: CircularProgressIndicator(color: StudlokColors.accent))
            : ListView(
                padding: const EdgeInsets.all(StudlokSpacing.xl),
                children: [
                  for (final pack in packs) ...[
                    StudlokOptionCard(
                      icon: _iconFor(pack.id),
                      title: pack.name,
                      subtitle: _subtitleFor(pack),
                      onTap: () => _openPack(pack),
                    ),
                    const SizedBox(height: StudlokSpacing.sm),
                  ],
                ],
              ),
      ),
    );
  }

  String _subtitleFor(QuestionPack pack) {
    final mastered = QuestionStatsStore().masteredCount(pack, _stats);
    return '${pack.description} — $mastered/${pack.questions.length} mastered';
  }

  IconData _iconFor(String packId) => switch (packId) {
        'test_prep' => LucideIcons.graduationCap,
        'cs_coding' => LucideIcons.code,
        _ => LucideIcons.libraryBig,
      };
}
