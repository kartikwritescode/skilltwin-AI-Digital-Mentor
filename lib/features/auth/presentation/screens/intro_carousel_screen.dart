import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../providers/intro_provider.dart';

/// Data model representing each slide in the introductory carousel.
class _IntroSlide {
  final String assetPath;
  final String fallbackPath;
  final String badge;
  final String headline;
  final String explanation;

  const _IntroSlide({
    required this.assetPath,
    required this.fallbackPath,
    required this.badge,
    required this.headline,
    required this.explanation,
  });
}

/// Friendly SkillTwin introductory carousel presented to new learners before auth.
class IntroCarouselScreen extends ConsumerStatefulWidget {
  const IntroCarouselScreen({super.key});

  @override
  ConsumerState<IntroCarouselScreen> createState() =>
      _IntroCarouselScreenState();
}

class _IntroCarouselScreenState extends ConsumerState<IntroCarouselScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _progressController;

  int _currentPage = 0;
  bool _isInteracting = false;

  static const List<_IntroSlide> _slides = [
    _IntroSlide(
      assetPath: 'assets/mascots/twin_home.webp',
      fallbackPath: 'assets/images/mascot/twin_home.webp',
      badge: 'WELCOME TO SKILLTWIN',
      headline: 'Meet your Learning Twin.',
      explanation:
          'SkillTwin creates a living digital twin of your knowledge, adapting your learning journey dynamically around you.',
    ),
    _IntroSlide(
      assetPath: 'assets/mascots/twin_journey_roadmap.webp',
      fallbackPath: 'assets/images/mascot/twin_journey_roadmap.webp',
      badge: 'ADAPTIVE ROADMAPS',
      headline: 'Your journey changes with you.',
      explanation:
          'Your progress, evidence, and session performance actively influence which concepts and tasks come next.',
    ),
    _IntroSlide(
      assetPath: 'assets/mascots/twin_coding.webp',
      fallbackPath: 'assets/images/mascot/twin_coding.webp',
      badge: 'ACTIVE MASTERY',
      headline: 'Learn it. Practice it. Prove it.',
      explanation:
          'Master core skills through bite-sized focus sessions, spaced revision, and real retrieval challenges.',
    ),
    _IntroSlide(
      assetPath: 'assets/mascots/twin_mentor.webp',
      fallbackPath: 'assets/images/mascot/twin_mentor.webp',
      badge: 'AI COMPANION',
      headline: 'You focus on learning. I\'ll figure out what\'s next.',
      explanation:
          'Get daily recommended tasks, intelligent pace feedback, and proactive mentor guidance every step of the way.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Subtle 4.5s automatic slide progression
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentPage < _slides.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _progressController.reset();
    if (_currentPage < _slides.length - 1 && !_isInteracting) {
      _progressController.forward();
    }
  }

  void _onPointerDown() {
    _isInteracting = true;
    _progressController.stop();
  }

  void _onPointerUp() {
    _isInteracting = false;
    if (_currentPage < _slides.length - 1) {
      _progressController.forward();
    }
  }

  bool _isFinishing = false;

  void _onNextTapped() {
    if (_isFinishing) return;
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishIntro();
    }
  }

  Future<void> _finishIntro() async {
    if (_isFinishing) return;
    _isFinishing = true;
    _progressController.stop();
    await ref.read(introCompletedProvider.notifier).completeIntro();
    if (!mounted) return;
    try {
      context.go('/login');
    } catch (_) {
      // Graceful fallback for test harnesses without GoRouter in ancestry
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkillTwinBackground(
        child: SafeArea(
          child: Listener(
          onPointerDown: (_) => _onPointerDown(),
          onPointerUp: (_) => _onPointerUp(),
          onPointerCancel: (_) => _onPointerUp(),
          child: Column(
            children: [
              // ── Top Header: Segmented Progress Indicator & Skip Action ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space20,
                  vertical: AppTheme.space12,
                ),
                child: Row(
                  children: [
                    // Segmented progress bar
                    Expanded(
                      child: Row(
                        children: List.generate(_slides.length, (index) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index == _slides.length - 1 ? 0 : 6.0,
                              ),
                              child: _buildProgressBar(index),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space16),
                    // Skip button
                    GestureDetector(
                      onTap: _finishIntro,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Carousel Viewport: Mascot, Headline, Explanation ──
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return _buildSlideContent(slide, size);
                  },
                ),
              ),

              // ── Bottom Action Area ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space24,
                  vertical: AppTheme.space16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _onNextTapped,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            _currentPage == _slides.length - 1
                                ? 'Get Started'
                                : 'Next',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  /// Builds a segmented progress bar element
  Widget _buildProgressBar(int index) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        double progress = 0.0;
        if (index < _currentPage) {
          progress = 1.0;
        } else if (index == _currentPage) {
          progress = _progressController.value;
        }

        return Container(
          height: 4.0,
          decoration: BoxDecoration(
            color: AppTheme.primaryAccent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(4.0),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Responsive slide layout preventing any RenderFlex overflows
  Widget _buildSlideContent(_IntroSlide slide, Size screenSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Clamped mascot size adapts dynamically across small and large phones
        final mascotSize =
            (constraints.maxHeight * 0.38).clamp(120.0, 190.0);

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Contextual Tag / Badge ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.18),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    slide.badge,
                    style: const TextStyle(
                      color: AppTheme.primaryAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.space16),

                // ── Twin Mascot in soft ambient halo ──
                Container(
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
                    slide.assetPath,
                    width: mascotSize,
                    height: mascotSize,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        slide.fallbackPath,
                        width: mascotSize,
                        height: mascotSize,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.school_rounded,
                            size: 80,
                            color: AppTheme.primaryAccent,
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppTheme.space24),

                // ── Headline ──
                Text(
                  slide.headline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.4,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: AppTheme.space12),

                // ── Short Explanation ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    slide.explanation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.1,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
