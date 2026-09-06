import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/mentor_recommendation.dart';

final currentMentorRecommendationProvider = FutureProvider<MentorRecommendation>((ref) async {
  // Simulates or retrieves the active mentor recommendation from the engine
  await Future.delayed(const Duration(milliseconds: 300));
  return MentorRecommendation(
    id: 'rec_current_1',
    userId: 'user_1',
    goalId: 'goal_ai_engineer',
    conceptId: 'concept_partial_derivatives',
    journeyNodeId: 'node_foundations',
    type: RecommendationType.practice,
    title: 'Solidify Partial Derivatives & Gradients',
    description: 'Your twin shows slight degradation in multidimensional chain rule invariants. A 15-minute active retrieval session will reinforce weights before backpropagation.',
    priority: 1,
    estimatedMinutes: 15,
    accepted: false,
    completed: false,
    metadata: {
      'source': 'twin_decay_engine',
      'target_node': 'Foundations',
      'invariants': ['Chain Rule', 'Gradient Vector'],
    },
    createdAt: DateTime.now(),
  );
});

// Alias for backwards compatibility with HomeScreen
final nextBestActionProvider = currentMentorRecommendationProvider;

final journeyMentorGuidanceProvider = Provider<String>((ref) {
  return 'Master the foundational invariants in Calculus Primitives first. Rushing to Backpropagation before mastering Partial Derivatives creates compounding cognitive debt.';
});

final twinMentorGuidanceProvider = Provider<String>((ref) {
  return 'Your mental model of Neurons and Weights is solid (85%). However, Partial Derivatives has crossed into the uncertainty threshold. Focus today\'s effort here.';
});

final libraryMentorGuidanceProvider = Provider<String>((ref) {
  return 'I synthesized "Neural Networks: A Visual Introduction" specifically focusing on your bias vs weight confusion. Review section 2 before your session.';
});
