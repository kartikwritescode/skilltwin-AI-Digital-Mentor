import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/learning_session.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/skilltwin_twin.dart';
import '../../../../core/widgets/skilltwin_ui.dart';
import '../providers/session_state_provider.dart';

class SessionIntroView extends ConsumerWidget {
  final LearningSession session;
  final String sessionId;

  const SessionIntroView({
    super.key,
    required this.session,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: SkillTwinMascot(
              asset: TwinAsset.sessionStart,
              size: 84,
              speechBubble: "Let's explore this together!",
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                session.type.name,
                style: AppTypography.supporting.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            session.conceptTitle,
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(
              fontSize: 22,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${session.durationMinutes} minutes',
                style: AppTypography.supporting.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SkillTwinCard(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 16),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Why this session matters',
                      style: AppTypography.label.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  session.whyStatement,
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SkillTwinButton(
            label: 'Start Session',
            onPressed: () => ref.read(sessionStateProvider(sessionId).notifier).startSession(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
