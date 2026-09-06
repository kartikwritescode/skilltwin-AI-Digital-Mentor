import '../../domain/repositories/home_repository.dart';
import '../../../../core/models/goal.dart';
import '../../../../core/models/mentor_message.dart';

class MockHomeRepository implements HomeRepository {
  @override
  Future<Goal> getActiveGoal() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Goal(
      id: '1',
      title: 'Master Machine Learning',
      constraints:'Go from zero to building production ML models.' ,
      // description: 'Go from zero to building production ML models.',
      progress: 0.35,
    );
  }

  @override
  Future<List<MentorMessage>> getRecentMentorMessages() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      MentorMessage(
        id: '1',
        text: 'I would fix probability before starting model evaluation.',
        intent: MentorIntent.remediate,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ctaText: 'Start 12-minute repair session',
        actionType: MentorAction.remediate,
      ),
    ];
  }
}
