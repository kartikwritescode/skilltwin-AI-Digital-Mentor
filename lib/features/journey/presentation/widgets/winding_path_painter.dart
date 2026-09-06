import 'package:flutter/material.dart';

class WindingPathPainter extends CustomPainter {
  final List<Offset> nodePositions;
  final Color pathColor;
  final double animationValue;

  WindingPathPainter({
    required this.nodePositions,
    this.animationValue = 1.0,
    this.pathColor = Colors.orange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

    final paint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(nodePositions[0].dx, nodePositions[0].dy);

    for (int i = 0; i < nodePositions.length - 1; i++) {
      final p0 = nodePositions[i];
      final p1 = nodePositions[i + 1];

      final controlPoint1 = Offset(p0.dx, p0.dy + (p1.dy - p0.dy) / 2);
      final controlPoint2 = Offset(p1.dx, p0.dy + (p1.dy - p0.dy) / 2);

      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p1.dx, p1.dy,
      );
    }

    // Animate path drawing
    final pathMetrics = path.computeMetrics();
    final extractPath = Path();
    for (var metric in pathMetrics) {
      extractPath.addPath(
        metric.extractPath(0.0, metric.length * animationValue),
        Offset.zero,
      );
    }

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant WindingPathPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.nodePositions != nodePositions;
  }
}
