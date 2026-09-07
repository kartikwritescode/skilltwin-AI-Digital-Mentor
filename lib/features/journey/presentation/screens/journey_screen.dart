import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/learning_path_provider.dart';
import '../../../../core/models/learning_path.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/mentor_app_bar_action.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/error_state_view.dart';

class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePathAsync = ref.watch(activeLearningPathProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Learning Journey'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          MentorAppBarAction(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          ref.invalidate(activeLearningPathProvider);
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: activePathAsync.when(
              data: (path) {
                if (path == null) {
                  return _buildEmptyState(context);
                }
                return _buildPathContent(context, path);
              },
              loading: () => const SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                child: SkeletonCardGroup(count: 4, height: 120),
              ),
              error: (err, _) => ErrorStateView(
                error: err.toString(),
                onRetry: () => ref.invalidate(activeLearningPathProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32.0),
      children: [
        const SizedBox(height: 60),
        Icon(Icons.map_outlined, size: 72, color: Colors.grey.shade400),
        const SizedBox(height: 24),
        const Text(
          'No Learning Path Active',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set a target outcome to have your AI mentor generate a deep, personalized learning curriculum.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
        ),
        const SizedBox(height: 32),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => context.push('/onboarding'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6D00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Set Learning Goal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPathContent(BuildContext context, LearningPath path) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: [
        _RoadmapHeader(path: path),
        const SizedBox(height: 20),
        ...path.sections.map((section) => _SectionGroup(
              section: section,
              onTopicTap: (topic) {
                HapticFeedback.lightImpact();
                context.push('/journey/topic/${topic.id}');
              },
            )),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _RoadmapHeader extends StatelessWidget {
  final LearningPath path;

  const _RoadmapHeader({required this.path});

  @override
  Widget build(BuildContext context) {
    final progressPct = (path.progress * 100).toInt();

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
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.explore, color: Color(0xFFFF6D00), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE ROADMAP (${path.targetLevel.toUpperCase()})',
                      style: const TextStyle(
                        color: Color(0xFFFF6D00),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      path.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$progressPct%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFFF6D00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: path.progress.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: const Color(0xFFFF6D00).withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6D00)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${path.completedTopics} of ${path.totalTopics} topics completed',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              if (path.estimatedDuration != null)
                Text(
                  path.estimatedDuration!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionGroup extends StatelessWidget {
  final LearningSection section;
  final ValueChanged<LearningTopic> onTopicTap;

  const _SectionGroup({
    required this.section,
    required this.onTopicTap,
  });

  @override
  Widget build(BuildContext context) {
    final sectionPct = (section.progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sectionPct == 100
                      ? Colors.green.shade50
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$sectionPct%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: sectionPct == 100
                        ? Colors.green.shade800
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (section.description != null && section.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 4.0),
            child: Text(
              section.description!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ...section.topics.map((topic) => _TopicTile(
              topic: topic,
              onTap: () => onTopicTap(topic),
            )),
      ],
    );
  }
}

class _TopicTile extends StatelessWidget {
  final LearningTopic topic;
  final VoidCallback onTap;

  const _TopicTile({
    required this.topic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: SkillTwinCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _StatusIcon(status: topic.status),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          topic.difficulty.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.schedule, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${topic.estimatedMinutes}m',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (topic.status == TopicStatus.completed &&
                          topic.masteryScore > 0) ...[
                        const SizedBox(width: 10),
                        Text(
                          '${(topic.masteryScore * 100).toInt()}% mastery',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final TopicStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case TopicStatus.completed:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
        );
      case TopicStatus.learning:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6D00).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_circle_fill,
              color: Color(0xFFFF6D00), size: 20),
        );
      case TopicStatus.needsRevision:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.history_edu, color: Colors.amber.shade800, size: 20),
        );
      case TopicStatus.notStarted:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 20),
        );
    }
  }
}
