import 'package:flutter/material.dart';

/// Wraps bottom navigation views with a direction-aware subtle slide & fade transition.
/// Forward navigation (e.g. index 0 -> 1) slides from the right.
/// Backward navigation (e.g. index 1 -> 0) slides from the left.
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

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slideAnimation = Tween<Offset>(
          begin: isForward
              ? const Offset(0.06, 0.0)
              : const Offset(-0.06, 0.0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(widget.currentIndex),
        child: widget.child,
      ),
    );
  }
}
