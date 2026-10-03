import 'package:flutter/material.dart';
import '../providers/teach_mode_provider.dart';

/// Clean, high-visibility status badge communicating the current stage:
/// READY, RECORDING, PROCESSING, EVALUATING, RESULT, or TOPIC COMPLETE.
class TeachStateBadge extends StatelessWidget {
  final TeachModeStatus status;

  const TeachStateBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _badgeConfig(status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.borderColor, width: 1.2),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, size: 13, color: config.textColor),
            const SizedBox(width: 6),
            Text(
              config.label,
              style: TextStyle(
                color: config.textColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _BadgeStyle _badgeConfig(TeachModeStatus status) {
    switch (status) {
      case TeachModeStatus.ready:
        return const _BadgeStyle(
          label: 'READY',
          icon: Icons.mic_none_rounded,
          backgroundColor: Color(0x226366F1),
          borderColor: Color(0x446366F1),
          textColor: Color(0xFF818CF8),
        );
      case TeachModeStatus.recording:
        return const _BadgeStyle(
          label: 'RECORDING',
          icon: Icons.fiber_manual_record_rounded,
          backgroundColor: Color(0x33EF4444),
          borderColor: Color(0x66EF4444),
          textColor: Color(0xFFF87171),
        );
      case TeachModeStatus.processing:
        return const _BadgeStyle(
          label: 'PROCESSING',
          icon: Icons.hourglass_top_rounded,
          backgroundColor: Color(0x33F59E0B),
          borderColor: Color(0x66F59E0B),
          textColor: Color(0xFFFBBF24),
        );
      case TeachModeStatus.evaluating:
        return const _BadgeStyle(
          label: 'EVALUATING',
          icon: Icons.psychology_rounded,
          backgroundColor: Color(0x338B5CF6),
          borderColor: Color(0x668B5CF6),
          textColor: Color(0xFFA78BFA),
        );
      case TeachModeStatus.result:
        return const _BadgeStyle(
          label: 'EVALUATION RESULT',
          icon: Icons.insights_rounded,
          backgroundColor: Color(0x333B82F6),
          borderColor: Color(0x663B82F6),
          textColor: Color(0xFF60A5FA),
        );
      case TeachModeStatus.completed:
        return const _BadgeStyle(
          label: 'TOPIC COMPLETE ✓',
          icon: Icons.check_circle_rounded,
          backgroundColor: Color(0x3310B981),
          borderColor: Color(0x6610B981),
          textColor: Color(0xFF34D399),
        );
    }
  }
}

class _BadgeStyle {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _BadgeStyle({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}
