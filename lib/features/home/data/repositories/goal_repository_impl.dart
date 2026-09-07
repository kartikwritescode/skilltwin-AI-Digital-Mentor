import '../../../../core/networking/api_client.dart';
import '../../../../core/models/goal.dart';
import '../../domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final ApiClient _apiClient;

  GoalRepositoryImpl(this._apiClient);

  @override
  Future<Goal> createGoal(Goal goal) async {
    final response = await _apiClient.post(
      '/learning-paths/generate',
      data: {
        'learning_goal': goal.title,
        'target_level': goal.targetLevel ?? 'Intermediate',
        if (goal.customTarget != null && goal.customTarget!.isNotEmpty)
          'custom_target': goal.customTarget,
        'daily_minutes': goal.dailyMinutes,
        'current_knowledge': goal.existingKnowledge,
        'learning_preferences': 'Hands-on and project-focused',
      },
    );
    return Goal.fromJson(response.data as Map<String, dynamic>);
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
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Goal>> getGoalHistory() async {
    try {
      final response = await _apiClient.get('/goals');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => Goal.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
