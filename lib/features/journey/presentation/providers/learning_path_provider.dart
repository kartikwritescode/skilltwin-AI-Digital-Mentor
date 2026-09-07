import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/learning_path_repository.dart';
import '../../data/repositories/learning_path_repository_provider.dart';
import '../../../../core/models/learning_path.dart';
import '../../../../core/models/topic_detail.dart';

final activeLearningPathProvider = FutureProvider<LearningPath?>((ref) async {
  final repo = ref.watch(learningPathRepositoryProvider);
  return repo.getActiveLearningPath();
});

final topicDetailProvider =
    FutureProvider.family<TopicDetailData, String>((ref, topicId) async {
  final repo = ref.watch(learningPathRepositoryProvider);
  return repo.getTopicDetail(topicId);
});

final topicExplanationProvider =
    FutureProvider.family<TopicExplanationData, String>((ref, topicId) async {
  final repo = ref.watch(learningPathRepositoryProvider);
  return repo.getTopicExplanation(topicId);
});

final topicQuestionsProvider =
    FutureProvider.family<List<TopicQuestionItem>, String>((ref, topicId) async {
  final repo = ref.watch(learningPathRepositoryProvider);
  return repo.getTopicQuestions(topicId);
});

class TopicActionNotifier extends StateNotifier<AsyncValue<void>> {
  final LearningPathRepository _repo;
  final Ref _ref;

  TopicActionNotifier(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  Future<TopicStatusUpdateResponse?> startTopic(String topicId) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repo.startTopic(topicId);
      state = const AsyncValue.data(null);
      _ref.invalidate(topicDetailProvider(topicId));
      _ref.invalidate(activeLearningPathProvider);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<TopicStatusUpdateResponse?> completeTopic(String topicId) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repo.completeTopic(topicId);
      state = const AsyncValue.data(null);
      _ref.invalidate(topicDetailProvider(topicId));
      _ref.invalidate(activeLearningPathProvider);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<TopicStatusUpdateResponse?> markNeedsRevision(String topicId) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repo.markTopicNeedsRevision(topicId);
      state = const AsyncValue.data(null);
      _ref.invalidate(topicDetailProvider(topicId));
      _ref.invalidate(activeLearningPathProvider);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
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
      _ref.invalidate(topicDetailProvider(topicId));
      _ref.invalidate(activeLearningPathProvider);
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
