import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/session_step.dart';
import '../providers/session_state_provider.dart';

class StepQuestionView extends ConsumerWidget {
  final SessionStep step;
  final String sessionId;

  const StepQuestionView({super.key, required this.step, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final question = step.content['question'] ?? step.content['problem'] ?? '';
    final options = step.content['options'] as List?;
    final selectedOption = ref.watch(sessionStateProvider(sessionId)).evidence[step.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 32),
        if (options != null)
          ...options.map((option) => _OptionTile(
                text: option.toString(),
                isSelected: selectedOption == option,
                onTap: () => ref.read(sessionStateProvider(sessionId).notifier).updateEvidence(step.id, option),
              ))
        else
          TextField(
            maxLines: 1,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Type your answer...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
            onChanged: (value) =>
                ref.read(sessionStateProvider(sessionId).notifier).updateEvidence(step.id, value),
          ),
        if (step.content['hint'] != null) ...[
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hint: ${step.content['hint']}'),
                  backgroundColor: Colors.grey.shade800,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: const Icon(Icons.lightbulb_outline, size: 18),
            label: const Text('I need a hint'),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
          ),
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.grey.shade200,
              width: 2,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (isSelected) 
                const Icon(Icons.check_circle, color: Colors.white)
              else
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
