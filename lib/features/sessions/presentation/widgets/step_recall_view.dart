import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/session_step.dart';
import '../../../../core/widgets/skilltwin_twin.dart';
import '../../../../core/widgets/skilltwin_markdown.dart';
import '../providers/session_state_provider.dart';

class StepRecallView extends ConsumerWidget {
  final SessionStep step;
  final String sessionId;

  const StepRecallView({super.key, required this.step, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            SkillTwinTwin(asset: TwinAsset.focused, size: 24),
            SizedBox(width: 8),
            Text(
              'QUICK RECALL',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryAccent, letterSpacing: 1.2),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SkillTwinMarkdown(
          data: step.content['question'] ?? 'What do you remember about this?',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 28),
        TextField(
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Type a brief answer...',
            hintStyle: const TextStyle(color: AppTheme.textMuted),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
          onChanged: (val) => ref.read(sessionStateProvider(sessionId).notifier).updateEvidence(step.id, val),
        ),
      ],
    );
  }
}
