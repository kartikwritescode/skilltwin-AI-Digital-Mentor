import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../home/presentation/providers/today_task_provider.dart';
import '../../../home/data/repositories/goal_repository_provider.dart';
import '../../../journey/presentation/providers/learning_path_provider.dart';
import '../../data/repositories/profile_repository_provider.dart';
import '../../../../core/models/goal.dart';
import '../../../../core/models/learning_path.dart';
import '../../../../core/models/user.dart';
import '../../../../core/utils/mastery_format.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../../../streak/presentation/widgets/streak_widgets.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final activeGoalAsync = ref.watch(activeGoalProvider);
    final allGoalsAsync = ref.watch(allGoalsProvider);
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final learningPathAsync = ref.watch(learningPathProvider);
    // Reactive subscription to today's task & completed sessions
    ref.watch(todayTaskStateProvider);

    final screenSize = MediaQuery.sizeOf(context);
    final isCompact = screenSize.width < 360;

    final displayName = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : (user?.name.isNotEmpty == true ? user!.name : 'Learner');
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'L';
    final email = user?.email ?? 'learner@skilltwin.ai';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Learner Profile',
          style: AppTypography.headline,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SkillTwinBackground(
        child: Center(
          child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              isCompact ? 16 : 20,
              12,
              isCompact ? 16 : 20,
              10
            ),
            children: [
              // ── 1. Who I am: Personalized Header Card ──
              _buildHeaderCard(context, user, displayName, initial, email),
              const SizedBox(height: 20),

              // ── 2. How I'm learning: Current Focus & Track ──
              _buildSectionHeader('How I\'m Learning'),
              activeGoalAsync.when(
                data: (goal) => _buildActiveGoalCard(context, goal),
                loading: () => const SkillTwinLoadingView.compact(
                  message: 'SkillTwin is preparing your next step.',
                  subMessage: 'Retrieving your active goal...',
                ),
                error: (_, __) => _buildEmptyGoalCard(context),
              ),
              const SizedBox(height: 16),

              // ── 2b. Other Saved Goals & History ──
              _buildSectionHeader('Other Saved Goals'),
              allGoalsAsync.when(
                data: (goals) {
                  if (goals == null) return const SizedBox.shrink();
                  final activeGoal = activeGoalAsync.valueOrNull;
                  final inactiveGoals = goals
                      .where((g) => g.id != activeGoal?.id)
                      .toList();
                  return _buildInactiveGoalsSection(context, inactiveGoals);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

                // ── 3. What I've achieved: Milestones & Mastery ──
                _buildSectionHeader('What I\'ve Achieved'),
                _buildAchievementsCard(context, dashboardAsync, learningPathAsync, user),
                const SizedBox(height: 24),

                // ── 4. My consistency: Interactive Streak & Calendar UI ──
                _buildSectionHeader('My Consistency & Rhythm'),
                _buildStreakCalendarSection(context, dashboardAsync, learningPathAsync),
                const SizedBox(height: 24),

                // ── 5. Learning Preferences ──
                _buildSectionHeader('Preferences'),
              SkillTwinCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Info',
                      subtitle: 'Name, daily practice & timezone',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                      onTap: () => _editPersonalInfo(context, user),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildSettingsTile(
                      icon: Icons.access_time_rounded,
                      title: 'Daily Practice Target',
                      subtitle: '${user?.dailyMinutes ?? 30} minutes / day',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                      onTap: () => _editPersonalInfo(context, user),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildSettingsTile(
                      icon: Icons.public_rounded,
                      title: 'Timezone',
                      subtitle: user?.timezone ?? 'Asia/Kolkata',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                      onTap: () => _editPersonalInfo(context, user),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── 6. Account & Clean Logout ──
              _buildSectionHeader('Account'),
              SkillTwinCard(
                padding: EdgeInsets.zero,
                child: _buildSettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Log Out of SkillTwin',
                  subtitle: 'Safely sign out of this device',
                  titleColor: Colors.red.shade600,
                  iconColor: Colors.red.shade600,
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.red.shade400),
                  onTap: () => _confirmLogout(context),
                ),
              ),
              const SizedBox(height: 32),

              // ── 7. App Version Footer ──
              Center(
                child: Column(
                  children: [
                    Text(
                      'SkillTwin v1.0.0 • Production Build',
                      style: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Personalized AI Learning Companion',
                      style: AppTypography.supporting.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.calculateBottomNavInset(context)),
            ],
          ),
        ),
      ),
    ),
  );
}

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. Personalized Header Card
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildHeaderCard(
    BuildContext context,
    User? user,
    String displayName,
    String initial,
    String email,
  ) {
    return SkillTwinCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryAccent, Color(0xFF38BDF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'LEARNER',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryAccent,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Edit Action Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textPrimary),
                  tooltip: 'Edit Name & Details',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _editPersonalInfo(context, user),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Digital Companion greeting banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/mascots/twin_home.webp',
                  width: 38,
                  height: 38,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.psychology_rounded,
                    color: AppTheme.primaryAccent,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SkillTwin Companion',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryAccent,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Ready to keep your momentum going today?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. Interactive Streak & Calendar Section
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildStreakCalendarSection(
    BuildContext context,
    AsyncValue<dynamic> dashboardAsync,
    AsyncValue<LearningPath?> learningPathAsync,
  ) {
    final streakDays = dashboardAsync.valueOrNull?.streakDays ?? 0;
    final learningPath = learningPathAsync.valueOrNull;

    // Collect all topics - with null safety
    final allTopics = learningPath?.sections
        .where((s) => s.topics != null)
        .expand((s) => s.topics)
        .where((t) => t != null)
        .toList() ?? [];

    // Build 14-day calendar window: 10 days before today to 3 days after today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(14, (index) {
      return today.subtract(Duration(days: 9 - index));
    });

    // Filter topics completed on _selectedDate - with null safety
    final topicsOnSelectedDate = allTopics.where((t) {
      if (t == null || t.completedAt == null) return false;
      return _isSameDay(t.completedAt!, _selectedDate);
    }).toList();

    // Check if selected date is today
    final isSelectedToday = _isSameDay(_selectedDate, today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Surfaced Learning Momentum & Streak ──
        if (dashboardAsync.valueOrNull != null)
          StreakSection(
            dashboardData: dashboardAsync.valueOrNull!,
            onStartToday: () => context.push('/journey'),
          )
        else
          HeroStreakCard(
            streakDays: streakDays,
          ),
        const SizedBox(height: 16),


        // ── Interactive Horizontal Day Strip ──
        SkillTwinCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, right: 6, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        DateFormat('MMMM yyyy').format(_selectedDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedDate = today);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelectedToday
                              ? AppTheme.primaryAccent.withValues(alpha: 0.12)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Jump to Today',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelectedToday ? AppTheme.primaryAccent : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: days.map((date) {
                    final isSelected = _isSameDay(date, _selectedDate);
                    final isDateToday = _isSameDay(date, today);

                    // Check if this date has any completed topics - with null safety
                    final hasCompletedTopic = allTopics.any((t) =>
                        t != null && t.completedAt != null && _isSameDay(t.completedAt!, date));

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.5),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedDate = date);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          width: 44,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryAccent
                                : (isDateToday ? AppTheme.primaryAccent.withValues(alpha: 0.08) : Colors.transparent),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryAccent
                                  : (isDateToday ? AppTheme.primaryAccent.withValues(alpha: 0.35) : Colors.transparent),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('E').format(date).substring(0, 1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : (isDateToday ? AppTheme.primaryAccent : AppTheme.textSecondary),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected || isDateToday ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDateToday ? AppTheme.primaryAccent : AppTheme.textPrimary),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Activity indicator dot
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? (hasCompletedTopic ? Colors.white : Colors.transparent)
                                      : (hasCompletedTopic
                                          ? Colors.green.shade600
                                          : (isDateToday ? AppTheme.primaryAccent : Colors.transparent)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Topics Aligned for Selected Date ──
        _buildTopicsAlignedCard(
          context,
          selectedDate: _selectedDate,
          isSelectedToday: isSelectedToday,
          completedTopics: topicsOnSelectedDate,
          dashboardAsync: dashboardAsync,
          learningPath: learningPath,
        ),
      ],
    );
  }

  Widget _buildTopicsAlignedCard(
    BuildContext context, {
    required DateTime selectedDate,
    required bool isSelectedToday,
    required List<LearningTopic> completedTopics,
    required AsyncValue<dynamic> dashboardAsync,
    required LearningPath? learningPath,
  }) {
    final dateLabel = isSelectedToday
        ? 'Today (${DateFormat('MMM d').format(selectedDate)})'
        : DateFormat('EEEE, MMM d').format(selectedDate);

    return SkillTwinCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_note_rounded,
                size: 18,
                color: AppTheme.primaryAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Topics Aligned • $dateLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Case A: Topics were completed on this date
          if (completedTopics.isNotEmpty) ...[
            ...completedTopics.map((topic) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                topic.difficulty.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.green.shade700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '•  Mastery ${topic.masteryScore.toMasteryPercentage}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                      onPressed: () => context.push('/topic/${topic.id}'),
                    ),
                  ],
                ),
              );
            }),
          ]
          // Case B: Selected date is Today and no topics completed yet -> show today's target topic
          else if (isSelectedToday) ...[
            Builder(
              builder: (context) {
                final dashboard = dashboardAsync.valueOrNull;
                // Get all topics with null safety
                final allTopicsList = learningPath?.sections
                    .where((s) => s.topics != null)
                    .expand((s) => s.topics)
                    .where((t) => t != null)
                    .toList() ?? [];
                LearningTopic? firstPendingTopic;
                for (final t in allTopicsList) {
                  if (t != null && t.status != TopicStatus.completed) {
                    firstPendingTopic = t;
                    break;
                  }
                }
                final targetTitle = dashboard?.todayTargetTopicTitle ??
                    firstPendingTopic?.title ??
                    'Foundations of Domain';
                final targetTopicId = dashboard?.todayTargetTopicId ??
                    firstPendingTopic?.id;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bolt_rounded, size: 16, color: AppTheme.primaryAccent),
                          ),
                          const SizedBox(width: 10),
                          const Flexible(
                            child: Text(
                              'TODAY\'S TARGET TOPIC',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryAccent,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        targetTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scheduled for today according to your deadline and daily study pace.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Start / Continue Today\'s Topic', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),  style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (targetTopicId != null && targetTopicId.isNotEmpty) {
                              context.push('/topic/$targetTopicId');
                            } else {
                              context.go('/journey');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ]
          // Case C: Any other date with no activity
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.nightlight_round, size: 22, color: Colors.grey.shade400),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No topics logged on this date',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rest day or external practice. Learning returns on scheduled days!',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. Current Active Goal Card & Progress Tracking (How I'm Learning)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildActiveGoalCard(BuildContext context, Goal? goal) {
    if (goal == null) {
      return _buildEmptyGoalCard(context);
    }

    final daysLeft = goal.deadline != null
        ? goal.deadline!.difference(DateTime.now()).inDays
        : null;

    return SkillTwinCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: AppTheme.primaryAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ACTIVE GOAL',
                            style: TextStyle(
                              fontSize: 9.0,
                              fontWeight: FontWeight.w800,
                              color: Colors.green,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        Text(
                          goal.targetLevel ?? 'Intermediate',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16.5,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (goal.description != null && goal.description!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        goal.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Action buttons (Edit / Delete)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (action) {
                  if (action == 'edit') {
                    _editGoal(context, goal);
                  } else if (action == 'delete') {
                    _confirmDeleteGoal(context, goal);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppTheme.textPrimary),
                        SizedBox(width: 10),
                        Text('Edit Goal', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red.shade600),
                        SizedBox(width: 10),
                        Text('Delete Goal', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (goal.progressPercent / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryAccent),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.progressPercent.toInt()}% Completed',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryAccent,
                ),
              ),
              if (goal.deadline != null)
                Flexible(
                  child: Text(
                    daysLeft != null && daysLeft > 0
                        ? '🎯 Target: ${DateFormat('MMM d').format(goal.deadline!)} ($daysLeft d)'
                        : '🎯 Target: ${DateFormat('MMM d').format(goal.deadline!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Bottom Action Row - Responsive Stacking on compact widths
          LayoutBuilder(
            builder: (context, constraints) {
              final isStacked = constraints.maxWidth < 310;
              final editBtn = OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 15),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Edit Goal'),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                onPressed: () => _editGoal(context, goal),
              );

              final journeyBtn = ElevatedButton.icon(
                icon: const Icon(Icons.map_outlined, size: 15),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Open Journey Roadmap'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  elevation: 0,
                ),
                onPressed: () => context.go('/journey'),
              );

              if (isStacked) {
                return Column(
                  children: [
                    SizedBox(width: double.infinity, child: journeyBtn),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: editBtn),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 2, child: editBtn),
                  const SizedBox(width: 10),
                  Expanded(flex: 3, child: journeyBtn),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGoalCard(BuildContext context) {
    return SkillTwinCard(
      padding: const EdgeInsets.all(18),
      onTap: () => context.push('/onboarding'),
      child: Row(
        children: [
          Image.asset(
            'assets/mascots/twin_rest.webp',
            width: 44,
            height: 44,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: AppTheme.primaryAccent,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No Active Goal Set',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Set a goal to generate your adaptive curriculum.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => context.push('/onboarding'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Set Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveGoalsSection(BuildContext context, List<Goal> inactiveGoals) {
    if (inactiveGoals.isEmpty) {
      return SkillTwinCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.inventory_2_outlined, size: 22, color: Colors.grey.shade400),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No Other Saved Goals',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Save multiple goals and switch between them anytime.',
                    style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Goal', style: TextStyle(fontSize: 12)),
              onPressed: () => context.push('/onboarding'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...inactiveGoals.map((goal) {
          final isCompleted = goal.status == GoalStatus.completed;
          final statusName = goal.status.name.toUpperCase();
          final statusColor = isCompleted
              ? Colors.green
              : (goal.status == GoalStatus.archived ? Colors.grey : const Color(0xFFFF8F00));

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SkillTwinCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                statusName,
                                style: TextStyle(
                                  fontSize: 9.0,
                                  fontWeight: FontWeight.w800,
                                  color: statusColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Text(
                              goal.targetLevel ?? 'Intermediate',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 17, color: Colors.grey),
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Edit Goal',
                            onPressed: () => _editGoal(context, goal),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded, size: 17, color: Colors.red.shade400),
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Delete Goal',
                            onPressed: () => _confirmDeleteGoal(context, goal),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (goal.progressPercent / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${goal.progressPercent.toInt()}% progress',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_circle_outline_rounded, size: 15),
                        label: const Text('Set as Active', style: TextStyle(fontSize: 11.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => _switchActiveGoal(context, goal),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          icon: const Icon(Icons.add_circle_outline_rounded, size: 17),
          label: const Text('Create Another Goal'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryAccent,
            side: const BorderSide(color: AppTheme.primaryAccent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 18),
          ),
          onPressed: () => context.push('/onboarding'),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. What I've Achieved: Milestones & Mastery Card
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildAchievementsCard(
    BuildContext context,
    AsyncValue<dynamic> dashboardAsync,
    AsyncValue<LearningPath?> learningPathAsync,
    User? user,
  ) {
    final learningPath = learningPathAsync.valueOrNull;
    // Collect all topics with null safety
    final allTopics = learningPath?.sections
        .where((s) => s.topics != null)
        .expand((s) => s.topics)
        .where((t) => t != null)
        .toList() ?? [];
    final completedTopics = allTopics.where((t) => t != null && t.status == TopicStatus.completed).toList();
    final completedCount = completedTopics.length;
    final totalCount = allTopics.length;

    final avgMastery = completedTopics.isNotEmpty
        ? (completedTopics.fold<double>(0.0, (acc, t) => acc + (t?.masteryScore ?? 0.0)) / completedTopics.length).toMasteryPercentage
        : (((dashboardAsync.valueOrNull?.overallMastery ?? 0.0) > 1.0)
            ? (dashboardAsync.valueOrNull?.overallMastery ?? 0.0).toInt()
            : ((dashboardAsync.valueOrNull?.overallMastery ?? 0.0) * 100).toInt());

    final dailyTargetMins = user?.dailyMinutes ?? 30;

    return SkillTwinCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/mascots/twin_celebrate.webp',
                width: 42,
                height: 42,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.emoji_events_rounded,
                  size: 34,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Milestones & Mastery',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      completedCount > 0
                          ? '$completedCount concept${completedCount == 1 ? '' : 's'} mastered & verified'
                          : 'Complete concepts to unlock verified milestones',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Metric Tiles (Responsive)
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.verified_rounded,
                  iconColor: Colors.green,
                  title: totalCount > 0 ? '$completedCount / $totalCount' : '$completedCount',
                  subtitle: 'Mastered',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.auto_awesome_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: '$avgMastery%',
                  subtitle: 'Retention',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.timer_outlined,
                  iconColor: AppTheme.primaryAccent,
                  title: '${dailyTargetMins}m',
                  subtitle: 'Daily Target',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Action Handlers (Edit Name, Edit Goal, Delete Goal, Switch Active, Logout)
  // ─────────────────────────────────────────────────────────────────────────────
  void _editPersonalInfo(BuildContext context, User? user) {
    if (user == null) return;
    HapticFeedback.lightImpact();

    final nameController = TextEditingController(
      text: user.displayName.isNotEmpty ? user.displayName : user.name,
    );
    int selectedMinutes = user.dailyMinutes;
    final timezoneController = TextEditingController(text: user.timezone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Edit Personal Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Customize how SkillTwin addresses you and schedules your daily learning.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Full Name',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Daily Practice Target',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [15, 30, 45, 60].map((mins) {
                      final isSelected = selectedMinutes == mins;
                      return ChoiceChip(
                        label: Text('$mins mins'),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryAccent,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedMinutes = mins);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Timezone',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: timezoneController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Asia/Kolkata',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        final newTz = timezoneController.text.trim();
                        if (newName.isEmpty) return;

                        final updated = user.copyWith(
                          name: newName,
                          displayName: newName,
                          dailyMinutes: selectedMinutes,
                          timezone: newTz.isNotEmpty ? newTz : user.timezone,
                        );

                        Navigator.pop(bottomSheetContext);
                        ref.read(authProvider.notifier).updateUser(updated);

                        try {
                          await ref.read(profileRepositoryProvider).updateProfile(updated);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (_) {}
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Save Profile Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editGoal(BuildContext context, Goal goal) {
    HapticFeedback.lightImpact();
    final titleController = TextEditingController(text: goal.title);
    String selectedLevel = goal.targetLevel ?? 'Intermediate';
    DateTime selectedDeadline = goal.deadline ?? DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Edit Learning Goal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Update title, difficulty level, or target deadline.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Goal Title',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Master Flutter & Riverpod',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Target Level',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['Beginner', 'Intermediate', 'Advanced', 'Production Ready'].map((lvl) {
                      final isSelected = selectedLevel.toLowerCase() == lvl.toLowerCase();
                      return ChoiceChip(
                        label: Text(lvl),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryAccent,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedLevel = lvl);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Target Deadline',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDeadline = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryAccent),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat.yMMMMd().format(selectedDeadline),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const Spacer(),
                          const Text('Change', style: TextStyle(color: AppTheme.primaryAccent, fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final newTitle = titleController.text.trim();
                        if (newTitle.isEmpty) return;
                        Navigator.pop(bottomSheetContext);
                        try {
                          await ref.read(goalRepositoryProvider).updateGoal(
                            goal.id,
                            {
                              'title': newTitle,
                              'current_level': selectedLevel,
                              'deadline': selectedDeadline.toIso8601String().split('T').first,
                            },
                          );
                          ref.invalidate(activeGoalProvider);
                          ref.invalidate(allGoalsProvider);
                          ref.invalidate(homeDashboardProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Goal updated successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update goal: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Save Goal Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteGoal(BuildContext context, Goal goal) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Goal?'),
        content: Text(
          'Are you sure you want to delete "${goal.title}"? This will permanently remove its curriculum roadmap and tracking progress.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await ref.read(goalRepositoryProvider).deleteGoal(goal.id);
                ref.invalidate(activeGoalProvider);
                ref.invalidate(allGoalsProvider);
                ref.invalidate(homeDashboardProvider);
                ref.invalidate(learningPathProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Goal deleted.'),
                      backgroundColor: Colors.black87,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete goal: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _switchActiveGoal(BuildContext context, Goal goal) async {
    HapticFeedback.lightImpact();
    try {
      await ref.read(goalRepositoryProvider).setActiveGoal(goal.id);
      ref.invalidate(activeGoalProvider);
      ref.invalidate(allGoalsProvider);
      ref.invalidate(homeDashboardProvider);
      ref.invalidate(learningPathProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched active goal to "${goal.title}"!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch goal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmLogout(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to log out of SkillTwin? Your progress and goals will remain safely synced on your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // UI Helpers
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: AppTheme.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.textPrimary).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 19,
          color: iconColor ?? AppTheme.textPrimary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
