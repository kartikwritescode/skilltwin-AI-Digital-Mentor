import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A sleek, futuristic AI loading animation featuring expanding glowing pulse rings,
/// an oscillating mentor core, and dynamically cycling cognitive status messages.
class SkillTwinPulseLoader extends StatefulWidget {
  final String? message;
  final double size;
  final bool showQuotes;

  const SkillTwinPulseLoader({
    super.key,
    this.message,
    this.size = 90.0,
    this.showQuotes = true,
  });

  const SkillTwinPulseLoader.compact({
    super.key,
    this.message,
    this.size = 50.0,
    this.showQuotes = false,
  });

  const SkillTwinPulseLoader.fullScreen({
    super.key,
    this.message,
    this.size = 110.0,
    this.showQuotes = true,
  });

  @override
  State<SkillTwinPulseLoader> createState() => _SkillTwinPulseLoaderState();
}

class _SkillTwinPulseLoaderState extends State<SkillTwinPulseLoader>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _textController;

  static const List<String> _cognitiveMessages = [
    "Synthesizing deep concepts...",
    "Calibrating your neural path...",
    "Aligning deliberate practice...",
    "Generating mental models...",
    "Connecting with cognitive twin...",
  ];

  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            setState(() {
              _messageIndex = (_messageIndex + 1) % _cognitiveMessages.length;
            });
            _textController.forward(from: 0.0);
          }
        }
      });
    _textController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeMessage = widget.message ?? _cognitiveMessages[_messageIndex];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size * 1.6,
            height: widget.size * 1.6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Concentric Pulse Rings
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _PulseRingsPainter(
                        progress: _pulseController.value,
                        baseColor: const Color(0xFFFF6D00),
                      ),
                      size: Size(widget.size * 1.6, widget.size * 1.6),
                    );
                  },
                ),

                // Rotating Orbit Particles
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateController.value * 2 * math.pi,
                      child: Container(
                        width: widget.size * 1.1,
                        height: widget.size * 1.1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFF6D00).withValues(alpha: 0.25),
                            width: 1.5,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFF9100),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFF6D00),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Glowing AI Core Orb
                Container(
                  width: widget.size * 0.65,
                  height: widget.size * 0.65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6D00), Color(0xFFFF9100), Color(0xFFFFAB40)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6D00).withValues(alpha: 0.4),
                        blurRadius: 18,
                        spreadRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: widget.size * 0.32,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (widget.showQuotes) ...[
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                activeMessage,
                key: ValueKey<String>(activeMessage),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "SkillTwin AI Active",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFF6D00).withValues(alpha: 0.8),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PulseRingsPainter extends CustomPainter {
  final double progress;
  final Color baseColor;

  _PulseRingsPainter({required this.progress, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i / 3.0)) % 1.0;
      final radius = maxRadius * (0.35 + 0.65 * ringProgress);
      final alpha = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.35;

      final paint = Paint()
        ..color = baseColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * (1.0 - ringProgress * 0.5);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulseRingsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
