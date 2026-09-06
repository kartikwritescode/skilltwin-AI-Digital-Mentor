import 'package:flutter/material.dart';
import '../../../../core/models/journey_node.dart';

class RoadmapNodeWidget extends StatelessWidget {
  final JourneyNode node;
  final VoidCallback onTap;
  final bool isHighlighted;

  const RoadmapNodeWidget({
    super.key,
    required this.node,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color nodeColor;
    Widget icon;
    double elevation = 0;
    
    switch (node.status) {
      case NodeStatus.completed:
        nodeColor = Colors.orange;
        icon = const Icon(Icons.check, color: Colors.white, size: 20);
        break;
      case NodeStatus.current:
        nodeColor = Colors.orange;
        icon = const Icon(Icons.play_arrow, color: Colors.white, size: 24);
        elevation = 8;
        break;
      case NodeStatus.needsAttention:
        nodeColor = Colors.orangeAccent;
        icon = const Icon(Icons.priority_high, color: Colors.white, size: 20);
        break;
      case NodeStatus.upcoming:
        nodeColor = Colors.white;
        icon = Icon(Icons.circle, color: Colors.orange.withOpacity(0.3), size: 12);
        break;
      case NodeStatus.locked:
        nodeColor = Colors.grey.shade200;
        icon = Icon(Icons.lock, color: Colors.grey.shade400, size: 16);
        break;
      case NodeStatus.skipped:
        nodeColor = Colors.grey.shade100;
        icon = Icon(Icons.redo, color: Colors.grey.shade300, size: 16);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseWrapper(
            active: node.status == NodeStatus.current,
            child: Material(
              elevation: elevation,
              shadowColor: Colors.orange.withOpacity(0.4),
              shape: const CircleBorder(),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: node.status == NodeStatus.upcoming || node.status == NodeStatus.locked
                        ? Colors.grey.shade300
                        : Colors.orange,
                    width: 3,
                  ),
                ),
                child: Center(child: icon),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            node.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: node.status == NodeStatus.locked ? Colors.grey : Colors.black87,
            ),
          ),
          if (node.subtitle != null)
            Text(
              node.subtitle!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}

class _PulseWrapper extends StatefulWidget {
  final Widget child;
  final bool active;

  const _PulseWrapper({required this.child, required this.active});

  @override
  State<_PulseWrapper> createState() => _PulseWrapperState();
}

class _PulseWrapperState extends State<_PulseWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulseWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4 * (1 - _controller.value)),
                blurRadius: 20 * _controller.value,
                spreadRadius: 10 * _controller.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
