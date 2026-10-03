import 'package:flutter/material.dart';
import '../../../../core/widgets/skilltwin_twin.dart';

/// Animated travel companion mascot perched near the learner's active milestone node.
/// Displays the genuine SkillTwin companion with contextual expression and encouraging speech bubble.
class JourneyMascot extends StatelessWidget {
  final String speechBubbleText;
  final double size;
  final VoidCallback? onTap;
  final TwinAsset asset;

  const JourneyMascot({
    super.key,
    this.speechBubbleText = "Let's master this! 🚀",
    this.size = 64.0,
    this.onTap,
    this.asset = TwinAsset.focused,
  });

  @override
  Widget build(BuildContext context) {
    return SkillTwinTwin(
      asset: asset,
      size: size,
      speechBubble: speechBubbleText.isNotEmpty ? speechBubbleText : null,
      onTap: onTap,
      bounce: true,
    );
  }
}
