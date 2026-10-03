import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_theme.dart';
import 'skilltwin_twin.dart';

// ============================================================================
// 1. SkillTwinText
// ============================================================================

/// Semantic typography component that enforces the design system's
/// font sizes, weights, line heights, and WCAG-friendly contrast.
class SkillTwinText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;

  const SkillTwinText(
    this.text, {
    super.key,
    this.style = AppTypography.body,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  });

  const SkillTwinText.display(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  }) : style = AppTypography.display;

  const SkillTwinText.headline(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  }) : style = AppTypography.headline;

  const SkillTwinText.headlineSmall(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  }) : style = AppTypography.headlineSmall;

  const SkillTwinText.body(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  }) : style = AppTypography.body;

  const SkillTwinText.bodyMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  }) : style = AppTypography.bodyMedium;

  const SkillTwinText.supporting(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  }) : style = AppTypography.supporting;

  const SkillTwinText.label(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  }) : style = AppTypography.label;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = color != null ? style.copyWith(color: color) : style;
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: effectiveStyle,
    );
  }
}

// ============================================================================
// 2. SkillTwinHeading
// ============================================================================

/// Consistent section or screen header with title, optional subtitle,
/// optional action (e.g. 'View all'), and optional status badge.
class SkillTwinHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final EdgeInsetsGeometry padding;
  final bool isLarge;

  const SkillTwinHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: isLarge ? AppTypography.headline : AppTypography.headlineSmall,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.supporting,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ============================================================================
// 3. SkillTwinBody
// ============================================================================

/// Mobile-optimized body paragraph widget with comfortable line height
/// and automatic high-readability text styling.
class SkillTwinBody extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool isMuted;

  const SkillTwinBody(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: AppTypography.body.copyWith(
        color: color ?? (isMuted ? AppColors.mutedText : AppColors.textSecondary),
      ),
    );
  }
}

// ============================================================================
// 4. SkillTwinButton
// ============================================================================

enum SkillTwinButtonVariant { primary, secondary, outline, ghost }

/// Accessible, responsive button supporting primary, secondary, outline,
/// and ghost variants with integrated loading and haptic response.
class SkillTwinButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final SkillTwinButtonVariant variant;
  final Color? customColor;

  const SkillTwinButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 48.0,
    this.variant = SkillTwinButtonVariant.primary,
    this.customColor,
  });

  const SkillTwinButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 48.0,
    this.customColor,
  }) : variant = SkillTwinButtonVariant.secondary;

  const SkillTwinButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 48.0,
    this.customColor,
  }) : variant = SkillTwinButtonVariant.outline;

  const SkillTwinButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 40.0,
    this.customColor,
  }) : variant = SkillTwinButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    Color bg;
    Color fg;
    BorderSide side = BorderSide.none;

    switch (variant) {
      case SkillTwinButtonVariant.primary:
        bg = customColor ?? AppColors.primary;
        fg = Colors.white;
        break;
      case SkillTwinButtonVariant.secondary:
        bg = customColor ?? AppColors.secondary;
        fg = Colors.white;
        break;
      case SkillTwinButtonVariant.outline:
        bg = Colors.transparent;
        fg = customColor ?? AppColors.textPrimary;
        side = const BorderSide(color: AppColors.border, width: 1.2);
        break;
      case SkillTwinButtonVariant.ghost:
        bg = Colors.transparent;
        fg = customColor ?? AppColors.secondary;
        break;
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            label,
            style: AppTypography.button.copyWith(color: fg),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      disabledBackgroundColor: bg.withValues(alpha: 0.5),
      disabledForegroundColor: fg.withValues(alpha: 0.6),
      elevation: 0,
      side: side,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    );

    Widget button = SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                HapticFeedback.lightImpact();
                onPressed?.call();
              }
            : null,
        style: buttonStyle,
        child: content,
      ),
    );

    return button;
  }
}

// ============================================================================
// 5. SkillTwinTextField
// ============================================================================

