import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_theme.dart';
import 'skilltwin_twin.dart';

class ErrorStateView extends StatelessWidget {
  final String title;
  final String error;
  final VoidCallback onRetry;
  final String retryLabel;

  const ErrorStateView({
    super.key,
    this.title = 'Unable to synchronize with mentor',
    required this.error,
    required this.onRetry,
    this.retryLabel = 'Retry Connection',
  });

  @override
  Widget build(BuildContext context) {
    final cleanError =
        error.replaceFirst(RegExp(r'^(Exception:\s*|Failure:\s*)'), '').trim();
    final lower = cleanError.toLowerCase();

    final isQuota = lower.contains('quota') ||
        lower.contains('rate limit') ||
        lower.contains('resource_exhausted') ||
        lower.contains('too many requests') ||
        lower.contains('429');

    final isWakingUp = lower.contains('warming up') ||
        lower.contains('waking up') ||
        lower.contains('timed out') ||
        lower.contains('timeout');

    final effectiveTitle = isQuota
        ? 'AI Quota Limit Reached'
        : isWakingUp
            ? 'Backend Server Connecting'
            : title;

    final effectiveMessage = isQuota
        ? (cleanError.isNotEmpty
            ? cleanError
            : 'The AI model quota limit was reached. Please wait a few moments before retrying, or verify your Gemini API key.')
        : isWakingUp
            ? 'The backend server is waking up from free-tier inactivity (~30-50s). Please tap below to retry.'
            : (cleanError.isNotEmpty ? cleanError : 'Oops, I lost the trail.');

    final buttonLabel = isQuota
        ? 'Try Again'
        : isWakingUp
            ? 'Retry Connection'
            : retryLabel;

    final bottomInset = AppSpacing.calculateBottomNavInset(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SkillTwinTwin.confused(
                size: 88,
                speechBubble: "Oops, I lost the trail.",
                isDecorative: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                effectiveTitle,
                textAlign: TextAlign.center,
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Text(
                  effectiveMessage,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onRetry();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(buttonLabel, style: AppTypography.button),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
