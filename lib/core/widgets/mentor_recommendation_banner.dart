import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/mentor_recommendation.dart';

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
    final theme = Theme.of(context);
    final isPracticeOrSession = recommendation.type == RecommendationType.practice ||
        recommendation.type == RecommendationType.remediation ||
        recommendation.type == RecommendationType.newConcept;

    final actionLabel = customActionLabel ??
        (recommendation.type == RecommendationType.revision
            ? 'Start 5-Min Retrieval'
            : (recommendation.estimatedMinutes != null
                ? 'Start ${recommendation.estimatedMinutes}m Session'
                : 'Start Session'));

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFFF6D00).withValues(alpha: 0.22),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6D00).withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header badge row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6D00).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: Color(0xFFFF6D00),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            sectionContext != null
                                ? 'MENTOR FOCUS • $sectionContext'
                                : 'MENTOR RECOMMENDATION',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: Color(0xFFFF6D00),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (recommendation.estimatedMinutes != null)
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${recommendation.estimatedMinutes} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Recommendation Title
                Text(
                  recommendation.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    letterSpacing: -0.3,
                    color: const Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 8),

                // Why today / Cognitive Rationale
                Text(
                  recommendation.reason.isNotEmpty
                      ? recommendation.reason
                      : 'Prioritized by your cognitive mentor based on recent retrieval performance and target goal invariants.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 18),

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
                          } else if (recommendation.type == RecommendationType.revision) {
                            context.push('/revision');
                          } else if (isPracticeOrSession) {
                            final targetId = recommendation.conceptId ?? recommendation.id;
                            context.push('/session/$targetId');
                          } else {
                            context.push('/mentor');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6D00),
                          foregroundColor: Colors.white,
                          elevation: 0,
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
                            const Icon(Icons.arrow_forward, size: 16),
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
                        icon: const Icon(Icons.chat_bubble_outline, size: 15),
                        label: const Text(
                          'Ask Why',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF424242),
                          side: BorderSide(color: Colors.grey.shade300, width: 1.2),
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
