import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/teach_mode_provider.dart';

/// Contextual mascot companion header that visually communicates:
/// - "I'm listening. Teach me." (Listening / Curious)
/// - "Take your time. I'm listening." (Recording)
/// - "Your Twin is thinking..." (Processing / Evaluating with GIF)
/// - "Okay, you actually taught me something." (Mastered / Celebrate)
/// - "You've got the idea. Let's tighten up one part." (Misconceptions / Mentor)
class TeachMascotHeader extends StatelessWidget {
  final TeachModeStatus status;
  final bool isMastered;
  final bool hasMisconceptions;
  final String? customSpeech;
  final double mascotSize;
  final bool isDark;

  const TeachMascotHeader({
    super.key,
    required this.status,
    this.isMastered = false,
    this.hasMisconceptions = false,
    this.customSpeech,
    this.mascotSize = 88,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = _resolveAssetPath();
    final speechText = customSpeech ?? _resolveSpeechText();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mascot image container with soft glow
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: mascotSize + 24,
              height: mascotSize + 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accentGlowColor().withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Image.asset(
              assetPath,
              width: mascotSize,
              height: mascotSize,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.psychology_outlined,
                size: mascotSize * 0.7,
                color: AppTheme.primaryAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Mascot Speech Bubble
        Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2238) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  speechText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _resolveAssetPath() {
    switch (status) {
      case TeachModeStatus.ready:
      case TeachModeStatus.recording:
        return 'assets/mascots/twin_curious.webp';
      case TeachModeStatus.processing:
      case TeachModeStatus.evaluating:
        return 'assets/mascots/skilltwin_mascot_loading.gif';
      case TeachModeStatus.result:
        if (hasMisconceptions) {
          return 'assets/mascots/twin_mentor.webp';
        }
        if (isMastered) {
          return 'assets/mascots/twin_celebrate.webp';
        }
        return 'assets/mascots/twin_cool.webp';
      case TeachModeStatus.completed:
        return 'assets/mascots/twin_celebrate.webp';
    }
  }

  String _resolveSpeechText() {
    switch (status) {
      case TeachModeStatus.ready:
        return "I'm listening. Teach me.";
      case TeachModeStatus.recording:
        return "Take your time. I'm listening.";
      case TeachModeStatus.processing:
        return "Your Twin is thinking...";
      case TeachModeStatus.evaluating:
        return "Evaluating your explanation...";
      case TeachModeStatus.result:
        if (hasMisconceptions) {
          return "You've got the idea. Let's tighten up one part.";
        }
        if (isMastered) {
          return "Okay, you actually taught me something.";
        }
        return "Good explanation! Here's how it broke down.";
      case TeachModeStatus.completed:
        return "You've got this concept down.";
    }
  }

  Color _accentGlowColor() {
    switch (status) {
      case TeachModeStatus.ready:
        return const Color(0xFF6366F1);
      case TeachModeStatus.recording:
        return const Color(0xFFEF4444);
      case TeachModeStatus.processing:
      case TeachModeStatus.evaluating:
        return const Color(0xFFF59E0B);
      case TeachModeStatus.result:
        return hasMisconceptions ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
      case TeachModeStatus.completed:
        return const Color(0xFF10B981);
    }
  }
}
