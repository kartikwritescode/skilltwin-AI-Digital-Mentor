import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/models/journey_node.dart';

class RoadmapNodeWidget extends StatelessWidget {
  final JourneyNode node;
  final VoidCallback onTap;
  final bool isHighlighted;

  const RoadmapNodeWidget({
    super.key,
    required this.node,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color nodeColor;
    Widget icon;
    double elevation = 0;
    bool isDashedGreen = false;
    double overallOpacity = 1.0;

    // Check states
    final bool isRemediation = node.isRemediation || node.status == NodeState.remediating;
    final bool isBypassed = node.status == NodeState.bypassed || node.status == NodeState.skipped;

    if (isBypassed) {
      overallOpacity = 0.6;
      nodeColor = const Color(0xFFE8F5E9);
      icon = const Icon(Icons.fast_forward_rounded, color: Color(0xFF2E7D32), size: 22);
      isDashedGreen = true;
    } else if (isRemediation) {
      nodeColor = const Color(0xFFFFF8E1);
      icon = const Icon(Icons.build_circle_outlined, color: Color(0xFFFF8F00), size: 24);
      elevation = 4;
    } else {
      switch (node.status) {
        case NodeState.completed:
          nodeColor = Colors.orange;
          icon = const Icon(Icons.check, color: Colors.white, size: 20);
          break;
        case NodeState.current:
          nodeColor = Colors.orange;
          icon = const Icon(Icons.play_arrow, color: Colors.white, size: 24);
          elevation = 8;
          break;
        case NodeState.needsRevision:
        case NodeState.needsAttention:
          nodeColor = Colors.orangeAccent;
          icon = const Icon(Icons.priority_high, color: Colors.white, size: 20);
          break;
        case NodeState.available:
        case NodeState.upcoming:
          nodeColor = Colors.white;
          icon = Icon(Icons.circle, color: Colors.orange.withOpacity(0.3), size: 12);
          break;
        case NodeState.locked:
          nodeColor = Colors.grey.shade200;
          icon = Icon(Icons.lock, color: Colors.grey.shade400, size: 16);
          break;
        case NodeState.remediating:
        case NodeState.bypassed:
        case NodeState.skipped:
          // Handled above
          nodeColor = Colors.white;
          icon = const SizedBox.shrink();
          break;
      }
    }

    // Determine border styling
    Border? border;
    if (!isDashedGreen) {
      if (isRemediation) {
        border = Border.all(color: const Color(0xFFFFB300), width: 3.5);
      } else if (node.status == NodeState.available ||
          node.status == NodeState.upcoming ||
          node.status == NodeState.locked) {
        border = Border.all(color: Colors.grey.shade300, width: 3);
      } else {
        border = Border.all(color: Colors.orange, width: 3);
      }
    }

    Widget circleContent = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: nodeColor,
        shape: BoxShape.circle,
        border: border,
      ),
      child: Center(child: icon),
    );

    if (isDashedGreen) {
      circleContent = CustomPaint(
        foregroundPainter: _DashedCirclePainter(
          color: const Color(0xFF4CAF50),
          strokeWidth: 3.0,
          dashCount: 16,
        ),
        child: circleContent,
      );
    }

    return Opacity(
      opacity: overallOpacity,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulseWrapper(
              active: node.status == NodeState.current,
              child: Material(
                elevation: elevation,
                shadowColor: isRemediation
                    ? const Color(0xFFFFB300).withOpacity(0.5)
                    : Colors.orange.withOpacity(0.4),
                shape: const CircleBorder(),
                child: circleContent,
              ),
            ),
            const SizedBox(height: 6),

            // Badges for Fast-Tracked or Remediation
            if (isBypassed) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                ),
                child: const Text(
                  'Fast-Tracked',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ] else if (isRemediation) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFB300), width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.alt_route, size: 9, color: Color(0xFFFF8F00)),
                    SizedBox(width: 2),
                    Text(
                      'Detour',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],

            Text(
              node.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: node.status == NodeState.locked ? Colors.grey : Colors.black87,
              ),
            ),
            if (node.subtitle != null)
              Text(
                node.subtitle!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  _DashedCirclePainter({
    required this.color,
    this.strokeWidth = 3.0,
    this.dashCount = 16,
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

class _PulseWrapper extends StatefulWidget {
  final Widget child;
  final bool active;

  const _PulseWrapper({required this.child, required this.active});

  @override
  State<_PulseWrapper> createState() => _PulseWrapperState();
}

class _PulseWrapperState extends State<_PulseWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulseWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4 * (1 - _controller.value)),
                blurRadius: 20 * _controller.value,
                spreadRadius: 10 * _controller.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
