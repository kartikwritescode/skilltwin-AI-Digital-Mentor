import '../../../../core/networking/api_client.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/models/goal.dart';
import '../../../../core/models/mentor_message.dart';
import '../../../../core/models/home_dashboard.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiClient _apiClient;

  HomeRepositoryImpl(this._apiClient);

  @override
  Future<HomeDashboardData> getHomeDashboard() async {
    try {
      final response = await _apiClient.get('/home/dashboard');
      if (response.data is Map<String, dynamic>) {
        return HomeDashboardData.fromJson(response.data as Map<String, dynamic>);
      }
      return const HomeDashboardData();
    } catch (e) {
      if (e is QuotaFailure) {
        rethrow;
      }
      try {
        final goal = await getActiveGoal();
        if (goal != null) {
          return HomeDashboardData(
            goalTitle: goal.title,
            targetLevel: goal.targetLevel ?? 'Intermediate',
            nextActionTitle: 'Continue your learning journey',
            nextActionReason: 'Resume learning towards ${goal.title}',
            nextActionType: 'topic',
          );
        }
      } catch (_) {}
      rethrow;
    }
  }

  @override
  Future<Goal?> getActiveGoal() async {
    try {
      final response = await _apiClient.get('/goals');
      if (response.data is List && (response.data as List).isNotEmpty) {
        return Goal.fromJson((response.data as List).first as Map<String, dynamic>);
      } else if (response.data is Map<String, dynamic>) {
        return Goal.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<MentorMessage>> getRecentMentorMessages() async {
    try {
      final response = await _apiClient.get('/mentor/today');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => MentorMessage.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map<String, dynamic>) {
        return [MentorMessage.fromJson(response.data as Map<String, dynamic>)];
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
