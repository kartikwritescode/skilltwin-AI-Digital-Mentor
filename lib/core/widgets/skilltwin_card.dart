import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// Clean, production-grade Card container.
/// Eliminates heavy AI-generated drop shadows, excessive gradients,
/// and provides subtle surface separation with accessible borders.
class SkillTwinCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final BorderSide? border;
  final double? borderRadius;

  const SkillTwinCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? AppSpacing.cardRadius);

    Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: radius,
        border: Border.fromBorderSide(
          border ?? const BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: content,
    );
  }
}
