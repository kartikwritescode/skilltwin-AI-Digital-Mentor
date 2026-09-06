import '../../../../core/networking/api_client.dart';
import '../../../../core/models/goal.dart';
import '../../domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final ApiClient _apiClient;

  GoalRepositoryImpl(this._apiClient);

  @override
  Future<Goal> createGoal(Goal goal) async {
    final response = await _apiClient.post('/goals', data: goal.toJson());
    return Goal.fromJson(response.data);
  }

  @override
  Future<Goal?> getActiveGoal() async {
    try {
      final response = await _apiClient.get('/goals/active');
      if (response.data == null) return null;
      return Goal.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Goal>> getGoalHistory() async {
    final response = await _apiClient.get('/goals');
    return (response.data as List).map((e) => Goal.fromJson(e)).toList();
  }
}
