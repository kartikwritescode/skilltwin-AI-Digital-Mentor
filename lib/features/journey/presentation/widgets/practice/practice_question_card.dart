import 'package:flutter/material.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../core/models/topic_detail.dart';
import '../../../../../core/widgets/skilltwin_markdown.dart';
import 'practice_mascot_header.dart';

class PracticeQuestionCard extends StatelessWidget {
  final TopicQuestionItem question;
  final int currentIndex;
  final int totalQuestions;
  final String? selectedAnswer;
  final bool isChecked;
  final bool? isCorrect;
  final bool isLastQuestion;
  final bool isSubmitting;
  final bool isReviewMode;
  final ValueChanged<String> onSelectOption;
  final VoidCallback onCheckAnswer;
  final VoidCallback onNextQuestion;
  final VoidCallback? onPreviousQuestion;
  final VoidCallback? onExitReview;

  const PracticeQuestionCard({
    super.key,
    required this.question,
    required this.currentIndex,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.isChecked,
    required this.isCorrect,
    required this.isLastQuestion,
    required this.isSubmitting,
    required this.isReviewMode,
    required this.onSelectOption,
    required this.onCheckAnswer,
    required this.onNextQuestion,
    this.onPreviousQuestion,
    this.onExitReview,
  });

  PracticeMascotMood _getMood() {
    if (isChecked) {
      return (isCorrect == true)
          ? PracticeMascotMood.correct
          : PracticeMascotMood.incorrect;
    }
    if (selectedAnswer != null && selectedAnswer!.trim().isNotEmpty) {
      return PracticeMascotMood.thinking;
    }
    return currentIndex == 0
        ? PracticeMascotMood.start
        : PracticeMascotMood.thinking;
  }

