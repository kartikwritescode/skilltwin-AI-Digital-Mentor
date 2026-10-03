import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';

/// Clean companion empty state displayed when the learner has not yet
/// generated sufficient empirical proof to construct the twin model.
class TwinEmptyStateView extends StatelessWidget {
  const TwinEmptyStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
      children: [
        const SizedBox(height: 16),

        // Mascot companion waiting
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Waiting for our first proof! 🧠',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 130,
                child: Image.asset(
                  'assets/mascots/twin_curious.webp',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.smart_toy_rounded,
                    size: 90,
                    color: AppTheme.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Your Cognitive Twin is Calibrating',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'SkillTwin does not generate vanity or fabricated metrics. Your Cognitive Twin is constructed solely from empirical proofs — completed lessons, practice quizzes, and spaced retrieval sessions.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.45,
          ),
        ),

        const SizedBox(height: 32),

        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.go('/journey');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E2238),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.explore_rounded, size: 18),
            label: const Text(
              'Start Practicing in Journey',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
