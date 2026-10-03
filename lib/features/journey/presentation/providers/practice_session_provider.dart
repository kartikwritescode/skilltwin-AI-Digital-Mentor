import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/topic_detail.dart';
import 'learning_path_provider.dart';

/// State of an active practice / assessment session for a topic.
class PracticeSessionState {
  final String topicId;
  final List<TopicQuestionItem> questions;
  final int currentIndex;
  final Map<String, String> selectedAnswers;
  final Map<String, bool> questionResults;
  final bool isChecked;
  final bool isSubmitting;
  final QuestionSubmissionResponse? submissionResult;
  final String? errorMessage;
  final bool isReviewMode;

  const PracticeSessionState({
    required this.topicId,
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswers = const {},
    this.questionResults = const {},
    this.isChecked = false,
    this.isSubmitting = false,
    this.submissionResult,
    this.errorMessage,
    this.isReviewMode = false,
  });

  bool get isEmpty => questions.isEmpty;
  int get totalQuestions => questions.length;
  bool get isCompleted => submissionResult != null && !isReviewMode;
  bool get isLastQuestion => currentIndex == questions.length - 1;
  bool get hasSelectedCurrent =>
      currentQuestion != null && selectedAnswers.containsKey(currentQuestion!.id);

  TopicQuestionItem? get currentQuestion =>
      (currentIndex >= 0 && currentIndex < questions.length)
          ? questions[currentIndex]
          : null;

  String? get currentSelectedAnswer =>
      currentQuestion != null ? selectedAnswers[currentQuestion!.id] : null;

  bool? get isCurrentAnswerCorrect {
    if (!isChecked || currentQuestion == null) return null;
    return questionResults[currentQuestion!.id];
  }

  double get progress =>
      totalQuestions > 0 ? (currentIndex + 1) / totalQuestions : 0.0;

  PracticeSessionState copyWith({
    String? topicId,
    List<TopicQuestionItem>? questions,
    int? currentIndex,
    Map<String, String>? selectedAnswers,
    Map<String, bool>? questionResults,
    bool? isChecked,
    bool? isSubmitting,
    QuestionSubmissionResponse? submissionResult,
    String? errorMessage,
    bool? isReviewMode,
  }) {
    return PracticeSessionState(
      topicId: topicId ?? this.topicId,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      questionResults: questionResults ?? this.questionResults,
      isChecked: isChecked ?? this.isChecked,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionResult: submissionResult ?? this.submissionResult,
      errorMessage: errorMessage,
      isReviewMode: isReviewMode ?? this.isReviewMode,
    );
  }
}

/// Riverpod family notifier managing practice session state and deterministic engine sync.
class PracticeSessionNotifier extends StateNotifier<PracticeSessionState> {
  final Ref _ref;
  final String _topicId;

  PracticeSessionNotifier(this._ref, this._topicId)
      : super(PracticeSessionState(topicId: _topicId));

  /// Initialize or refresh questions from repository.
  void initQuestions(List<TopicQuestionItem> questions) {
    if (state.questions.isNotEmpty) return; // Keep existing session state on rebuild
    state = state.copyWith(questions: questions);
  }

  /// Select an answer option for the current question.
  void selectAnswer(String option) {
    final q = state.currentQuestion;
    if (q == null || state.isChecked) return;

    final updated = Map<String, String>.from(state.selectedAnswers);
    updated[q.id] = option;
    state = state.copyWith(selectedAnswers: updated);
  }

  /// Check answer for immediate feedback & mascot reaction.
  void checkAnswer() {
    final q = state.currentQuestion;
    if (q == null) return;
    final selected = state.selectedAnswers[q.id];
    if (selected == null) return;

    final isCorrect =
        selected.trim().toLowerCase() == q.correctAnswer.trim().toLowerCase();

    final updatedResults = Map<String, bool>.from(state.questionResults);
    updatedResults[q.id] = isCorrect;

    state = state.copyWith(
      isChecked: true,
      questionResults: updatedResults,
    );
  }

  /// Move to the next question.
  void nextQuestion() {
    if (state.currentIndex < state.totalQuestions - 1) {
      final nextIndex = state.currentIndex + 1;
      final nextQ = state.questions[nextIndex];
      final alreadyChecked = state.questionResults.containsKey(nextQ.id);

      state = state.copyWith(
        currentIndex: nextIndex,
        isChecked: alreadyChecked,
      );
    }
  }

  /// Move to previous question (for review).
  void previousQuestion() {
    if (state.currentIndex > 0) {
      final prevIndex = state.currentIndex - 1;
      final prevQ = state.questions[prevIndex];
      final alreadyChecked = state.questionResults.containsKey(prevQ.id);

      state = state.copyWith(
        currentIndex: prevIndex,
        isChecked: alreadyChecked,
      );
    }
  }

  /// Submit the full practice assessment to backend.
  Future<void> submitPractice() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final answers = state.questions.map((q) {
      return AnswerSubmissionItem(
        questionId: q.id,
        userAnswer: state.selectedAnswers[q.id] ?? '',
      );
    }).toList();

    try {
      final notifier = _ref.read(topicActionProvider.notifier);
      final res = await notifier.submitAnswers(_topicId, answers);

      if (res != null) {
        state = state.copyWith(
          isSubmitting: false,
          submissionResult: res,
          isReviewMode: false,
        );
      } else {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Unable to grade assessment. Your answers are saved.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Network error submitting answers: $e',
      );
    }
  }

  /// Enter review mode to review all questions and explanations.
  void enterReviewMode() {
    state = state.copyWith(
      isReviewMode: true,
      currentIndex: 0,
      isChecked: true,
    );
  }

  /// Exit review mode back to completion view.
  void exitReviewMode() {
    state = state.copyWith(isReviewMode: false);
  }

  /// Restart practice session.
  void restartPractice() {
    state = PracticeSessionState(
      topicId: _topicId,
      questions: state.questions,
    );
  }
}

final practiceSessionProvider = StateNotifierProvider.family<
    PracticeSessionNotifier, PracticeSessionState, String>((ref, topicId) {
  return PracticeSessionNotifier(ref, topicId);
});
