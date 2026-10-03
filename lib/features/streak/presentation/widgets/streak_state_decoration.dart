import 'package:flutter/material.dart';
import '../../domain/streak_models.dart';

class StreakStateDecoration extends StatelessWidget {
  final StreakTier tier;

  const StreakStateDecoration({
    super.key,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _AtmosphericDecorationPainter(tier: tier),
        size: Size.infinite,
      ),
    );
  }
}

class _AtmosphericDecorationPainter extends CustomPainter {
  final StreakTier tier;

  _AtmosphericDecorationPainter({required this.tier});

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);

    // Ambient radial glow in top-right or center-right
    if (tier == StreakTier.active) {
      glowPaint.color = const Color(0xFFFFD54F).withValues(alpha: 0.18);
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.4), 90, glowPaint);
    } else if (tier == StreakTier.shortStreak) {
      glowPaint.color = const Color(0xFF00E5FF).withValues(alpha: 0.15);
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.35), 85, glowPaint);
    } else if (tier == StreakTier.zero) {
      glowPaint.color = const Color(0xFFB388FF).withValues(alpha: 0.15);
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.4), 85, glowPaint);
    } else {
      // Legendary
      glowPaint.color = const Color(0xFFFFD700).withValues(alpha: 0.22);
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.35), 100, glowPaint);
    }

    // Sparkles / Learning stars
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.45);
    final yellowStarPaint = Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.6);

    _drawSparkle(canvas, Offset(size.width * 0.28, size.height * 0.18), 3.5, starPaint);
    _drawSparkle(canvas, Offset(size.width * 0.52, size.height * 0.12), 4.5, yellowStarPaint);
    _drawSparkle(canvas, Offset(size.width * 0.88, size.height * 0.15), 3.0, starPaint);
    _drawSparkle(canvas, Offset(size.width * 0.48, size.height * 0.78), 2.5, starPaint);

    if (tier == StreakTier.legendary) {
      // Extra festive golden achievement particles
      _drawSparkle(canvas, Offset(size.width * 0.15, size.height * 0.65), 5.0, yellowStarPaint);
      _drawSparkle(canvas, Offset(size.width * 0.65, size.height * 0.22), 4.0, yellowStarPaint);
      _drawSparkle(canvas, Offset(size.width * 0.92, size.height * 0.6), 3.5, yellowStarPaint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    // Draw 4-point sparkle star
    final path = Path();
    path.moveTo(center.dx, center.dy - radius * 1.8);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + radius * 1.8, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius * 1.8);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - radius * 1.8, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius * 1.8);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AtmosphericDecorationPainter oldDelegate) {
    return oldDelegate.tier != tier;
  }
}
