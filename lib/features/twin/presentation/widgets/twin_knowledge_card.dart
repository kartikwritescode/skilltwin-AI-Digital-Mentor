import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/twin_dashboard.dart';
import '../../../../core/utils/mastery_format.dart';

/// Renders the "What your Twin knows" card on the Twin screen.
/// Surfaces verified strengths, cognitive learning insights, and blindspots
/// with a direct action to launch Knowledge Maintenance.
class TwinKnowledgeCard extends StatelessWidget {
  final TwinDashboardData twinData;

  const TwinKnowledgeCard({
    super.key,
    required this.twinData,
  });

  @override
  Widget build(BuildContext context) {
    final strongest = twinData.strongestAreas;
    final weakest = twinData.weakestAreas;
    final atRisk = twinData.conceptsAtRisk;
    final insights = twinData.insights;
    final hasBlindspots = atRisk.isNotEmpty || weakest.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Color(0xFF059669),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WHAT YOUR TWIN KNOWS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF059669),
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Empirical boundaries of verified conceptual memory',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF10B981)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'VERIFIED STRENGTHS',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${strongest.length} Mastered',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (strongest.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: strongest.map((area) {
                final scorePct = area.masteryScore.toMasteryPercentage;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFBBF7D0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 13, color: Color(0xFF16A34A)),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          area.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF14532D),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$scorePct%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Color(0xFF94A3B8)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Complete topic practice & quizzes to build verified strengths.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 18),

          // ── Subsection 2: Cognitive Learning Patterns & Insights ──
          if (insights.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.lightbulb_rounded,
                    size: 15, color: Color(0xFFF59E0B)),
                SizedBox(width: 6),
                Text(
                  'LEARNING PATTERNS & INSIGHTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...insights.take(3).map((insight) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5.0, right: 8.0),
                      child: Icon(Icons.circle, size: 5, color: Color(0xFF6366F1)),
                    ),
                    Expanded(
                      child: Text(
                        insight,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.38,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 14),
          ],

          // ── Subsection 3: Blindspots & Maintenance CTA ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: hasBlindspots ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasBlindspots ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      hasBlindspots
                          ? Icons.warning_amber_rounded
                          : Icons.shield_rounded,
                      size: 16,
                      color: hasBlindspots ? const Color(0xFFD97706) : const Color(0xFF059669),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        hasBlindspots
                            ? 'BLINDSPOTS & SPACING REVIEW'
                            : 'RETENTION HEALTHY',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: hasBlindspots ? const Color(0xFFB45309) : const Color(0xFF047857),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (hasBlindspots) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${atRisk.length + weakest.length} Due',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  hasBlindspots
                      ? (atRisk.isNotEmpty
                          ? 'Due for review: ${atRisk.join(', ')}.'
                          : 'Developing concepts: ${weakest.map((w) => w.name).join(', ')}.')
                      : 'All verified conceptual traces are reinforced and within safe memory retention windows.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
                if (hasBlindspots) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/twin/maintenance');
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_fix_high_rounded,
                              size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Reinforce Blindspots in Maintenance',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded,
                              size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
