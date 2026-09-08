import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/twin_provider.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/models/learner_concept.dart';
import '../../../../core/utils/mastery_format.dart';

class ConceptDetailScreen extends ConsumerWidget {
  final String conceptId;
  const ConceptDetailScreen({super.key, required this.conceptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptAsync = ref.watch(conceptDetailProvider(conceptId));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: Text(conceptId.toUpperCase().replaceAll('_', ' ')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: conceptAsync.when(
        data: (concept) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMasteryHeader(context, concept),
            const SizedBox(height: 24),
            _buildMetricsGrid(context, concept),
            const SizedBox(height: 24),
            _buildMentorRecommendation(context, concept),
            const SizedBox(height: 24),
            _buildPrerequisitesSection(context),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Misconceptions',
              child: concept.misconceptionTags.isEmpty
                  ? const Text('No active misconceptions detected.', style: TextStyle(color: Colors.grey))
                  : Wrap(
                      spacing: 8,
                      children: concept.misconceptionTags
                          .map((t) => Chip(
                                label: Text(t, style: const TextStyle(fontSize: 12)),
                                backgroundColor: Colors.red.shade50,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Evidence of Mastery',
              child: SkillTwinCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SkillTwin has observed ${concept.evidenceCount} instances of verified understanding.',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    const _EvidenceItem(text: 'Correctly identified base case in recursive call.'),
                    const _EvidenceItem(text: 'Explained the stack frame behavior during session #4.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Start Focused Session'),
            ),
            const SizedBox(height: 16),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMasteryHeader(BuildContext context, LearnerConcept concept) {
    return SkillTwinCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'CURRENT MASTERY',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Text(
            '${concept.mastery.toMasteryPercentage}%',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: concept.mastery.toMasteryFraction,
              minHeight: 8,
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, LearnerConcept concept) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _MetricTile(label: 'CONFIDENCE', value: concept.confidence),
        _MetricTile(label: 'RETENTION', value: concept.retention),
        _MetricTile(label: 'FORGETTING RISK', value: concept.risk),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('STATUS', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                concept.status.name.toUpperCase(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMentorRecommendation(BuildContext context, LearnerConcept concept) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assistant, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'MENTOR ADVICE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getMockRecommendation(concept),
            style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildPrerequisitesSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Prerequisites',
      child: Wrap(
        spacing: 8,
        children: ['Basic Logic', 'Functions', 'Stack Memory']
            .map((p) => ActionChip(
                  label: Text(p, style: const TextStyle(fontSize: 12)),
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ))
            .toList(),
      ),
    );
  }

  String _getMockRecommendation(LearnerConcept concept) {
    if (concept.risk.toMasteryFraction > 0.7) {
      return "You're at high risk of forgetting this. I recommend a focused retrieval session today to reinforce the mental model.";
    }
    if (concept.mastery.toMasteryFraction < 0.4) {
      return "This is a new area for you. Let's start with high-level conceptual mapping before diving into implementation details.";
    }
    if (concept.confidence < concept.mastery) {
      return "You know this better than you think. You've answered 80% of questions correctly. We should do a 'Prove' session to build your confidence.";
    }
    return "You have a solid foundation here. Let's move on to the next dependent node in your journey.";
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final double value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final frac = value.toMasteryFraction;
    final color = frac > 0.7 ? Colors.green : (frac > 0.4 ? Colors.orange : Colors.red);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: frac,
                  minHeight: 4,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(width: 8),
              Text('${value.toMasteryPercentage}%',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvidenceItem extends StatelessWidget {
  final String text;
  const _EvidenceItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black54))),
        ],
      ),
    );
  }
}
