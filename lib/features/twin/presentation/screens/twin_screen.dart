import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/twin_provider.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/mentor_app_bar_action.dart';
import '../../../../core/widgets/mentor_recommendation_banner.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/models/learner_concept.dart';
import '../../../../core/models/evidence.dart';
import '../../../mentor/presentation/providers/mentor_recommendation_provider.dart';

class TwinScreen extends ConsumerWidget {
  const TwinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(twinOverviewProvider);
    final learnerStateAsync = ref.watch(learnerStateProvider);
    final evidenceAsync = ref.watch(evidenceHistoryProvider);
    final recommendationAsync = ref.watch(currentMentorRecommendationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('My Cognitive Twin'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          MentorAppBarAction(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          ref.invalidate(twinOverviewProvider);
          ref.invalidate(learnerStateProvider);
          ref.invalidate(evidenceHistoryProvider);
          ref.invalidate(currentMentorRecommendationProvider);
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildQuestionHeader(context),
                const SizedBox(height: 16),
                overviewAsync.when(
                  data: (data) => _TwinOverviewSection(data: data),
                  loading: () => const SkeletonLoader.card(height: 150),
                  error: (err, _) => ErrorStateView(
                    error: err.toString(),
                    onRetry: () => ref.invalidate(twinOverviewProvider),
                  ),
                ),
                const SizedBox(height: 20),
                recommendationAsync.when(
                  data: (rec) => MentorRecommendationBanner(
                    recommendation: rec,
                    sectionContext: 'COGNITIVE REPAIR',
                    customActionLabel: 'Remediate Blindspot',
                  ),
                  loading: () => const SkeletonLoader.card(height: 150),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),
                _buildMaintenanceCTA(context),
                const SizedBox(height: 28),
                _SectionHeader(title: 'Knowledge Graph', action: 'Inspect'),
                const _KnowledgeMapPlaceholder(),
                const SizedBox(height: 28),
                _SectionHeader(title: 'Verified Concepts'),
                learnerStateAsync.when(
                  data: (concepts) => Column(
                    children: concepts
                        .map((concept) => _ConceptSummaryCard(concept: concept))
                        .toList(),
                  ),
                  loading: () => const SkeletonCardGroup(count: 3, height: 80),
                  error: (err, _) => ErrorStateView(
                    error: err.toString(),
                    onRetry: () => ref.invalidate(learnerStateProvider),
                  ),
                ),
                const SizedBox(height: 28),
                _SectionHeader(title: 'Retrieval & Practice Evidence'),
                evidenceAsync.when(
                  data: (evidence) => Column(
                    children: evidence
                        .map((e) => _EvidenceTile(evidence: e))
                        .toList(),
                  ),
                  loading: () => const SkeletonCardGroup(count: 2, height: 70),
                  error: (err, _) => ErrorStateView(
                    error: err.toString(),
                    onRetry: () => ref.invalidate(evidenceHistoryProvider),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHAT DO I ACTUALLY KNOW?',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFFFF6D00),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'An uninflated, evidence-based model of your long-term memory and conceptual boundaries.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceCTA(BuildContext context) {
    return SkillTwinCard(
      onTap: () => context.push('/twin/maintenance'),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_fix_high, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Knowledge Maintenance',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Personalized plan to fix, revise, and keep your skills sharp.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
          ),
          if (action != null)
            TextButton(
              onPressed: () {},
              child: Text(
                action!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),
        ],
      ),
    );
  }
}

class _TwinOverviewSection extends StatelessWidget {
  final Map<String, dynamic> data;
  const _TwinOverviewSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overall = (data['overall_understanding'] ?? 0.0) as double;
    final insights = (data['insights'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkillTwinCard(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OVERALL UNDERSTANDING',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(overall * 100).toInt()}%',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Mastery level is stable and progressing.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _CircularProgress(value: overall),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _StatBox(
              label: 'Strong areas',
              items: List<String>.from(data['strong_areas'] ?? []),
              color: Colors.green.shade50,
              textColor: Colors.green.shade800,
              icon: Icons.trending_up,
            ),
            _StatBox(
              label: 'Developing',
              items: List<String>.from(data['developing_areas'] ?? []),
              color: Colors.blue.shade50,
              textColor: Colors.blue.shade800,
              icon: Icons.hourglass_empty,
            ),
            _StatBox(
              label: 'Needs attention',
              items: List<String>.from(data['needs_attention'] ?? []),
              color: Colors.red.shade50,
              textColor: Colors.red.shade800,
              icon: Icons.warning_amber_rounded,
            ),
            _StatBox(
              label: 'Retention Risk',
              items: ['Recursion'],
              color: Colors.orange.shade50,
              textColor: Colors.orange.shade800,
              icon: Icons.psychology_alt,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Mentor Insights',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _InsightTile(text: insight.toString()),
            )),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color color;
  final Color textColor;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.items,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: textColor.withOpacity(0.6)),
              const SizedBox(width: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor.withOpacity(0.7),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              items.isEmpty ? 'None' : items.join(', '),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String text;
  const _InsightTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _KnowledgeMapPlaceholder extends ConsumerWidget {
  const _KnowledgeMapPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topologyAsync = ref.watch(conceptGraphTopologyProvider);

    return topologyAsync.when(
      data: (data) => _InteractiveKnowledgeGraphWidget(data: data),
      loading: () => const SkeletonLoader.card(height: 240),
      error: (_, __) => _InteractiveKnowledgeGraphWidget(
        data: const {
          'nodes': [
            {'id': 'python_basics', 'name': 'Python Basics', 'domain': 'programming', 'tier': 1, 'mastery_score': 95.0, 'status': 'MASTERED'},
            {'id': 'probability', 'name': 'Probability & Bayes', 'domain': 'math', 'tier': 1, 'mastery_score': 45.0, 'status': 'NEEDS_REVIEW'},
            {'id': 'linear_algebra', 'name': 'Linear Algebra', 'domain': 'math', 'tier': 1, 'mastery_score': 60.0, 'status': 'LEARNING'},
            {'id': 'backpropagation', 'name': 'Backpropagation', 'domain': 'ml', 'tier': 3, 'mastery_score': 30.0, 'status': 'UNCERTAIN'},
          ],
          'edges': [
            {'source': 'linear_algebra', 'target': 'backpropagation', 'relationship': 'prerequisite'},
          ]
        },
      ),
    );
  }
}

class _InteractiveKnowledgeGraphWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const _InteractiveKnowledgeGraphWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final nodes = (data['nodes'] as List<dynamic>?) ?? [];
    final edges = (data['edges'] as List<dynamic>?) ?? [];

    return SkillTwinCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.hub_outlined, color: Color(0xFFFF6D00), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'CONCEPT DEPENDENCY NETWORK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${nodes.length} Concepts • ${edges.length} Dependencies',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6D00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: nodes.length,
              separatorBuilder: (context, index) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              itemBuilder: (context, index) {
                final node = nodes[index] as Map<String, dynamic>;
                return _GraphNodeCard(node: node);
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: Colors.green, label: 'Mastered'),
              const SizedBox(width: 14),
              _LegendDot(color: Colors.blue, label: 'Learning'),
              const SizedBox(width: 14),
              _LegendDot(color: Colors.orange, label: 'Review'),
              const SizedBox(width: 14),
              _LegendDot(color: Colors.red, label: 'Uncertain'),
            ],
          ),
        ],
      ),
    );
  }
}

