import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../providers/teach_mode_provider.dart';
import '../widgets/teach_mascot_header.dart';
import '../widgets/teach_evaluation_report_view.dart';

/// Standalone Understanding / Evaluation Report Screen for Feynman Teach Mode.
/// Accessible directly at /teach/report.
class TeachModeReportScreen extends ConsumerWidget {
  const TeachModeReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teachModeProvider);
    final report = state.report;

    if (report == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Understanding Report',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const SkillTwinBackground(
          child: Center(
            child: Text(
              'No report available.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ),
          ),
        ),
      );
    }

    final hasMisconceptions = state.misconceptions.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Understanding Report',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            ref.read(teachModeProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
      body: SkillTwinBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              TeachMascotHeader(
                status: state.status,
                isMastered: state.isMastered,
                hasMisconceptions: hasMisconceptions,
                mascotSize: 84,
                isDark: false,
              ),
              const SizedBox(height: 20),
              TeachEvaluationReportView(
                report: report,
                isDark: false,
                onTeachAgain: () {
                  ref.read(teachModeProvider.notifier).init(
                        state.conceptId ?? '',
                        state.conceptTitle ?? 'Concept',
                        state.mentorPrompt ?? 'Explain this concept in your own words.',
                      );
                  context.pop();
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
