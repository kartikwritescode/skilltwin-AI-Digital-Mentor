import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/streak_models.dart';

class StreakWeekProgress extends StatefulWidget {
  final List<DayProgressItem> days;
  final bool isCompact;
  final Color activeGlowColor;
  final IconData currentIcon;

  const StreakWeekProgress({
    super.key,
    required this.days,
    this.isCompact = false,
    this.activeGlowColor = const Color(0xFFFFD54F),
    this.currentIcon = Icons.local_fire_department_rounded,
  });

  @override
  State<StreakWeekProgress> createState() => _StreakWeekProgressState();
}

class _StreakWeekProgressState extends State<StreakWeekProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayDays = widget.days;
    final nodeSize = widget.isCompact ? 18.0 : 28.0;
    final currentNodeSize = widget.isCompact ? 24.0 : 36.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCompact ? 8 : 16,
        vertical: widget.isCompact ? 6 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(widget.isCompact ? 14 : 22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Day Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: displayDays.map((day) {
              final isCurrent = day.status == DayCompletionStatus.current;
              return Expanded(
                child: Center(
                  child: Text(
                    day.label,
                    style: TextStyle(
                      fontSize: widget.isCompact ? 10 : 12,
                      fontWeight:
                          isCurrent ? FontWeight.w800 : FontWeight.w600,
                      color: isCurrent
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: widget.isCompact ? 4 : 8),

          // Nodes connected with horizontal line
          SizedBox(
            height: currentNodeSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Connecting background line
                Positioned(
                  left: 14,
                  right: 14,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Nodes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: displayDays.map((day) {
                    return Expanded(
                      child: Center(
                        child: _buildDayNode(
                          day,
                          nodeSize: nodeSize,
                          currentNodeSize: currentNodeSize,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayNode(
    DayProgressItem day, {
    required double nodeSize,
    required double currentNodeSize,
  }) {
    switch (day.status) {
      case DayCompletionStatus.completed:
        return Container(
          width: nodeSize,
          height: nodeSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.45),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              size: nodeSize * 0.65,
              color: AppTheme.primaryAccent,
            ),
          ),
        );

      case DayCompletionStatus.current:
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: currentNodeSize,
                height: currentNodeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.activeGlowColor,
                      widget.activeGlowColor.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.activeGlowColor.withValues(alpha: 0.7),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.currentIcon,
                    size: currentNodeSize * 0.58,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        );

      case DayCompletionStatus.missed:
        return Container(
          width: nodeSize,
          height: nodeSize,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );

      case DayCompletionStatus.future:
        return Container(
          width: nodeSize,
          height: nodeSize,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
        );
    }
  }
}
