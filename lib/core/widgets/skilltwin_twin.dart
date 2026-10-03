import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Contexts in which the SkillTwin Learning Twin companion appears.
enum TwinContext {
  home,
  streak,
  journey,
  session,
  milestone,
  emptyState,
  motivation,
  loading,
}

/// Emotional expressions of the Learning Twin mascot.
enum TwinExpression {
  happy,
  excited,
  thinking,
  focused,
  confused,
  tired,
  coding,
  reading,
  studying,
  celebrating,
}

/// Milestone growth levels of the Learning Twin mascot.
enum TwinMilestone {
  newLearner,
  exploring,
  building,
  growing,
  mastering,
  legend,
}

/// Strongly-typed asset representation for the SkillTwin mascot.
/// Exposes both `.path` and canonical singleton constants for every mood & role.
class TwinAsset {
  final String path;
  const TwinAsset(this.path);

  static const String basePath = 'assets/images/mascot/';

  // ── Home & Greeting ──
  static const TwinAsset home = TwinAsset('${basePath}twin_home.webp');
  static const TwinAsset waving = TwinAsset('${basePath}twin_home.webp');
  static const TwinAsset happy = TwinAsset('${basePath}twin_home.webp');

  // ── AI Mentor ──
  static const TwinAsset mentor = TwinAsset('${basePath}twin_mentor.webp');
  static const TwinAsset mentorThinking = TwinAsset('${basePath}twin_mentor_thinking.webp');
  static const TwinAsset thinking = TwinAsset('${basePath}twin_mentor_thinking.webp');
  static const TwinAsset confused = TwinAsset('${basePath}twin_mentor_thinking.webp');

  // ── Journey Poses ──
  static const TwinAsset journeyWalk = TwinAsset('${basePath}twin_journey_walk.webp');
  static const TwinAsset exploring = TwinAsset('${basePath}twin_journey_walk.webp');
  static const TwinAsset journeyPoint = TwinAsset('${basePath}twin_journey_point.webp');
  static const TwinAsset focused = TwinAsset('${basePath}twin_journey_point.webp');
  static const TwinAsset journeyGuide = TwinAsset('${basePath}twin_journey_guide.webp');
  static const TwinAsset journeyRoadmap = TwinAsset('${basePath}twin_journey_roadmap.webp');
  static const TwinAsset journeyNode = TwinAsset('${basePath}twin_journey_node.webp');
  static const TwinAsset building = TwinAsset('${basePath}twin_journey_node.webp');
  static const TwinAsset journeyClimb = TwinAsset('${basePath}twin_journey_climb.webp');
  static const TwinAsset journeyStudy = TwinAsset('${basePath}twin_journey_study.webp');
  static const TwinAsset reading = TwinAsset('${basePath}twin_journey_study.webp');
  static const TwinAsset studying = TwinAsset('${basePath}twin_journey_study.webp');
  static const TwinAsset journeyRevision = TwinAsset('${basePath}twin_journey_revision.webp');
  static const TwinAsset revision = TwinAsset('${basePath}twin_journey_revision.webp');
  static const TwinAsset journeyComplete = TwinAsset('${basePath}twin_journey_complete.webp');
  static const TwinAsset mastering = TwinAsset('${basePath}twin_journey_complete.webp');

  // ── Streak Poses ──
  static const TwinAsset streakFire = TwinAsset('${basePath}twin_streak_fire.webp');
  static const TwinAsset streak = TwinAsset('${basePath}twin_streak_fire.webp');
  static const TwinAsset streakComeback = TwinAsset('${basePath}twin_streak_comeback.webp');
  static const TwinAsset streakWarning = TwinAsset('${basePath}twin_streak_warning.webp');
  static const TwinAsset streakLegend = TwinAsset('${basePath}twin_streak_legend.webp');
  static const TwinAsset legend = TwinAsset('${basePath}twin_streak_legend.webp');
  static const TwinAsset streakComplete = TwinAsset('${basePath}twin_celebrate.webp');

  // ── Expressions, Actions & Milestones ──
  static const TwinAsset celebrate = TwinAsset('${basePath}twin_celebrate.webp');
  static const TwinAsset celebrating = TwinAsset('${basePath}twin_celebrate.webp');
  static const TwinAsset excited = TwinAsset('${basePath}twin_celebrate.webp');
  static const TwinAsset coding = TwinAsset('${basePath}twin_coding.webp');
  static const TwinAsset task = TwinAsset('${basePath}twin_task.webp');
  static const TwinAsset growing = TwinAsset('${basePath}twin_growing.webp');
  static const TwinAsset hero = TwinAsset('${basePath}twin_hero.webp');
  static const TwinAsset tired = TwinAsset('${basePath}twin_tired.webp');
  static const TwinAsset empty = TwinAsset('${basePath}twin_tired.webp');
  static const TwinAsset rest = TwinAsset('${basePath}twin_rest.webp');
  static const TwinAsset motivation = TwinAsset('${basePath}twin_motivation.webp');
  static const TwinAsset sessionStart = TwinAsset('${basePath}twin_motivation.webp');
  static const TwinAsset cool = TwinAsset('${basePath}twin_cool.webp');
  static const TwinAsset curious = TwinAsset('${basePath}twin_curious.webp');
  static const TwinAsset newLearner = TwinAsset('${basePath}twin_curious.webp');

