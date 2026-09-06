import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/learning_session.dart';
import '../../../../core/models/session_step.dart';
import '../../../../core/models/session_result.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../../data/repositories/sessions_repository_provider.dart';

class SessionState {
  final LearningSession? session;
  final int currentStepIndex;
  final Map<String, dynamic> evidence;
  final bool isLoading;
  final bool isSubmitting;
  final SessionResult? result;
  final String? error;

  SessionState({
    this.session,
    this.currentStepIndex = -1, // -1 means Intro
    this.evidence = const {},
    this.isLoading = false,
    this.isSubmitting = false,
    this.result,
    this.error,
  });

  SessionStep? get currentStep {
    if (session == null || currentStepIndex < 0 || currentStepIndex >= session!.steps.length) {
      return null;
    }
    return session!.steps[currentStepIndex];
  }

  bool get isIntro => currentStepIndex == -1;
  bool get isFinished => result != null;
  bool get isLastStep => session != null && currentStepIndex == session!.steps.length - 1;

  SessionState copyWith({
    LearningSession? session,
    int? currentStepIndex,
    Map<String, dynamic>? evidence,
    bool? isLoading,
    bool? isSubmitting,
    SessionResult? result,
    String? error,
  }) {
    return SessionState(
      session: session ?? this.session,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      evidence: evidence ?? this.evidence,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: result ?? this.result,
      error: error,
    );
  }
}

final sessionStateProvider = StateNotifierProvider.family<SessionNotifier, SessionState, String>((ref, sessionId) {
  final repository = ref.watch(sessionsRepositoryProvider);
  return SessionNotifier(repository, sessionId);
});

class SessionNotifier extends StateNotifier<SessionState> {
  final SessionsRepository _repository;
  final String _sessionId;

  SessionNotifier(this._repository, this._sessionId) : super(SessionState()) {
    loadSession();
  }

  Future<void> loadSession() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _repository.getSession(_sessionId);
      
      // Handle resuming session
      int startIndex = -1; // Default to intro
      // If we wanted to auto-skip intro if some progress exists:
      // final firstUncompleted = session.steps.indexWhere((s) => !s.isCompleted);
      // if (firstUncompleted > 0) startIndex = firstUncompleted;

      state = state.copyWith(session: session, currentStepIndex: startIndex, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Failed to load session. Please check your connection.");
    }
  }

  void startSession() {
    if (state.session != null && state.session!.steps.isNotEmpty) {
      // Find the first uncompleted step to support resume
      final resumeIndex = state.session!.steps.indexWhere((s) => !s.isCompleted);
      state = state.copyWith(currentStepIndex: resumeIndex != -1 ? resumeIndex : 0);
    }
  }

  void updateEvidence(String key, dynamic value) {
    final newEvidence = Map<String, dynamic>.from(state.evidence);
    newEvidence[key] = value;
    state = state.copyWith(evidence: newEvidence);
  }

  Future<void> nextStep() async {
    if (state.session == null) return;

    if (state.isLastStep) {
      await submitSession();
    } else {
      final currentStepId = state.currentStep?.id;
      if (currentStepId != null) {
        // Sync progress with backend
        try {
          await _repository.updateStepProgress(_sessionId, currentStepId, true);
        } catch (e) {
          // Non-blocking for UI, but could show a subtle retry/warning
        }
      }
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
    }
  }

  Future<void> submitSession() async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final result = await _repository.completeSession(_sessionId, state.evidence);
      state = state.copyWith(result: result, isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: "Evaluation failed. Please try again.");
    }
  }
}
