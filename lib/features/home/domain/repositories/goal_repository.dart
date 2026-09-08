import '../../../../core/models/goal.dart';

abstract class GoalRepository {
  Future<Goal> createGoal(Goal goal);
  Future<Goal?> getActiveGoal();
  Future<List<Goal>> getGoalHistory();
  Future<void> updateGoal(String goalId, Map<String, dynamic> updates);
  Future<void> deleteGoal(String goalId);
  Future<void> setActiveGoal(String goalId);
}
