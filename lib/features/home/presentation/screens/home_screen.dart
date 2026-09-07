import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../../../../core/models/home_dashboard.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/mentor_app_bar_action.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/error_state_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('SkillTwin'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          MentorAppBarAction(),
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
                  _buildGreeting(context, userName),
                  const SizedBox(height: 20),

                  // 1. Next Action Banner
                  _SectionHeader(
                    title: "What should I do now?",
                    subtitle: "Your mentor's highest-yield next step",
                  ),
                  _NextActionCard(data: data),
                  const SizedBox(height: 24),

                  // 2. Active Roadmap Destination
                  _SectionHeader(
                    title: "Where am I going?",
                    subtitle: "Active roadmap destination & current progress",
                  ),
                  _RoadmapProgressCard(data: data),
                  const SizedBox(height: 24),

                  // 3. Spaced Revision Queue
                  _SectionHeader(
                    title: "Will I remember it?",
                    subtitle: "Spaced retrieval queue",
                  ),
                  _RevisionQueueCard(revisionDueCount: data.revisionDueCount),
                  const SizedBox(height: 24),

                  // 4. Learning Momentum & Real Metrics
                  _SectionHeader(
                    title: "Learning Momentum",
                    subtitle: "Empirically tracked practice and consistency",
                  ),
                  _MetricsRow(data: data),
                  const SizedBox(height: 24),

                  // 5. Mentor Insights
                  if (data.insights.isNotEmpty) ...[
                    _SectionHeader(
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

                  // 6. Weak Areas (if any)
                  if (data.weakAreas.isNotEmpty) ...[
                    _SectionHeader(
                      title: "Areas Needing Attention",
                      subtitle: "Topics where practice attempts indicated uncertainty",
                    ),
                    _WeakAreasCard(weakAreas: data.weakAreas),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
              loading: () => ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                children: const [
                  SkeletonLoader.card(height: 60),
                  SizedBox(height: 20),
                  SkeletonLoader.card(height: 160),
                  SizedBox(height: 24),
                  SkeletonLoader.card(height: 130),
                  SizedBox(height: 24),
                  SkeletonLoader.card(height: 80),
                ],
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

  Widget _buildGreeting(BuildContext context, String userName) {
    final hour = DateTime.now().hour;
    String salutation = 'Good morning';
    if (hour >= 12 && hour < 17) {
      salutation = 'Good afternoon';
    } else if (hour >= 17) {
      salutation = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$salutation, $userName',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your cognitive twin is ready for today\'s deliberate practice.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
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

class _NextActionCard extends StatelessWidget {
  final HomeDashboardData data;

  const _NextActionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final targetTopicId = data.nextActionTopicId ?? data.currentTopicId;

    return SkillTwinCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt, color: Color(0xFFFF6D00), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.nextActionType.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFF6D00),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      data.nextActionTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.nextActionReason,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                if (targetTopicId != null && targetTopicId.isNotEmpty) {
                  context.push('/journey/topic/$targetTopicId');
                } else {
                  context.go('/journey');
                }
              },
              icon: const Icon(Icons.play_arrow, size: 18),
              label: Text(
                data.isNewLearner ? 'Start First Topic' : 'Continue Practice',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6D00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
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
