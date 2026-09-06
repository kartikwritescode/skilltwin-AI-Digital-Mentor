import '../../../../core/models/goal.dart';

abstract class GoalRepository {
  Future<Goal> createGoal(Goal goal);
  Future<Goal?> getActiveGoal();
  Future<List<Goal>> getGoalHistory();
}
