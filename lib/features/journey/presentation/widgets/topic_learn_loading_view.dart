import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';

/// Topic learn loading state widget delegating to [SkillTwinLoadingView]
/// with 150ms anti-flicker delay.
class TopicLearnLoadingView extends StatefulWidget {
  final String? message;
  final String? subMessage;

  const TopicLearnLoadingView({
    super.key,
    this.message,
    this.subMessage,
  });

  @override
  State<TopicLearnLoadingView> createState() => _TopicLearnLoadingViewState();
}

class _TopicLearnLoadingViewState extends State<TopicLearnLoadingView> {
  bool _showContent = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showContent) {
      return const SizedBox.shrink();
    }
    return SkillTwinLoadingView(
      message: widget.message ?? 'Synthesizing your concept guide...',
      subMessage: widget.subMessage ??
          'Your Twin is organizing intuition, examples, and key rules.',
    );
  }
}
