import 'package:flutter/material.dart';
import '../../../../core/widgets/skilltwin_background.dart';

/// Calm, soothing SkillTwin background for authentication screens.
/// Wraps the screen content in the global [SkillTwinBackground].
class SkillTwinAuthBackground extends StatelessWidget {
  final Widget child;

  const SkillTwinAuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SkillTwinBackground(
      child: child,
    );
  }
}
