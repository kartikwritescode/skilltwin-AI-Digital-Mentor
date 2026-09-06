import '../../../../core/networking/api_client.dart';
import '../../../../core/models/learning_session.dart';
import '../../../../core/models/session_result.dart';
import '../../domain/repositories/sessions_repository.dart';
import 'mock_sessions_repository.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  final ApiClient _apiClient;
  final MockSessionsRepository _fallback = MockSessionsRepository();

  SessionsRepositoryImpl(this._apiClient);

  @override
  Future<LearningSession> getSession(String sessionId) async {
    try {
      final response = await _apiClient.get('/sessions/$sessionId');
      return LearningSession.fromJson(response.data);
    } catch (_) {
      return _fallback.getSession(sessionId);
    }
  }

  @override
  Future<LearningSession> createSession(String conceptId, SessionType type) async {
    try {
      final response = await _apiClient.post('/sessions', data: {
        'concept_id': conceptId,
        'type': type.name,
        'session_type': type.name,
      });
      return LearningSession.fromJson(response.data);
    } catch (_) {
      return _fallback.createSession(conceptId, type);
    }
  }

  @override
  Future<SessionResult> completeSession(String sessionId, Map<String, dynamic> evidence) async {
    try {
      final stepResponses = evidence.entries.map((e) => {
        'step_id': e.key,
        'response': e.value?.toString() ?? '',
      }).toList();

      final userSubmissionSummary = evidence.entries
          .where((e) => e.value != null && e.value.toString().trim().isNotEmpty)
          .map((e) => 'Step ${e.key}: ${e.value}')
          .join('\n');

      final timeSpent = evidence['time_spent_seconds'] is int
          ? evidence['time_spent_seconds'] as int
          : 300;
      final confidence = evidence['self_reported_confidence'] is num
          ? (evidence['self_reported_confidence'] as num).toDouble()
          : 75.0;

      final payload = {
        'user_submission': userSubmissionSummary,
        'step_responses': stepResponses,
        'time_spent_seconds': timeSpent,
        'self_reported_confidence': confidence,
        ...evidence,
      };

      final response = await _apiClient.post('/sessions/$sessionId/complete', data: payload);
      return SessionResult.fromJson(response.data);
    } catch (_) {
      return _fallback.completeSession(sessionId, evidence);
    }
  }

  @override
  Future<void> updateStepProgress(String sessionId, String stepId, bool completed) async {
    try {
      await _apiClient.post('/sessions/$sessionId/steps/$stepId', data: {
        'completed': completed,
      });
    } catch (_) {
      await _fallback.updateStepProgress(sessionId, stepId, completed);
    }
  }
}
