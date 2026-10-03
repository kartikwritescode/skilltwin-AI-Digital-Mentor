import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/mastery_format.dart';
import 'journey_theme_models.dart';

/// Interactive circular milestone node representing a topic or video milestone.
/// Fully reflects adaptive states: Completed, Current, Available, Locked,
/// Needs Revision, Remediating Detour, and Bypassed Fast-Track.
/// Features generous title constraints (prevents awkward truncation) and accurate mastery formatting.
class JourneyMilestoneNode extends StatefulWidget {
  final RoadmapTopicItem topic;
  final ModuleRegionTheme theme;
  final VoidCallback onTap;
  final bool isCurrent;

  const JourneyMilestoneNode({
    super.key,
    required this.topic,
    required this.theme,
    required this.onTap,
    this.isCurrent = false,
  });

  @override
  State<JourneyMilestoneNode> createState() => _JourneyMilestoneNodeState();
}

class _JourneyMilestoneNodeState extends State<JourneyMilestoneNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScaleAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _floatAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseScaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -2.5, end: 2.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isCurrent || widget.topic.visualState.isCurrent) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(JourneyMilestoneNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isNowCurrent = widget.isCurrent || widget.topic.visualState.isCurrent;
    final wasCurrent =
        oldWidget.isCurrent || oldWidget.topic.visualState.isCurrent;

    if (isNowCurrent && !wasCurrent) {
      _pulseController.repeat(reverse: true);
    } else if (!isNowCurrent && wasCurrent) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final state = topic.visualState;
    final theme = widget.theme;

    // Refined diameter so nodes do not overpower cards
    final double nodeDiameter = state.isCurrent ? 64.0 : (state.isRemediating ? 48.0 : 54.0);

    final semanticLabel = _buildSemanticLabel(topic, state);

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: !state.isLocked,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          if (state.isLocked) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Milestone locked: Complete previous topics to unlock "${topic.title}".',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            return;
          }
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Contextual "CONTINUE" Affordance for Active Node
              if (state.isCurrent) ...[
                _buildActiveAffordanceBadge(theme),
                const SizedBox(height: 5),
              ],

              // 2. Animated Glowing Node Ring with Gentle Movement
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = state.isCurrent ? _pulseScaleAnimation.value : 1.0;
                  final floatDy = state.isCurrent ? _floatAnimation.value : 0.0;
                  return Transform.translate(
                    offset: Offset(0, floatDy),
                    child: Transform.scale(
                      scale: scale,
                      child: _buildNodeCircle(state, theme, nodeDiameter),
                    ),
                  );
                },
              ),
              const SizedBox(height: 7),

              // 3. Adaptive State Pill Badge (if Detour / Proved / Revise)
              _buildStatePillBadge(state),

              // 4. Topic Title & Accurate Mastery Percentage Container
              _buildTopicTitle(topic, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveAffordanceBadge(ModuleRegionTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFF5B5FEF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B5FEF).withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow_rounded, color: Colors.white, size: 12),
          SizedBox(width: 2),
          Flexible(
            child: Text(
              'CONTINUE',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.0,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeCircle(
    RoadmapVisualState state,
    ModuleRegionTheme theme,
    double diameter,
  ) {
    Color outerRingColor = Colors.white;
    Color innerColor;
    Color iconColor = Colors.white;
    List<BoxShadow> shadows = [];
    double opacity = 1.0;

    switch (state) {
      case RoadmapVisualState.completed:
        innerColor = const Color(0xFF10B981);
        iconColor = Colors.white;
        shadows = [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.32),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
        break;

      case RoadmapVisualState.current:
        innerColor = const Color(0xFF5B5FEF);
        iconColor = Colors.white;
        outerRingColor = Colors.white;
        final glowAlpha = _glowAnimation.value;
        shadows = [
          BoxShadow(
            color: const Color(0xFF5B5FEF).withValues(alpha: 0.50 * glowAlpha),
            blurRadius: 20 * glowAlpha,
            spreadRadius: 3 * glowAlpha,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ];
        break;

      case RoadmapVisualState.available:
        innerColor = Colors.white;
        iconColor = const Color(0xFF5B5FEF);
        outerRingColor = const Color(0xFF5B5FEF);
        shadows = [
          BoxShadow(
            color: const Color(0xFF5B5FEF).withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ];
        break;

      case RoadmapVisualState.locked:
        innerColor = const Color(0xFFF1F5F9);
        iconColor = const Color(0xFF94A3B8);
        outerRingColor = const Color(0xFFCBD5E1);
        opacity = 0.60;
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
        break;

      case RoadmapVisualState.needsRevision:
        innerColor = const Color(0xFFA855F7); // Soft purple
        iconColor = Colors.white;
        outerRingColor = Colors.white;
        shadows = [
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
        break;

      case RoadmapVisualState.remediating:
        innerColor = const Color(0xFF6366F1);
        iconColor = Colors.white;
        outerRingColor = const Color(0xFFE0E7FF);
        shadows = [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ];
        break;

      case RoadmapVisualState.bypassed:
        innerColor = const Color(0xFFECFDF5);
        iconColor = const Color(0xFF10B981);
        outerRingColor = const Color(0xFF10B981);
        opacity = 0.78;
        shadows = [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
        break;
    }

    final Widget coreIcon = Icon(
      widget.topic.icon,
      color: iconColor,
      size: diameter * 0.44,
    );

    Widget nodeBody = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: innerColor,
        border: Border.all(
          color: outerRingColor,
          width: state.isCurrent ? 4.0 : 3.0,
        ),
        boxShadow: shadows,
        gradient: state.isCompleted
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF34D399), Color(0xFF10B981)],
              )
            : (state.isCurrent
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7C82FB), Color(0xFF5B5FEF)],
                  )
                : null),
      ),
      child: Center(child: coreIcon),
    );

    if (state.isBypassed) {
      nodeBody = CustomPaint(
        foregroundPainter: _DashedCirclePainter(
          color: const Color(0xFF10B981),
          strokeWidth: 2.8,
          dashCount: 12,
        ),
        child: nodeBody,
      );
    }

    return Opacity(
      opacity: opacity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          nodeBody,

          // Mini Completion Checkmark Badge
          if (state.isCompleted)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(2.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ),

          // Mini Warning / Revision Exclamation Badge
          if (state.isNeedsRevision)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(2.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA855F7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.priority_high_rounded,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ),

          // Mini Lock Badge for Locked Nodes
          if (state.isLocked)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(2.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF64748B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ),

          // Mini Detour Badge for Remediation Nodes
          if (state.isRemediating)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(2.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.alt_route_rounded,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ),

          // Mini Fast-Forward Badge for Bypassed Nodes
          if (state.isBypassed)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(2.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fast_forward_rounded,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatePillBadge(RoadmapVisualState state) {
    if (state.isBypassed) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF10B981), width: 1),
        ),
        child: const Text(
          'PROVED',
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            color: Color(0xFF065F46),
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    if (state.isRemediating) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF6366F1), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.alt_route_rounded, size: 9, color: Color(0xFF4F46E5)),
            SizedBox(width: 3),
            Text(
              'QUICK FIX',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3730A3),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    if (state.isNeedsRevision) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF5FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFA855F7), width: 1),
        ),
        child: const Text(
          'REVISE',
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            color: Color(0xFF7E22CE),
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTopicTitle(RoadmapTopicItem topic, RoadmapVisualState state) {
    final masteryPercentage = topic.masteryScore.toMasteryPercentage;

    return Container(
      constraints: const BoxConstraints(maxWidth: 168),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            topic.title,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              height: 1.25,
              letterSpacing: -0.2,
              color: state.isLocked
                  ? const Color(0xFF64748B)
                  : const Color(0xFF0F172A),
              shadows: const [
                Shadow(
                  color: Colors.white,
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          if (state.isCompleted && masteryPercentage > 0) ...[
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$masteryPercentage% mastery',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF059669),
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildSemanticLabel(
      RoadmapTopicItem topic, RoadmapVisualState state) {
    final statusName = state.name;
    final mastery = topic.masteryScore.toMasteryPercentage;
    return '${topic.title}, $statusName, $mastery percent mastery';
  }
}

/// Helper custom painter for dashed circular borders on Bypassed nodes.
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  _DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2.8,
    this.dashCount = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const totalAngle = 2 * math.pi;
    final dashAngle = totalAngle / (dashCount * 2);

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * 2 * dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashCount != dashCount;
}
