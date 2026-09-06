import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/session_step.dart';
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
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1.2),
        ),
        const SizedBox(height: 16),
        Text(
          step.content['question'] ?? 'Explain this concept to your mentor.',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
        ),
        const SizedBox(height: 12),
        Text(
          'Use your own words. Your mentor will analyze your reasoning to identify any gaps.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 32),
        TextField(
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Start explaining...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(24),
          ),
          onChanged: (val) => ref.read(sessionStateProvider(sessionId).notifier).updateEvidence(step.id, val),
        ),
        const SizedBox(height: 24),
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
          color: Colors.orange.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              child: const Icon(Icons.mic, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TEACH WITH VOICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange)),
                Text('Faster and more natural', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}
