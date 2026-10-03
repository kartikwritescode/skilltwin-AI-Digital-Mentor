import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Builds SkillTwin's optimized page transitions with instant content rendering.
///
/// Behavior:
/// - New screen slides in from RIGHT with NO fade (instant content visibility)
/// - Current screen moves slightly LEFT with subtle fade
/// - Duration: 250ms (faster, snappier feel)
/// - Content renders immediately, no delayed text/widget appearance
/// - Respects Android system back gestures and iOS edge swipes
Widget buildSkillTwinPageTransitions<T>({
  required Animation<double> animation,
  required Animation<double> secondaryAnimation,
  required Widget child,
}) {
  // New incoming screen (slides in from right - NO FADE for instant content)
  final primarySlide = Tween<Offset>(
    begin: const Offset(1.0, 0.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  ));

  // Current screen being pushed underneath (moves slightly left with subtle dimming)
  final secondarySlide = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-0.20, 0.0),
  ).animate(CurvedAnimation(
    parent: secondaryAnimation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  ));

  final secondaryFade = Tween<double>(
    begin: 1.0,
    end: 0.90,
  ).animate(CurvedAnimation(
    parent: secondaryAnimation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  ));

  return SlideTransition(
    position: secondarySlide,
    child: FadeTransition(
      opacity: secondaryFade,
      child: SlideTransition(
        position: primarySlide,
        child: child, // NO FADE - content appears instantly
      ),
    ),
  );
}

/// Custom [PageTransitionsBuilder] for [ThemeData.pageTransitionsTheme].
/// Ensures standard Navigator.push and Flutter route transitions inherit
/// the cohesive carousel sliding behavior across all platforms.
class SkillTwinCarouselPageTransitionsBuilder extends PageTransitionsBuilder {
  const SkillTwinCarouselPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return buildSkillTwinPageTransitions<T>(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Reusable GoRouter [CustomTransitionPage] factory using the 250ms optimized slide transition.
CustomTransitionPage<T> skillTwinTransitionPage<T>({
  required LocalKey key,
  required Widget child,
  String? name,
  Object? arguments,
  String? restorationId,
}) {
  return CustomTransitionPage<T>(
    key: key,
    name: name,
    arguments: arguments,
    restorationId: restorationId,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return buildSkillTwinPageTransitions<T>(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );
    },
    child: child,
  );
}
