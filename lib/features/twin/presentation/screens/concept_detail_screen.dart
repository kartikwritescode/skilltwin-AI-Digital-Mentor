import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';
import '../../../../core/widgets/skilltwin_transition_switcher.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../../../../core/widgets/skilltwin_twin.dart';
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(conceptId.toUpperCase().replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SkillTwinBackground(
        child: SkillTwinTransitionSwitcher(
        child: conceptAsync.when(
          data: (concept) => ListView(
            key: const ValueKey('concept_detail_content'),
            padding: EdgeInsets.fromLTRB(16, 16, 16, AppSpacing.calculateBottomNavInset(context)),
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
                  backgroundColor: AppTheme.primaryAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Start Focused Session', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
          loading: () => const SkillTwinLoadingView.fullScreen(
            key: ValueKey('concept_detail_loading'),
            message: 'SkillTwin is preparing your next step.',
            subMessage: 'Retrieving concept mastery insights...',
          ),
          error: (err, _) => Center(
            key: const ValueKey('concept_detail_error'),
            child: Text('Error: $err'),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildMasteryHeader(BuildContext context, LearnerConcept concept) {
    final frac = concept.mastery.toMasteryFraction;
    final isStrong = frac >= 0.7;

    return SkillTwinCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SkillTwinTwin(
            asset: isStrong ? TwinAsset.celebrating : TwinAsset.studying,
            size: 56,
          ),
          const SizedBox(height: 14),
          const Text(
            'CURRENT MASTERY',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            '${concept.mastery.toMasteryPercentage}%',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isStrong ? AppTheme.positive : AppTheme.primaryAccent,
                ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 8,
              backgroundColor: AppTheme.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(isStrong ? AppTheme.positive : AppTheme.primaryAccent),
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
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('STATUS', style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                concept.status.name.toUpperCase(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
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
        color: AppTheme.primaryAccent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SkillTwinTwin(asset: TwinAsset.thinking, size: 24),
              SizedBox(width: 10),
              Text(
                'MENTOR ADVICE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getMockRecommendation(concept),
            style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.textPrimary),
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
    final color = frac > 0.7 ? AppTheme.positive : (frac > 0.4 ? AppTheme.primaryAccent : Colors.redAccent);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
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
              Text(
                '${(frac * 100).toInt()}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
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
