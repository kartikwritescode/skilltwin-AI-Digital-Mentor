import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/learning_session.dart';
import '../../../../core/models/session_step.dart';
import '../../../../core/models/session_result.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../../data/repositories/sessions_repository_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';

class SessionState {
  final LearningSession? session;
  final int currentStepIndex;
  final Map<String, dynamic> evidence;
  final bool isLoading;
  final bool isSubmitting;
  final SessionResult? result;
  final String? error;
  final DateTime? startedAt;
  final double userConfidence;

  SessionState({
    this.session,
    this.currentStepIndex = -1, // -1 means Intro
    this.evidence = const {},
    this.isLoading = false,
    this.isSubmitting = false,
    this.result,
    this.error,
    this.startedAt,
    this.userConfidence = 75.0,
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

  int get elapsedSeconds {
    if (startedAt == null) return 0;
    return DateTime.now().difference(startedAt!).inSeconds;
  }

  SessionState copyWith({
    LearningSession? session,
    int? currentStepIndex,
    Map<String, dynamic>? evidence,
    bool? isLoading,
    bool? isSubmitting,
    SessionResult? result,
    String? error,
    DateTime? startedAt,
    double? userConfidence,
  }) {
    return SessionState(
      session: session ?? this.session,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      evidence: evidence ?? this.evidence,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: result ?? this.result,
      error: error,
      startedAt: startedAt ?? this.startedAt,
      userConfidence: userConfidence ?? this.userConfidence,
    );
  }
}

final sessionStateProvider = StateNotifierProvider.family<SessionNotifier, SessionState, String>((ref, sessionId) {
  final repository = ref.watch(sessionsRepositoryProvider);
  return SessionNotifier(repository, sessionId, ref);
});

class SessionNotifier extends StateNotifier<SessionState> {
  final SessionsRepository _repository;
  final String _sessionId;
  final Ref _ref;

  SessionNotifier(this._repository, this._sessionId, this._ref) : super(SessionState()) {
    loadSession();
  }

  Future<void> loadSession() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _repository.getSession(_sessionId);
      
      // Handle resuming session
      int startIndex = -1; // Default to intro
      state = state.copyWith(session: session, currentStepIndex: startIndex, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Failed to load session. Please check your connection.");
    }
  }

  String get _effectiveTopicId {
    final cId = state.session?.conceptId;
    if (cId != null && cId.isNotEmpty) return cId;
    final jId = state.session?.journeyNodeId;
    if (jId != null && jId.isNotEmpty) return jId;
    return _sessionId;
  }

  void startSession() {
    if (state.session != null && state.session!.steps.isNotEmpty) {
      // Find the first uncompleted step to support resume
      final resumeIndex = state.session!.steps.indexWhere((s) => !s.isCompleted);
      state = state.copyWith(
        currentStepIndex: resumeIndex != -1 ? resumeIndex : 0,
        startedAt: state.startedAt ?? DateTime.now(),
      );
      _ref.read(todayTaskStateProvider.notifier).markStarted(
        topicId: _effectiveTopicId,
        topicTitle: state.session?.conceptTitle,
      );
    }
  }

  void setConfidence(double confidence) {
    state = state.copyWith(userConfidence: confidence);
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
      final submissionPayload = Map<String, dynamic>.from(state.evidence);
      submissionPayload['time_spent_seconds'] = state.elapsedSeconds > 0 ? state.elapsedSeconds : 120;
      submissionPayload['self_reported_confidence'] = state.userConfidence;

      final result = await _repository.completeSession(_sessionId, submissionPayload);
      state = state.copyWith(result: result, isSubmitting: false);

      // Single source of truth: propagate confirmed completion to Home & derived states
      await _ref.read(todayTaskStateProvider.notifier).recordCompletion(
        topicId: _effectiveTopicId,
        topicTitle: state.session?.conceptTitle,
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: "Evaluation failed. Please try again.");
      _ref.read(todayTaskStateProvider.notifier).recordFailure("Evaluation failed. Please try again.");
    }
  }
}
