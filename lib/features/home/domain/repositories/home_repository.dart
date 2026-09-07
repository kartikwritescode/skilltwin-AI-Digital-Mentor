import '../../../../core/models/goal.dart';
import '../../../../core/models/mentor_message.dart';
import '../../../../core/models/home_dashboard.dart';

abstract class HomeRepository {
  Future<HomeDashboardData> getHomeDashboard();
  Future<Goal?> getActiveGoal();
  Future<List<MentorMessage>> getRecentMentorMessages();
}
