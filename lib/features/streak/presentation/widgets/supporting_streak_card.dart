import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/streak_models.dart';
import 'streak_week_progress.dart';
import 'streak_mascot.dart';
import 'streak_state_decoration.dart';

class SupportingStreakCard extends StatefulWidget {
  final StreakTier tier;
  final int days;
  final String? customTitle;
  final String? customSubtitle;
  final VoidCallback? onTap;
  final VoidCallback? onActionButtonTap;
  final String? actionButtonText;
  final bool showProgress;

  const SupportingStreakCard({
    super.key,
    required this.tier,
    required this.days,
    this.customTitle,
    this.customSubtitle,
    this.onTap,
    this.onActionButtonTap,
    this.actionButtonText,
    this.showProgress = true,
  });

  @override
  State<SupportingStreakCard> createState() => _SupportingStreakCardState();
}

class _SupportingStreakCardState extends State<SupportingStreakCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final config = StreakTierConfig.forTier(widget.tier);
    final title = widget.customTitle ?? config.title;
    final subtitle = widget.customSubtitle ?? config.subtitle;
    final weekProgress = StreakTierConfig.generateWeekProgress(streakDays: widget.days);

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: config.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: config.accentGlow.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned.fill(
                  child: StreakStateDecoration(tier: widget.tier),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top row: Streak count + icon + mascot
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        config.streakIcon,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.days} Days',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.82),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Mascot thumb
                          StreakMascot(
                            tier: widget.tier,
                            width: 48,
                            height: 48,
                            showSpeechBubble: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Bottom: Week progress or Action Button
                      if (widget.tier == StreakTier.zero &&
                          widget.actionButtonText != null)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onActionButtonTap?.call();
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.actionButtonText!,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF512DA8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else if (widget.showProgress)
                        StreakWeekProgress(
                          days: weekProgress,
                          isCompact: true,
                          activeGlowColor: config.accentGlow,
                          currentIcon: config.streakIcon,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
