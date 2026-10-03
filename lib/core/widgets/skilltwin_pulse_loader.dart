import 'package:flutter/material.dart';
import 'skilltwin_loading_view.dart';

/// Backwards-compatible loader facade delegating to the unified [SkillTwinLoadingView].
class SkillTwinPulseLoader extends StatelessWidget {
  final String? message;
  final double size;
  final bool showQuotes;

  const SkillTwinPulseLoader({
    super.key,
    this.message,
    this.size = 90.0,
    this.showQuotes = true,
  });

  const SkillTwinPulseLoader.compact({
    super.key,
    this.message,
    this.size = 50.0,
    this.showQuotes = false,
  });

  const SkillTwinPulseLoader.fullScreen({
    super.key,
    this.message,
    this.size = 110.0,
    this.showQuotes = true,
  });

  @override
  Widget build(BuildContext context) {
    return SkillTwinLoadingView(
      message: message,
      mascotSize: size,
      cycleMessages: showQuotes && message == null,
    );
  }
}
