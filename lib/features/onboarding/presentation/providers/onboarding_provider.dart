import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/goal.dart';
import '../../../home/domain/repositories/goal_repository.dart';
import '../../../home/data/repositories/goal_repository_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/storage/storage_provider.dart';

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

  String get videoPreference {
    for (final r in goal.preferredResources) {
      if (r.startsWith('Videos: ')) {
        return r.replaceFirst('Videos: ', '');
      }
    }
    return 'Only when helpful';
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final goalRepository = ref.watch(goalRepositoryProvider);
  SharedPreferences? prefs;
  try {
    prefs = ref.watch(sharedPrefsProvider);
  } catch (_) {
    // Fallback for tests where sharedPrefsProvider is not overridden
  }
  return OnboardingNotifier(goalRepository, ref, prefs);
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final GoalRepository _goalRepository;
  final Ref _ref;
  final SharedPreferences? _prefs;

  static const String _kDraftStep = 'skilltwin_onboarding_draft_step';
  static const String _kDraftTitle = 'skilltwin_onboarding_draft_title';
  static const String _kDraftCurrentLevel = 'skilltwin_onboarding_draft_current_level';
  static const String _kDraftDailyMinutes = 'skilltwin_onboarding_draft_daily_minutes';
  static const String _kDraftDeadline = 'skilltwin_onboarding_draft_deadline';
  static const String _kDraftPreferredResources = 'skilltwin_onboarding_draft_resources';

  OnboardingNotifier(this._goalRepository, this._ref, [this._prefs])
      : super(_restoreInitialState(_prefs));

  static OnboardingState _restoreInitialState(SharedPreferences? prefs) {
    if (prefs == null) {
      return OnboardingState(
        goal: Goal(
          id: '',
          title: '',
          currentLevel: 'Intermediate',
          dailyMinutes: 30,
          deadline: DateTime.now().add(const Duration(days: 90)),
          existingKnowledge: const [],
          preferredResources: const [],
        ),
      );
    }

    final step = prefs.getInt(_kDraftStep) ?? 0;
    final title = prefs.getString(_kDraftTitle) ?? '';
    final level = prefs.getString(_kDraftCurrentLevel) ?? 'Intermediate';
    final minutes = prefs.getInt(_kDraftDailyMinutes) ?? 30;
    final deadlineStr = prefs.getString(_kDraftDeadline);
    final deadline = deadlineStr != null
        ? DateTime.tryParse(deadlineStr) ?? DateTime.now().add(const Duration(days: 90))
        : DateTime.now().add(const Duration(days: 90));
    final resources = prefs.getStringList(_kDraftPreferredResources) ?? const [];

    return OnboardingState(
      currentStep: step,
      goal: Goal(
        id: '',
        title: title,
        currentLevel: level,
        dailyMinutes: minutes,
        dailyTime: '$minutes mins/day',
        deadline: deadline,
        existingKnowledge: const [],
        preferredResources: resources,
      ),
    );
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
    _prefs?.setInt(_kDraftStep, step);
  }

  void nextStep() {
    setStep(state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      setStep(state.currentStep - 1);
    }
  }

  void setGoalTitle(String title) {
    state = state.copyWith(goal: state.goal.copyWith(title: title));
    _prefs?.setString(_kDraftTitle, title);
  }

  void setCurrentLevel(String level) {
    state = state.copyWith(
      goal: state.goal.copyWith(
        currentLevel: level,
        targetLevel: level,
      ),
    );
    _prefs?.setString(_kDraftCurrentLevel, level);
  }

  void setDailyMinutes(int minutes) {
    state = state.copyWith(
      goal: state.goal.copyWith(
        dailyMinutes: minutes,
        dailyTime: '$minutes mins/day',
      ),
    );
    _prefs?.setInt(_kDraftDailyMinutes, minutes);
  }

  void setDeadline(DateTime deadline) {
    state = state.copyWith(goal: state.goal.copyWith(deadline: deadline));
    _prefs?.setString(_kDraftDeadline, deadline.toIso8601String());
  }

  void setPreferredResources(List<String> resources) {
    state = state.copyWith(goal: state.goal.copyWith(preferredResources: resources));
    _prefs?.setStringList(_kDraftPreferredResources, resources);
  }

  void setVideoPreference(String preference) {
    final updated = List<String>.from(state.goal.preferredResources)
      ..removeWhere((r) => r.startsWith('Videos: ') || r.startsWith('Video preference: '));
    updated.add('Videos: $preference');
    setPreferredResources(updated);
  }

  void updateGoal(Goal goal) {
    state = state.copyWith(goal: goal);
    _prefs?.setString(_kDraftTitle, goal.title);
    if (goal.currentLevel != null) {
      _prefs?.setString(_kDraftCurrentLevel, goal.currentLevel!);
    }
    _prefs?.setInt(_kDraftDailyMinutes, goal.dailyMinutes);
    if (goal.deadline != null) {
      _prefs?.setString(_kDraftDeadline, goal.deadline!.toIso8601String());
    }
    _prefs?.setStringList(_kDraftPreferredResources, goal.preferredResources);
  }

  Future<void> clearDraft() async {
    try {
      await _prefs?.remove(_kDraftStep);
      await _prefs?.remove(_kDraftTitle);
      await _prefs?.remove(_kDraftCurrentLevel);
      await _prefs?.remove(_kDraftDailyMinutes);
      await _prefs?.remove(_kDraftDeadline);
      await _prefs?.remove(_kDraftPreferredResources);
    } catch (_) {}
  }

  Future<bool> submitGoal() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _goalRepository.createGoal(state.goal);
      _ref.read(authProvider.notifier).setOnboardingComplete();
      await clearDraft();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> startJourney(String title) async {
    setGoalTitle(title);
    return submitGoal();
  }
}
