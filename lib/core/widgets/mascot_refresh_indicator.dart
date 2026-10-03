import 'package:flutter/material.dart';
import 'skilltwin_refresh_indicator.dart';

/// Legacy alias for [SkillTwinRefreshIndicator].
/// Unifies all pull-to-refresh behavior with the SkillTwin mascot and flowing wave.
class MascotRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final double displacement;
  final double edgeOffset;
  final String? refreshMessage;

  const MascotRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.displacement = 50.0,
    this.edgeOffset = 0.0,
    this.refreshMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SkillTwinRefreshIndicator(
      onRefresh: onRefresh,
      message: refreshMessage,
      edgeOffset: edgeOffset,
      child: child,
    );
  }
}
