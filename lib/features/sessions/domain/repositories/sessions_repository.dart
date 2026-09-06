import '../../../../core/models/learning_session.dart';
import '../../../../core/models/session_result.dart';

abstract class SessionsRepository {
  Future<LearningSession> getSession(String sessionId);
  Future<LearningSession> createSession(String conceptId, SessionType type);
  Future<SessionResult> completeSession(String sessionId, Map<String, dynamic> evidence);
  Future<void> updateStepProgress(String sessionId, String stepId, bool completed);
}
