import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/journey/presentation/providers/learning_path_provider.dart';
import '../models/learning_path.dart';

/// Service to prefetch topic details and explanations in the background
/// This ensures instant navigation to topic screens without loading delays
class TopicPrefetchService {
  final Ref _ref;

  TopicPrefetchService(this._ref);

  /// Prefetch the first 3 upcoming topics in the learning path
  /// Called on app initialization to prepare data before user navigates
  Future<void> prefetchUpcomingTopics() async {
    try {
      final pathAsync = _ref.read(activeLearningPathProvider);

      await pathAsync.when(
        data: (path) async {
          if (path == null) return;

          // Get all not-started and in-progress topics
          final upcomingTopics = <String>[];

          for (final section in path.sections) {
            for (final topic in section.topics) {
              if (topic.status == TopicStatus.notStarted ||
                  topic.status == TopicStatus.learning) {
                upcomingTopics.add(topic.id);
                if (upcomingTopics.length >= 3) break;
              }
            }
            if (upcomingTopics.length >= 3) break;
          }

          // Prefetch topic details and explanations in parallel
          await Future.wait(
            upcomingTopics.map((topicId) async {
              // This triggers the provider to load and cache the data
              _ref.read(topicDetailProvider(topicId));
              _ref.read(topicExplanationProvider(topicId));
            }),
          );
        },
        loading: () async {},
        error: (_, __) async {},
      );
    } catch (e) {
      // Silently fail - prefetching is best-effort optimization
      // Don't block app startup if prefetch fails
    }
  }

  /// Prefetch a specific topic by ID
  /// Useful when user is likely to navigate to this topic next
  void prefetchTopic(String topicId) {
    try {
      _ref.read(topicDetailProvider(topicId));
      _ref.read(topicExplanationProvider(topicId));
    } catch (e) {
      // Silently fail - prefetching is optional optimization
    }
  }

  /// Prefetch the next topic in sequence
  /// Called when user completes current topic or navigates through journey
  void prefetchNextTopic(String currentTopicId) {
    try {
      final pathAsync = _ref.read(activeLearningPathProvider);

      pathAsync.whenData((path) {
        if (path == null) return;

        // Find the next topic after currentTopicId
        bool foundCurrent = false;

        for (final section in path.sections) {
          for (final topic in section.topics) {
            if (foundCurrent && topic.status == TopicStatus.notStarted) {
              prefetchTopic(topic.id);
              return;
            }
            if (topic.id == currentTopicId) {
              foundCurrent = true;
            }
          }
        }
      });
    } catch (e) {
      // Silently fail
    }
  }
}

/// Provider for the prefetch service
final topicPrefetchServiceProvider = Provider<TopicPrefetchService>((ref) {
  return TopicPrefetchService(ref);
});
