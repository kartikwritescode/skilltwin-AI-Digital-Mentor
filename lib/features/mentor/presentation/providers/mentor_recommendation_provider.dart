import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/mentor_recommendation.dart';
import '../../../../core/models/learning_path.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../journey/presentation/providers/learning_path_provider.dart';

final currentMentorRecommendationProvider =
    FutureProvider<MentorRecommendation>((ref) async {
  final pathAsync = ref.watch(activeLearningPathProvider);
  final goalAsync = ref.watch(activeGoalProvider);

  final path = pathAsync.asData?.value;
  final goal = goalAsync.asData?.value;

  LearningTopic? activeTopic;
  String currentSectionTitle = 'Foundations';

  if (path != null && path.sections.isNotEmpty) {
    for (final sec in path.sections) {
      for (final top in sec.topics) {
        if (top.status == TopicStatus.learning ||
            top.status == TopicStatus.needsRevision) {
          activeTopic = top;
          currentSectionTitle = sec.title;
          break;
        }
      }
      if (activeTopic != null) break;
    }

    if (activeTopic == null) {
      for (final sec in path.sections) {
        for (final top in sec.topics) {
          if (top.status != TopicStatus.completed) {
            activeTopic = top;
            currentSectionTitle = sec.title;
            break;
          }
        }
        if (activeTopic != null) break;
      }
    }
  }

  final topicTitle = activeTopic?.title ?? 'Active Milestone';
  final goalTitle = goal?.title ?? 'Your Learning Goal';
  final minutes = goal?.dailyMinutes ?? 25;

  return MentorRecommendation(
    id: 'rec_dynamic_${activeTopic?.id ?? "1"}',
    userId: goal?.userId ?? 'user_active',
    goalId: goal?.id ?? 'goal_active',
    conceptId: activeTopic?.id ?? 'concept_active',
    journeyNodeId: activeTopic?.id ?? 'node_active',
    type: RecommendationType.practice,
    title: 'Master $topicTitle',
    description:
        'Continue deliberate practice on $topicTitle in $currentSectionTitle for $goalTitle. Maintaining daily momentum prevents cognitive decay.',
    priority: 1,
    estimatedMinutes: minutes,
    accepted: false,
    completed: false,
    metadata: {
      'source': 'twin_dynamic_engine',
      'target_node': currentSectionTitle,
      'invariants': activeTopic?.keyConcepts ?? ['Core Invariants'],
    },
    createdAt: DateTime.now(),
  );
});

// Alias for backwards compatibility with HomeScreen
final nextBestActionProvider = currentMentorRecommendationProvider;

final journeyMentorGuidanceProvider = Provider<String>((ref) {
  final path = ref.watch(activeLearningPathProvider).asData?.value;
  final goal = ref.watch(activeGoalProvider).asData?.value;

  if (path != null && path.sections.isNotEmpty) {
    LearningTopic? activeTopic;
    for (final sec in path.sections) {
      for (final top in sec.topics) {
        if (top.status == TopicStatus.learning ||
            top.status == TopicStatus.needsRevision) {
          activeTopic = top;
          break;
        }
      }
      if (activeTopic != null) break;
    }
    if (activeTopic != null) {
      return 'Prioritize "${activeTopic.title}" today. Deep deliberate practice on core invariants guarantees retention without knowledge debt.';
    }
  }

  final goalTitle = goal?.title ?? 'your current curriculum';
  return 'Follow your milestone order in $goalTitle. Skipping foundational topics leads to compounding cognitive debt downstream.';
});

final twinMentorGuidanceProvider = Provider<String>((ref) {
  final path = ref.watch(activeLearningPathProvider).asData?.value;
  if (path != null && path.sections.isNotEmpty) {
    LearningTopic? activeTopic;
    for (final sec in path.sections) {
      for (final top in sec.topics) {
        if (top.status == TopicStatus.learning ||
            top.status == TopicStatus.needsRevision) {
          activeTopic = top;
          break;
        }
      }
      if (activeTopic != null) break;
    }
    if (activeTopic != null) {
      final mastery = activeTopic.masteryScore.toInt();
      return 'Your Twin model shows $mastery% mastery on "${activeTopic.title}". Complete today\'s session to solidify this concept.';
    }
  }
  return 'Your Digital Twin is actively tracking your neural retention and concept decay. Keep up your daily streak!';
});

final libraryMentorGuidanceProvider = Provider<String>((ref) {
  final path = ref.watch(activeLearningPathProvider).asData?.value;
  if (path != null && path.sections.isNotEmpty) {
    final firstSection = path.sections.first;
    if (firstSection.topics.isNotEmpty) {
      return 'Recommended reading synthesized for "${firstSection.topics.first.title}". Review key mental models before practice.';
    }
  }
  return 'Explore synthesized study guides and conceptual breakdowns aligned with your active roadmap.';
});
