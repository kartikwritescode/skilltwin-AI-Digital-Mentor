import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_refresh_indicator.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../../../../core/widgets/skilltwin_twin.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../journey/presentation/providers/learning_path_provider.dart';
import '../../../../core/models/learning_path.dart';
import '../widgets/streak_widgets.dart';

/// The dedicated SkillTwin Learning Streak Screen.
/// Highlights the Learning Twin companion celebrating the learner's real momentum,
/// utilizing the Deep Indigo / Soft Violet palette while letting
/// the mascot's warm character naturally shine as the visual hero.
class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  TwinAsset _resolveStreakMascot(int days) {
    if (days <= 0) return TwinAsset.streakComeback;
    if (days < 3) return TwinAsset.growing;
    if (days < 7) return TwinAsset.journeyClimb;
    if (days < 14) return TwinAsset.streakFire;
    if (days < 30) return TwinAsset.celebrate;
    return TwinAsset.streakLegend;
  }

  String _resolveMascotSpeech(int days) {
    if (days <= 0) return "Let's ignite the flame! ⚡";
    if (days < 3) return "Great start, keep it going! 🌱";
    if (days < 7) return "Momentum unlocked! 🚀";
    if (days < 14) return "Unstoppable habit! 🔥";
    if (days < 30) return "Mastery in motion! 👑";
    return "Legendary learner! 🏆";
  }

  int _nextMilestone(int days) {
    if (days < 3) return 3;
    if (days < 7) return 7;
    if (days < 14) return 14;
    if (days < 30) return 30;
    if (days < 60) return 60;
    if (days < 100) return 100;
    return days + 50;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final learningPathAsync = ref.watch(learningPathProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Your Learning Streak',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
          onPressed: () {
            HapticFeedback.lightImpact();
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Streak',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(homeDashboardProvider);
              ref.invalidate(learningPathProvider);
            },
          ),
        ],
      ),
      body: SkillTwinBackground(
        child: SafeArea(
          child: dashboardAsync.when(
            data: (dashboard) => _buildStreakContent(
              context,
              ref,
              dashboard,
              learningPathAsync,
            ),
            loading: () => const SkillTwinLoadingView(
              message: 'Loading your streak data...',
              subMessage: 'Calculating your learning momentum',
            ),
            error: (error, stack) => _buildErrorState(context, ref, error),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SkillTwinCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SkillTwinTwin.confused(size: 80),
                const SizedBox(height: 16),
                const Text(
                  'Unable to Load Streak',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We couldn\'t fetch your streak data. Please check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.invalidate(homeDashboardProvider);
                    ref.invalidate(learningPathProvider);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakContent(
    BuildContext context,
    WidgetRef ref,
    dynamic dashboard,
    AsyncValue<LearningPath?> learningPathAsync,
  ) {
    final int streakDays = dashboard?.streakDays ?? 0;
    final int targetMilestone = _nextMilestone(streakDays);
    final double milestoneProgress = streakDays <= 0
        ? 0.0
        : (streakDays / targetMilestone).clamp(0.0, 1.0);

    final mascot = _resolveStreakMascot(streakDays);
    final speech = _resolveMascotSpeech(streakDays);
    final tier = StreakTierConfig.getTierForStreak(streakDays);
    final tierConfig = StreakTierConfig.forTier(tier);

    final weekProgress = StreakTierConfig.generateWeekProgress(
      streakDays: streakDays,
    );

    // Calculate total study time and completed topics
    final learningPath = learningPathAsync.valueOrNull;
    final allTopics = learningPath?.sections
            .where((s) => s.topics.isNotEmpty)
            .expand((s) => s.topics)
            .toList() ??
        [];
    final completedTopics =
        allTopics.where((t) => t.status == TopicStatus.completed).toList();
    final totalMinutesStudied = completedTopics.fold<int>(
      0,
      (sum, topic) => sum + topic.estimatedMinutes,
    );

    return SkillTwinRefreshIndicator(
      message: 'SkillTwin is updating your streak...',
      onRefresh: () async {
        ref.invalidate(homeDashboardProvider);
        ref.invalidate(learningPathProvider);
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              // ── 1. Hero Streak Celebration Card ──
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: tierConfig.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: tierConfig.accentGlow.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: tierConfig.accentGlow.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Crown emoji based on streak tier
                    Text(
                      streakDays >= 100
                          ? '👑'
                          : streakDays >= 30
                              ? '🏆'
                              : streakDays >= 7
                                  ? '🔥'
                                  : streakDays > 0
                                      ? '⚡'
                                      : '🌙',
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 8),

                    // Companion Mascot Hero with subtle float
                    SkillTwinTwin(
                      asset: mascot,
                      size: 120,
                      floatAnimation: true,
                      enableInteraction: true,
                      speechBubble: speech,
                    ),
                    const SizedBox(height: 16),

                    // Streak Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tierConfig.streakIcon,
                            color: const Color(0xFFFFD54F),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tierConfig.badgeText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Giant Streak Number
                    Text(
                      '$streakDays ${streakDays == 1 ? "DAY" : "DAYS"}',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Motivational Subtitle
                    Text(
                      tierConfig.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.95),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tierConfig.secondaryLine,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Milestone Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Next Milestone: $targetMilestone Days',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    tierConfig.accentGlow.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(milestoneProgress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: milestoneProgress,
                            minHeight: 8,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              tierConfig.accentGlow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── 2. Stats Overview Card ──
              SkillTwinCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.analytics_rounded,
                          size: 18,
                          color: AppTheme.primaryAccent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Your Progress Stats',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatTile(
                            icon: Icons.verified_rounded,
                            value: '${completedTopics.length}',
                            label: 'Completed',
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatTile(
                            icon: Icons.schedule_rounded,
                            value: '${totalMinutesStudied}m',
                            label: 'Total Time',
                            color: AppTheme.primaryAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatTile(
                            icon: Icons.trending_up_rounded,
                            value: streakDays > 0
                                ? '${(completedTopics.length / streakDays).toStringAsFixed(1)}'
                                : '0',
                            label: 'Topics/Day',
                            color: const Color(0xFFFFD54F),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatTile(
                            icon: Icons.calendar_month_rounded,
                            value: DateFormat('MMM d').format(DateTime.now()),
                            label: 'Today',
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── 3. Weekly Activity Calendar Card ──
              SkillTwinCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: AppTheme.primaryAccent,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This Week\'s Discipline',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.primaryAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            '7-Day View',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Streak Week Progress Row
                    StreakWeekProgress(
                      days: weekProgress,
                      activeGlowColor: tierConfig.accentGlow,
                      currentIcon: tierConfig.streakIcon,
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.primaryAccent.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          SkillTwinTwin.focused(
                            size: 40,
                            isDecorative: true,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Study at least once a day to keep your Twin focused and preserve your streak!',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── 4. Action Callout: Continue Streak Today ──
              SkillTwinCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.positive,
                            AppTheme.positive.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.positive.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            streakDays > 0
                                ? 'Protect Your Streak Today'
                                : 'Start Day 1 Today',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            dashboard?.todayTargetTopicTitle ??
                                'Complete today\'s study checkpoint',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push('/journey');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
