import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/learning_path.dart';

enum DayStudyStatus {
  completed,
  today,
  todayCompleted,
  notStudied,
  future,
}

class WeeklyLearningTracker extends StatelessWidget {
  final int streakDays;
  final LearningPath? learningPath;
  final DateTime? referenceDate;
  final bool? isTodayCompleted;

  const WeeklyLearningTracker({
    super.key,
    required this.streakDays,
    this.learningPath,
    this.referenceDate,
    this.isTodayCompleted,
  });

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate Sunday of the current week (Dart weekday: Monday=1, Sunday=7)
    final daysSinceSunday = today.weekday % 7;
    final sunday = today.subtract(Duration(days: daysSinceSunday));

    // Extract all completed topic dates from learning path
    final completedDates = <DateTime>[];
    if (learningPath != null) {
      for (final section in learningPath!.sections) {
        for (final topic in section.topics) {
          if (topic.completedAt != null) {
            completedDates.add(DateTime(
              topic.completedAt!.year,
              topic.completedAt!.month,
              topic.completedAt!.day,
            ));
          }
        }
      }
    }

    const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.cardBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final dayDate = sunday.add(Duration(days: index));
          final isToday = _isSameDay(dayDate, today);
          final isFuture = dayDate.isAfter(today);
          final isPast = dayDate.isBefore(today);

          // Check if studied on this day
          final hasCompletedTopic = completedDates.any((d) => _isSameDay(d, dayDate));
          final daysAgo = today.difference(dayDate).inDays;
          final wasStreakDay = isPast && streakDays > 0 && daysAgo < streakDays;
          final studied = hasCompletedTopic || wasStreakDay;

          DayStudyStatus status;
          if (isToday) {
            final todayStudied = isTodayCompleted == true ||
                hasCompletedTopic ||
                (isTodayCompleted == null && streakDays > 0);
            status = todayStudied ? DayStudyStatus.todayCompleted : DayStudyStatus.today;
          } else if (isFuture) {
            status = DayStudyStatus.future;
          } else {
            status = studied ? DayStudyStatus.completed : DayStudyStatus.notStudied;
          }

          return Expanded(
            child: _buildDayColumn(
              label: dayLabels[index],
              dayNumber: dayDate.day,
              status: status,
              isToday: isToday,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayColumn({
    required String label,
    required int dayNumber,
    required DayStudyStatus status,
    required bool isToday,
  }) {
    if (isToday) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: AppTheme.primaryAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryAccent.withValues(alpha: 0.28),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryAccent.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryAccent,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '$dayNumber',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildStatusNode(status),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: status == DayStudyStatus.future
                ? AppTheme.textMuted
                : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$dayNumber',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: status == DayStudyStatus.future
                ? AppTheme.textMuted
                : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildStatusNode(status),
      ],
    );
  }

  Widget _buildStatusNode(DayStudyStatus status) {
    switch (status) {
      case DayStudyStatus.todayCompleted:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppTheme.positive,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 15,
            ),
          ),
        );

      case DayStudyStatus.today:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryAccent,
              width: 2,
            ),
            color: Colors.white,
          ),
          child: const Center(
            child: Icon(
              Icons.local_fire_department_rounded,
              color: AppTheme.mascotAccent,
              size: 14,
            ),
          ),
        );

      case DayStudyStatus.completed:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppTheme.positive,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 15,
            ),
          ),
        );

      case DayStudyStatus.notStudied:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFCBD5E1),
              width: 1.5,
            ),
          ),
        );

      case DayStudyStatus.future:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
        );
    }
  }
}
