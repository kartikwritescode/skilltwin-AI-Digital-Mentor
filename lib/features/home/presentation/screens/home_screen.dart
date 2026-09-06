import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/home_provider.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/mentor_recommendation_banner.dart';
import '../../../../core/widgets/mentor_app_bar_action.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/models/goal.dart';
import '../../../../core/models/mentor_message.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGoalAsync = ref.watch(activeGoalProvider);
    final recommendationAsync = ref.watch(nextBestActionProvider);
    final mentorMessagesAsync = ref.watch(recentMentorMessagesProvider);

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
          ref.invalidate(activeGoalProvider);
          ref.invalidate(nextBestActionProvider);
          ref.invalidate(recentMentorMessagesProvider);
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              children: [
                _buildGreeting(context),
                const SizedBox(height: 20),

                // Question answered: "What should I do now?"
                _SectionHeader(
                  title: "What should I do now?",
                  subtitle: "Your mentor's highest-yield next step",
                ),
                recommendationAsync.when(
                  data: (rec) => MentorRecommendationBanner(
                    recommendation: rec,
                    sectionContext: 'IMMEDIATE FOCUS',
                  ),
                  loading: () => const SkeletonLoader.card(height: 180),
                  error: (err, _) => ErrorStateView(
                    error: err.toString(),
                    onRetry: () => ref.invalidate(nextBestActionProvider),
                  ),
                ),
                const SizedBox(height: 24),

                // Spaced Revision: "5 minutes for your future self."
                _SectionHeader(
                  title: "Will I remember it?",
                  subtitle: "Spaced retrieval queue",
                ),
                const _RevisionQuickCard(),
                const SizedBox(height: 24),

                // Current Goal: "Where am I going?"
                _SectionHeader(
                  title: "Where am I going?",
                  subtitle: "Active roadmap destination",
                ),
                activeGoalAsync.when(
                  data: (goal) => _ActiveGoalCard(goal: goal),
                  loading: () => const SkeletonLoader.card(height: 130),
                  error: (err, _) => ErrorStateView(
                    error: err.toString(),
                    onRetry: () => ref.invalidate(activeGoalProvider),
                  ),
                ),
                const SizedBox(height: 24),

                // Mentor's Note: "Why should I do this?"
                _SectionHeader(
                  title: "Why should I do this?",
                  subtitle: "Cognitive guidance from your personal mentor",
                ),
                mentorMessagesAsync.when(
                  data: (messages) => messages.isNotEmpty
                      ? _MentorNoteCard(message: messages.first)
                      : const SizedBox.shrink(),
                  loading: () => const SkeletonLoader.card(height: 110),
                  error: (err, _) => ErrorStateView(
                    error: err.toString(),
                    onRetry: () => ref.invalidate(recentMentorMessagesProvider),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, Alex',
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

class _ActiveGoalCard extends StatelessWidget {
  final Goal goal;
  const _ActiveGoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
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
                'TARGET OUTCOME',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            goal.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (goal.description != null && goal.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              goal.description!,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6D00)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(goal.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFFFF6D00),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MentorNoteCard extends StatelessWidget {
  final MentorMessage message;
  const _MentorNoteCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return SkillTwinCard(
      onTap: () => context.push('/mentor'),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6D00).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assistant, size: 18, color: Color(0xFFFF6D00)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${message.text}"',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF37474F),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Ask Mentor about this',
                      style: TextStyle(
                        color: Color(0xFFFF6D00),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 12, color: Color(0xFFFF6D00)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevisionQuickCard extends StatelessWidget {
  const _RevisionQuickCard();

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFFFF6D00).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.history_edu, color: Color(0xFFFF6D00), size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '5 minutes for your future self.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prioritized spaced retrieval to stop knowledge decay.',
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
