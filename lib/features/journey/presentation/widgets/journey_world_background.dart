import 'package:flutter/material.dart';
import 'journey_theme_models.dart';

/// Layered environmental world background for the Learning Journey.
/// Dynamically layers soft celestial lavender/blue gradients, dreamy atmospheric blobs,
/// subtle landscape texture, and regional ambient lighting without competing with the roadmap.
class JourneyWorldBackground extends StatelessWidget {
  final double contentHeight;
  final double viewportWidth;
  final List<RoadmapModuleItem> modules;

  const JourneyWorldBackground({
    super.key,
    required this.contentHeight,
    required this.viewportWidth,
    this.modules = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Soft Celestial Lavender/Blue Base Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.30, 0.65, 1.0],
                colors: [
                  Color(0xFFF6F8FE), // Soothing celestial white-blue
                  Color(0xFFEEF3FC), // Periwinkle morning light
                  Color(0xFFF5F3FF), // Soft lavender trail
                  Color(0xFFF1F7FD), // Clear mountain blue
                ],
              ),
            ),
          ),

          // Layer 2: Seamless vertically repeating gamified pathway world artwork
          // Faded to ensure text readability across the roadmap
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                'assets/images/journey/journey_bg.webp',
                repeat: ImageRepeat.repeatY,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          // Layer 2.5: Full-screen white wash to further mute background noise
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.white.withValues(alpha: 0.30),
              ),
            ),
          ),

          // Layer 3: Soft Atmospheric Floating Blobs (Deep Indigo, Violet, Periwinkle, Mint, Rose)
          CustomPaint(
            size: Size(viewportWidth, contentHeight),
            painter: _AtmosphericBlobsPainter(),
          ),



          // Layer 4: Regional Ambient Color Lighting for Modules
          if (modules.isNotEmpty)
            ...List.generate(modules.length, (index) {
              final module = modules[index];
              final double regionTop = (index / modules.length) * contentHeight;
              final double regionHeight = contentHeight / modules.length;

              return Positioned(
                top: regionTop,
                left: 0,
                right: 0,
                height: regionHeight,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(
                          module.isCardOnLeft ? 0.35 : -0.35,
                          0.0,
                        ),
                        radius: 1.2,
                        colors: [
                          module.theme.glowColor.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

          // Layer 5: Top and Bottom Seamless Blending Vignettes
          // Strong top fade ensures text in the frosted header bar stays readable
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.45, 0.75, 1.0],
                    colors: [
                      Color(0xF0F6F8FE), // Near-opaque match to base gradient top
                      Color(0xC0F6F8FE), // Softer mid transition
                      Color(0x60F6F8FE), // Gentle tail
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Blends softly behind the floating bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 140,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xCCFFFFFF),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints subtle atmospheric ambient light blobs across the journey scroll depth.
class _AtmosphericBlobsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Top Indigo-Violet Glow
    final indigoPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF5B5FEF).withValues(alpha: 0.07),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.12),
        radius: 180,
      ));
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.12), 180, indigoPaint);

    // 2. Mid Periwinkle Glow
    final periwinklePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.15, size.height * 0.35),
        radius: 200,
      ));
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.35), 200, periwinklePaint);

    // 3. Lavender Crystal Glow
    final lavenderPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B5CF6).withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.80, size.height * 0.60),
        radius: 220,
      ));
    canvas.drawCircle(Offset(size.width * 0.80, size.height * 0.60), 220, lavenderPaint);

    // 4. Emerald Base Glow
    final mintPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF10B981).withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.20, size.height * 0.82),
        radius: 200,
      ));
    canvas.drawCircle(Offset(size.width * 0.20, size.height * 0.82), 200, mintPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fallback procedural painter for tests or offline environments.
class _ProceduralWorldPainter extends CustomPainter {
  final List<RoadmapModuleItem> modules;

  _ProceduralWorldPainter({required this.modules});

  @override
  void paint(Canvas canvas, Size size) {
    final double islandWidth = size.width * 0.78;
    final int count = modules.isNotEmpty ? modules.length : 5;
    final double segH = size.height / count;

    for (int i = 0; i < count; i++) {
      final theme = ModuleRegionTheme.forIndex(i);
      final double topY = i * segH;
      final double midY = topY + segH * 0.5;
      final double biasX = (i % 2 == 0) ? size.width * 0.52 : size.width * 0.48;

      final islandPath = Path();
      islandPath.moveTo(biasX - islandWidth * 0.45, midY - 50);
      islandPath.quadraticBezierTo(
        biasX, midY - 80,
        biasX + islandWidth * 0.45, midY - 50,
      );
      islandPath.quadraticBezierTo(
        biasX + islandWidth * 0.5, midY + 30,
        biasX, midY + 70,
      );
      islandPath.quadraticBezierTo(
        biasX - islandWidth * 0.5, midY + 30,
        biasX - islandWidth * 0.45, midY - 50,
      );
      islandPath.close();

      final islandPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.surfaceTint.withValues(alpha: 0.5),
            theme.borderColor.withValues(alpha: 0.2),
          ],
        ).createShader(Rect.fromLTWH(0, topY, size.width, segH));

      canvas.drawPath(islandPath, islandPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProceduralWorldPainter oldDelegate) =>
      oldDelegate.modules != modules;
}
