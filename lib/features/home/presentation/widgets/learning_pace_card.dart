import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/home_dashboard.dart';
import '../../../../app/theme/app_theme.dart';

class LearningPaceCard extends StatelessWidget {
  final HomeDashboardData data;

  const LearningPaceCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Intelligently derive state from backend dynamic pacing metrics
    final isBehind =
        data.scheduleStatus == 'BEHIND_SCHEDULE' || data.backlogCount > 0;
    final isAhead = data.scheduleStatus == 'AHEAD_OF_SCHEDULE';
    final isGoalCompleted = data.scheduleStatus == 'COMPLETED';

    final Color bgColor;
    final Color borderColor;
    final Color accentColor;
    final Color iconBgColor;
    final IconData iconData;
    final String title;
    final String subtitle;
    final String metricText;

    if (isGoalCompleted) {
      bgColor = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFFBBF7D0);
      accentColor = const Color(0xFF16A34A);
      iconBgColor = const Color(0xFFDCFCE7);
      iconData = Icons.military_tech_rounded;
      title = "Curriculum Completed";
      subtitle = "All roadmap topics mastered. Spaced retention active.";
      metricText = "${data.topicsCompleted} of ${data.topicsCompleted} topics mastered";
    } else if (isBehind) {
      bgColor = const Color(0xFFFFFBEB);
      borderColor = const Color(0xFFFDE68A);
      accentColor = const Color(0xFFD97706);
      iconBgColor = const Color(0xFFFEF3C7);
      iconData = Icons.bolt_rounded;
      title = "You have a little catching up to do";
      subtitle = "You have some unfinished learning from previous days.";
      final count = data.backlogCount > 0 ? data.backlogCount : 1;
      metricText = "$count ${count == 1 ? 'task' : 'tasks'} waiting for you";
    } else if (isAhead) {
      bgColor = const Color(0xFFFAF5FF);
      borderColor = const Color(0xFFE9D5FF);
      accentColor = const Color(0xFF7C3AED);
      iconBgColor = const Color(0xFFF3E8FF);
      iconData = Icons.rocket_launch_rounded;
      title = "You're ahead of schedule";
      subtitle = "You're moving faster than your planned pace.";
      final daysText = data.daysRemaining > 0 ? " • ${data.daysRemaining}d remaining" : "";
      metricText = "${data.topicsCompleted} completed$daysText";
    } else {
      // Default: On Track
      bgColor = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFFDCFCE7);
      accentColor = const Color(0xFF059669);
      iconBgColor = const Color(0xFFD1FAE5);
      iconData = Icons.auto_awesome_rounded;
      title = "You're right on track";
      subtitle = "You're progressing at a healthy pace toward your goal.";
      final progressPct = (data.overallProgress * 100).toInt().clamp(0, 100);
      final daysText = data.daysRemaining > 0 ? " • ${data.daysRemaining}d to target" : "";
      metricText = "$progressPct% progress$daysText";
    }

    final progressRatio = data.overallProgress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main Header Row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    iconData,
                    color: accentColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Progress Visualization & Metric ──
          if (isBehind) ...[
            // Distinct Backlog Strip with Subtle CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    '📚',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      metricText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/journey');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Catch up',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: Color(0xFFD97706),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Subtle compact progress bar & metric pill
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 5,
                      backgroundColor: accentColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    metricText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
