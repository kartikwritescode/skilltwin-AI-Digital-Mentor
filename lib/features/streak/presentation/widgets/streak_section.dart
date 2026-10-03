import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/home_dashboard.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_twin.dart';
import '../../domain/streak_models.dart';
import 'hero_streak_card.dart';
import 'supporting_streak_card.dart';

class StreakSection extends StatefulWidget {
  final HomeDashboardData dashboardData;
  final VoidCallback? onStartToday;
  final VoidCallback? onOpenRevision;

  const StreakSection({
    super.key,
    required this.dashboardData,
    this.onStartToday,
    this.onOpenRevision,
  });

  @override
  State<StreakSection> createState() => _StreakSectionState();
}

class _StreakSectionState extends State<StreakSection> {
  // Allows user to preview any tier or keep it on 'live'
  StreakTier? _previewTier;

  @override
  Widget build(BuildContext context) {
    final liveStreakDays = widget.dashboardData.streakDays;
    final liveTier = StreakTierConfig.getTierForStreak(liveStreakDays);
    final activeTier = _previewTier ?? liveTier;

    // Days count for hero card
    final displayedDays = _previewTier == null
        ? liveStreakDays
        : (_previewTier == StreakTier.active
            ? (liveStreakDays >= 7 ? liveStreakDays : 74)
            : (_previewTier == StreakTier.shortStreak
                ? 4
                : (_previewTier == StreakTier.zero ? 0 : 623)));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with interactive Tier Selector Toggle
            _buildSectionHeader(context, activeTier, liveTier),
            const SizedBox(height: 12),

            // Dominant Hero Streak Card
            HeroStreakCard(
              streakDays: displayedDays,
              forcedTier: activeTier,
              onStartToday: widget.onStartToday,
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/streak');
              },
            ),
            const SizedBox(height: 16),

            // Supporting Cards Grid / Layout
            if (isWide)
              _buildWideSupportingGrid(context)
            else
              _buildMobileSupportingList(context),
            const SizedBox(height: 16),

            // Integrated Learning Momentum Stats Strip (Retaining practice time & true mastery)
            _buildCompanionStatsStrip(context),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    StreakTier activeTier,
    StreakTier liveTier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              SkillTwinTwin.streak(
                size: 32,
                isDecorative: true,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learning Momentum',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Consistency builds your cognitive twin',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // If in preview mode, show "Reset to Live" button
        if (_previewTier != null)
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _previewTier = null);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 14, color: AppTheme.primaryAccent),
                  SizedBox(width: 4),
                  Text(
                    'Live View',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWideSupportingGrid(BuildContext context) {
    return Row(
      children: [
        // Short Streak Card (4 Days)
        Expanded(
          child: SupportingStreakCard(
            tier: StreakTier.shortStreak,
            days: 4,
            customTitle: "Almost there!",
            customSubtitle: "Small steps, big results!",
            onTap: () {
              setState(() => _previewTier = StreakTier.shortStreak);
            },
          ),
        ),
        const SizedBox(width: 14),

        // Zero / Recovery Card (0 Days)
        Expanded(
          child: SupportingStreakCard(
            tier: StreakTier.zero,
            days: 0,
            customTitle: "Let's get back on track!",
            customSubtitle: "You can do it!",
            actionButtonText: "🚀 Start Today",
            onActionButtonTap: widget.onStartToday,
            onTap: () {
              setState(() => _previewTier = StreakTier.zero);
            },
          ),
        ),
        const SizedBox(width: 14),

        // Legendary Card (623 Days)
        Expanded(
          child: SupportingStreakCard(
            tier: StreakTier.legendary,
            days: 623,
            customTitle: "That's legendary!",
            customSubtitle: "You're built different! 👑",
            onTap: () {
              setState(() => _previewTier = StreakTier.legendary);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSupportingList(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final cardHeight = (226.0 * textScale).clamp(226.0, 260.0);

    return SizedBox(
      height: cardHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(
            width: 250,
            child: SupportingStreakCard(
              tier: StreakTier.shortStreak,
              days: 4,
              customTitle: "Almost there!",
              customSubtitle: "Small steps, big results!",
              onTap: () {
                setState(() => _previewTier = StreakTier.shortStreak);
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 250,
            child: SupportingStreakCard(
              tier: StreakTier.zero,
              days: 0,
              customTitle: "Let's get back on track!",
              customSubtitle: "You can do it!",
              actionButtonText: "🚀 Start Today",
              onActionButtonTap: widget.onStartToday,
              onTap: () {
                setState(() => _previewTier = StreakTier.zero);
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 250,
            child: SupportingStreakCard(
              tier: StreakTier.legendary,
              days: 623,
              customTitle: "That's legendary!",
              customSubtitle: "You're built different! 👑",
              onTap: () {
                setState(() => _previewTier = StreakTier.legendary);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanionStatsStrip(BuildContext context) {
    final minutes = widget.dashboardData.learningMinutes;
    final mastery = (widget.dashboardData.overallMastery * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricTile(
              icon: Icons.timer_outlined,
              iconColor: const Color(0xFF1976D2),
              bgColor: const Color(0xFFE3F2FD),
              label: 'Practice Time',
              value: '${minutes}m',
              subtext: 'Accumulated focus',
            ),
          ),
          Container(
            height: 38,
            width: 1,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: _buildMetricTile(
              icon: Icons.psychology_outlined,
              iconColor: const Color(0xFF7B1FA2),
              bgColor: const Color(0xFFF3E5F5),
              label: 'True Mastery',
              value: '$mastery%',
              subtext: 'Verified neural retention',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
    required String subtext,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtext,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
