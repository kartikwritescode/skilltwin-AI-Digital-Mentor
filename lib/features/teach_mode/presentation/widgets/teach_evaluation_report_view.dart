import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_markdown.dart';
import '../providers/teach_mode_provider.dart';

/// Information-first evaluation report view for Feynman / Teach Mode.
/// Displays:
/// - Conceptual Accuracy Score & Mastery status
/// - Evaluation signals (Reasoning Depth, Completeness, Transfer)
/// - Detected Misconceptions & Strengths
/// - Mentor Feedback & Actionable Recommendations
/// - Authoritative topic completion CTAs
class TeachEvaluationReportView extends ConsumerWidget {
  final Map<String, dynamic> report;
  final bool isDark;
  final VoidCallback? onTeachAgain;

  const TeachEvaluationReportView({
    super.key,
    required this.report,
    this.isDark = true,
    this.onTeachAgain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teachModeProvider);
    final notifier = ref.read(teachModeProvider.notifier);

    final accuracy = _extractNum(report, ['conceptual_accuracy', 'accuracy']);
    final reasoning = _extractNum(report, ['reasoning', 'depth', 'reasoning_depth', 'clarity']);
    final completeness = _extractNum(report, ['completeness']);
    final transfer = _extractNum(report, ['transfer', 'transfer_analogy', 'confidence']);

    final misconceptions = _extractList(report, ['misconceptions']);
    final strengths = _extractList(report, ['strengths']);
    final feedback = (report['feedback'] ?? report['mentor_feedback'] ?? '').toString();
    final recommendation = (report['recommendation'] ?? report['mentor_recommendation'])?.toString();
    final fixActionId = report['fix_action_id']?.toString();

    final isMastered = state.isMastered ||
        (report['topic_completed'] == true) ||
        (report['is_mastered'] == true) ||
        (accuracy >= 0.75 && misconceptions.isEmpty) ||
        accuracy >= 0.85;

    final cardBg = isDark ? const Color(0xFF181C2E) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : AppTheme.textPrimary;
    final secondaryTextColor = isDark ? Colors.white70 : AppTheme.textSecondary;

    final items = <Widget>[];

    // 1. Mastery Banner
    if (isMastered) {
      items.add(_buildMasteryBanner());
      items.add(const SizedBox(height: 16));
    }

    // 2. Accuracy Overview Card
    items.add(
      _buildAccuracyCard(
        accuracy: accuracy,
        isMastered: isMastered,
        cardBg: cardBg,
        borderColor: borderColor,
        secondaryTextColor: secondaryTextColor,
      ),
    );
    items.add(const SizedBox(height: 18));

    // 3. Evaluation Signals Grid
    items.add(
      _buildSignalsCard(
        reasoning: reasoning,
        completeness: completeness,
        transfer: transfer,
        cardBg: cardBg,
        borderColor: borderColor,
      ),
    );

    // 4. Misconceptions Card
    if (misconceptions.isNotEmpty) {
      items.add(const SizedBox(height: 18));
      items.add(_buildMisconceptionsCard(misconceptions));
    }

    // 5. Strengths Card
    if (strengths.isNotEmpty) {
      items.add(const SizedBox(height: 18));
      items.add(_buildStrengthsCard(strengths));
    }

    // 6. Mentor Advice & Recommendation
    if (feedback.isNotEmpty || (recommendation != null && recommendation.isNotEmpty)) {
      items.add(const SizedBox(height: 18));
      items.add(
        _buildMentorAdviceCard(
          feedback: feedback,
          recommendation: recommendation,
          cardBg: cardBg,
          borderColor: borderColor,
          titleColor: titleColor,
          secondaryTextColor: secondaryTextColor,
        ),
      );
    }

    // 7. Interactive Action Buttons
    items.add(const SizedBox(height: 28));
    items.addAll(
      _buildActionButtons(
        context: context,
        state: state,
        notifier: notifier,
        fixActionId: fixActionId,
        isMastered: isMastered,
        borderColor: borderColor,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );
  }

  Widget _buildMasteryBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Topic Complete \u2713',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "You've got this concept down.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyCard({
    required double accuracy,
    required bool isMastered,
    required Color cardBg,
    required Color borderColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'CONCEPTUAL ACCURACY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white54 : AppTheme.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(accuracy * 100).toInt()}%',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: isMastered ? const Color(0xFF10B981) : const Color(0xFF6366F1),
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isMastered
                ? 'Your mental model of this concept is solid!'
                : 'Good attempt! Let us solidify the key missing details.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalsCard({
    required double reasoning,
    required double completeness,
    required double transfer,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EVALUATION SIGNALS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white54 : AppTheme.textMuted,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          _SignalBar(
            label: 'Reasoning Depth',
            value: reasoning,
            isDark: isDark,
            accentColor: const Color(0xFF6366F1),
          ),
          _SignalBar(
            label: 'Completeness',
            value: completeness,
            isDark: isDark,
            accentColor: const Color(0xFF3B82F6),
          ),
          _SignalBar(
            label: 'Transfer / Analogy',
            value: transfer,
            isDark: isDark,
            accentColor: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildMisconceptionsCard(List<String> misconceptions) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'DETECTED MISCONCEPTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEF4444),
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...misconceptions.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Color(0xFFEF4444), fontSize: 16)),
                  Expanded(
                    child: Text(
                      m,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF991B1B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsCard(List<String> strengths) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'KEY STRENGTHS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...strengths.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Color(0xFF10B981), fontSize: 16)),
                  Expanded(
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF065F46),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorAdviceCard({
    required String feedback,
    required String? recommendation,
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined, color: Color(0xFF6366F1), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'TWIN MENTOR ADVICE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF818CF8) : AppTheme.primary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          if (feedback.isNotEmpty) ...[
            const SizedBox(height: 12),
            SkillTwinMarkdown(
              data: feedback,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                fontStyle: FontStyle.italic,
                color: secondaryTextColor,
              ),
            ),
          ],
          if (recommendation != null && recommendation.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(color: borderColor),
            const SizedBox(height: 12),
            Text(
              'Recommendation:',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white54 : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            SkillTwinMarkdown(
              data: recommendation,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: titleColor,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons({
    required BuildContext context,
    required TeachModeState state,
    required TeachModeNotifier notifier,
    required String? fixActionId,
    required bool isMastered,
    required Color borderColor,
  }) {
    final list = <Widget>[];

    if (fixActionId != null && fixActionId.isNotEmpty) {
      list.add(
        ElevatedButton(
          onPressed: () {
            notifier.reset();
            context.push('/session/$fixActionId');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text(
            'FIX THIS WEAKNESS',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
          ),
        ),
      );
      list.add(const SizedBox(height: 12));
    }

    if (isMastered && !state.isCompleted) {
      list.add(
        ElevatedButton(
          onPressed: () => notifier.confirmTopicCompletion(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text(
            'CONFIRM TOPIC COMPLETION \u2713',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
          ),
        ),
      );
      list.add(const SizedBox(height: 12));
    }

    if (onTeachAgain != null) {
      list.add(
        OutlinedButton(
          onPressed: onTeachAgain,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            foregroundColor: isDark ? Colors.white : AppTheme.textPrimary,
            side: BorderSide(color: borderColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text(
            'TEACH AGAIN',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ),
      );
      list.add(const SizedBox(height: 12));
    }

    list.add(
      ElevatedButton(
        onPressed: () {
          notifier.reset();
          context.go('/');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text(
          'CONTINUE JOURNEY',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
      ),
    );

    return list;
  }

  static double _extractNum(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final val = map[key];
      if (val is num) {
        return val.toDouble().clamp(0.0, 1.0);
      }
    }
    return 0.0;
  }

  static List<String> _extractList(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final val = map[key];
      if (val is List) {
        return val.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
      }
    }
    return const [];
  }
}

class _SignalBar extends StatelessWidget {
  final String label;
  final double value;
  final bool isDark;
  final Color accentColor;

  const _SignalBar({
    required this.label,
    required this.value,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
