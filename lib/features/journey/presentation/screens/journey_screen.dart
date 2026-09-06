import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/journey_provider.dart';
import '../widgets/winding_roadmap.dart';
import '../../../../core/models/journey_node.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/mentor_app_bar_action.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../mentor/presentation/providers/mentor_recommendation_provider.dart';

class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyState = ref.watch(journeyProvider);
    final notifier = ref.read(journeyProvider.notifier);
    final mentorGuidance = ref.watch(journeyMentorGuidanceProvider);

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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                _buildHeader(context, notifier.overallProgress, mentorGuidance),
                Expanded(
                  child: journeyState.isLoading
                      ? const SingleChildScrollView(
                          padding: EdgeInsets.all(24.0),
                          child: SkeletonCardGroup(count: 3, height: 110),
                        )
                      : journeyState.error != null
                          ? ErrorStateView(
                              error: journeyState.error!,
                              onRetry: () => notifier.loadJourney(),
                            )
                          : WindingRoadmap(
                              nodes: journeyState.nodes,
                              onNodeTap: (node) {
                                HapticFeedback.selectionClick();
                                _showNodeDetails(context, node);
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double progress, String mentorGuidance) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SkillTwinCard(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WHERE AM I GOING?',
                      style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFFF6D00),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const Text(
                      'AI / Machine Learning Engineer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF6D00),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6D00)),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6D00).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.assistant_outlined, size: 16, color: Color(0xFFFF6D00)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mentorGuidance,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade800,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNodeDetails(BuildContext context, JourneyNode node) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NodeDetailsBottomSheet(node: node),
    );
  }
}

class _NodeDetailsBottomSheet extends StatelessWidget {
  final JourneyNode node;

  const _NodeDetailsBottomSheet({required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
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
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.phase?.toUpperCase() ?? 'PHASE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFFF6D00),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      node.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: node.status),
            ],
          ),
          const SizedBox(height: 20),
          if (node.whyItMatters != null) ...[
            Text(
              'WHY THIS STEP MATTERS',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Text(node.whyItMatters!, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
            const SizedBox(height: 18),
          ],
          if (node.prerequisites.isNotEmpty) ...[
            Text(
              'PREREQUISITES',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: node.prerequisites.map((p) => Chip(
                label: Text(p, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.grey.shade100,
                side: BorderSide.none,
              )).toList(),
            ),
            const SizedBox(height: 18),
          ],
          if (node.mentorRecommendation != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6D00).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFF6D00).withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.assistant, color: Color(0xFFFF6D00), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MENTOR RECOMMENDATION',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6D00),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          node.mentorRecommendation!,
                          style: const TextStyle(fontSize: 12.5, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
          ],
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: node.status == NodeStatus.locked ? null : () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    context.push('/session/${node.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6D00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    node.status == NodeStatus.completed ? 'Review Practice' : 'Start Practice Session',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    context.push('/mentor');
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 15),
                  label: const Text('Discuss'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final NodeStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label = status.name.toUpperCase();
    
    switch (status) {
      case NodeStatus.completed: color = Colors.green; break;
      case NodeStatus.current: color = const Color(0xFFFF6D00); break;
      case NodeStatus.needsAttention: color = Colors.redAccent; break;
      case NodeStatus.upcoming: color = Colors.blueGrey; break;
      case NodeStatus.locked: color = Colors.grey; break;
      case NodeStatus.skipped: color = Colors.grey; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
