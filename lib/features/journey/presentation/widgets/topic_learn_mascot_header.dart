import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/mastery_format.dart';

/// Friendly, teaching mascot companion header for the Understand / Learn topic screen.
/// Establishes an encouraging mentor vibe without cluttering reading once the learner scrolls.
class TopicLearnMascotHeader extends StatelessWidget {
  final String topicTitle;
  final String difficulty;
  final int estimatedMinutes;
  final double masteryScore;
  final String status;
  final String? companionMessage;

  const TopicLearnMascotHeader({
    super.key,
    required this.topicTitle,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.masteryScore,
    required this.status,
    this.companionMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryAccent.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryAccent.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Mascot in Teaching / Guiding Pose ──
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryAccent.withValues(alpha: 0.14),
                      AppTheme.primaryAccent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/mascots/twin_journey_point.webp',
                width: 82,
                height: 82,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/mascots/twin_journey_guide.webp',
                    width: 82,
                    height: 82,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/mascots/twin_mentor.webp',
                        width: 82,
                        height: 82,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.school_rounded,
                            size: 56,
                            color: AppTheme.primaryAccent,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Mascot Speech Badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryAccent.withValues(alpha: 0.20),
              ),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: AppTheme.primaryAccent,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Let's make this click.",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryAccent,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Topic / Concept Title ──
          Text(
            topicTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // ── Metadata Chips: Difficulty, Time, Mastery, Status ──
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetaChip(
                icon: Icons.speed_rounded,
                label: difficulty.toUpperCase(),
                color: _getDifficultyColor(difficulty),
              ),
              _buildMetaChip(
                icon: Icons.schedule_rounded,
                label: '~$estimatedMinutes MIN',
                color: AppTheme.textSecondary,
              ),
              if (masteryScore > 0)
                _buildMetaChip(
                  icon: Icons.insights_rounded,
                  label: '${masteryScore.toMasteryPercentage}% MASTERY',
                  color: const Color(0xFF10B981),
                ),
              _buildStatusChip(status),
            ],
          ),

          const SizedBox(height: 14),

          // ── Companion Microcopy ──
          Text(
            companionMessage ??
                "I'll walk you through the core intuition, practical examples, and rules. You've got this — one piece at a time.",
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4.5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
        bg = const Color(0xFF10B981).withValues(alpha: 0.12);
        fg = const Color(0xFF059669);
        label = 'COMPLETED';
        break;
      case 'learning':
        bg = AppTheme.primaryAccent.withValues(alpha: 0.12);
        fg = AppTheme.primaryAccent;
        label = 'IN PROGRESS';
        break;
      case 'needs_revision':
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        label = 'NEEDS REVISION';
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
        label = 'READY TO LEARN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF10B981);
      case 'intermediate':
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'advanced':
      case 'hard':
        return const Color(0xFFEF4444);
      default:
        return AppTheme.primaryAccent;
    }
  }
}
