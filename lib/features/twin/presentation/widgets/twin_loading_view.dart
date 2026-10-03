import 'package:flutter/material.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';

/// Meaningful loading state widget for the Twin screen delegating to [SkillTwinLoadingView].
class TwinLoadingView extends StatelessWidget {
  const TwinLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkillTwinLoadingView(
      message: 'SkillTwin is preparing your next step.',
      subMessage: 'Synchronizing verified memory traces & cognitive synapses...',
    );
  }
}
