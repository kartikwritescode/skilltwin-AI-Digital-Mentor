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
        if (goal.deadline != null)
          'deadline': goal.deadline!.toIso8601String().split('T').first,
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
      if (response.data is List) {
        final list = (response.data as List)
            .map((e) => Goal.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isEmpty) return null;
        return list.firstWhere(
          (g) => g.status == GoalStatus.active,
          orElse: () => list.first,
        );
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

  @override
  Future<void> updateGoal(String goalId, Map<String, dynamic> updates) async {
    await _apiClient.patch('/goals/$goalId', data: updates);
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await _apiClient.delete('/goals/$goalId');
  }

  @override
  Future<void> setActiveGoal(String goalId) async {
    await _apiClient.patch('/goals/$goalId', data: {'status': 'ACTIVE'});
  }
}
