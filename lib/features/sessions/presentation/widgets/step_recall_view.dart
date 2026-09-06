import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/session_step.dart';
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
        const Text(
          'QUICK RECALL',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1.2),
        ),
        const SizedBox(height: 16),
        Text(
          step.content['question'] ?? 'What do you remember about this?',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
        ),
        const SizedBox(height: 32),
        TextField(
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Type a brief answer...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
          onChanged: (val) => ref.read(sessionStateProvider(sessionId).notifier).updateEvidence(step.id, val),
        ),
      ],
    );
  }
}
