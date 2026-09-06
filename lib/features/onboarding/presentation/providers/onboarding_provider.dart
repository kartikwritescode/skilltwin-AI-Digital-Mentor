import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/goal.dart';
import '../../../home/domain/repositories/goal_repository.dart';
import '../../../home/data/repositories/goal_repository_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class OnboardingState {
  final int currentStep;
  final Goal goal;
  final bool isLoading;
  final String? error;

  OnboardingState({
    this.currentStep = 0,
    required this.goal,
    this.isLoading = false,
    this.error,
  });

  OnboardingState copyWith({
    int? currentStep,
    Goal? goal,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      goal: goal ?? this.goal,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final goalRepository = ref.watch(goalRepositoryProvider);
  return OnboardingNotifier(goalRepository, ref);
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final GoalRepository _goalRepository;
  final Ref _ref;

  OnboardingNotifier(this._goalRepository, this._ref)
      : super(OnboardingState(
          goal: Goal(
            id: '',
            title: '',
            description: '',
            existingKnowledge: [],
          ),
        ));

  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updateGoal(Goal goal) {
    state = state.copyWith(goal: goal);
  }

  Future<void> submitGoal() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _goalRepository.createGoal(state.goal);
      _ref.read(authProvider.notifier).setOnboardingComplete();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> startJourney(String title) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      goal: state.goal.copyWith(title: title),
    );
    try {
      await _goalRepository.createGoal(state.goal);
      _ref.read(authProvider.notifier).setOnboardingComplete();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
