import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/twin_provider.dart';
import '../../../../core/models/twin_dashboard.dart';
import '../../../../core/models/learner_concept.dart';
import '../../../../core/models/evidence.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/mentor_app_bar_action.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/utils/mastery_format.dart';

class TwinScreen extends ConsumerWidget {
  const TwinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final twinDashboardAsync = ref.watch(twinDashboardProvider);
    final learnerStateAsync = ref.watch(learnerStateProvider);
    final evidenceAsync = ref.watch(evidenceHistoryProvider);

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
          ref.invalidate(twinDashboardProvider);
          ref.invalidate(learnerStateProvider);
          ref.invalidate(evidenceHistoryProvider);
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: twinDashboardAsync.when(
              data: (dashboard) {
                if (!dashboard.hasSufficientData) {
                  return _buildInitialEmptyState(context);
                }
                return _buildTwinContent(
                  context,
                  dashboard,
                  learnerStateAsync.asData?.value ?? [],
                  evidenceAsync.asData?.value ?? [],
                );
              },
              loading: () => ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                children: const [
                  SkeletonLoader.card(height: 60),
                  SizedBox(height: 16),
                  SkeletonLoader.card(height: 150),
                  SizedBox(height: 20),
                  SkeletonCardGroup(count: 2, height: 100),
                ],
              ),
              error: (err, _) => ErrorStateView(
                error: err.toString(),
                onRetry: () => ref.invalidate(twinDashboardProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialEmptyState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32.0),
      children: [
        const SizedBox(height: 48),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_outlined,
              size: 64,
              color: Color(0xFFFF6D00),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          "Your Cognitive Twin is Calibrating",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "SkillTwin does not generate vanity or fabricated metrics. Your Cognitive Twin is constructed solely from empirical proofs — completed lessons, practice quizzes, and spaced retrieval sessions.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            color: Colors.grey.shade600,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => context.go('/journey'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6D00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.explore, size: 18),
            label: const Text(
              "Start Practicing in Journey",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTwinContent(
    BuildContext context,
    TwinDashboardData data,
    List<LearnerConcept> concepts,
    List<Evidence> evidence,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _buildQuestionHeader(context),
        const SizedBox(height: 16),

        // 1. Overall Understanding Card
        _TwinMasteryOverview(data: data),
        const SizedBox(height: 20),

        // 2. Stat Boxes: Strong, Developing, Attention, At Risk
        _StatBoxesGrid(data: data),
        const SizedBox(height: 24),

        // 3. Knowledge Maintenance CTA
        _buildMaintenanceCTA(context),
        const SizedBox(height: 28),

        // 4. Mentor Insights
        if (data.insights.isNotEmpty) ...[
          _SectionHeader(title: 'Cognitive Insights'),
          ...data.insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _InsightTile(text: insight),
              )),
          const SizedBox(height: 28),
        ],

        // 5. Verified Concepts (if available)
        if (concepts.isNotEmpty) ...[
          _SectionHeader(title: 'Verified Concepts'),
          ...concepts.map((concept) => _ConceptSummaryCard(concept: concept)),
          const SizedBox(height: 28),
        ],

        // 6. Evidence History (if available)
        if (evidence.isNotEmpty) ...[
          _SectionHeader(title: 'Retrieval & Practice Evidence'),
          ...evidence.map((e) => _EvidenceTile(evidence: e)),
          const SizedBox(height: 32),
        ],

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildQuestionHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WHAT DO I ACTUALLY KNOW?',
          style: TextStyle(
            color: Color(0xFFFF6D00),
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'An uninflated, evidence-based model of your conceptual memory and skill boundaries.',
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
              color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_fix_high, color: Color(0xFFFF6D00)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Knowledge Maintenance',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  'Personalized plan to repair blindspots and reinforce memory.',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
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

class _TwinMasteryOverview extends StatelessWidget {
  final TwinDashboardData data;

  const _TwinMasteryOverview({required this.data});

  @override
  Widget build(BuildContext context) {
    final masteryPct = data.overallMastery.toMasteryPercentage;

    return SkillTwinCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'VERIFIED MASTERY',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data.learningLevel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6D00),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$masteryPct%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on ${data.verifiedEvidenceCount} validated practice attempts.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          _CircularProgress(value: data.overallMastery.toMasteryFraction),
        ],
      ),
    );
  }
}

class _StatBoxesGrid extends StatelessWidget {
  final TwinDashboardData data;

  const _StatBoxesGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final strongNames = data.strongestAreas.map((a) => a.name).toList();
    final weakNames = data.weakestAreas.map((a) => a.name).toList();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatBox(
          label: 'Strong Areas',
          items: strongNames,
          color: Colors.green.shade50,
          textColor: Colors.green.shade800,
          icon: Icons.trending_up,
        ),
        _StatBox(
          label: 'Developing',
          items: weakNames,
          color: Colors.blue.shade50,
          textColor: Colors.blue.shade800,
          icon: Icons.hourglass_empty,
        ),
        _StatBox(
          label: 'Concepts At Risk',
          items: data.conceptsAtRisk,
          color: Colors.red.shade50,
          textColor: Colors.red.shade800,
          icon: Icons.warning_amber_rounded,
        ),
        _StatBox(
          label: 'Consistency',
          items: ['${data.consistencyStreak} day streak'],
          color: Colors.orange.shade50,
          textColor: Colors.orange.shade800,
          icon: Icons.local_fire_department,
        ),
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
              Icon(icon, size: 14, color: textColor.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor.withValues(alpha: 0.7),
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
                fontSize: 12.5,
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212121),
        ),
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
                height: 1.4,
                color: Color(0xFF37474F),
              ),
            ),
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
      padding: const EdgeInsets.only(bottom: 10.0),
      child: SkillTwinCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  concept.conceptId.toUpperCase().replaceAll('_', ' '),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
                Text(
                  '${concept.mastery.toMasteryPercentage}% mastery',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFFFF6D00),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: concept.mastery.toMasteryFraction,
                minHeight: 5,
                backgroundColor: Colors.grey.shade100,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFFF6D00)),
              ),
            ),
          ],
        ),
      ),
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
        border: Border.all(color: Colors.grey.shade200),
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
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
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

class _CircularProgress extends StatelessWidget {
  final double value;

  const _CircularProgress({required this.value});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 68,
          height: 68,
          child: CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: 7,
            backgroundColor: const Color(0xFFFF6D00).withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6D00)),
            strokeCap: StrokeCap.round,
          ),
        ),
        Icon(Icons.psychology, color: Colors.orange.shade800, size: 30),
      ],
    );
  }
}
