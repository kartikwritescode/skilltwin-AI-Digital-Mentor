import 'package:flutter/material.dart';
import '../../../../core/models/journey_node.dart';

class WindingPathPainter extends CustomPainter {
  final List<Offset> nodePositions;
  final List<JourneyNode>? nodes;
  final Color pathColor;
  final double animationValue;

  WindingPathPainter({
    required this.nodePositions,
    this.nodes,
    this.animationValue = 1.0,
    this.pathColor = Colors.orange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

    final standardPaint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final detourPaint = Paint()
      ..color = const Color(0xFFFFB300) // Amber detour
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final bypassedPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.5) // Light green fast-track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < nodePositions.length - 1; i++) {
      final p0 = nodePositions[i];
      final p1 = nodePositions[i + 1];

      final bool isCurrentDetour = nodes != null &&
          i + 1 < nodes!.length &&
          (nodes![i].isRemediation ||
              nodes![i].status == NodeState.remediating ||
              nodes![i + 1].isRemediation ||
              nodes![i + 1].status == NodeState.remediating);

      final bool isCurrentBypassed = nodes != null &&
          i + 1 < nodes!.length &&
          (nodes![i].status == NodeState.bypassed ||
              nodes![i].status == NodeState.skipped ||
              nodes![i + 1].status == NodeState.bypassed ||
              nodes![i + 1].status == NodeState.skipped);

      final segmentPath = Path();
      segmentPath.moveTo(p0.dx, p0.dy);

      if (isCurrentDetour) {
        // Curved detour arch connector bulging out to indicate dynamic remediation detour
        final double midY = (p0.dy + p1.dy) / 2;
        final double detourOffset = (p1.dx >= p0.dx) ? 40.0 : -40.0;

        final controlPoint1 = Offset(p0.dx + detourOffset, midY);
        final controlPoint2 = Offset(p1.dx + detourOffset, midY);

        segmentPath.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          p1.dx, p1.dy,
        );
      } else {
        // Standard smooth cubic S-curve
        final controlPoint1 = Offset(p0.dx, p0.dy + (p1.dy - p0.dy) / 2);
        final controlPoint2 = Offset(p1.dx, p0.dy + (p1.dy - p0.dy) / 2);

        segmentPath.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          p1.dx, p1.dy,
        );
      }

      // Compute animation slice
      final pathMetrics = segmentPath.computeMetrics();
      final extractPath = Path();
      for (var metric in pathMetrics) {
        extractPath.addPath(
          metric.extractPath(0.0, metric.length * animationValue),
          Offset.zero,
        );
      }

      // Pick proper paint style
      Paint activePaint = standardPaint;
      if (isCurrentDetour) {
        activePaint = detourPaint;
      } else if (isCurrentBypassed) {
        activePaint = bypassedPaint;
      }

      canvas.drawPath(extractPath, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant WindingPathPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.nodePositions != nodePositions ||
        oldDelegate.nodes != nodes;
  }
}
