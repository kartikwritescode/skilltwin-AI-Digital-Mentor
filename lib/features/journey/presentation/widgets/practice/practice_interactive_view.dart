import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../providers/learning_path_provider.dart';
import '../../providers/practice_session_provider.dart';
import 'practice_question_card.dart';
import 'practice_completion_view.dart';

class PracticeInteractiveView extends ConsumerStatefulWidget {
  final String topicId;
  final Widget? askQuestionsSection;
  final Widget? socraticSection;
  final VoidCallback? onContinueLearning;

  const PracticeInteractiveView({
    super.key,
    required this.topicId,
    this.askQuestionsSection,
    this.socraticSection,
    this.onContinueLearning,
  });

  Widget? get _effectiveAskSection => askQuestionsSection ?? socraticSection;

  @override
  ConsumerState<PracticeInteractiveView> createState() =>
      _PracticeInteractiveViewState();
}

class _PracticeInteractiveViewState
    extends ConsumerState<PracticeInteractiveView> {
  bool _askExpanded = false;

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(topicQuestionsProvider(widget.topicId));
    final sessionState = ref.watch(practiceSessionProvider(widget.topicId));
    final sessionNotifier =
        ref.read(practiceSessionProvider(widget.topicId).notifier);

    return questionsAsync.when(
      data: (questions) {
        // Initialize questions on first arrival
        if (questions.isNotEmpty && sessionState.questions.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sessionNotifier.initQuestions(questions);
          });
        }

        if (questions.isEmpty) {
          return _buildEmptyQuestionsView();
        }

        return Column(
          children: [
            // ── Conversational Ask Questions Action ──
            if (widget._effectiveAskSection != null)
              _buildAskQuestionsHeader(),

            // ── Error Banner if submission failed (Preserves answers!) ──
            if (sessionState.errorMessage != null)
              _buildSubmissionErrorBanner(sessionNotifier, sessionState),

            // ── Main Practice Body ──
            Expanded(
              child: _buildPracticeBody(sessionState, sessionNotifier),
            ),
          ],
        );
      },
      loading: () => _buildLoadingView('Twin is loading your practice questions...'),
      error: (err, _) => _buildErrorView(err.toString()),
    );
  }

  Widget _buildAskQuestionsHeader() {
    final askWidget = widget._effectiveAskSection;
    if (askWidget == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _askExpanded
              ? const Color(0xFF6366F1).withValues(alpha: 0.35)
              : const Color(0xFFE2E8F0),
          width: _askExpanded ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _askExpanded
                ? const Color(0xFF6366F1).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.025),
            blurRadius: _askExpanded ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _askExpanded = !_askExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: _askExpanded
                          ? const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: _askExpanded ? null : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _askExpanded
                          ? [
                              BoxShadow(
                                color: const Color(0xFF6366F1)
                                    .withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _askExpanded
                          ? Icons.auto_awesome_rounded
                          : Icons.chat_bubble_outline_rounded,
                      color: _askExpanded
                          ? Colors.white
                          : const Color(0xFF475569),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Ask a question',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'AI MENTOR',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF6366F1),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _askExpanded
                              ? 'Ask for hints, step explanations, or concept breakdowns.'
                              : 'Stuck on something? Ask your Twin.',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _askExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _askExpanded
                            ? const Color(0xFFEEF2FF)
                            : const Color(0xFFF8FAFC),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _askExpanded
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: askWidget,
                ),
              ],
            ),
            crossFadeState: _askExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionErrorBanner(
      PracticeSessionNotifier notifier, PracticeSessionState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.errorMessage ?? 'Submission failed. Your answers are saved.',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF991B1B),
              ),
            ),
          ),
          TextButton(
            onPressed: state.isSubmitting ? null : notifier.submitPractice,
            child: Text(
              state.isSubmitting ? 'Retrying...' : 'Retry',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeBody(
      PracticeSessionState state, PracticeSessionNotifier notifier) {
    // If completed assessment and not reviewing:
    if (state.isCompleted && state.submissionResult != null) {
      return PracticeCompletionView(
        result: state.submissionResult!,
        onReviewQuestions: notifier.enterReviewMode,
        onContinue: widget.onContinueLearning,
        onRestart: notifier.restartPractice,
      );
    }

    // While submitting answers to backend:
    if (state.isSubmitting) {
      return _buildLoadingView('Twin is grading your practice answers...');
    }

    // Active question card (taking practice or in review mode)
    final question = state.currentQuestion;
    if (question == null) {
      return _buildEmptyQuestionsView();
    }

    return PracticeQuestionCard(
      question: question,
      currentIndex: state.currentIndex,
      totalQuestions: state.totalQuestions,
      selectedAnswer: state.currentSelectedAnswer,
      isChecked: state.isChecked,
      isCorrect: state.isCurrentAnswerCorrect,
      isLastQuestion: state.isLastQuestion,
      isSubmitting: state.isSubmitting,
      isReviewMode: state.isReviewMode,
      onSelectOption: notifier.selectAnswer,
      onCheckAnswer: notifier.checkAnswer,
      onNextQuestion: () {
        if (state.isLastQuestion && !state.isReviewMode) {
          notifier.submitPractice();
        } else {
          notifier.nextQuestion();
        }
      },
      onPreviousQuestion:
          state.currentIndex > 0 ? notifier.previousQuestion : null,
      onExitReview: state.isReviewMode ? notifier.exitReviewMode : null,
    );
  }

  Widget _buildLoadingView(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/mascots/skilltwin_mascot_loading.gif',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const CircularProgressIndicator(
              color: AppTheme.primaryAccent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQuestionsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/mascots/twin_curious.webp',
              width: 90,
              height: 90,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.quiz_outlined,
                size: 64,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No practice questions yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Twin will generate active recall questions for this topic soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'Unable to load questions',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(topicQuestionsProvider(widget.topicId)),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
