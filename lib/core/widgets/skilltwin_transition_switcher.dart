import 'package:flutter/material.dart';

/// Reusable content transition switcher for SkillTwin.
///
/// Ensures that when async content finishes loading, the loader does not
/// abruptly pop into the content. Instead, it transitions gracefully:
///
/// loader → subtle fade & micro-slide → content
///
/// Standard duration: 300ms (within the 250-400ms range).
class SkillTwinTransitionSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration reverseDuration;
  final Curve inCurve;
  final Curve outCurve;

  const SkillTwinTransitionSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 240),
    this.inCurve = Curves.easeOutCubic,
    this.outCurve = Curves.easeInCubic,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      reverseDuration: reverseDuration,
      switchInCurve: inCurve,
      switchOutCurve: outCurve,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.025),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: inCurve,
          reverseCurve: outCurve,
        ));

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: inCurve,
          reverseCurve: outCurve,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
