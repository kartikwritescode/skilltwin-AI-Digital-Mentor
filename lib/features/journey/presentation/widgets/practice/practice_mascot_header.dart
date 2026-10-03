import 'package:flutter/material.dart';
import '../../../../../app/theme/app_theme.dart';

enum PracticeMascotMood {
  start,
  thinking,
  correct,
  incorrect,
  completion,
}

/// Small, non-cluttering mascot companion for practice & assessment.
/// Supports the interaction with encouraging, contextual expressions.
class PracticeMascotHeader extends StatelessWidget {
  final PracticeMascotMood mood;
  final String? customMessage;

  const PracticeMascotHeader({
    super.key,
    required this.mood,
    this.customMessage,
  });

  String _getMascotAsset() {
    switch (mood) {
      case PracticeMascotMood.start:
        return 'assets/mascots/twin_curious.webp';
      case PracticeMascotMood.thinking:
        return 'assets/mascots/twin_mentor_thinking.webp';
      case PracticeMascotMood.correct:
        return 'assets/mascots/twin_celebrate.webp';
      case PracticeMascotMood.incorrect:
        return 'assets/mascots/twin_mentor.webp';
      case PracticeMascotMood.completion:
        return 'assets/mascots/twin_journey_complete.webp';
    }
  }

  String _getDefaultMessage() {
    switch (mood) {
      case PracticeMascotMood.start:
        return "Let's see what stuck.";
      case PracticeMascotMood.thinking:
        return "Take your time. Think through the logic.";
      case PracticeMascotMood.correct:
        return "Yep. You got that one.";
      case PracticeMascotMood.incorrect:
        return "Not quite. Let's figure out why.";
      case PracticeMascotMood.completion:
        return "Nice. That's another piece locked in.";
    }
  }

  Color _getBadgeColor() {
    switch (mood) {
      case PracticeMascotMood.correct:
        return const Color(0xFF10B981);
      case PracticeMascotMood.incorrect:
        return const Color(0xFFEF4444);
      case PracticeMascotMood.completion:
        return const Color(0xFF6366F1);
      default:
        return AppTheme.primaryAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = _getMascotAsset();
    final message = customMessage ?? _getDefaultMessage();
    final badgeColor = _getBadgeColor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Small, Tasteful Mascot Companion (Non-dominating) ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.88, end: 1.0).animate(animation),
                child: child,
              ),
            ),
            child: Container(
              key: ValueKey<String>(asset),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeColor.withValues(alpha: 0.08),
              ),
              child: Center(
                child: Image.asset(
                  asset,
                  width: 38,
                  height: 38,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.psychology_alt_rounded,
                    color: badgeColor,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ── Contextual Speech Bubble ──
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: badgeColor.withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  message,
                  key: ValueKey<String>(message),
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
