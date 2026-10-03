import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/mastery_format.dart';
import '../../../../core/widgets/skilltwin_twin.dart';
import 'journey_theme_models.dart';
import 'journey_world_background.dart';
import 'journey_path_painter.dart';
import 'adaptive_module_card.dart';
import 'journey_milestone_node.dart';
import 'journey_mascot.dart';

class _NodeLayoutData {
  final RoadmapTopicItem topic;
  final ModuleRegionTheme theme;
  final Offset position;
  final bool isCurrent;

  _NodeLayoutData({
    required this.topic,
    required this.theme,
    required this.position,
    required this.isCurrent,
  });
}

class _CardLayoutData {
  final RoadmapModuleItem module;
  final double top;
  final double? left;
  final double? right;
  final double width;

  _CardLayoutData({
    required this.module,
    required this.top,
    this.left,
    this.right,
    required this.width,
  });
}

class _SideCompanionLayoutData {
  final double top;
  final bool isLeft;
  final TwinAsset asset;

  _SideCompanionLayoutData({
    required this.top,
    required this.isLeft,
    required this.asset,
  });
}

/// The high-performance gamified roadmap viewport.
/// Smoothly computes the winding cubic bezier path, positions floating glassmorphic
/// module cards with zero overlap, renders state-aware milestone nodes, and positions
/// the animated companion mascot next to the active node.
class GamifiedRoadmapViewport extends StatefulWidget {
  final List<RoadmapModuleItem> modules;
  final ValueChanged<RoadmapTopicItem> onTopicTap;
  final ValueChanged<RoadmapModuleItem>? onModuleTap;
  final ScrollController scrollController;
  final Animation<double> entranceAnimation;
  final bool isYouTube;
  final String? channelName;
  final bool isStrictMode;

  const GamifiedRoadmapViewport({
    super.key,
    required this.modules,
    required this.onTopicTap,
    this.onModuleTap,
    required this.scrollController,
    required this.entranceAnimation,
    this.isYouTube = false,
    this.channelName,
    this.isStrictMode = false,
  });

  @override
  State<GamifiedRoadmapViewport> createState() =>
      _GamifiedRoadmapViewportState();
}

class _GamifiedRoadmapViewportState extends State<GamifiedRoadmapViewport> {
  Offset? _currentNodeOffset;
  bool _showJumpButton = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (_currentNodeOffset == null) return;
    final currentY = _currentNodeOffset!.dy;
    final scrollOffset = widget.scrollController.offset;
    final viewportHeight = MediaQuery.of(context).size.height;

    // Show jump button when current node is far from visible viewport
    final isFar = (currentY < scrollOffset - 120) ||
        (currentY > scrollOffset + viewportHeight + 120);

