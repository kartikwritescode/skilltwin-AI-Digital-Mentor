import '../../../../core/networking/api_client.dart';
import '../../../../core/models/learning_path.dart';
import '../../../../core/models/topic_detail.dart';

abstract class LearningPathRepository {
  Future<LearningPath?> getActiveLearningPath();
  Future<LearningPath> getLearningPathById(String pathId);
  Future<Map<String, dynamic>> generateLearningPath({
    required String learningGoal,
    required String targetLevel,
    String? customTarget,
    int dailyMinutes = 30,
    List<String> currentKnowledge = const [],
    String? learningPreferences,
  });
  Future<TopicDetailData> getTopicDetail(String topicId);
  Future<TopicStatusUpdateResponse> startTopic(String topicId);
  Future<TopicStatusUpdateResponse> completeTopic(String topicId);
  Future<TopicStatusUpdateResponse> markTopicNeedsRevision(String topicId);
  Future<TopicExplanationData> getTopicExplanation(String topicId);
  Future<List<TopicQuestionItem>> getTopicQuestions(String topicId);
  Future<QuestionSubmissionResponse> submitAnswers(
    String topicId,
    List<AnswerSubmissionItem> answers,
  );
  Future<ContextualAskResponse> askTopicQuestion(String topicId, String query);
}

class LearningPathRepositoryImpl implements LearningPathRepository {
  final ApiClient _apiClient;

  LearningPathRepositoryImpl(this._apiClient);

  @override
  Future<LearningPath?> getActiveLearningPath() async {
    final response = await _apiClient.get('/learning-paths/active');
    if (response.data == null) return null;
    if (response.data is Map<String, dynamic>) {
      return LearningPath.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<LearningPath> getLearningPathById(String pathId) async {
    final response = await _apiClient.get('/learning-paths/$pathId');
    return LearningPath.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> generateLearningPath({
    required String learningGoal,
    required String targetLevel,
    String? customTarget,
    int dailyMinutes = 30,
    List<String> currentKnowledge = const [],
    String? learningPreferences,
  }) async {
    final response = await _apiClient.post(
      '/learning-paths/generate',
      data: {
        'learning_goal': learningGoal,
        'target_level': targetLevel,
        if (customTarget != null && customTarget.isNotEmpty)
          'custom_target': customTarget,
        'daily_minutes': dailyMinutes,
        'current_knowledge': currentKnowledge,
        if (learningPreferences != null && learningPreferences.isNotEmpty)
          'learning_preferences': learningPreferences,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  @override
  Future<TopicDetailData> getTopicDetail(String topicId) async {
    final response = await _apiClient.get('/topics/$topicId');
    return TopicDetailData.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TopicStatusUpdateResponse> startTopic(String topicId) async {
    final response = await _apiClient.post('/topics/$topicId/start');
    return TopicStatusUpdateResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<TopicStatusUpdateResponse> completeTopic(String topicId) async {
    final response = await _apiClient.post('/topics/$topicId/complete');
    return TopicStatusUpdateResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<TopicStatusUpdateResponse> markTopicNeedsRevision(
      String topicId) async {
    final response = await _apiClient.post('/topics/$topicId/revision');
    return TopicStatusUpdateResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<TopicExplanationData> getTopicExplanation(String topicId) async {
    final response = await _apiClient.post('/topics/$topicId/explain');
    return TopicExplanationData.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<List<TopicQuestionItem>> getTopicQuestions(String topicId) async {
    final response = await _apiClient.post('/topics/$topicId/questions');
    final rawQuestions = (response.data['questions'] as List<dynamic>?) ?? [];
    return rawQuestions
        .map((q) => TopicQuestionItem.fromJson(q as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<QuestionSubmissionResponse> submitAnswers(
    String topicId,
    List<AnswerSubmissionItem> answers,
  ) async {
    final response = await _apiClient.post(
      '/topics/$topicId/submit',
      data: {
        'answers': answers.map((a) => a.toJson()).toList(),
      },
    );
    return QuestionSubmissionResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<ContextualAskResponse> askTopicQuestion(
      String topicId, String query) async {
    final response = await _apiClient.post(
      '/topics/$topicId/ask',
      data: {
        'query': query,
        'topic_id': topicId,
      },
    );
    return ContextualAskResponse.fromJson(
        response.data as Map<String, dynamic>);
  }
}
