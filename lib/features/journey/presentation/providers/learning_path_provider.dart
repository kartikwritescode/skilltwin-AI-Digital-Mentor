import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/learning_path_repository.dart';
import '../../data/repositories/learning_path_repository_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../../core/models/learning_path.dart';
import '../../../../core/models/topic_detail.dart';

// -----------------------------------------------------------------------------
// Active Learning Path Notifier (Optimistic & Reactive)
// -----------------------------------------------------------------------------

class ActiveLearningPathNotifier
    extends StateNotifier<AsyncValue<LearningPath?>> {
  final LearningPathRepository _repo;

  ActiveLearningPathNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final path = await _repo.getActiveLearningPath();
      state = AsyncValue.data(path);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void refresh() {
    load();
  }

  /// Optimistically updates a topic's status and progress in memory instantly (0ms)
  void updateTopicStatusOptimistically(String topicId, TopicStatus newStatus) {
    state.whenData((path) {
      if (path == null) return;
      final updatedSections = path.sections.map((section) {
        final updatedTopics = section.topics.map((t) {
          if (t.id == topicId) {
            return t.copyWith(
              status: newStatus,
              masteryScore: newStatus == TopicStatus.completed
                  ? 100.0
                  : (newStatus == TopicStatus.learning ? 25.0 : t.masteryScore),
              completedAt: newStatus == TopicStatus.completed
                  ? DateTime.now()
                  : t.completedAt,
            );
          }
          return t;
        }).toList();
        return section.copyWith(topics: updatedTopics);
      }).toList();

      final total =
          updatedSections.fold(0, (sum, s) => sum + s.topics.length);
      final completed = updatedSections.fold(
        0,
        (sum, s) =>
            sum +
            s.topics.where((t) => t.status == TopicStatus.completed).length,
      );
      final newProgress = total > 0 ? completed / total : 0.0;

      state = AsyncValue.data(
        path.copyWith(
          sections: updatedSections,
          progress: newProgress,
        ),
      );
    });
  }
}

final activeLearningPathProvider = StateNotifierProvider<
    ActiveLearningPathNotifier, AsyncValue<LearningPath?>>((ref) {
  final repo = ref.watch(learningPathRepositoryProvider);
  return ActiveLearningPathNotifier(repo);
});

final learningPathProvider = activeLearningPathProvider;

// -----------------------------------------------------------------------------
// Topic Detail Notifier (Optimistic & Reactive)
// -----------------------------------------------------------------------------

class TopicDetailNotifier extends StateNotifier<AsyncValue<TopicDetailData>> {
  final LearningPathRepository _repo;
  final String _topicId;

  TopicDetailNotifier(this._repo, this._topicId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final data = await _repo.getTopicDetail(_topicId);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateStatusOptimistically(String newStatus, double newMastery) {
    state.whenData((data) {
      state = AsyncValue.data(
        data.copyWith(
          status: newStatus,
          masteryScore: newMastery,
          completedAt:
              newStatus == 'completed' ? DateTime.now() : data.completedAt,
        ),
      );
    });
  }
}

final topicDetailProvider = StateNotifierProvider.family<
    TopicDetailNotifier, AsyncValue<TopicDetailData>, String>((ref, topicId) {
  final repo = ref.watch(learningPathRepositoryProvider);
  return TopicDetailNotifier(repo, topicId);
});

final topicExplanationProvider =
    FutureProvider.family<TopicExplanationData, String>((ref, topicId) async {
  final repo = ref.watch(learningPathRepositoryProvider);
  return repo.getTopicExplanation(topicId);
});

final topicQuestionsProvider =
    FutureProvider.family<List<TopicQuestionItem>, String>(
        (ref, topicId) async {
  final repo = ref.watch(learningPathRepositoryProvider);
  return repo.getTopicQuestions(topicId);
});

// -----------------------------------------------------------------------------
// Topic Action Notifier
// -----------------------------------------------------------------------------

class TopicActionNotifier extends StateNotifier<AsyncValue<void>> {
  final LearningPathRepository _repo;
  final Ref _ref;

  TopicActionNotifier(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  Future<TopicStatusUpdateResponse?> startTopic(String topicId) async {
    // 1. INSTANT OPTIMISTIC UPDATE (0ms)
    _ref
        .read(activeLearningPathProvider.notifier)
        .updateTopicStatusOptimistically(topicId, TopicStatus.learning);
    _ref
        .read(topicDetailProvider(topicId).notifier)
        .updateStatusOptimistically('learning', 0.15);

    state = const AsyncValue.loading();
    try {
      final res = await _repo.startTopic(topicId);
      state = const AsyncValue.data(null);
      // Keep Home screen in lockstep
      _ref.invalidate(homeDashboardProvider);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _ref.read(topicDetailProvider(topicId).notifier).load();
      _ref.read(activeLearningPathProvider.notifier).load();
      return null;
    }
  }

  Future<TopicStatusUpdateResponse?> completeTopic(String topicId) async {
    // 1. INSTANT OPTIMISTIC UPDATE (0ms)
    _ref
        .read(activeLearningPathProvider.notifier)
        .updateTopicStatusOptimistically(topicId, TopicStatus.completed);
    _ref
        .read(topicDetailProvider(topicId).notifier)
        .updateStatusOptimistically('completed', 1.0);

    state = const AsyncValue.loading();
    try {
      final res = await _repo.completeTopic(topicId);
      state = const AsyncValue.data(null);
      // Keep Home screen in lockstep
      _ref.invalidate(homeDashboardProvider);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _ref.read(topicDetailProvider(topicId).notifier).load();
      _ref.read(activeLearningPathProvider.notifier).load();
      return null;
    }
  }

  Future<TopicStatusUpdateResponse?> markNeedsRevision(String topicId) async {
    // 1. INSTANT OPTIMISTIC UPDATE (0ms)
    _ref
        .read(activeLearningPathProvider.notifier)
        .updateTopicStatusOptimistically(topicId, TopicStatus.needsRevision);
    _ref
        .read(topicDetailProvider(topicId).notifier)
        .updateStatusOptimistically('needs_revision', 0.50);

    state = const AsyncValue.loading();
    try {
      final res = await _repo.markTopicNeedsRevision(topicId);
      state = const AsyncValue.data(null);
      _ref.invalidate(homeDashboardProvider);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _ref.read(topicDetailProvider(topicId).notifier).load();
      _ref.read(activeLearningPathProvider.notifier).load();
      return null;
    }
  }

  Future<QuestionSubmissionResponse?> submitAnswers(
    String topicId,
    List<AnswerSubmissionItem> answers,
  ) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repo.submitAnswers(topicId, answers);
      state = const AsyncValue.data(null);
      _ref.read(topicDetailProvider(topicId).notifier).load();
      _ref.read(activeLearningPathProvider.notifier).load();
      _ref.invalidate(homeDashboardProvider);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<ContextualAskResponse?> askQuestion(
    String topicId,
    String query,
  ) async {
    try {
      return await _repo.askTopicQuestion(topicId, query);
    } catch (e) {
      rethrow;
    }
  }
}

final topicActionProvider =
    StateNotifierProvider<TopicActionNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(learningPathRepositoryProvider);
  return TopicActionNotifier(repo, ref);
});
