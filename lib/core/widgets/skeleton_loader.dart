import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
    this.margin,
  });

  const SkeletonLoader.card({
    super.key,
    this.width = double.infinity,
    this.height = 140.0,
    this.borderRadius = 16.0,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
  });

  const SkeletonLoader.line({
    super.key,
    this.width = double.infinity,
    this.height = 16.0,
    this.borderRadius = 6.0,
    this.margin = const EdgeInsets.symmetric(vertical: 4.0),
  });

  const SkeletonLoader.circle({
    super.key,
    double size = 44.0,
    this.margin,
  })  : width = size,
        height = size,
        borderRadius = size / 2;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: _animation.value * 0.25),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class SkeletonCardGroup extends StatelessWidget {
  final int count;
  final double height;

  const SkeletonCardGroup({
    super.key,
    this.count = 3,
    this.height = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int effectiveCount = count;
        if (constraints.maxHeight.isFinite && constraints.maxHeight > 0) {
          final computed = (constraints.maxHeight / (height + 12.0)).floor();
          effectiveCount = computed > 0 ? computed : 1;
        }
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              effectiveCount,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SkeletonLoader.card(height: height),
              ),
            ),
          ),
        );
      },
    );
  }
}
