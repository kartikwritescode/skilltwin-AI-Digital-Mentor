import 'package:flutter/material.dart';
import '../../domain/streak_models.dart';

class StreakMascot extends StatefulWidget {
  final StreakTier tier;
  final String? bubbleText;
  final double width;
  final double height;
  final bool showSpeechBubble;

  const StreakMascot({
    super.key,
    required this.tier,
    this.bubbleText,
    this.width = 160,
    this.height = 160,
    this.showSpeechBubble = true,
  });

  @override
  State<StreakMascot> createState() => _StreakMascotState();
}

class _StreakMascotState extends State<StreakMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = StreakTierConfig.forTier(widget.tier);
    final bubble = widget.bubbleText ?? config.bubbleText;

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Soft ambient glow behind mascot
          Container(
            width: widget.width * 0.9,
            height: widget.height * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: config.accentGlow.withValues(alpha: 0.35),
                  blurRadius: 36,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),

          // Speech Bubble (if enabled)
          if (widget.showSpeechBubble && bubble.isNotEmpty)
            Positioned(
              top: -12,
              left: -20,
              child: _SpeechBubble(text: bubble),
            ),

          // Transparent Learning Twin Mascot Illustration
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: Image.asset(
              config.mascotAsset,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackMascot(config);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackMascot(StreakTierConfig config) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.accentGlow.withValues(alpha: 0.4),
            config.gradientColors.first,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              config.streakIcon,
              size: widget.width * 0.4,
              color: Colors.white,
            ),
            const SizedBox(height: 6),
            const Text(
              'TwinBot',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String text;

  const _SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
