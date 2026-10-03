import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/session_step.dart';
import '../../../../core/widgets/skilltwin_markdown.dart';
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
        // ── Small Mascot Companion ──
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryAccent.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Image.asset(
                  selectedOption != null
                      ? 'assets/mascots/twin_mentor_thinking.webp'
                      : 'assets/mascots/twin_curious.webp',
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.psychology_alt_rounded,
                    color: AppTheme.primaryAccent,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryAccent.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  selectedOption != null
                      ? "Good choice. Ready to check?"
                      : "Take your time. Think through the logic.",
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // ── Question Text ──
        SkillTwinMarkdown(
          data: question,
          style: const TextStyle(
            fontSize: 17.5,
            height: 1.45,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 22),

        // ── Options with Letter Badges ──
        if (options != null)
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value.toString();
            final letter = String.fromCharCode(65 + index);
            return _OptionTile(
              letter: letter,
              text: option,
              isSelected: selectedOption == option,
              onTap: () => ref
                  .read(sessionStateProvider(sessionId).notifier)
                  .updateEvidence(step.id, option),
            );
          })
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
              contentPadding: const EdgeInsets.all(18),
            ),
            onChanged: (value) =>
                ref.read(sessionStateProvider(sessionId).notifier).updateEvidence(step.id, value),
          ),
        if (step.content['hint'] != null) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hint: ${step.content['hint']}'),
                  backgroundColor: AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: const Icon(Icons.lightbulb_outline, size: 18),
            label: const Text('I need a hint'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryAccent),
          ),
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.letter,
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
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryAccent.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primaryAccent : AppTheme.cardBorder,
              width: isSelected ? 1.8 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryAccent
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.primaryAccent : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.radio_button_checked,
                    color: AppTheme.primaryAccent, size: 20)
              else
                Icon(Icons.radio_button_off,
                    color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
