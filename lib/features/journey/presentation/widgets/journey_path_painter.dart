import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'journey_theme_models.dart';

/// Segment of the winding roadmap path between two consecutive milestone nodes.
class RoadmapPathSegment {
  final Offset start;
  final Offset end;
  final RoadmapVisualState startState;
  final RoadmapVisualState endState;
  final ModuleRegionTheme startTheme;
  final ModuleRegionTheme endTheme;
  final bool isRemediation;
  final bool isBypassed;

  const RoadmapPathSegment({
    required this.start,
    required this.end,
    required this.startState,
    required this.endState,
    required this.startTheme,
    required this.endTheme,
    this.isRemediation = false,
    this.isBypassed = false,
  });
}

/// Custom painter for the winding dynamic game-map roadmap path.
/// Renders smooth cubic bezier splines, multi-color module gradient transitions,
/// glowing active trails, amber detour splines, and green bypassed dashed connectors.
class JourneyPathPainter extends CustomPainter {
  final List<RoadmapPathSegment> segments;
  final double animationValue;

  JourneyPathPainter({
    required this.segments,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    for (final segment in segments) {
      _paintSegment(canvas, segment);
    }
  }

  void _paintSegment(Canvas canvas, RoadmapPathSegment segment) {
    final p0 = segment.start;
    final p1 = segment.end;

    // 1. Construct the smooth cubic Bezier path between p0 and p1
    final path = Path();
    path.moveTo(p0.dx, p0.dy);

    final dy = p1.dy - p0.dy;
    final dx = p1.dx - p0.dx;

    if (segment.isRemediation) {
      // Bulge out laterally in an amber detour arch
      final double detourOffset = (dx >= 0) ? 48.0 : -48.0;
      final cp1 = Offset(p0.dx + detourOffset, p0.dy + dy * 0.35);
      final cp2 = Offset(p1.dx + detourOffset, p0.dy + dy * 0.65);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    } else {
      // Standard gentle S-curve
      final cp1 = Offset(p0.dx, p0.dy + dy * 0.5);
      final cp2 = Offset(p1.dx, p0.dy + dy * 0.5);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }

    // 2. Compute progressive drawing slice for entrance animation
    final pathMetrics = path.computeMetrics();
    final animatedPath = Path();
    for (final metric in pathMetrics) {
      final extractLength = metric.length * animationValue.clamp(0.0, 1.0);
      animatedPath.addPath(
        metric.extractPath(0.0, extractLength),
        Offset.zero,
      );
    }

    // 3. Resolve path state and colors
    final isBothCompleted = segment.startState.isCompleted &&
        (segment.endState.isCompleted || segment.endState.isCurrent);
    final isLocked = segment.endState.isLocked;

    // A. Under-track shadow / road bed
    final underTrackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(animatedPath, underTrackPaint);

    // B. Color Gradient along segment
    final Color startColor;
    final Color endColor;

    if (segment.isRemediation) {
      startColor = const Color(0xFF6366F1);
      endColor = const Color(0xFF818CF8);
    } else if (segment.isBypassed) {
      startColor = const Color(0xFF10B981).withValues(alpha: 0.65);
      endColor = const Color(0xFF34D399).withValues(alpha: 0.65);
    } else if (isBothCompleted) {
      startColor = segment.startTheme.primary;
      endColor = segment.endTheme.primary;
    } else if (segment.endState.isCurrent) {
      startColor = segment.startTheme.primary;
      endColor = segment.endTheme.primary;
    } else if (isLocked) {
      startColor = const Color(0xFFCBD5E1);
      endColor = const Color(0xFFE2E8F0);
    } else {
      startColor = segment.startTheme.primary.withValues(alpha: 0.45);
      endColor = segment.endTheme.primary.withValues(alpha: 0.45);
    }

    final lineShader = ui.Gradient.linear(
      p0,
      p1,
      [startColor, endColor],
    );

    // C. Foreground stroke
    if (segment.isBypassed) {
      // Dashed fast-track line
      _drawDashedPath(
        canvas,
        animatedPath,
        Paint()
          ..shader = lineShader
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round,
        dashLength: 8,
        dashSpace: 6,
      );
    } else if (isLocked) {
      // Dashed muted path for locked upcoming segments
      _drawDashedPath(
        canvas,
        animatedPath,
        Paint()
          ..shader = lineShader
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round,
        dashLength: 6,
        dashSpace: 6,
      );
    } else {
      // Solid continuous path
      final mainStrokePaint = Paint()
        ..shader = lineShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = segment.isRemediation ? 4.0 : 5.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(animatedPath, mainStrokePaint);

      // Soft ambient glow for completed & active paths
      if (isBothCompleted || segment.endState.isCurrent) {
        final glowPaint = Paint()
          ..shader = lineShader
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawPath(animatedPath, glowPaint);
      }
    }
  }

  void _drawDashedPath(
    Canvas canvas,
    Path source,
    Paint paint, {
    required double dashLength,
    required double dashSpace,
  }) {
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = (distance + dashLength < metric.length)
            ? dashLength
            : metric.length - distance;
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant JourneyPathPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.segments != segments;
}
