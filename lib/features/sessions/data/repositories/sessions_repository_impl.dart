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
      final response = await _apiClient.post('/sessions/$sessionId/complete', data: evidence);
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
