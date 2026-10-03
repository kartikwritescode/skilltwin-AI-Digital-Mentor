import 'package:flutter/material.dart';

enum StreakTier {
  zero,
  shortStreak,
  active,
  legendary,
}

enum DayCompletionStatus {
  completed,
  current,
  missed,
  future,
}

class DayProgressItem {
  final String label; // "Mon", "Tue", etc.
  final DayCompletionStatus status;
  final DateTime date;

  const DayProgressItem({
    required this.label,
    required this.status,
    required this.date,
  });
}

class StreakTierConfig {
  final StreakTier tier;
  final String title;
  final String subtitle;
  final String quote;
  final String bubbleText;
  final String badgeText;
  final String mascotAsset;
  final List<Color> gradientColors;
  final Color accentGlow;
  final Color textColor;
  final Color pillBgColor;
  final String secondaryLine;
  final IconData streakIcon;

  const StreakTierConfig({
    required this.tier,
    required this.title,
    required this.subtitle,
    required this.quote,
    required this.bubbleText,
    required this.badgeText,
    required this.mascotAsset,
    required this.gradientColors,
    required this.accentGlow,
    this.textColor = Colors.white,
    required this.pillBgColor,
    required this.secondaryLine,
    this.streakIcon = Icons.local_fire_department_rounded,
  });

  static StreakTier getTierForStreak(int streakDays) {
    if (streakDays <= 0) return StreakTier.zero;
    if (streakDays < 7) return StreakTier.shortStreak;
    if (streakDays >= 100) return StreakTier.legendary;
    return StreakTier.active;
  }

  static StreakTierConfig forTier(StreakTier tier, {int? daysOverride}) {
    switch (tier) {
      case StreakTier.active:
        return const StreakTierConfig(
          tier: StreakTier.active,
          title: "On fire! Keep learning, you got this!",
          subtitle: "Discipline today, dream tomorrow!",
          quote: "Discipline today, dream tomorrow!",
          bubbleText: "Still going strong! 🚀",
          badgeText: "ACTIVE 🔥",
          mascotAsset: "assets/images/mascot/twin_streak_fire.webp",
          gradientColors: [
            Color(0xFF1E1B4B), // Midnight Violet
            Color(0xFF312E81), // Deep Indigo
            Color(0xFF4338CA), // Electric Royal Indigo
          ],
          accentGlow: Color(0xFF818CF8),
          pillBgColor: Color(0x33000000),
          secondaryLine: "Your Twin is growing stronger every day.",
          streakIcon: Icons.local_fire_department_rounded,
        );

      case StreakTier.shortStreak:
        return const StreakTierConfig(
          tier: StreakTier.shortStreak,
          title: "Almost there!",
          subtitle: "Small steps, big results!",
          quote: "Momentum unlocked. Keep the flame alive!",
          bubbleText: "Momentum unlocked! ⚡",
          badgeText: "BUILDING ⚡",
          mascotAsset: "assets/images/mascot/twin_journey_climb.webp",
          gradientColors: [
            Color(0xFF0F172A), // Midnight Slate
            Color(0xFF1E293B),
            Color(0xFF2563EB), // Electric Blue
          ],
          accentGlow: Color(0xFF38BDF8),
          pillBgColor: Color(0x33000000),
          secondaryLine: "Consistency builds the neural pathway.",
          streakIcon: Icons.bolt_rounded,
        );

      case StreakTier.zero:
        return const StreakTierConfig(
          tier: StreakTier.zero,
          title: "Let's get back on track!",
          subtitle: "Your Twin isn't judging. Character development arc begins now.",
          quote: "Day 0. The best time to restart is right now.",
          bubbleText: "We rise again! 🌙",
          badgeText: "RESTART 🚀",
          mascotAsset: "assets/images/mascot/twin_streak_comeback.webp",
          gradientColors: [
            Color(0xFF18181B), // Soft Charcoal
            Color(0xFF27272A),
            Color(0xFF3F3F46),
          ],
          accentGlow: Color(0xFF71717A),
          pillBgColor: Color(0x33000000),
          secondaryLine: "One session today ignites the momentum.",
          streakIcon: Icons.nightlight_round,
        );

      case StreakTier.legendary:
        return const StreakTierConfig(
          tier: StreakTier.legendary,
          title: "That's legendary!",
          subtitle: "You're built different! 👑",
          quote: "Unstoppable momentum. True cognitive mastery!",
          bubbleText: "Pure Mastery! 🏆",
          badgeText: "LEGENDARY 👑",
          mascotAsset: "assets/images/mascot/twin_streak_legend.webp",
          gradientColors: [
            Color(0xFF2E1065), // Cosmic Royal Purple
            Color(0xFF581C87),
            Color(0xFF7E22CE),
          ],
          accentGlow: Color(0xFFC084FC),
          pillBgColor: Color(0x33000000),
          secondaryLine: "Top 0.1% learner momentum worldwide.",
          streakIcon: Icons.emoji_events_rounded,
        );
    }
  }

  static List<DayProgressItem> generateWeekProgress({
    required int streakDays,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    // In Dart DateTime.weekday: Mon=1, Sun=7
    final currentWeekday = now.weekday;
    final monday = now.subtract(Duration(days: currentWeekday - 1));

    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      final dayNumber = index + 1; // 1 = Mon, 7 = Sun

      DayCompletionStatus status;
      if (dayNumber < currentWeekday) {
        // If streak is long enough, this past day of this week was completed
        final daysAgo = currentWeekday - dayNumber;
        if (streakDays > daysAgo) {
          status = DayCompletionStatus.completed;
        } else {
          status = DayCompletionStatus.missed;
        }
      } else if (dayNumber == currentWeekday) {
        // Current day
        status = DayCompletionStatus.current;
      } else {
        // Future day in the week
        status = DayCompletionStatus.future;
      }

      return DayProgressItem(
        label: dayLabels[index],
        status: status,
        date: date,
      );
    });
  }
}
