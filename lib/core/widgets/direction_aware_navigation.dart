import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tracks the active bottom navigation tab index and transition direction.
class TabNavigationTracker {
  static int _previousIndex = 0;
  static int _currentIndex = 0;

  static int get previousIndex => _previousIndex;
  static int get currentIndex => _currentIndex;
  static bool get isForward => _currentIndex >= _previousIndex;

  static void updateIndex(int newIndex) {
    if (newIndex != _currentIndex) {
      _previousIndex = _currentIndex;
      _currentIndex = newIndex;
    }
  }

  static void reset() {
    _previousIndex = 0;
    _currentIndex = 0;
  }
}

/// Builds a modern, silky direction-aware GoRouter page transition for bottom navigation tabs.
/// Uses a subtle directional micro-drift (15-20px) and a smooth crossfade instead of a full-screen page flip.
/// When moving to an upfront tab (e.g. Journey -> Twin), gently drifts in from the RIGHT.
/// When moving to a preceding tab (e.g. Twin -> Journey), gently drifts in from the LEFT.
Page<dynamic> buildDirectionalTransitionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  required int targetIndex,
}) {
  // Determine if moving forward based on target vs previous index
  final bool isForward = targetIndex >= TabNavigationTracker.previousIndex;
  TabNavigationTracker.updateIndex(targetIndex);

  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      // Subtle directional micro-drift (~16-20px) — avoids looking like turning book pages
      final inOffset = isForward
          ? const Offset(0.04, 0.0) // Subtle micro-drift from right
          : const Offset(-0.04, 0.0); // Subtle micro-drift from left

      final slideAnimation = Tween<Offset>(
        begin: inOffset,
        end: Offset.zero,
      ).animate(curve);

      final fadeIn = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(curve);

      final outFade = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInQuad,
      ));

      return FadeTransition(
        opacity: outFade,
        child: SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeIn,
            child: child,
          ),
        ),
      );
    },
  );
}

/// Standalone wrapper widget for directional sliding when not using GoRouter pageBuilder.
class DirectionAwareNavigation extends StatefulWidget {
  final int currentIndex;
  final Widget child;

  const DirectionAwareNavigation({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  @override
  State<DirectionAwareNavigation> createState() =>
      _DirectionAwareNavigationState();
}

class _DirectionAwareNavigationState extends State<DirectionAwareNavigation> {
  int _previousIndex = 0;

  @override
  void didUpdateWidget(covariant DirectionAwareNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isForward = widget.currentIndex >= _previousIndex;

    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          final isIncoming =
              (child.key as ValueKey<int>?)?.value == widget.currentIndex;

          // Micro-drift instead of sweeping book flip
          final Offset beginOffset;
          if (isIncoming) {
            beginOffset = isForward
                ? const Offset(0.04, 0.0)
                : const Offset(-0.04, 0.0);
          } else {
            beginOffset = isForward
                ? const Offset(-0.04, 0.0)
                : const Offset(0.04, 0.0);
          }

          final slideAnimation = Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));

          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(widget.currentIndex),
          child: widget.child,
        ),
      ),
    );
  }
}
