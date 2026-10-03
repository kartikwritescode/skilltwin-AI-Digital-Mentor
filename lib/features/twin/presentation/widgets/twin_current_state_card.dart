import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/home_dashboard.dart';
import '../../../../core/models/twin_dashboard.dart';
import '../../../home/presentation/providers/today_task_provider.dart';

/// Renders the "Current Learning State" card on the Twin screen.
/// Shows real Goal, Active topic, curriculum progress, and direct action.
class TwinCurrentStateCard extends StatelessWidget {
  final HomeDashboardData? homeData;
  final TwinDashboardData twinData;
  final TodayTaskState? todayState;

  const TwinCurrentStateCard({
    super.key,
    this.homeData,
    required this.twinData,
    this.todayState,
  });

  @override
  Widget build(BuildContext context) {
    final goalTitle = homeData?.goalTitle != 'No Active Goal' &&
            homeData?.goalTitle != null &&
            homeData!.goalTitle.isNotEmpty
        ? homeData!.goalTitle
        : 'Active Learning Path';

    final targetLevel = homeData?.targetLevel ?? twinData.learningLevel;

    final isTodayDone = todayState?.isCompleted == true ||
        (homeData?.isTodayCompleted == true) ||
        (homeData?.todayStatus.toUpperCase() == 'COMPLETED');

    final isLearningNow = todayState?.isLearning == true ||
        (homeData?.todayStatus.toUpperCase() == 'LEARNING');

    final activeTopicTitle = todayState?.topicTitle ??
        homeData?.todayTargetTopicTitle ??
        homeData?.nextActionTitle ??
        'Next Curriculum Topic';

    final estMinutes = todayState?.estimatedMinutes ??
        homeData?.todayEstimatedMinutes ??
        homeData?.dailyCommitmentMinutes ??
        25;

    final progressRatio = (homeData?.overallProgress ??
            (twinData.overallMastery / 100.0))
        .clamp(0.0, 1.0);
    final progressPct = (progressRatio * 100).toInt();

    final topicsDone = homeData?.topicsCompleted ??
        (twinData.verifiedEvidenceCount > 0
            ? twinData.verifiedEvidenceCount
            : 0);
    final topicsLeft = homeData?.topicsRemaining ?? 0;

    final targetTopicId = todayState?.topicId ?? homeData?.todayTargetTopicId;

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
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: Color(0xFF0284C7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT LEARNING STATE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0284C7),
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Active roadmap focus & curriculum velocity',
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

          // ── Goal & Target Level ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    size: 18,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goalTitle,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Target level: $targetLevel',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Active Focus Topic Row ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isTodayDone
                  ? const Color(0xFFECFDF5)
                  : (isLearningNow
                      ? const Color(0xFFEFF6FF)
                      : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isTodayDone
                    ? const Color(0xFFA7F3D0)
                    : (isLearningNow
                        ? const Color(0xFFBFDBFE)
                        : const Color(0xFFE2E8F0)),
                width: 1.1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isTodayDone
                      ? Icons.check_circle_rounded
                      : (isLearningNow
                          ? Icons.play_circle_fill_rounded
                          : Icons.radio_button_checked_rounded),
                  size: 20,
                  color: isTodayDone
                      ? const Color(0xFF059669)
                      : (isLearningNow
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF6366F1)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeTopicTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isTodayDone
                            ? 'Completed today • Great work!'
                            : '$estMinutes min session target',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isTodayDone
                              ? const Color(0xFF059669)
                              : const Color(0xFF64748B),
                          fontWeight:
                              isTodayDone ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTodayDone
                        ? const Color(0xFFD1FAE5)
                        : (isLearningNow
                            ? const Color(0xFFDBEAFE)
                            : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isTodayDone
                        ? 'COMPLETED'
                        : (isLearningNow ? 'IN PROGRESS' : 'UP NEXT'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isTodayDone
                          ? const Color(0xFF065F46)
                          : (isLearningNow
                              ? const Color(0xFF1E40AF)
                              : const Color(0xFF475569)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Curriculum Progress Bar ──
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 4,
            children: [
              Text(
                'Curriculum Progress: $progressPct%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              if (topicsDone > 0 || topicsLeft > 0)
                Text(
                  '$topicsDone completed • $topicsLeft left',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 6,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          ),

          const SizedBox(height: 18),

          // ── Action CTA Button ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                if (targetTopicId != null && targetTopicId.isNotEmpty && !isTodayDone) {
                  context.push('/journey/topic/$targetTopicId');
                } else {
                  context.go('/journey');
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: isTodayDone
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFF1E2238),
                  borderRadius: BorderRadius.circular(16),
                  border: isTodayDone
                      ? Border.all(color: const Color(0xFFCBD5E1), width: 1)
                      : null,
                  boxShadow: isTodayDone
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFF1E2238).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isTodayDone
                          ? Icons.explore_rounded
                          : Icons.play_arrow_rounded,
                      size: 18,
                      color: isTodayDone
                          ? const Color(0xFF334155)
                          : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isTodayDone
                            ? 'Explore Next in Journey'
                            : 'Continue Today\'s Focus',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isTodayDone
                              ? const Color(0xFF334155)
                              : Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: isTodayDone
                          ? const Color(0xFF334155)
                          : Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
