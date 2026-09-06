import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/revision_provider.dart';
import '../../../../core/models/revision_item.dart';
import '../../../../core/widgets/skilltwin_card.dart';

class RevisionRetrievalScreen extends ConsumerStatefulWidget {
  final String conceptId;
  const RevisionRetrievalScreen({super.key, required this.conceptId});

  @override
  ConsumerState<RevisionRetrievalScreen> createState() =>
      _RevisionRetrievalScreenState();
}

class _RevisionRetrievalScreenState
    extends ConsumerState<RevisionRetrievalScreen> {
  bool _showAnswer = false;
  bool _isFinished = false;
  String _selectedAccuracy = 'correct'; // default
  String _selectedConfidence = 'confident'; // default
  String _nextReviewText = 'Next review in 3 days.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final revisionState = ref.watch(revisionProvider);

    // Look up item from state or fallback
    final item = revisionState.dueItems.firstWhere(
      (i) =>
          i.conceptId.toLowerCase() == widget.conceptId.toLowerCase() ||
          i.id.toLowerCase() == widget.conceptId.toLowerCase(),
      orElse: () => RevisionItem(
        id: widget.conceptId,
        conceptId: widget.conceptId,
        title: widget.conceptId.replaceAll('_', ' ').toUpperCase(),
        mastery: 0.78,
        risk: RetentionRisk.high,
        lastRetrieval: DateTime.now().subtract(const Duration(days: 9)),
        dueDate: DateTime.now(),
        mentorNote:
            'Give me 4 minutes. I want to check whether the mental model is intact.',
        whyToday:
            'Memory decay threshold reached. Spaced retrieval anchors foundational invariants.',
        mentorPrompt:
            'Explain the invariant mechanism and core state transitions without notes.',
      ),
    );

    if (_isFinished) {
      return _buildResultView(context, item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Active Retrieval Practice',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _showAnswer ? 0.9 : 0.45,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              const SizedBox(height: 24),

              // Concept Badge & Name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CONCEPT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 11,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.risk.name.toUpperCase()} RISK',
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Challenge Card
              SkillTwinCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology_alt,
                            color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'RETRIEVAL CHALLENGE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.mentorPrompt,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pause and recall the fundamental principles before revealing the model.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    if (_showAnswer) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.verified,
                              color: Colors.teal, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'CORE INVARIANT MODEL',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              color: Colors.teal.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getAnswerForConcept(item.conceptId),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (!_showAnswer)
                ElevatedButton.icon(
                  onPressed: () => setState(() => _showAnswer = true),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text(
                    'REVEAL MODEL & INVARIANTS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                )
              else
                _buildSelfAssessment(context, item),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getAnswerForConcept(String conceptId) {
    switch (conceptId.toLowerCase()) {
      case 'recursion':
        return 'Recursion relies on two foundational invariants: (1) a well-defined base case that halts decomposition, and (2) recursive steps that strictly reduce state space towards the base case on the call stack.';
      case 'chain_rule':
        return 'The multivariable chain rule computes composite function gradients by multiplying local Jacobian matrices along all intermediate paths backward from output to inputs.';
      case 'precision_recall':
        return 'Precision measures accuracy of positive predictions (minimizing false positives), while Recall measures coverage of true positives (minimizing false negatives).';
      default:
        return 'The core invariant connects fundamental constraints to predictable state transitions, preventing runtime failures and cognitive regressions.';
    }
  }

  Widget _buildSelfAssessment(BuildContext context, RevisionItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AFTER RETRIEVAL SELF-ASSESSMENT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.1,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),

        // 1. Accuracy Selection
        const Text(
          'Retrieval Accuracy',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _OptionCard(
              label: 'Correct',
              isSelected: _selectedAccuracy == 'correct',
              activeColor: Colors.green.shade700,
              icon: Icons.check_circle_outline,
              onTap: () => setState(() => _selectedAccuracy = 'correct'),
            ),
            const SizedBox(width: 8),
            _OptionCard(
              label: 'Partially correct',
              isSelected: _selectedAccuracy == 'partially_correct',
              activeColor: Colors.orange.shade700,
              icon: Icons.change_circle_outlined,
              onTap: () =>
                  setState(() => _selectedAccuracy = 'partially_correct'),
            ),
            const SizedBox(width: 8),
            _OptionCard(
              label: 'Incorrect',
              isSelected: _selectedAccuracy == 'incorrect',
              activeColor: Colors.red.shade700,
              icon: Icons.cancel_outlined,
              onTap: () => setState(() => _selectedAccuracy = 'incorrect'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 2. Confidence Selection
        const Text(
          'Confidence Level',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _OptionCard(
              label: 'Confident',
              isSelected: _selectedConfidence == 'confident',
              activeColor: Colors.blue.shade700,
              icon: Icons.sentiment_very_satisfied,
              onTap: () => setState(() => _selectedConfidence = 'confident'),
            ),
            const SizedBox(width: 8),
            _OptionCard(
              label: 'Not confident',
              isSelected: _selectedConfidence == 'not_confident',
              activeColor: Colors.grey.shade700,
              icon: Icons.sentiment_dissatisfied,
              onTap: () =>
                  setState(() => _selectedConfidence = 'not_confident'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Submission Button
        ElevatedButton(
          onPressed: () => _handleSubmission(item),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Center(
            child: Text(
              'RECORD RETRIEVAL RESULT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmission(RevisionItem item) async {
    final result = await ref
        .read(revisionProvider.notifier)
        .submitRetrieval(
          reviewItemId: item.id,
          accuracy: _selectedAccuracy,
          confidence: _selectedConfidence,
          timeSpentSeconds: 90,
        );

    setState(() {
      _nextReviewText = result?.nextReviewText ?? 'Next review in 3 days.';
      _isFinished = true;
    });
  }

  Widget _buildResultView(BuildContext context, RevisionItem item) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.orange,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Mental Model Strengthened',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your mentor updated your retention curve for ${item.title}. Spaced retrieval has stopped forgetting decay.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 36),

                // Then show: "Next review in 3 days."
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_available,
                          color: Colors.green, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        _nextReviewText,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'RETURN TO QUEUE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final IconData icon;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : Colors.grey.shade300,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : Colors.grey.shade500,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? activeColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

