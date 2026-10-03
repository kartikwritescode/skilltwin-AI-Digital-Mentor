import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/session_step.dart';
import '../../../../core/widgets/skilltwin_markdown.dart';
import '../providers/session_state_provider.dart';

class StepExplanationView extends ConsumerWidget {
  final SessionStep step;
  final String sessionId;

  const StepExplanationView({super.key, required this.step, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXPLAIN IT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryAccent,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        SkillTwinMarkdown(
          data: step.content['question'] ?? 'Explain this concept to your mentor.',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.35,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Use your own words. Your mentor will analyze your reasoning to identify any gaps.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, height: 1.4),
        ),
        const SizedBox(height: 24),
        TextField(
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Start explaining...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppTheme.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppTheme.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppTheme.primaryAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
          onChanged: (val) => ref.read(sessionStateProvider(sessionId).notifier).updateEvidence(step.id, val),
        ),
        const SizedBox(height: 20),
        _VoiceTeachButton(onPressed: () {
          context.push('/teach/${step.id}');
        }),
      ],
    );
  }
}

class _VoiceTeachButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _VoiceTeachButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryAccent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppTheme.primaryAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TEACH WITH VOICE',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                      color: AppTheme.primaryAccent,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Faster, conversational, and natural',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.primaryAccent),
          ],
        ),
      ),
    );
  }
}
