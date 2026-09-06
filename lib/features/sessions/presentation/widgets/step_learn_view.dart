import 'package:flutter/material.dart';
import '../../../../core/models/session_step.dart';
import '../../../../core/widgets/skilltwin_card.dart';

class StepLearnView extends StatelessWidget {
  final SessionStep step;

  const StepLearnView({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (step.content['text'] != null)
          Text(
            step.content['text'],
            style: const TextStyle(fontSize: 17, height: 1.6, color: Colors.black87),
          ),
        const SizedBox(height: 24),
        if (step.content['image_url'] != null)
          SkillTwinCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 220,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
              ),
            ),
          ),
        if (step.content['key_points'] != null) ...[
          const SizedBox(height: 32),
          const Text(
            'KEY TAKEAWAYS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          ...(step.content['key_points'] as List).map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      child: const Icon(Icons.check_circle, size: 18, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        point.toString(),
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}
