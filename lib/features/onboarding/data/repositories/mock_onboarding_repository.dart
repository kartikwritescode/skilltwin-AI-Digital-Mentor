import '../../domain/repositories/onboarding_repository.dart';
import '../../../../core/models/goal.dart';

class MockOnboardingRepository implements OnboardingRepository {
  @override
  Future<Goal> submitOnboarding(Goal goal) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return goal;
  }

  Future<void> saveInitialGoal(Goal goal) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> completeOnboarding() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