    if (isFar != _showJumpButton) {
      setState(() => _showJumpButton = isFar);
    }
  }

  void _jumpToCurrent() {
    if (_currentNodeOffset == null) return;
    HapticFeedback.mediumImpact();
    final targetY = math.max(0.0, _currentNodeOffset!.dy - 220);
    widget.scrollController.animateTo(
      targetY,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topSafeArea = MediaQuery.of(context).padding.top;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    final double width = MediaQuery.sizeOf(context).width;

    // 1. Calculate positions dynamically from data with responsive corridor and structural bottom safe area
    final layoutResult = _calculateLayout(width, topSafeArea, bottomSafeArea);
    final double totalHeight = layoutResult.totalHeight;
    final List<_NodeLayoutData> nodeLayouts = layoutResult.nodes;
    final List<_CardLayoutData> cardLayouts = layoutResult.cards;
    final List<_SideCompanionLayoutData> sideCompanions =
        layoutResult.companions;
    final List<RoadmapPathSegment> segments = layoutResult.segments;

    // Save current node position for jump-to feature
    if (layoutResult.currentNodePosition != null) {
      _currentNodeOffset = layoutResult.currentNodePosition;
    }

    return Stack(
          children: [
            SingleChildScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              child: SizedBox(
                width: width,
                height: totalHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Layer 1-4: Environmental World Artwork & Atmosphere
                    JourneyWorldBackground(
                      contentHeight: totalHeight,
                      viewportWidth: width,
                      modules: widget.modules,
                    ),

                    // Layer 4.5: Visual Trailhead Entry Zone with generous breathing room
                    Positioned(
                      top: topSafeArea + 72.0,
                      left: 0,
                      right: 0,
                      child: _buildRoadmapEntryZone(),
                    ),

                    // Layer 5: Dynamic Flutter Roadmap Path
                    AnimatedBuilder(
                      animation: widget.entranceAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(width, totalHeight),
                          painter: JourneyPathPainter(
                            segments: segments,
                            animationValue: widget.entranceAnimation.value,
                          ),
                        );
                      },
                    ),

                    // Layer 6: Alternating Floating Module Cards
                    ...cardLayouts.map((card) {
                      return Positioned(
                        top: card.top,
                        left: card.left,
                        right: card.right,
                        width: card.width,
                        child: AdaptiveModuleCard(
                          module: card.module,
                          onTap: () => widget.onModuleTap?.call(card.module),
                        ),
                      );
                    }),

                    // Layer 6.5: Floating Side Mascot Companions on outer edges (illustration style, non-blocking)
                    ...sideCompanions.map((comp) {
                      return Positioned(
                        top: comp.top,
                        left: comp.isLeft ? -8.0 : null,
                        right: comp.isLeft ? null : -8.0,
                        child: IgnorePointer(
                          child: Transform.rotate(
                            angle: comp.isLeft ? 0.05 : -0.05,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF5B5FEF).withValues(alpha: 0.12),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: SkillTwinTwin(
                                asset: comp.asset,
                                size: 50,
                                floatAnimation: true,
                                isDecorative: true,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    // Layer 7: State-Aware Circular Milestone Nodes with Generous Width Constraints
                    ...nodeLayouts.map((nodeData) {
                      final pos = nodeData.position;
                      final nodeWidth = layoutResult.nodeWidgetWidth;

                      return Positioned(
                        left: pos.dx - (nodeWidth / 2),
                        top: pos.dy - 32,
                        child: SizedBox(
                          width: nodeWidth,
                          child: JourneyMilestoneNode(
                            topic: nodeData.topic,
                            theme: nodeData.theme,
                            isCurrent: nodeData.isCurrent,
                            onTap: () => widget.onTopicTap(nodeData.topic),
                          ),
                        ),
                      );
                    }),

                    // Layer 8: Companion Travel Mascot perched beside Current Node
                    if (layoutResult.currentNodePosition != null) ...[
                      Positioned(
                        left: layoutResult.mascotPosition.dx - 36,
                        top: layoutResult.mascotPosition.dy - 64,
                        child: JourneyMascot(
                          speechBubbleText: layoutResult.mascotSpeech,
                          asset: layoutResult.mascotAsset,
                          size: 60,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _jumpToCurrent();
                          },
                        ),
                      ),
                    ],

                    // Layer 9: Finish Trophy Podium at Journey Summit
                    if (layoutResult.finishPosition != null) ...[
                      Positioned(
                        left: layoutResult.finishPosition!.dx - 55,
                        top: layoutResult.finishPosition!.dy - 30,
                        child: _buildFinishPodium(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Floating "Jump to Current" Action Affordance structurally positioned above floating bottom nav
            if (_showJumpButton && _currentNodeOffset != null)
              Positioned(
                bottom: layoutResult.bottomNavClearance + 16.0,
                right: 20,
                child: FloatingActionButton.extended(
                  heroTag: 'journey_jump_btn',
                  onPressed: _jumpToCurrent,
                  backgroundColor: const Color(0xFF5B5FEF),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  icon: const Icon(Icons.my_location_rounded, size: 18),
                  label: const Text(
                    'Jump to Active',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.0,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
          ],
        );
  }

  Widget _buildRoadmapEntryZone() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            // Mascot ready at trailhead with backpack
            const SkillTwinTwin(
              asset: TwinAsset.journeyWalk,
              size: 38,
              isDecorative: true,
            ),

            // Trailhead Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF5B5FEF).withValues(alpha: 0.20),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B5FEF).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                spacing: 5,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B5FEF).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      size: 11,
                      color: Color(0xFF5B5FEF),
                    ),
                  ),
                  const Text(
                    'JOURNEY TRAILHEAD',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.0,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5B5FEF),
                      letterSpacing: 0.6,
                    ),
                  ),
                  Container(
                    width: 3.0,
                    height: 3.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Text(
                    'Adaptive Trail',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Contextual YouTube Pill if imported playlist (replaces colliding top overlay)
        if (widget.isYouTube) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF0000).withValues(alpha: 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_circle_fill,
                  size: 13,
                  color: Color(0xFFFF0000),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.channelName != null
                      ? 'YouTube: ${widget.channelName}'
                      : 'YouTube Curriculum',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (widget.isStrictMode) ...[
                  const SizedBox(width: 6),
                  const Text('🔒', style: TextStyle(fontSize: 10)),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFinishPodium() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B5FEF), Color(0xFF38BDF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B5FEF).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
            const Positioned(
              top: -8,
              child: SkillTwinTwin(
                milestone: TwinMilestone.legend,
                size: 72,
                isDecorative: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF5B5FEF).withValues(alpha: 0.2),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('👑', style: TextStyle(fontSize: 12)),
              SizedBox(width: 5),
              Text(
                'MASTERY SUMMIT',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E2238),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _LayoutComputationResult _calculateLayout(
      double width, double topSafeArea, double bottomSafeArea) {
    // 1. Establish responsive map corridor (capped on tablets and landscape to prevent cavernous empty areas)
    final double corridorWidth = math.min(width, 560.0);
    final double corridorLeft = (width - corridorWidth) / 2;
    final double corridorRight = corridorLeft + corridorWidth;
    final double corridorCenterX = corridorLeft + (corridorWidth / 2);

    // 2. Start at Trailhead zone
    final double startY = topSafeArea + 72.0;
    final Offset startMarkerPos = Offset(corridorCenterX, startY + 54.0);
    double currentY = startY + 118.0;

    final List<_NodeLayoutData> nodes = [];
    final List<_CardLayoutData> cards = [];
    final List<_SideCompanionLayoutData> companions = [];
    final List<RoadmapPathSegment> segments = [];
    Offset? currentNodePos;
    Offset mascotPos = Offset.zero;
    String mascotSpeech = "Keep going! 🚀";
    TwinAsset mascotAsset = TwinAsset.focused;

    // Card width (responsive to corridor)
    final double cardMargin = 12.0;
    final double cardWidth = (corridorWidth * 0.42).clamp(134.0, 195.0);

    for (int m = 0; m < widget.modules.length; m++) {
      final module = widget.modules[m];
      final isLeft = module.isCardOnLeft;

      // 1. Module Card Layout: placed on alternating sides
      final cardTop = currentY;
      cards.add(
        _CardLayoutData(
          module: module,
          top: cardTop,
          left: isLeft ? (corridorLeft + cardMargin) : null,
          right: isLeft ? null : (width - corridorRight + cardMargin),
          width: cardWidth,
        ),
      );

      // 2. Safe Node Corridor on opposite side of card
      final double minNodeX;
      final double maxNodeX;
      if (isLeft) {
        minNodeX = corridorLeft + cardMargin + cardWidth + 12.0;
        maxNodeX = corridorRight - cardMargin;
      } else {
        minNodeX = corridorLeft + cardMargin;
        maxNodeX = corridorRight - cardMargin - cardWidth - 12.0;
      }

      final double availableNodeWidth = maxNodeX - minNodeX;
      final double nodeWidgetWidth = availableNodeWidth.clamp(126.0, 164.0);
      final double nodeCenterBaseX = (minNodeX + maxNodeX) / 2;
      final double waveAmplitude = (availableNodeWidth * 0.16).clamp(8.0, 20.0);

      double nodeY = cardTop + 20.0;

      for (int t = 0; t < module.topics.length; t++) {
        final topic = module.topics[t];
        final isCurrent = topic.visualState.isCurrent;

        final double sineFactor = math.sin((t + (isLeft ? 0 : math.pi)) * 1.4);
        double nodeX = nodeCenterBaseX + (sineFactor * waveAmplitude);

        // Detour lateral arch for remediation
        if (topic.isRemediation || topic.visualState.isRemediating) {
          nodeX += isLeft ? (waveAmplitude * 1.2) : -(waveAmplitude * 1.2);
        }

        // Clamp safely so node widget never crosses bounds
        final double halfNode = nodeWidgetWidth / 2;
        nodeX = nodeX.clamp(minNodeX + halfNode, maxNodeX - halfNode);

        final nodePos = Offset(nodeX, nodeY);

        nodes.add(
          _NodeLayoutData(
            topic: topic,
            theme: module.theme,
            position: nodePos,
            isCurrent: isCurrent,
          ),
        );

        if (isCurrent) {
          currentNodePos = nodePos;
          // Perch companion mascot safely beside active node
          final double mascotX = (nodePos.dx + (isLeft ? -76.0 : 76.0))
              .clamp(corridorLeft + 36.0, corridorRight - 36.0);
          mascotPos = Offset(mascotX, nodePos.dy - 36.0);
          mascotSpeech = _deriveMascotEncouragement(topic);
          mascotAsset = _deriveMascotAsset(topic);
        }

        final double spacing = isCurrent ? 144.0 : 122.0;
        nodeY += spacing;
      }

      // Transition breathing room into next module
      currentY = math.max(nodeY, cardTop + 140.0) + 110.0;
    }

    // Connect Start marker to first node (START -> learning path)
    if (nodes.isNotEmpty) {
      segments.add(
        RoadmapPathSegment(
          start: startMarkerPos,
          end: nodes.first.position,
          startState: RoadmapVisualState.completed,
          endState: nodes.first.topic.visualState,
          startTheme: nodes.first.theme,
          endTheme: nodes.first.theme,
        ),
      );
    }

    // Connect consecutive nodes into path segments
    for (int i = 0; i < nodes.length - 1; i++) {
      final n0 = nodes[i];
      final n1 = nodes[i + 1];

      segments.add(
        RoadmapPathSegment(
          start: n0.position,
          end: n1.position,
          startState: n0.topic.visualState,
          endState: n1.topic.visualState,
          startTheme: n0.theme,
          endTheme: n1.theme,
          isRemediation: n1.topic.visualState.isRemediating,
          isBypassed: n1.topic.visualState.isBypassed,
        ),
      );
    }

    // Connect last node to Mastery Summit finish podium
    Offset? finishPos;
    if (nodes.isNotEmpty) {
      final lastNode = nodes.last;
      finishPos = Offset(corridorCenterX, lastNode.position.dy + 120.0);

      segments.add(
        RoadmapPathSegment(
          start: lastNode.position,
          end: finishPos,
          startState: lastNode.topic.visualState,
          endState: RoadmapVisualState.completed,
          startTheme: lastNode.theme,
          endTheme: ModuleRegionTheme.forIndex(4),
        ),
      );
    }

    // STRUCTURAL BOTTOM SAFE-AREA PADDING
    // Calculate based on:
    // - bottom navigation height (72.0 + 12.0 = 84.0)
    // - bottom safe area (bottomSafeArea)
    // - desired breathing room (44.0)
    final double bottomNavHeight = 72.0 + 12.0;
    const double desiredBreathingRoom = 44.0;
    final double structuralBottomPadding =
        bottomNavHeight + bottomSafeArea + desiredBreathingRoom;

    final double totalHeight =
        (finishPos?.dy ?? currentY) + structuralBottomPadding;

    final double effectiveNodeWidth = (corridorWidth * 0.40).clamp(126.0, 164.0);

    return _LayoutComputationResult(
      totalHeight: totalHeight,
      nodes: nodes,
      cards: cards,
      companions: companions,
      segments: segments,
      currentNodePosition: currentNodePos,
      mascotPosition: mascotPos,
      mascotSpeech: mascotSpeech,
      mascotAsset: mascotAsset,
      finishPosition: finishPos,
      nodeWidgetWidth: effectiveNodeWidth,
      bottomNavClearance:  bottomSafeArea,
    );
  }

  TwinAsset _deriveMascotAsset(RoadmapTopicItem topic) {
    if (topic.isRemediation) {
      return TwinAsset.mentorThinking;
    }
    if (topic.visualState.isNeedsRevision) {
      return TwinAsset.journeyRevision;
    }
    if (topic.masteryScore.toMasteryFraction > 0.5) {
      return TwinAsset.journeyComplete;
    }
    return TwinAsset.journeyPoint;
  }

  String _deriveMascotEncouragement(RoadmapTopicItem topic) {
    if (topic.isRemediation) {
      return "Quick fix, let's nail it! 💡";
    }
    if (topic.visualState.isNeedsRevision) {
      return "Spaced review time! 🧠";
    }
    if (topic.masteryScore.toMasteryFraction > 0.5) {
      return "You're crushing it! 🔥";
    }
    return "Let's explore this! ✨";
  }
}

class _LayoutComputationResult {
  final double totalHeight;
  final List<_NodeLayoutData> nodes;
  final List<_CardLayoutData> cards;
  final List<_SideCompanionLayoutData> companions;
  final List<RoadmapPathSegment> segments;
  final Offset? currentNodePosition;
  final Offset mascotPosition;
  final String mascotSpeech;
  final TwinAsset mascotAsset;
  final Offset? finishPosition;
  final double nodeWidgetWidth;
  final double bottomNavClearance;

  _LayoutComputationResult({
    required this.totalHeight,
    required this.nodes,
    required this.cards,
    required this.companions,
    required this.segments,
    this.currentNodePosition,
    required this.mascotPosition,
    required this.mascotSpeech,
    required this.mascotAsset,
    this.finishPosition,
    required this.nodeWidgetWidth,
    required this.bottomNavClearance,
  });
}