/// Clean, production-grade text field with consistent padding, borders,
/// and error handling. Avoids visual clutter and awkward borders.
class SkillTwinTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;
  final int maxLines;
  final bool enabled;

  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final TextCapitalization textCapitalization;

  const SkillTwinTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.maxLines = 1,
    this.enabled = true,
    this.textInputAction,
    this.onFieldSubmitted,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.label.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          focusNode: focusNode,
          autofocus: autofocus,
          maxLines: maxLines,
          enabled: enabled,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.surfaceSubtle,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 6. SkillTwinSection
// ============================================================================

/// Replaces generic card-in-card patterns with clean whitespace,
/// semantic grouping, and consistent vertical rhythm.
class SkillTwinSection extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final bool showDivider;

  const SkillTwinSection({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.lg),
    this.padding = EdgeInsets.zero,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            SkillTwinHeading(
              title: title!,
              subtitle: subtitle,
              trailing: trailing,
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            ),
          ],
          child,
          if (showDivider) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.border, height: 1),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// 7. SkillTwinMascot
// ============================================================================

/// Responsive, naturally-breathing mascot placement.
/// Never traps the mascot in an artificial box or rounded rectangle container
/// unless specifically asked, and guarantees healthy breathing room.
class SkillTwinMascot extends StatelessWidget {
  final TwinAsset asset;
  final double size;
  final String? speechBubble;
  final bool isSpeechOnLeft;
  final VoidCallback? onTap;
  final bool floatAnimation;
  final bool bounce;

  const SkillTwinMascot({
    super.key,
    this.asset = TwinAsset.home,
    this.size = 80.0,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.floatAnimation = true,
    this.bounce = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Scale mascot gracefully on narrow screens (<360dp)
    final effectiveSize = screenWidth < 360 ? size * 0.85 : size;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: SkillTwinTwin(
        asset: asset,
        size: effectiveSize,
        speechBubble: speechBubble,
        isSpeechOnLeft: isSpeechOnLeft,
        onTap: onTap,
        floatAnimation: floatAnimation,
        bounce: bounce,
      ),
    );
  }
}

// ============================================================================
// 8. SkillTwinLoader
// ============================================================================

/// Calm, educational loading view with the SkillTwin mascot and cycling
/// supportive progress messaging. Does not trap the mascot in a box.
class SkillTwinLoader extends StatefulWidget {
  final String? message;
  final double size;
  final bool isFullScreen;

  const SkillTwinLoader({
    super.key,
    this.message,
    this.size = 80.0,
    this.isFullScreen = false,
  });

  const SkillTwinLoader.fullScreen({
    super.key,
    this.message,
    this.size = 100.0,
  }) : isFullScreen = true;

  @override
  State<SkillTwinLoader> createState() => _SkillTwinLoaderState();
}

class _SkillTwinLoaderState extends State<SkillTwinLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _textController;
  int _messageIndex = 0;

  static const List<String> _friendlyStatusMessages = [
    "Preparing your learning session...",
    "Connecting with your companion...",
    "Organizing your concept map...",
    "Calibrating personalized practice...",
  ];

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            _messageIndex = (_messageIndex + 1) % _friendlyStatusMessages.length;
          });
          _textController.forward(from: 0.0);
        }
      });
    _textController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeMessage = widget.message ?? _friendlyStatusMessages[_messageIndex];

    Widget content = Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/mascots/skilltwin_mascot_loading.gif',
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => SizedBox(
                width: widget.size * 0.5,
                height: widget.size * 0.5,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                activeMessage,
                key: ValueKey<String>(activeMessage),
                textAlign: TextAlign.center,
                style: AppTypography.supporting.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.isFullScreen) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: content),
      );
    }

    return content;
  }
}

// ============================================================================
// 9. SkillTwinEmptyState
// ============================================================================

/// Friendly, modern empty state view with integrated mascot, clear headline,
/// concise supporting explanation, and optional action button.
class SkillTwinEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final TwinAsset mascotAsset;

  const SkillTwinEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.mascotAsset = TwinAsset.empty,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SkillTwinMascot(
              asset: mascotAsset,
              size: 96.0,
              floatAnimation: true,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SkillTwinButton(
                label: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