  // ── Activity Domains ──
  static const TwinAsset aiml = TwinAsset('${basePath}twin_mentor.webp');
  static const TwinAsset cloud = TwinAsset('${basePath}twin_coding.webp');
  static const TwinAsset webdev = TwinAsset('${basePath}twin_coding.webp');
  static const TwinAsset datascience = TwinAsset('${basePath}twin_coding.webp');

  @override
  String toString() => path;

  static TwinAsset resolveAsset({
    TwinContext? context,
    TwinExpression? expression,
    TwinMilestone? milestone,
  }) {
    if (milestone != null) {
      switch (milestone) {
        case TwinMilestone.newLearner:
          return newLearner;
        case TwinMilestone.exploring:
          return journeyWalk;
        case TwinMilestone.building:
          return journeyNode;
        case TwinMilestone.growing:
          return growing;
        case TwinMilestone.mastering:
          return journeyComplete;
        case TwinMilestone.legend:
          return streakLegend;
      }
    }

    if (expression != null) {
      switch (expression) {
        case TwinExpression.happy:
          return happy;
        case TwinExpression.excited:
          return celebrate;
        case TwinExpression.thinking:
          return mentorThinking;
        case TwinExpression.focused:
          return journeyPoint;
        case TwinExpression.confused:
          return mentorThinking;
        case TwinExpression.tired:
          return tired;
        case TwinExpression.coding:
          return coding;
        case TwinExpression.reading:
        case TwinExpression.studying:
          return journeyStudy;
        case TwinExpression.celebrating:
          return celebrate;
      }
    }

    if (context != null) {
      switch (context) {
        case TwinContext.home:
          return home;
        case TwinContext.streak:
          return streakFire;
        case TwinContext.journey:
          return journeyPoint;
        case TwinContext.session:
          return journeyStudy;
        case TwinContext.milestone:
          return journeyComplete;
        case TwinContext.emptyState:
          return tired;
        case TwinContext.motivation:
          return motivation;
        case TwinContext.loading:
          return mentorThinking;
      }
    }

    return home;
  }
}

/// The reusable SkillTwin Learning Twin companion widget.
/// Supports multiple expressions, contexts, milestone states, optional speech bubble,
/// playful micro-interactions, responsive sizing, and decorative safety.
class SkillTwinTwin extends StatefulWidget {
  final TwinAsset? asset;
  final String? customAssetPath;
  final TwinContext? context;
  final TwinExpression? expression;
  final TwinMilestone? milestone;
  final double size;
  final String? speechBubble;
  final bool isSpeechOnLeft;
  final VoidCallback? onTap;
  final bool enableInteraction;
  final bool isDecorative;
  final bool floatAnimation;
  final bool bounce;

  const SkillTwinTwin({
    super.key,
    this.asset,
    this.customAssetPath,
    this.context,
    this.expression,
    this.milestone,
    this.size = 64,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.enableInteraction = false,
    this.isDecorative = false,
    this.floatAnimation = false,
    this.bounce = false,
  });

  // ── Preset Named Constructors ──

  const SkillTwinTwin.happy({
    super.key,
    this.size = 64,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.isDecorative = false,
  })  : asset = null,
        customAssetPath = null,
        context = null,
        expression = TwinExpression.happy,
        milestone = null,
        enableInteraction = true,
        floatAnimation = true,
        bounce = false;

  const SkillTwinTwin.excited({
    super.key,
    this.size = 64,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.isDecorative = false,
  })  : asset = null,
        customAssetPath = null,
        context = null,
        expression = TwinExpression.excited,
        milestone = null,
        enableInteraction = true,
        floatAnimation = true,
        bounce = false;

  const SkillTwinTwin.thinking({
    super.key,
    this.size = 64,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.isDecorative = false,
  })  : asset = null,
        customAssetPath = null,
        context = null,
        expression = TwinExpression.thinking,
        milestone = null,
        enableInteraction = false,
        floatAnimation = true,
        bounce = false;

  const SkillTwinTwin.focused({
    super.key,
    this.size = 64,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.isDecorative = false,
  })  : asset = null,
        customAssetPath = null,
        context = null,
        expression = TwinExpression.focused,
        milestone = null,
        enableInteraction = false,
        floatAnimation = false,
        bounce = false;

