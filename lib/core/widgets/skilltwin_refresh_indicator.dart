import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_theme.dart';

/// One coherent SkillTwin pull-to-refresh experience.
///
/// Features:
/// - Replaces default circular Material refresh indicator with the SkillTwin mascot.
/// - User pulls down → mascot appears & scales with pull depth.
/// - User passes threshold → mascot reacts with subtle bounce & light haptic feedback.
/// - Refreshing → active animated mascot GIF loops with flowing loading wave.
/// - Finished → mascot smoothly collapses and disappears (250ms).
/// - Non-blocking: standard list scrolling is 100% native and unhindered.
class SkillTwinRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? message;
  final double triggerDistance;
  final double refreshHeight;
  final double edgeOffset;

  const SkillTwinRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.message,
    this.triggerDistance = 70.0,
    this.refreshHeight = 64.0,
    this.edgeOffset = 0.0,
  });

  @override
  State<SkillTwinRefreshIndicator> createState() =>
      _SkillTwinRefreshIndicatorState();
}

class _SkillTwinRefreshIndicatorState extends State<SkillTwinRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resetController;

  double _dragDistance = 0.0;
  double _animatedDistance = 0.0;
  bool _isRefreshing = false;
  bool _hasHapticTriggered = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;

    // Track scroll start
    if (notification is ScrollStartNotification) {
      if (notification.dragDetails != null &&
          notification.metrics.extentBefore == 0.0) {
        _isDragging = true;
      }
    }

    // Accumulate pull distance on overscroll or top drag
    if (notification is ScrollUpdateNotification) {
      if (_isDragging &&
          notification.dragDetails != null &&
          notification.metrics.extentBefore == 0.0 &&
          notification.scrollDelta != null &&
          notification.scrollDelta! < 0) {
        final double delta = -notification.scrollDelta! * 0.55;
        _updateDragDistance(_dragDistance + delta);
      }
    } else if (notification is OverscrollNotification) {
      if (_isDragging &&
          notification.dragDetails != null &&
          notification.metrics.extentBefore == 0.0 &&
          notification.overscroll < 0) {
        final double delta = -notification.overscroll * 0.55;
        _updateDragDistance(_dragDistance + delta);
      }
    }

    // Handle finger lift / gesture completion
    if (notification is ScrollEndNotification ||
        (notification is UserScrollNotification &&
            notification.direction == ScrollDirection.idle)) {
      if (_isDragging) {
        _isDragging = false;
        _handleDragRelease();
      }
    }

    return false;
  }

  void _updateDragDistance(double newDistance) {
    // Maximum pull resistance
    final double maxPull = widget.triggerDistance * 1.5;
    final double clamped = newDistance.clamp(0.0, maxPull);

    if ((clamped - _dragDistance).abs() > 0.5) {
      setState(() {
        _dragDistance = clamped;
        _animatedDistance = clamped;
      });

      if (_dragDistance >= widget.triggerDistance && !_hasHapticTriggered) {
        _hasHapticTriggered = true;
        HapticFeedback.lightImpact();
      } else if (_dragDistance < widget.triggerDistance && _hasHapticTriggered) {
        _hasHapticTriggered = false;
      }
    }
  }

  Future<void> _handleDragRelease() async {
    if (_dragDistance >= widget.triggerDistance && !_isRefreshing) {
      // Trigger refresh
      setState(() {
        _isRefreshing = true;
      });

      // Animate smoothly to resting refresh height
      await _animateToDistance(widget.refreshHeight, duration: 160);

      try {
        await widget.onRefresh();
      } finally {
        if (mounted) {
          // Smoothly collapse back to 0
          await _animateToDistance(0.0, duration: 240);
          setState(() {
            _isRefreshing = false;
            _hasHapticTriggered = false;
            _dragDistance = 0.0;
            _animatedDistance = 0.0;
          });
        }
      }
    } else {
      // Cancelled pull
      _hasHapticTriggered = false;
      await _animateToDistance(0.0, duration: 180);
      if (mounted) {
        setState(() {
          _dragDistance = 0.0;
          _animatedDistance = 0.0;
        });
      }
    }
  }

  Future<void> _animateToDistance(double target, {required int duration}) async {
    _resetController.duration = Duration(milliseconds: duration);
    final double start = _animatedDistance;
    final animation = CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOutCubic,
    );

    void listener() {
      if (mounted) {
        setState(() {
          _animatedDistance =
              start + (target - start) * animation.value;
          _dragDistance = _animatedDistance;
        });
      }
    }

    _resetController.addListener(listener);
    _resetController.reset();
    await _resetController.forward();
    _resetController.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    final double pullRatio =
        (_animatedDistance / widget.triggerDistance).clamp(0.0, 1.0);
    final bool hasMetThreshold = _animatedDistance >= widget.triggerDistance;
    final bool showHeader = _animatedDistance > 0.0 || _isRefreshing;

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── The Scrollable Child ──
          // Smoothly translated down when pulled, otherwise zero overhead
          Transform.translate(
            offset: Offset(0, _animatedDistance),
            child: widget.child,
          ),

          // ── Mascot Pull & Refresh Header ──
          if (showHeader)
            Positioned(
              top: widget.edgeOffset,
              left: 0,
              right: 0,
              height: _animatedDistance,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.bottomCenter,
                  minHeight: 0,
                  maxHeight: widget.triggerDistance * 1.5,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: _buildMascotHeader(
                      pullRatio: pullRatio,
                      hasMetThreshold: hasMetThreshold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMascotHeader({
    required double pullRatio,
    required bool hasMetThreshold,
  }) {
    final double mascotScale = _isRefreshing
        ? 1.0
        : (0.45 + 0.55 * pullRatio).clamp(0.45, 1.1);
    final double opacity = _isRefreshing ? 1.0 : pullRatio.clamp(0.0, 1.0);

    String statusText;
    if (_isRefreshing) {
      statusText = widget.message ?? 'SkillTwin is updating...';
    } else if (hasMetThreshold) {
      statusText = 'Release to refresh';
    } else {
      statusText = 'Pull to refresh';
    }

    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mascot (GIF during refresh or pull)
          Transform.scale(
            scale: mascotScale,
            child: Image.asset(
              'assets/mascots/skilltwin_mascot_loading.gif',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/mascots/twin_mentor_thinking.webp',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.psychology_rounded,
                  size: 24,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            statusText,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
