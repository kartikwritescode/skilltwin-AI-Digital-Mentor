import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_background.dart';

/// Minimal, mascot-driven splash screen establishing SkillTwin's visual identity.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _mascotFade;
  late final Animation<double> _mascotScale;
  late final Animation<double> _brandFade;
  late final Animation<Offset> _brandSlide;
  Timer? _transitionTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SkillTwinBackground.precache(context);
      }
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // 1. Mascot fades & smoothly scales in first
    _mascotFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );

    _mascotScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Branding (Title + Tagline) slides up & fades in sequentially
    _brandFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.32, 0.85, curve: Curves.easeOut),
    );

    _brandSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // Start subtle entrance sequence, then transition cleanly
    _controller.forward().then((_) {
      if (!mounted) return;
      _transitionTimer = Timer(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        ref.read(splashCompleteProvider.notifier).state = true;
      });
    });
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Responsive mascot sizing tailored for all mobile viewport widths
    final mascotSize = (size.width * 0.42).clamp(130.0, 180.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkillTwinBackground(
        child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── 1. Mascot with subtle ambient halo ──
                FadeTransition(
                  opacity: _mascotFade,
                  child: ScaleTransition(
                    scale: _mascotScale,
                    child: Container(
                      width: mascotSize + 28,
                      height: mascotSize + 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryAccent.withValues(alpha: 0.10),
                            AppTheme.primaryAccent.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                      child: Image.asset(
                        'assets/mascots/twin_home.webp',
                        width: mascotSize,
                        height: mascotSize,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/mascot/twin_home.webp',
                            width: mascotSize,
                            height: mascotSize,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.psychology_alt_rounded,
                                size: 80,
                                color: AppTheme.primaryAccent,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.space24),

                // ── 2. Branding (SkillTwin + Tagline) ──
                FadeTransition(
                  opacity: _brandFade,
                  child: SlideTransition(
                    position: _brandSlide,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SkillTwin',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: AppTheme.space8),
                        Text(
                          'Your learning. Evolved.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
