import '../../domain/repositories/journey_repository.dart';
import '../../../../core/models/journey_node.dart';

class MockJourneyRepository implements JourneyRepository {
  @override
  Future<List<JourneyNode>> getJourneyNodes(String goalId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      JourneyNode(
        id: '1',
        title: 'Foundations',
        subtitle: 'The basics of ML',
        phase: 'Phase 1',
        status: NodeStatus.completed,
        progress: 1.0,
        estimatedMinutes: 45,
        whyItMatters: 'Without foundations, you cannot understand advanced architectures.',
        mentorRecommendation: 'You mastered this quickly. Move to the next node.',
      ),
      JourneyNode(
        id: '2',
        title: 'Probability',
        subtitle: 'Bayesian thinking',
        phase: 'Phase 1',
        status: NodeStatus.completed,
        progress: 1.0,
        estimatedMinutes: 60,
        whyItMatters: 'ML is essentially applied probability.',
      ),
      JourneyNode(
        id: '3',
        title: 'Backpropagation',
        subtitle: 'Chain rule & gradients',
        phase: 'Phase 2',
        status: NodeStatus.needsAttention,
        progress: 0.4,
        estimatedMinutes: 90,
        whyItMatters: 'This is the engine of neural networks.',
        mentorRecommendation: 'Your retention on "Chain Rule" is dropping. I recommend a 12-minute revision before proceeding.',
        prerequisites: ['Foundations', 'Calculus Basics'],
      ),
      JourneyNode(
        id: '4',
        title: 'Neural Networks',
        subtitle: 'Architectures',
        phase: 'Phase 2',
        status: NodeStatus.current,
        progress: 0.1,
        estimatedMinutes: 120,
        whyItMatters: 'The core of modern AI.',
        mentorRecommendation: 'Start with Multi-Layer Perceptrons.',
      ),
      JourneyNode(
        id: '5',
        title: 'Computer Vision',
        subtitle: 'CNNs & Transformers',
        phase: 'Phase 3',
        status: NodeStatus.upcoming,
        progress: 0.0,
        estimatedMinutes: 180,
        whyItMatters: 'Teaching machines to see.',
      ),
      JourneyNode(
        id: '6',
        title: 'Reinforcement Learning',
        subtitle: 'Agents & Rewards',
        phase: 'Phase 4',
        status: NodeStatus.locked,
        progress: 0.0,
        estimatedMinutes: 200,
        whyItMatters: 'Building agents that learn from interaction.',
        prerequisites: ['Neural Networks', 'Probability'],
      ),
    ];
  }

  @override
  Future<void> updateNodeStatus(String nodeId, NodeStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
