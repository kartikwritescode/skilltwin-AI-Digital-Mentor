import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// A premium, custom floating Mentor companion button featuring the SkillTwin
/// red-panda mascot. Replaces the generic Material FloatingActionButton with
/// an isolated presentation component.
class MentorTwinFab extends StatefulWidget {
  /// Invoked immediately when the button is tapped.
  final VoidCallback? onPressed;

  /// Accessibility semantic label and tooltip message. Defaults to 'Open Mentor'.
  final String tooltip;

  /// Diameter/size of the button in logical pixels (recommended 56–68).
  final double size;

  /// Optional Hero tag for route transitions. Defaults to 'mentor_twin_fab'.
  final Object? heroTag;

  const MentorTwinFab({
    super.key,
    this.onPressed,
    this.tooltip = 'Open Mentor',
    this.size = 78.0,
    this.heroTag = 'mentor_twin_fab',
  });

  @override
  State<MentorTwinFab> createState() => _MentorTwinFabState();
}

class _MentorTwinFabState extends State<MentorTwinFab>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const String _mascotAsset = 'assets/images/mascot/twin_mentor.webp';

  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ── 1. Subtle Idle Floating Animation (3-4px vertical movement) ──
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _floatAnimation = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    // ── 2. Tap Feedback Scale Animation ──
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOutCubic,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bool reduceMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (!reduceMotion) {
        _floatController.repeat(reverse: true);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed) {
      final bool reduceMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (!reduceMotion && !_floatController.isAnimating) {
        _floatController.repeat(reverse: true);
      }
    } else {
      if (_floatController.isAnimating) {
        _floatController.stop();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _floatController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _onTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget buttonContent = Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.tooltip,
      child: Tooltip(
        message: widget.tooltip,
        waitDuration: const Duration(milliseconds: 600),
        child: AnimatedBuilder(
          animation: Listenable.merge([_floatAnimation, _scaleAnimation]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onPressed,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Image.asset(
                _mascotAsset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                cacheWidth: 256,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.assistant_rounded,
                  color: AppTheme.primaryAccent,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.heroTag != null) {
      buttonContent = Hero(
        tag: widget.heroTag!,
        child: buttonContent,
      );
    }

    return buttonContent;
  }
}
