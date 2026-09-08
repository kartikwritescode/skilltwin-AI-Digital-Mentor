import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final cleanError = error.replaceFirst(RegExp(r'^(Exception:\s*|Failure:\s*)'), '').trim();
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

    final effectiveIcon = isQuota
        ? Icons.hourglass_top_rounded
        : isWakingUp
            ? Icons.cloud_sync_outlined
            : Icons.cloud_off_outlined;

    final iconColor = isQuota
        ? const Color(0xFFE65100)
        : isWakingUp
            ? const Color(0xFF1976D2)
            : Colors.redAccent;

    final effectiveMessage = isQuota
        ? (cleanError.isNotEmpty
            ? cleanError
            : 'The AI model quota limit was reached. Please wait a few moments before retrying, or verify your Gemini API key.')
        : isWakingUp
            ? 'The backend server is waking up from free-tier inactivity (~30-50s). Please tap below to retry.'
            : cleanError;

    final buttonLabel = isQuota
        ? 'Try Again'
        : isWakingUp
            ? 'Retry Connection'
            : retryLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                effectiveIcon,
                size: 40,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              effectiveMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onRetry();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(buttonLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6D00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
