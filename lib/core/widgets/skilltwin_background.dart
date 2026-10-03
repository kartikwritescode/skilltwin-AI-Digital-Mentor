import 'package:flutter/material.dart';

/// Scope marker to detect and prevent duplicate wallpaper layers in nested trees.
class _SkillTwinBackgroundScope extends InheritedWidget {
  const _SkillTwinBackgroundScope({required super.child});

  @override
  bool updateShouldNotify(_SkillTwinBackgroundScope oldWidget) => false;
}

/// Global, reusable SkillTwin background widget.
///
/// Features:
/// - Renders the optimized WebP pastel mascot wallpaper (`skilltwin_app_background.webp`).
/// - Fills the available screen using [BoxFit.cover] with [Alignment.topCenter]
///   to preserve the 9:16 composition across phone aspect ratios without stretching.
/// - Wrapped with [RepaintBoundary] so foreground animations and scrolling
///   never cause the static wallpaper layer to repaint.
/// - Automatically detects parent [_SkillTwinBackgroundScope] to guarantee
///   zero duplicate background layers in nested navigation.
/// - Explicitly excluded from the Journey/Roadmap screen which has its own
///   gamified world background.
class SkillTwinBackground extends StatelessWidget {
  static const String assetPath = 'assets/images/skilltwin_app_background.webp';

  /// The child content placed above the background wallpaper.
  final Widget? child;

  /// Optional opacity multiplier (defaults to 1.0 for the calibrated artwork).
  final double opacity;

  const SkillTwinBackground({
    super.key,
    this.child,
    this.opacity = 1.0,
  });

  /// Precaches the background WebP asset into Flutter's image cache.
  static Future<void> precache(BuildContext context) {
    return precacheImage(const AssetImage(assetPath), context);
  }

  @override
  Widget build(BuildContext context) {
    // If an ancestor already provides the background, skip creating another layer
    final hasAncestor = context.dependOnInheritedWidgetOfExactType<_SkillTwinBackgroundScope>() != null;
    if (hasAncestor) {
      return child ?? const SizedBox.shrink();
    }

    final backgroundLayer = RepaintBoundary(
      child: _SkillTwinBackgroundLayer(opacity: opacity),
    );

    if (child == null) {
      return _SkillTwinBackgroundScope(child: backgroundLayer);
    }

    return _SkillTwinBackgroundScope(
      child: Stack(
        fit: StackFit.expand,
        children: [
          backgroundLayer,
          child!,
        ],
      ),
    );
  }
}

class _SkillTwinBackgroundLayer extends StatelessWidget {
  final double opacity;

  const _SkillTwinBackgroundLayer({this.opacity = 1.0});

  @override
  Widget build(BuildContext context) {
    Widget image = const SizedBox.expand(
      child: Image(
        image: AssetImage(SkillTwinBackground.assetPath),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
      ),
    );

    if (opacity < 1.0) {
      image = Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: image,
      );
    }

    return image;
  }
}
