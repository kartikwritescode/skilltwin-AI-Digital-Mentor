import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../../data/repositories/sessions_repository_provider.dart';
import '../../../../core/models/learning_session.dart';

final sessionProvider = FutureProvider.family<LearningSession, String>((ref, sessionId) async {
  final repository = ref.watch(sessionsRepositoryProvider);
  return repository.getSession(sessionId);
});

final sessionControllerProvider = Provider<SessionController>((ref) {
  final repository = ref.watch(sessionsRepositoryProvider);
  return SessionController(repository);
});

class SessionController {
  final SessionsRepository _repository;
  SessionController(this._repository);

  Future<String> startNewSession(String conceptId, SessionType type) async {
    final session = await _repository.createSession(conceptId, type);
    return session.id;
  }
}
