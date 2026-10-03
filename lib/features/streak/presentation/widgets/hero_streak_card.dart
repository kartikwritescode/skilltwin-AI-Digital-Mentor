import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/streak_models.dart';
import 'streak_status_badge.dart';
import 'streak_week_progress.dart';
import 'streak_mascot.dart';
import 'streak_state_decoration.dart';

class HeroStreakCard extends StatefulWidget {
  final int streakDays;
  final StreakTier? forcedTier;
  final List<DayProgressItem>? weekProgress;
  final VoidCallback? onTap;
  final VoidCallback? onStartToday;

  const HeroStreakCard({
    super.key,
    required this.streakDays,
    this.forcedTier,
    this.weekProgress,
    this.onTap,
    this.onStartToday,
  });

  @override
  State<HeroStreakCard> createState() => _HeroStreakCardState();
}

class _HeroStreakCardState extends State<HeroStreakCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final tier = widget.forcedTier ?? StreakTierConfig.getTierForStreak(widget.streakDays);
    final config = StreakTierConfig.forTier(tier);
    final days = widget.weekProgress ??
        StreakTierConfig.generateWeekProgress(streakDays: widget.streakDays);

    final isNarrow = MediaQuery.sizeOf(context).width < 580;
    final mascotSize = isNarrow ? 125.0 : 165.0;

    return AnimatedScale(
          scale: _isPressed ? 0.985 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              HapticFeedback.lightImpact();
              widget.onTap?.call();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: config.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: config.accentGlow.withValues(alpha: 0.32),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Atmospheric background sparkles and ambient glow
                    Positioned.fill(
                      child: StreakStateDecoration(tier: tier),
                    ),

                    // Card Content
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isNarrow ? 18 : 26,
                        vertical: isNarrow ? 18 : 22,
                      ),
                      child: isNarrow
                          ? _buildNarrowLayout(context, tier, config, days, mascotSize)
                          : _buildWideLayout(context, tier, config, days, mascotSize),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }

  Widget _buildWideLayout(
    BuildContext context,
    StreakTier tier,
    StreakTierConfig config,
    List<DayProgressItem> days,
    double mascotSize,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Streak details + Activity Tracker
        Expanded(
          flex: 62,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Streak Header Row
              Row(
                children: [
                  // Fire / Streak Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: config.accentGlow.withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        config.streakIcon,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Numeric value + Days
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${widget.streakDays} Days',
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Badge
                  StreakStatusBadge(label: config.badgeText),
                ],
              ),
              const SizedBox(height: 8),

              // Title / Motivational subtitle
              Text(
                config.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 3),

              // Secondary quote
              Text(
                '"${config.quote}"',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.88),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 14),

              // 7-day Tracker
              StreakWeekProgress(
                days: days,
                activeGlowColor: config.accentGlow,
                currentIcon: config.streakIcon,
              ),

              // Optional "Start Today" button for zero streak
              if (tier == StreakTier.zero && widget.onStartToday != null) ...[
                const SizedBox(height: 12),
                _StartTodayButton(onPressed: widget.onStartToday!),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Right Column: Mascot Illustration with floating animation and speech bubble
        Expanded(
          flex: 38,
          child: Center(
            child: StreakMascot(
              tier: tier,
              width: mascotSize,
              height: mascotSize,
              showSpeechBubble: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    StreakTier tier,
    StreakTierConfig config,
    List<DayProgressItem> days,
    double mascotSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top row with streak count, badge, and compact mascot preview
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            config.streakIcon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${widget.streakDays} Days',
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  StreakStatusBadge(
                    label: config.badgeText,
                    fontSize: 10,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    config.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '"${config.quote}"',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StreakMascot(
              tier: tier,
              width: mascotSize * 0.85,
              height: mascotSize * 0.85,
              showSpeechBubble: false,
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 7-day Tracker
        StreakWeekProgress(
          days: days,
          isCompact: true,
          activeGlowColor: config.accentGlow,
          currentIcon: config.streakIcon,
        ),

        // Optional "Start Today" button for zero streak
        if (tier == StreakTier.zero && widget.onStartToday != null) ...[
          const SizedBox(height: 12),
          _StartTodayButton(onPressed: widget.onStartToday!),
        ],
      ],
    );
  }
}

class _StartTodayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartTodayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🚀 Start Today',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF512DA8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
