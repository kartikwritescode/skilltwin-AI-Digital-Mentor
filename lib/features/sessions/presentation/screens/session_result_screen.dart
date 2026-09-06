import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/session_result.dart';
import '../../../../core/widgets/skilltwin_card.dart';

class SessionResultScreen extends ConsumerWidget {
  final SessionResult result;
  final String sessionId;

  const SessionResultScreen({
    super.key,
    required this.result,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          _ResultHeader(theme: theme),
          const SizedBox(height: 40),
          
          // Absolute States
          const Text(
            'NEW UNDERSTANDING STATE',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 20),
          _CurrentStateDisplay(
            mastery: result.currentMastery,
            confidence: result.currentConfidence,
            masteryDelta: result.masteryDelta,
            confidenceDelta: result.confidenceDelta,
          ),
          
          const SizedBox(height: 32),
          _ImprovementsList(result: result),
          const SizedBox(height: 24),
          _FocusAreasList(result: result),
          const SizedBox(height: 32),
          _MentorRecommendation(result: result, theme: theme),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6D00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'RETURN TO JOURNEY',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    context.pop();
                    context.push('/mentor');
                  },
                  icon: const Icon(Icons.assistant, size: 16),
                  label: const Text('Debrief'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final ThemeData theme;
  const _ResultHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified, color: Colors.green, size: 48),
        ),
        const SizedBox(height: 24),
        Text(
          'Session Evaluated',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your AI Mentor has updated your Learner Twin with new evidence.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
      ],
    );
  }
}

class _CurrentStateDisplay extends StatelessWidget {
  final double mastery;
  final double confidence;
  final double masteryDelta;
  final double confidenceDelta;

  const _CurrentStateDisplay({
    required this.mastery,
    required this.confidence,
    required this.masteryDelta,
    required this.confidenceDelta,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StateCard(
            label: 'Understanding',
            value: mastery,
            delta: masteryDelta,
            icon: Icons.psychology,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StateCard(
            label: 'Confidence',
            value: confidence,
            delta: confidenceDelta,
            icon: Icons.auto_awesome,
          ),
        ),
      ],
    );
  }
}

class _StateCard extends StatelessWidget {
  final String label;
  final double value;
  final double delta;
  final IconData icon;

  const _StateCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = delta >= 0;
    final deltaColor = isPositive ? Colors.green : Colors.red;

    return SkillTwinCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 20),
          const SizedBox(height: 12),
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: deltaColor,
              ),
              const SizedBox(width: 2),
              Text(
                '${(delta * 100).abs().toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: deltaColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ImprovementsList extends StatelessWidget {
  final SessionResult result;
  const _ImprovementsList({required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.improvements.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WHAT IMPROVED',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
        ),
        const SizedBox(height: 12),
        ...result.improvements.map((item) => _ResultItem(text: item, icon: Icons.trending_up, color: Colors.green)),
      ],
    );
  }
}

class _FocusAreasList extends StatelessWidget {
  final SessionResult result;
  const _FocusAreasList({required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.focusAreas.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STILL NEEDS WORK',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
        ),
        const SizedBox(height: 12),
        ...result.focusAreas.map((item) => _ResultItem(text: item, icon: Icons.info_outline, color: Colors.orange)),
      ],
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _ResultItem({required this.text, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorRecommendation extends StatelessWidget {
  final SessionResult result;
  final ThemeData theme;

  const _MentorRecommendation({required this.result, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assistant, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Text(
                'MENTOR\'S NEXT STEP',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            result.mentorRecommendation,
            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
