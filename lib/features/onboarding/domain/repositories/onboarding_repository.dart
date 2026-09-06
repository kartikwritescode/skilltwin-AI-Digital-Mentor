import '../../../../core/models/goal.dart';

abstract class OnboardingRepository {
  Future<Goal> submitOnboarding(Goal goal);
}
