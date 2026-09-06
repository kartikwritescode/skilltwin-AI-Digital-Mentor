import '../../../../core/networking/api_client.dart';
import '../../../../core/models/goal.dart';
import '../../../../core/models/mentor_message.dart';
import '../../domain/repositories/home_repository.dart';
import 'mock_home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiClient _apiClient;
  final MockHomeRepository _fallback = MockHomeRepository();

  HomeRepositoryImpl(this._apiClient);

  @override
  Future<Goal> getActiveGoal() async {
    try {
      final response = await _apiClient.get('/goals');
      if (response.data is List && (response.data as List).isNotEmpty) {
        return Goal.fromJson((response.data as List).first);
      } else if (response.data is Map<String, dynamic>) {
        return Goal.fromJson(response.data);
      }
      return _fallback.getActiveGoal();
    } catch (_) {
      return _fallback.getActiveGoal();
    }
  }

  @override
  Future<List<MentorMessage>> getRecentMentorMessages() async {
    try {
      final response = await _apiClient.get('/mentor/today');
      if (response.data is List) {
        return (response.data as List).map((e) => MentorMessage.fromJson(e)).toList();
      } else if (response.data is Map<String, dynamic>) {
        return [MentorMessage.fromJson(response.data)];
      }
      return _fallback.getRecentMentorMessages();
    } catch (_) {
      return _fallback.getRecentMentorMessages();
    }
  }
}
