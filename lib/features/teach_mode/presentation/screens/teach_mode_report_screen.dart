import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/teach_mode_provider.dart';
import '../../../../core/widgets/skilltwin_card.dart';

class TeachModeReportScreen extends ConsumerWidget {
  const TeachModeReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teachModeProvider);
    final report = state.report;
    final theme = Theme.of(context);

    if (report == null) {
      return const Scaffold(body: Center(child: Text('No report available.')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Understanding Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(teachModeProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildScoreOverview(context, report),
          const SizedBox(height: 32),
          _buildSignalsGrid(context, report),
          const SizedBox(height: 32),
          _buildMisconceptions(context, report),
          const SizedBox(height: 32),
          _buildMentorFeedback(context, report),
          const SizedBox(height: 40),
          _buildActions(context, report, ref),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScoreOverview(BuildContext context, Map<String, dynamic> report) {
    final accuracy = (report['conceptual_accuracy'] ?? 0.0) as double;
    return SkillTwinCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('CONCEPTUAL ACCURACY',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Text(
            '${(accuracy * 100).toInt()}%',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 8),
          const Text('Your mental model of this concept is strong.', style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSignalsGrid(BuildContext context, Map<String, dynamic> report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('EVALUATION SIGNALS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
        const SizedBox(height: 16),
        _SignalRow(label: 'Completeness', value: report['completeness'] ?? 0.0),
        _SignalRow(label: 'Reasoning', value: report['reasoning'] ?? 0.0),
        _SignalRow(label: 'Confidence', value: report['confidence'] ?? 0.0),
        _SignalRow(label: 'Transfer', value: report['transfer'] ?? 0.0),
      ],
    );
  }

  Widget _buildMisconceptions(BuildContext context, Map<String, dynamic> report) {
    final list = List<String>.from(report['misconceptions'] ?? []);
    if (list.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DETECTED MISCONCEPTIONS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent, letterSpacing: 1.1)),
        const SizedBox(height: 12),
        ...list.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 12),
                    Expanded(child: Text(m, style: const TextStyle(fontSize: 13, color: Colors.black87))),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildMentorFeedback(BuildContext context, Map<String, dynamic> report) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assistant, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Text('MENTOR ADVICE',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade900, letterSpacing: 1.1)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            report['feedback'] ?? '',
            style: const TextStyle(fontSize: 15, height: 1.5, fontStyle: FontStyle.italic),
          ),
          if (report['recommendation'] != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              report['recommendation'],
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, Map<String, dynamic> report, WidgetRef ref) {
    final fixActionId = report['fix_action_id'];

    return Column(
      children: [
        if (fixActionId != null)
          ElevatedButton(
            onPressed: () {
              ref.read(teachModeProvider.notifier).reset();
              context.push('/session/$fixActionId');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('FIX THIS WEAKNESS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            ref.read(teachModeProvider.notifier).reset();
            context.go('/');
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('CONTINUE JOURNEY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        ),
      ],
    );
  }
}

class _SignalRow extends StatelessWidget {
  final String label;
  final double value;
  const _SignalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              Text('${(value * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(Colors.orange.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }
}
