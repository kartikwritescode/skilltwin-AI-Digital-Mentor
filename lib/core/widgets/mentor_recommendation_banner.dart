import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_theme.dart';
import '../models/mentor_recommendation.dart';
import 'skilltwin_twin.dart';

class MentorRecommendationBanner extends StatelessWidget {
  final MentorRecommendation recommendation;
  final VoidCallback? onActionTap;
  final String? customActionLabel;
  final String? sectionContext;

  const MentorRecommendationBanner({
    super.key,
    required this.recommendation,
    this.onActionTap,
    this.customActionLabel,
    this.sectionContext,
  });

  @override
  Widget build(BuildContext context) {
    final isPracticeOrSession =
        recommendation.type == RecommendationType.practice ||
            recommendation.type == RecommendationType.remediation ||
            recommendation.type == RecommendationType.newConcept;

    final actionLabel = customActionLabel ??
        (recommendation.type == RecommendationType.revision
            ? 'Start Retrieval'
            : 'Start Personalized Session');

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: AppColors.border,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header badge row with mini companion avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 13,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            sectionContext != null
                                ? 'Mentor Focus • $sectionContext'
                                : 'Mentor Recommendation',
                            style: AppTypography.label.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SkillTwinTwin.focused(
                      size: 32,
                      isDecorative: true,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Recommendation Title
                Text(
                  recommendation.title,
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),

                // Why today / Cognitive Rationale
                Text(
                  recommendation.reason.isNotEmpty
                      ? recommendation.reason
                      : 'Prioritized by your cognitive mentor based on recent retrieval performance.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (onActionTap != null) {
                            onActionTap!();
                          } else if (recommendation.type ==
                              RecommendationType.revision) {
                            context.push('/revision');
                          } else if (isPracticeOrSession) {
                            final targetId =
                                recommendation.conceptId ?? recommendation.id;
                            context.push('/session/$targetId');
                          } else {
                            context.push('/mentor');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              actionLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          context.push('/mentor');
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 15),
                        label: const Text(
                          'Ask Why',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textPrimary,
                          side: BorderSide(
                              color: AppTheme.cardBorder, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
