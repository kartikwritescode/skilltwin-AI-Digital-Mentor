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
import '../../../../core/utils/mastery_format.dart';
import '../widgets/youtube_import_modal.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add, color: Color(0xFFFF0000)),
            tooltip: 'Import YouTube Playlist',
            onPressed: () => YouTubeImportModal.show(context),
          ),
          const MentorAppBarAction(),
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
          'Set a target outcome to have your AI mentor generate a curriculum, or import any YouTube playlist to learn sequentially.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
        ),
        const SizedBox(height: 32),
        Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => context.push('/onboarding'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6D00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
              OutlinedButton.icon(
                onPressed: () => YouTubeImportModal.show(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF0000),
                  side: const BorderSide(color: Color(0xFFFF0000)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_circle_fill, size: 18),
                label: const Text(
                  'Import YouTube Playlist',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
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
    final isYouTube = path.isYouTubeCurriculum;

    LearningTopic? nextTopic;
    for (final section in path.sections) {
      for (final topic in section.topics) {
        if (topic.status != TopicStatus.completed) {
          nextTopic = topic;
          break;
        }
      }
      if (nextTopic != null) break;
    }

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
                  color: isYouTube
                      ? const Color(0xFFFF0000).withValues(alpha: 0.1)
                      : const Color(0xFFFF6D00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isYouTube ? Icons.play_circle_fill : Icons.explore,
                  color: isYouTube ? const Color(0xFFFF0000) : const Color(0xFFFF6D00),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isYouTube
                          ? 'YOUTUBE PLAYLIST CURRICULUM'
                          : 'ACTIVE ROADMAP (${path.targetLevel.toUpperCase()})',
                      style: TextStyle(
                        color: isYouTube ? const Color(0xFFFF0000) : const Color(0xFFFF6D00),
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isYouTube ? const Color(0xFFFF0000) : const Color(0xFFFF6D00),
                ),
              ),
            ],
          ),
          if (isYouTube && path.channelName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Created by ${path.channelName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
                if (path.isStrictMode) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blueGrey.shade200),
                    ),
                    child: Text(
                      '🔒 Strict Sequence',
                      style: TextStyle(fontSize: 10, color: Colors.blueGrey.shade800, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: path.progress.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: isYouTube
                  ? const Color(0xFFFF0000).withValues(alpha: 0.12)
                  : const Color(0xFFFF6D00).withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                isYouTube ? const Color(0xFFFF0000) : const Color(0xFFFF6D00),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${path.completedTopics} of ${path.totalTopics} ${isYouTube ? 'videos' : 'topics'} completed',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              if (path.estimatedDuration != null)
                Text(
                  path.estimatedDuration!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
            ],
          ),
          if (nextTopic != null) ...[
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/journey/topic/${nextTopic!.id}');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isYouTube
                      ? const Color(0xFFFF0000).withValues(alpha: 0.06)
                      : const Color(0xFFFF6D00).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isYouTube
                        ? const Color(0xFFFF0000).withValues(alpha: 0.25)
                        : const Color(0xFFFF6D00).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: isYouTube ? const Color(0xFFFF0000) : const Color(0xFFFF6D00),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CONTINUE LEARNING',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: isYouTube ? const Color(0xFFFF0000) : const Color(0xFFFF6D00),
                            ),
                          ),
                          Text(
                            nextTopic.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
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

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final remM = m % 60;
      return '${h}h ${remM}m';
    }
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

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
                      if (topic.isYouTubeVideo) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF0000).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_circle_fill,
                                  size: 10, color: Color(0xFFFF0000)),
                              const SizedBox(width: 3),
                              Text(
                                'Video #${(topic.position ?? 0) + 1}',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF0000),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (topic.durationSeconds > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            _formatDuration(topic.durationSeconds),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                      if (topic.status == TopicStatus.completed &&
                          topic.masteryScore > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${topic.masteryScore.toMasteryPercentage}% mastery',
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