  @override
  Widget build(BuildContext context) {
    final mood = _getMood();
    final progress =
        totalQuestions > 0 ? (currentIndex + 1) / totalQuestions : 0.0;
    final bottomInset = AppSpacing.calculateBottomNavInset(context);
    final hMargin = AppSpacing.responsiveHorizontalPadding(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hMargin, 8.0, hMargin, bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Progress & Meta Bar ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'QUESTION ${currentIndex + 1} OF $totalQuestions',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppTheme.primaryAccent,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  question.difficulty.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Progress Indicator Bar ──
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryAccent),
            ),
          ),
          const SizedBox(height: 8),

          // ── Small Companion Mascot Header ──
          PracticeMascotHeader(mood: mood),
          const SizedBox(height: 8),

          // ── Question Prompt Card ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkillTwinMarkdown(
                  data: question.prompt,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                if (question.options.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  ...question.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final letter = String.fromCharCode(65 + index); // A, B, C, D
                    return _buildOptionTile(
                      letter: letter,
                      option: option,
                    );
                  }),
                ] else ...[
                  const SizedBox(height: 16),
                  TextField(
                    enabled: !isChecked,
                    controller: TextEditingController(text: selectedAnswer)
                      ..selection = TextSelection.collapsed(
                          offset: selectedAnswer?.length ?? 0),
                    onChanged: onSelectOption,
                    decoration: InputDecoration(
                      hintText: 'Type your answer here...',
                      filled: true,
                      fillColor: isChecked ? Colors.grey.shade100 : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryAccent, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Explanation Card (Revealed upon Check or in Review Mode) ──
          if (isChecked && question.explanation.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildExplanationCard(),
          ],

          const SizedBox(height: 24),

          // ── Bottom Action Controls ──
          _buildActionControls(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String letter,
    required String option,
  }) {
    final isSelected = selectedAnswer == option;
    final isOptionCorrect =
        option.trim().toLowerCase() == question.correctAnswer.trim().toLowerCase();

    Color bgColor = Colors.white;
    Color borderColor = AppTheme.cardBorder;
    Color badgeBgColor = Colors.grey.shade100;
    Color badgeTextColor = Colors.grey.shade700;
    Color textColor = AppTheme.textPrimary;
    Widget? trailingIcon;

    if (!isChecked) {
      if (isSelected) {
        bgColor = AppTheme.primaryAccent.withValues(alpha: 0.08);
        borderColor = AppTheme.primaryAccent;
        badgeBgColor = AppTheme.primaryAccent;
        badgeTextColor = Colors.white;
        textColor = AppTheme.primaryAccent;
        trailingIcon = const Icon(Icons.radio_button_checked,
            color: AppTheme.primaryAccent, size: 20);
      } else {
        trailingIcon = Icon(Icons.radio_button_off,
            color: Colors.grey.shade400, size: 20);
      }
    } else {
      // Checked / Result State
      if (isSelected && isOptionCorrect) {
        // User picked correct answer
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.1);
        borderColor = const Color(0xFF10B981);
        badgeBgColor = const Color(0xFF10B981);
        badgeTextColor = Colors.white;
        textColor = const Color(0xFF065F46);
        trailingIcon = const Icon(Icons.check_circle_rounded,
            color: Color(0xFF10B981), size: 22);
      } else if (isSelected && !isOptionCorrect) {
        // User picked incorrect answer
        bgColor = const Color(0xFFEF4444).withValues(alpha: 0.08);
        borderColor = const Color(0xFFEF4444);
        badgeBgColor = const Color(0xFFEF4444);
        badgeTextColor = Colors.white;
        textColor = const Color(0xFF991B1B);
        trailingIcon = const Icon(Icons.cancel_rounded,
            color: Color(0xFFEF4444), size: 22);
      } else if (!isSelected && isOptionCorrect) {
        // Correct answer that the user missed
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.06);
        borderColor = const Color(0xFF10B981).withValues(alpha: 0.5);
        badgeBgColor = const Color(0xFF10B981).withValues(alpha: 0.2);
        badgeTextColor = const Color(0xFF065F46);
        textColor = const Color(0xFF065F46);
        trailingIcon = const Icon(Icons.check_circle_outline_rounded,
            color: Color(0xFF10B981), size: 20);
      } else {
        // Non-selected neutral option
        bgColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade200;
        badgeBgColor = Colors.grey.shade100;
        badgeTextColor = Colors.grey.shade500;
        textColor = Colors.grey.shade500;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: isChecked ? null : () => onSelectOption(option),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: isSelected ? 1.8 : 1.2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // ── Letter Badge (A, B, C, D) ──
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Option Text ──
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),

              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                trailingIcon,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    final isAnswerCorrect = isCorrect == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAnswerCorrect
            ? const Color(0xFFF0FDF4)
            : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAnswerCorrect
              ? const Color(0xFF86EFAC)
              : const Color(0xFFFCA5A5),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAnswerCorrect ? Icons.lightbulb_rounded : Icons.info_outline_rounded,
                size: 18,
                color: isAnswerCorrect
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAnswerCorrect ? "Why this is correct:" : "Twin's Explanation:",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isAnswerCorrect
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SkillTwinMarkdown(
            data: question.explanation,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: isAnswerCorrect
                  ? const Color(0xFF14532D)
                  : const Color(0xFF7F1D1D),
            ),
          ),
          if (!isAnswerCorrect && question.correctAnswer.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Text(
                'Correct Answer: ${question.correctAnswer}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF991B1B),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionControls(BuildContext context) {
    if (isReviewMode) {
      return Row(
        children: [
          if (currentIndex > 0 && onPreviousQuestion != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPreviousQuestion,
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (currentIndex > 0 && onPreviousQuestion != null)
            const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLastQuestion ? onExitReview : onNextQuestion,
              icon: Icon(
                isLastQuestion ? Icons.check : Icons.arrow_forward,
                size: 16,
              ),
              label: Text(
                isLastQuestion ? 'Back to Results' : 'Next',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (!isChecked) {
      final hasSelected =
          selectedAnswer != null && selectedAnswer!.trim().isNotEmpty;
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: hasSelected ? onCheckAnswer : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryAccent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade500,
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: hasSelected ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Check Answer',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      );
    }

    // Checked state: Next or Submit
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : onNextQuestion,
        icon: isSubmitting
            ? const SizedBox.shrink()
            : Icon(
                isLastQuestion ? Icons.stars_rounded : Icons.arrow_forward_rounded,
                size: 18,
              ),
        label: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isLastQuestion ? 'Complete Assessment' : 'Next Question',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLastQuestion
              ? const Color(0xFF10B981)
              : AppTheme.primaryAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