class _GraphNodeCard extends StatelessWidget {
  final Map<String, dynamic> node;

  const _GraphNodeCard({required this.node});

  @override
  Widget build(BuildContext context) {
    final name = (node['name'] ?? node['id'] ?? 'Concept').toString();
    final id = (node['id'] ?? '').toString();
    final status = (node['status'] ?? 'NOT_STARTED').toString().toUpperCase();
    final mastery = ((node['mastery_score'] ?? 0.0) as num).toDouble();
    final domain = (node['domain'] ?? 'core').toString();

    Color statusColor;
    if (status.contains('MASTERED')) {
      statusColor = Colors.green;
    } else if (status.contains('LEARN')) {
      statusColor = Colors.blue;
    } else if (status.contains('REVIEW')) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        HapticFeedback.lightImpact();
        if (id.isNotEmpty) {
          context.push('/journey/concept/$id');
        }
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    domain.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mastery',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                    Text(
                      '${mastery.toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (mastery / 100.0).clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  final Evidence evidence;
  const _EvidenceTile({required this.evidence});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified, color: Colors.green, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evidence.description,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  evidence.conceptId,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            '${DateTime.now().difference(evidence.timestamp).inDays}d ago',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _ConceptSummaryCard extends StatelessWidget {
  final LearnerConcept concept;
  const _ConceptSummaryCard({required this.concept});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SkillTwinCard(
        onTap: () => context.push('/journey/concept/${concept.conceptId}'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  concept.conceptId.toUpperCase().replaceAll('_', ' '),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                _StatusBadge(status: concept.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _MiniStat(label: 'Mastery', value: concept.mastery),
                _MiniStat(label: 'Confidence', value: concept.confidence),
                _MiniStat(label: 'Retention', value: concept.retention),
              ],
            ),
            if (concept.risk > 0.6) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 12, color: Colors.red.shade800),
                    const SizedBox(width: 4),
                    Text(
                      'High retention risk',
                      style: TextStyle(color: Colors.red.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final color = value > 0.7 ? Colors.green : (value > 0.4 ? Colors.orange : Colors.red);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ConceptStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ConceptStatus.mastered: color = Colors.green; break;
      case ConceptStatus.learning: color = Colors.blue; break;
      case ConceptStatus.needsReview: color = Colors.orange; break;
      case ConceptStatus.uncertain: color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  final double value;
  const _CircularProgress({required this.value});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 8,
            backgroundColor: Colors.orange.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            strokeCap: StrokeCap.round,
          ),
        ),
        Icon(Icons.psychology, color: Colors.orange.shade800, size: 32),
      ],
    );
  }
}