  const SkillTwinTwin.confused({
    super.key,
    this.size = 64,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.isDecorative = false,
  })  : asset = null,
        customAssetPath = null,
        context = null,
        expression = TwinExpression.confused,
        milestone = null,
        enableInteraction = false,
        floatAnimation = false,
        bounce = false;

  const SkillTwinTwin.tired({
    super.key,
    this.size = 64,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.isDecorative = false,
  })  : asset = null,
        customAssetPath = null,
        context = null,
        expression = TwinExpression.tired,
        milestone = null,
        enableInteraction = false,
        floatAnimation = false,
        bounce = false;

  const SkillTwinTwin.coding({
    super.key,
    this.size = 64,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.isDecorative = false,
  })  : asset = null,
        customAssetPath = null,
        context = null,
        expression = TwinExpression.coding,
        milestone = null,
        enableInteraction = false,
        floatAnimation = false,
        bounce = false;

  const SkillTwinTwin.reading({
    super.key,
    this.size = 64,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.isDecorative = false,
  })  : asset = null,
        customAssetPath = null,
        context = null,
        expression = TwinExpression.reading,
        milestone = null,
        enableInteraction = false,
        floatAnimation = false,
        bounce = false;

  const SkillTwinTwin.celebrating({
    super.key,
    this.size = 64,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.isDecorative = false,
  })  : asset = null,
        customAssetPath = null,
        context = null,
        expression = TwinExpression.celebrating,
        milestone = null,
        enableInteraction = true,
        floatAnimation = true,
        bounce = false;

  const SkillTwinTwin.streak({
    super.key,
    this.size = 80,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.isDecorative = false,
  })  : asset = null,
        customAssetPath = null,
        context = TwinContext.streak,
        expression = null,
        milestone = null,
        enableInteraction = true,
        floatAnimation = true,
        bounce = false;

  const SkillTwinTwin.empty({
    super.key,
    this.size = 110,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.isDecorative = false,
  })  : asset = null,
        customAssetPath = null,
        context = TwinContext.emptyState,
        expression = null,
        milestone = null,
        enableInteraction = false,
        floatAnimation = false,
        bounce = false;

  const SkillTwinTwin.waving({
    super.key,
    this.size = 64,
    this.speechBubble,
    this.isSpeechOnLeft = false,
    this.onTap,
    this.isDecorative = false,
  })  : asset = null,
        customAssetPath = null,
        context = TwinContext.home,
        expression = null,
        milestone = null,
        enableInteraction = true,
        floatAnimation = true,
        bounce = false;

  @override
  State<SkillTwinTwin> createState() => _SkillTwinTwinState();
}

class _SkillTwinTwinState extends State<SkillTwinTwin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _floatAnim;
  bool _isTapped = false;

  bool get _shouldFloat => widget.floatAnimation || widget.bounce;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _floatAnim = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    if (_shouldFloat) {
      _animController.forward().then((_) {
        if (mounted) _animController.reverse();
      });
    }
  }

  @override
  void didUpdateWidget(SkillTwinTwin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.floatAnimation || widget.bounce) &&
        !(oldWidget.floatAnimation || oldWidget.bounce)) {
      _animController.forward().then((_) {
        if (mounted) _animController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enableInteraction && widget.onTap == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isTapped = true);
    _animController.forward(from: 0.0).then((_) {
      if (mounted) _animController.reverse();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isTapped = false);
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final String resolvedPath;
    if (widget.asset != null) {
      resolvedPath = widget.asset!.path;
    } else if (widget.customAssetPath != null &&
        widget.customAssetPath!.isNotEmpty) {
      resolvedPath = widget.customAssetPath!;
    } else {
      resolvedPath = TwinAsset.resolveAsset(
        context: widget.context,
        expression: widget.expression,
        milestone: widget.milestone,
      ).path;
    }

    Widget mascot = AnimatedScale(
      scale: _isTapped ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.elasticOut,
      child: Image.asset(
        resolvedPath,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => Icon(
          Icons.pets_rounded,
          size: widget.size * 0.7,
          color: const Color(0xFF6366F1),
        ),
      ),
    );

    if (_shouldFloat) {
      mascot = AnimatedBuilder(
        animation: _floatAnim,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: child,
        ),
        child: mascot,
      );
    }

    Widget content = mascot;

    // Optional Speech Bubble
    if (widget.speechBubble != null && widget.speechBubble!.isNotEmpty) {
      final bubble = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          widget.speechBubble!,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: 0.1,
          ),
        ),
      );

      if (widget.isSpeechOnLeft) {
        content = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            bubble,
            const SizedBox(width: 6),
            mascot,
          ],
        );
      } else {
        content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            bubble,
            const SizedBox(height: 4),
            mascot,
          ],
        );
      }
    }

    if (widget.isDecorative) {
      return IgnorePointer(child: content);
    }

    if (widget.enableInteraction || widget.onTap != null) {
      return GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
