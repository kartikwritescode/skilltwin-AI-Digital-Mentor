import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../../../../core/models/home_dashboard.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/mentor_app_bar_action.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/skilltwin_pulse_loader.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/storage_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static String _getSalutation() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning,';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final authState = ref.watch(authProvider);

    final rawName = authState.user?.displayName.trim();
    final userName = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : (authState.user?.name.trim().isNotEmpty == true
            ? authState.user!.name.trim()
            : 'Learner');

    // Auto-schedule daily native reminders when dashboard loads
    ref.listen<AsyncValue<HomeDashboardData>>(
      homeDashboardProvider,
      (previous, next) {
        next.whenData((data) {
          final targetTopic = data.todayTargetTopicTitle ?? data.nextActionTitle;
          if (targetTopic.isNotEmpty) {
            NotificationService.instance.scheduleDailyStudyReminders(
              pendingTopicTitle: targetTopic,
              backlogCount: data.backlogCount,
              dailyMinutes: data.dailyCommitmentMinutes,
            );
          }
        });
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6D00), Color(0xFFFF9100)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6D00).withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'L',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getSalutation(),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF212121),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.notifications_active_outlined, size: 18, color: Color(0xFF212121)),
            ),
            tooltip: 'Notification Testing Center',
            onPressed: () {
              HapticFeedback.mediumImpact();
              final dashboard = dashboardAsync.valueOrNull;
              _showNotificationTestingSheet(context, ref, dashboard);
            },
          ),
          const SizedBox(width: 4),
          const MentorAppBarAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          ref.invalidate(homeDashboardProvider);
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: dashboardAsync.when(
              data: (data) => ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                children: [
                  // Flagship: Today's Study Plan, Schedule & Backlog
                  _TodayScheduleCard(data: data),
                  const SizedBox(height: 24),

                  // Active Roadmap Destination
                  const _SectionHeader(
                    title: "Active Roadmap Progress",
                    subtitle: "Roadmap milestone & progress velocity",
                  ),
                  _RoadmapProgressCard(data: data),
                  const SizedBox(height: 24),

                  // Spaced Revision Queue
                  const _SectionHeader(
                    title: "Spaced Retrieval Queue",
                    subtitle: "5-minute memory consolidation",
                  ),
                  _RevisionQueueCard(revisionDueCount: data.revisionDueCount),
                  const SizedBox(height: 24),

                  // Learning Momentum
                  const _SectionHeader(
                    title: "Learning Momentum",
                    subtitle: "Empirically tracked practice and consistency",
                  ),
                  _MetricsRow(data: data),
                  const SizedBox(height: 24),

                  // Mentor Insights
                  if (data.insights.isNotEmpty) ...[
                    const _SectionHeader(
                      title: "Mentor Cognitive Insights",
                      subtitle:
                          "Synthesized from your quiz attempts and learning pace",
                    ),
                    ...data.insights.map((insight) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _InsightCard(text: insight),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Weak Areas (if any)
                  if (data.weakAreas.isNotEmpty) ...[
                    const _SectionHeader(
                      title: "Areas Needing Attention",
                      subtitle: "Topics where practice attempts indicated uncertainty",
                    ),
                    _WeakAreasCard(weakAreas: data.weakAreas),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
              loading: () => const SkillTwinPulseLoader.fullScreen(
                message: "Calibrating study schedule & daily path...",
              ),
              error: (err, _) => ErrorStateView(
                error: err.toString(),
                onRetry: () => ref.invalidate(homeDashboardProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                  color: const Color(0xFF212121),
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TodayScheduleCard extends StatelessWidget {
  final HomeDashboardData data;

  const _TodayScheduleCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final hasGoal = data.goalId != null && data.goalId!.isNotEmpty;
    if (!hasGoal && data.isNewLearner) {
      return SkillTwinCard(
        onTap: () => context.push('/onboarding'),
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.rocket_launch_rounded, size: 32, color: Color(0xFFFF6D00)),
            ),
            const SizedBox(height: 14),
            const Text(
              "Set Up Your Personalized Roadmap",
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 6),
            Text(
              "Tell your mentor what you want to master, how much time you have, and your deadline.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/onboarding'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6D00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Create Learning Path", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    final deadlineStr = data.targetDeadline != null
        ? DateFormat.yMMMd().format(data.targetDeadline!)
        : null;

    final isBehind =
        data.scheduleStatus == 'BEHIND_SCHEDULE' || data.backlogCount > 0;
    final isAhead = data.scheduleStatus == 'AHEAD_OF_SCHEDULE';
    final isCompleted = data.scheduleStatus == 'COMPLETED';

    Color statusColor = const Color(0xFF047857);
    Color statusBg = const Color(0xFFECFDF5);
    Color statusBorder = const Color(0xFFA7F3D0);
    IconData statusIcon = Icons.check_circle_rounded;
    String statusLabel = 'On Track';

    if (isBehind) {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEF2F2);
      statusBorder = const Color(0xFFFECACA);
      statusIcon = Icons.warning_amber_rounded;
      statusLabel = 'Behind Schedule';
    } else if (isAhead) {
      statusColor = const Color(0xFF7C3AED);
      statusBg = const Color(0xFFF5F3FF);
      statusBorder = const Color(0xFFDDD6FE);
      statusIcon = Icons.bolt_rounded;
      statusLabel = 'Ahead of Schedule';
    } else if (isCompleted) {
      statusColor = const Color(0xFF2563EB);
      statusBg = const Color(0xFFEFF6FF);
      statusBorder = const Color(0xFFBFDBFE);
      statusIcon = Icons.stars_rounded;
      statusLabel = 'Goal Completed';
    }

    final targetTopicId = data.todayTargetTopicId ?? data.nextActionTopicId ?? data.currentTopicId;
    final targetTopicTitle = data.todayTargetTopicTitle ?? data.nextActionTitle;
    final instructionText = data.dailyInstructions ?? data.nextActionReason;

    return SkillTwinCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Schedule Status Badge & Deadline / Pacing
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (deadlineStr != null) ...[
                Icon(Icons.event_outlined, size: 13, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${data.daysRemaining} days remaining',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ] else ...[
                Text(
                  'Self-Paced Learning',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ],
          ),

          // Row 2: Backlog Warning or On-Track Status
          if (isBehind) ...[
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 13),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data.backlogCount} Topic${data.backlogCount > 1 ? 's' : ''} in Backlog',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Falling behind target deadline. Finish today\'s study to catch up.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (deadlineStr != null) ...[
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A), size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Zero backlog • On track for $deadlineStr',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Row 3: Target Topic Title & Meta
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6D00), Color(0xFFFF9100)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6D00).withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TODAY'S MISSION",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Color(0xFFFF6D00),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      targetTopicTitle,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Row 4: Mentor Daily Guidance Callout
          if (instructionText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.psychology, color: Color(0xFFFF6D00), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      instructionText,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: Color(0xFF7C2D12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Row 5: Key Concepts Chips
          if (data.todayKeyConcepts.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              "KEY CONCEPTS IN THIS TOPIC:",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: data.todayKeyConcepts.map((concept) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    '#$concept',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Row 6: High-yield Action Button
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                if (targetTopicId != null && targetTopicId.isNotEmpty) {
                  context.push('/journey/topic/$targetTopicId');
                } else {
                  context.push('/journey');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6D00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                shadowColor: const Color(0xFFFF6D00).withValues(alpha: 0.35),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isBehind
                        ? "Start Today's Topic & Catch Up"
                        : "Start Today's Session",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapProgressCard extends StatelessWidget {
  final HomeDashboardData data;

  const _RoadmapProgressCard({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isNewLearner && data.goalTitle == 'No Active Goal') {
      return SkillTwinCard(
        onTap: () => context.push('/onboarding'),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.flag_outlined, size: 36, color: Color(0xFFFF6D00)),
            const SizedBox(height: 12),
            const Text(
              "No Active Learning Goal",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Define what you want to master to generate your personalized learning path.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/onboarding'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6D00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Create Goal"),
            ),
          ],
        ),
      );
    }

    final progressPct = (data.overallProgress * 100).toInt();

    return SkillTwinCard(
      onTap: () => context.go('/journey'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flag, color: Color(0xFFFF6D00), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'TARGET OUTCOME (${data.targetLevel.toUpperCase()})',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.goalTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF212121),
            ),
          ),
          if (data.currentModuleName != null) ...[
            const SizedBox(height: 4),
            Text(
              'Current: ${data.currentModuleName}${data.currentTopicTitle != null ? ' > ${data.currentTopicTitle}' : ''}',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: data.overallProgress.clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor:
                        const Color(0xFFFF6D00).withValues(alpha: 0.12),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFFF6D00)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$progressPct%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFFFF6D00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${data.topicsCompleted} completed',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                '${data.topicsRemaining} remaining',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevisionQueueCard extends StatelessWidget {
  final int revisionDueCount;

  const _RevisionQueueCard({required this.revisionDueCount});

  @override
  Widget build(BuildContext context) {
    final hasDue = revisionDueCount > 0;

    return SkillTwinCard(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/revision');
      },
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasDue
                  ? Colors.amber.shade50
                  : const Color(0xFFFF6D00).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.history_edu,
              color: hasDue ? Colors.amber.shade800 : const Color(0xFFFF6D00),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasDue
                      ? '$revisionDueCount ${revisionDueCount == 1 ? 'topic' : 'topics'} due for spaced review'
                      : 'Retention is optimal',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasDue
                      ? '5-minute retrieval sessions stop knowledge decay.'
                      : 'All concepts are within high-retention intervals.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final HomeDashboardData data;

  const _MetricsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricItem(
            icon: Icons.local_fire_department,
            iconColor: Colors.orange.shade800,
            bgColor: Colors.orange.shade50,
            value: '${data.streakDays}',
            label: 'Day Streak',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricItem(
            icon: Icons.timer,
            iconColor: Colors.blue.shade700,
            bgColor: Colors.blue.shade50,
            value: '${data.learningMinutes}m',
            label: 'Practice Time',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricItem(
            icon: Icons.psychology,
            iconColor: Colors.purple.shade700,
            bgColor: Colors.purple.shade50,
            value: '${(data.overallMastery * 100).toInt()}%',
            label: 'True Mastery',
          ),
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String label;

  const _MetricItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String text;

  const _InsightCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6D00).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFFFF6D00), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: Color(0xFF37474F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeakAreasCard extends StatelessWidget {
  final List<String> weakAreas;

  const _WeakAreasCard({required this.weakAreas});

  @override
  Widget build(BuildContext context) {
    return SkillTwinCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 18, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                "BLINDSPOTS IDENTIFIED",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weakAreas
                .map((area) => Chip(
                      label: Text(area),
                      backgroundColor: Colors.red.shade50,
                      side: BorderSide(color: Colors.red.shade100),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

void _showNotificationTestingSheet(
  BuildContext context,
  WidgetRef ref,
  HomeDashboardData? dashboard,
) {
  final prefs = ref.read(sharedPrefsProvider);
  final fcmToken = prefs.getString('fcm_token');

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E293B),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active, color: Color(0xFF38BDF8)),
                SizedBox(width: 8),
                Text(
                  'Notification Testing Center',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flash_on, color: Colors.amber, size: 20),
              ),
              title: const Text(
                'Send Instant Trolling Roast',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Fires a sarcastic reminder immediately to your device tray.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
              onTap: () async {
                Navigator.pop(ctx);
                await NotificationService.instance.showInstantTrollNotification(
                  topicTitle: dashboard?.todayTargetTopicTitle,
                  backlogCount: dashboard?.backlogCount,
                  dailyMinutes: dashboard?.dailyCommitmentMinutes,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔔 Trolling reminder sent! Check your notification drawer.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            const Divider(color: Color(0xFF334155), height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cloud_done, color: Colors.greenAccent, size: 20),
              ),
              title: const Text(
                'FCM Device Token (Firebase Cloud Push)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                fcmToken ?? 'Token pending (run on real device or Android emulator with Google Play)',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Color(0xFF38BDF8)),
                tooltip: 'Copy Token for Firebase Console',
                onPressed: fcmToken != null
                    ? () {
                        Clipboard.setData(ClipboardData(text: fcmToken));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📋 FCM Token copied! Paste it in Firebase Console to send test push.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    : null,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}
