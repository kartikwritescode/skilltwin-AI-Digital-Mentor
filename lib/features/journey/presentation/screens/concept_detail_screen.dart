import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/skilltwin_card.dart';

class ConceptDetailScreen extends ConsumerWidget {
  final String conceptId;
  const ConceptDetailScreen({super.key, required this.conceptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(conceptId)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SkillTwinCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mastery', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const LinearProgressIndicator(value: 0.7),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Start Practice Session'),
          ),
        ],
      ),
    );
  }
}
