import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/home_dashboard.dart';
import '../../../../core/widgets/skilltwin_twin.dart';

class TodaysTaskCard extends StatelessWidget {
  final HomeDashboardData data;
  final VoidCallback onStartSession;
  final bool? isCompleted;
  final bool? isLearning;
  final String? currentTopicTitle;
  final String? currentTopicId;
  final int? currentTopicMinutes;
  final int? taskIndex;
  final int? totalTasks;

  const TodaysTaskCard({
    super.key,
    required this.data,
    required this.onStartSession,
    this.isCompleted,
    this.isLearning,
    this.currentTopicTitle,
    this.currentTopicId,
    this.currentTopicMinutes,
    this.taskIndex,
    this.totalTasks,
  });

  /// Selects a meaningful contextual icon based on topic title and action type.
  static IconData getContextualTopicIcon(String? topicTitle, String? actionType) {
    final title = (topicTitle ?? '').toLowerCase();
    final action = (actionType ?? '').toLowerCase();

    if (title.contains('array') ||
        title.contains('hash') ||
        title.contains('code') ||
        title.contains('algorithm') ||
        title.contains('data structure') ||
        title.contains('tree') ||
        title.contains('graph') ||
        title.contains('dp') ||
        title.contains('sort') ||
        title.contains('string')) {
      return Icons.code_rounded;
    }
    if (action.contains('video') || title.contains('video') || title.contains('watch')) {
      return Icons.play_circle_fill_rounded;
    }
    if (action.contains('practice') ||
        title.contains('practice') ||
        title.contains('problem') ||
        title.contains('solve')) {
      return Icons.track_changes_rounded;
    }
    if (action.contains('revision') ||
        action.contains('retrieve') ||
        title.contains('revision') ||
        title.contains('review')) {
      return Icons.history_rounded;
    }
    if (action.contains('teach') || title.contains('teach')) {
      return Icons.record_voice_over_rounded;
    }
    if (title.contains('system') ||
        title.contains('project') ||
        title.contains('design') ||
        title.contains('build')) {
      return Icons.rocket_launch_rounded;
    }
    if (title.contains('quiz') || title.contains('assessment')) {
      return Icons.psychology_rounded;
    }
    return Icons.terminal_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final taskCompleted = (isCompleted ?? false) ||
        data.isTodayCompleted ||
        data.todayStatus.toUpperCase() == 'COMPLETED';
    final taskLearning =
        (!taskCompleted) && ((isLearning ?? false) || data.todayStatus.toUpperCase() == 'LEARNING');

    final effectiveTotal = totalTasks ??
        (data.todayTasksTotal > 1
            ? data.todayTasksTotal
            : (data.todayTasks.isNotEmpty ? data.todayTasks.length : 1));
    final effectiveIndex = taskIndex ??
        (data.todayTasksCompleted + 1).clamp(1, effectiveTotal);
    final isMultiTask = effectiveTotal > 1;

    final targetTopicTitle = currentTopicTitle ??
        (data.currentActionableTask?.title ??
            (data.todayTargetTopicTitle ?? data.nextActionTitle));
    final topicIcon =
        getContextualTopicIcon(targetTopicTitle, data.nextActionType);
    final effectiveMinutes = currentTopicMinutes ??
        (data.currentActionableTask?.estimatedMinutes ?? data.todayEstimatedMinutes);

    final dayNumber = data.streakDays > 0 ? data.streakDays + 1 : 1;
    final journeyName = data.goalTitle != 'No Active Goal'
        ? data.goalTitle
        : 'Daily Path';

    // Format date: e.g. "Thu, 25 Sep 2026"
    final formattedDate = DateFormat('EEE, d MMM yyyy').format(DateTime.now());

    // Card Header Title
    final String cardHeaderTitle;
    if (taskCompleted) {
      cardHeaderTitle = isMultiTask ? "Today's Tasks Completed" : "Today's Session Completed";
    } else if (isMultiTask && effectiveIndex > 1) {
      cardHeaderTitle = "Up Next";
    } else {
      cardHeaderTitle = isMultiTask ? "Today's Focus" : "Today's Task";
    }

    // Build concise task items from actual data
    final taskItems = <_TaskBreakdownItem>[];

    // 1. Core / Learn item
    final firstConcept = data.todayKeyConcepts.isNotEmpty
        ? data.todayKeyConcepts.first
        : targetTopicTitle;
    taskItems.add(
      _TaskBreakdownItem(
        icon: taskCompleted ? Icons.check_circle_rounded : Icons.menu_book_rounded,
        iconColor: taskCompleted ? const Color(0xFF10B981) : const Color(0xFF6366F1),
        text: taskCompleted
            ? 'Completed: $firstConcept ($effectiveMinutes min)'
            : 'Learn: $firstConcept ($effectiveMinutes min)',
      ),
    );

    // 2. Practice item
    final secondConcept = data.todayKeyConcepts.length > 1
        ? data.todayKeyConcepts[1]
        : (data.todayKeyConcepts.isNotEmpty ? data.todayKeyConcepts.first : 'Target concepts');
    taskItems.add(
      _TaskBreakdownItem(
        icon: taskCompleted ? Icons.check_circle_rounded : Icons.assignment_rounded,
        iconColor: taskCompleted ? const Color(0xFF10B981) : const Color(0xFF0284C7),
        text: taskCompleted
            ? 'Solved practice problems on $secondConcept'
            : 'Solve 2 practice problems on $secondConcept',
      ),
    );

    // 3. Review / Revision item
    if (data.revisionDueCount > 0) {
      taskItems.add(
        _TaskBreakdownItem(
          icon: taskCompleted ? Icons.check_circle_rounded : Icons.history_edu_rounded,
          iconColor: taskCompleted ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
          text: taskCompleted
              ? 'Reviewed spaced retention cards'
              : 'Review ${data.revisionDueCount} spaced retention cards',
        ),
      );
    } else {
      taskItems.add(
        _TaskBreakdownItem(
          icon: taskCompleted ? Icons.check_circle_rounded : Icons.article_rounded,
          iconColor: const Color(0xFF10B981),
          text: taskCompleted ? 'Notes saved & synthesized' : 'Make short summary notes',
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: taskCompleted
              ? const Color(0xFFA7F3D0)
              : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: taskCompleted
                ? const Color(0xFF10B981).withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header Row ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: taskCompleted
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  taskCompleted
                      ? Icons.task_alt_rounded
                      : Icons.calendar_today_rounded,
                  color: taskCompleted
                      ? const Color(0xFF059669)
                      : const Color(0xFF6366F1),
                  size: 18,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardHeaderTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      formattedDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (taskCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFA7F3D0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 12,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isMultiTask ? 'All $effectiveTotal Tasks Done' : 'Completed',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                )
              else if (isMultiTask)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFC7D2FE),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6366F1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Task $effectiveIndex of $effectiveTotal',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                )
              else if (taskLearning)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFBFDBFE),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.play_circle_fill_rounded,
                        size: 12,
                        color: Color(0xFF2563EB),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'In Progress',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFDDD6FE),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Day $dayNumber • $journeyName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Inner White Task Card ──
          Builder(
            builder: (context) {
              final isVeryCompact = (MediaQuery.sizeOf(context).width - 36) < 330;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: taskCompleted ? const Color(0xFFF8FAFC) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: taskCompleted
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFFF1F5F9),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main content
                    Padding(
                      padding: EdgeInsets.only(
                        right: isVeryCompact ? 0 : 108.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Topic Icon & Title
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: taskCompleted
                                        ? const [
                                            Color(0xFF059669),
                                            Color(0xFF10B981),
                                          ]
                                        : const [
                                            Color(0xFF6366F1),
                                            Color(0xFF8B5CF6),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (taskCompleted
                                              ? const Color(0xFF059669)
                                              : const Color(0xFF6366F1))
                                          .withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    taskCompleted
                                        ? Icons.check_rounded
                                        : topicIcon,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  targetTopicTitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Breakdown items
                          ...taskItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 7.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 15,
                                    color: item.iconColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: taskCompleted
                                            ? FontWeight.w500
                                            : FontWeight.w600,
                                        color: taskCompleted
                                            ? const Color(0xFF64748B)
                                            : const Color(0xFF334155),
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    // Mascot companion positioned on right
                    if (!isVeryCompact)
                      Positioned(
                        right: 0,
                        bottom: -2,
                        child: taskCompleted
                            ? const SkillTwinTwin.celebrating(
                                size: 92,
                                isDecorative: true,
                              )
                            : const SkillTwinTwin.coding(
                                size: 92,
                                isDecorative: true,
                              ),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // ── Today's Session CTA Button ──
          Semantics(
            button: true,
            label: taskCompleted
                ? "Today's session completed"
                : (taskLearning
                    ? "Continue today's learning session"
                    : "Start today's learning session"),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (taskCompleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("✓ Today's session completed! Great work staying consistent."),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    onStartSession();
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: taskCompleted
                        ? const Color(0xFF065F46)
                        : (taskLearning
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF1E2238)),
                    borderRadius: BorderRadius.circular(30),
                    border: taskCompleted
                        ? Border.all(
                            color: const Color(0xFF34D399).withValues(alpha: 0.3),
                            width: 1.2,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: (taskCompleted
                                ? const Color(0xFF065F46)
                                : (taskLearning
                                    ? const Color(0xFF1D4ED8)
                                    : const Color(0xFF1E2238)))
                            .withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        taskCompleted
                            ? Icons.check_circle_rounded
                            : (taskLearning
                                ? Icons.play_circle_filled_rounded
                                : Icons.play_arrow_rounded),
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          taskCompleted
                              ? "✓ Today's Session Completed"
                              : (taskLearning
                                  ? "Continue Today's Session"
                                  : "Start Today's Session"),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            taskCompleted
                                ? Icons.done_all_rounded
                                : Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
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

class _TaskBreakdownItem {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _TaskBreakdownItem({
    required this.icon,
    required this.iconColor,
    required this.text,
  });
}
