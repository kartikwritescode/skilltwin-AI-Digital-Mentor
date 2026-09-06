import '../../../../core/models/goal.dart';
import '../../../../core/models/mentor_message.dart';

abstract class HomeRepository {
  Future<Goal> getActiveGoal();
  Future<List<MentorMessage>> getRecentMentorMessages();
}
