import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/learning_path_provider.dart';
import '../providers/journey_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../../core/models/learning_path.dart';
import '../../../../core/models/journey_node.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/skilltwin_twin.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';
import '../../../../core/widgets/skilltwin_transition_switcher.dart';
import '../../../../core/widgets/skilltwin_refresh_indicator.dart';
import '../widgets/youtube_import_modal.dart';
import '../widgets/journey_theme_models.dart';
import '../widgets/journey_header.dart';
import '../widgets/gamified_roadmap_viewport.dart';

/// The redesigned Journey / Learning Roadmap Screen.
/// Delivers a polished, gamified "learning world" progression inspired by
/// modern mobile games and Apple-quality UI design.
class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _entranceAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _hasAutoScrolled = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTopicTapped(RoadmapTopicItem topic) {
    HapticFeedback.lightImpact();
    try {
      context.push('/journey/topic/${topic.id}');
    } catch (_) {
      // In unit test environments without GoRouter ancestor
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePathAsync = ref.watch(activeLearningPathProvider);
    final journeyState = ref.watch(journeyProvider);
    final homeData = ref.watch(homeDashboardProvider).valueOrNull;
    final int streakDays = homeData?.streakDays ?? 12;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SkillTwinRefreshIndicator(
        message: 'SkillTwin is updating your journey...',
        edgeOffset: 0,
        onRefresh: () async {
          ref.invalidate(activeLearningPathProvider);
          ref.invalidate(journeyProvider);
          _entranceController.reset();
          _entranceController.forward();
        },
        child: SkillTwinTransitionSwitcher(
          child: activePathAsync.when(
            data: (path) {
              if (path != null && path.sections.isNotEmpty) {
                return KeyedSubtree(
                  key: const ValueKey('journey_active_roadmap'),
                  child: _buildRoadmapView(
                    title: path.title,
                    modules: _convertLearningPathToModules(path),
                    streakDays: streakDays,
                    isYouTube: path.isYouTubeCurriculum,
                    channelName: path.channelName,
                    isStrictMode: path.isStrictMode,
                  ),
                );
              }

              // Fallback to journeyProvider nodes if present
              if (journeyState.nodes.isNotEmpty) {
                return KeyedSubtree(
                  key: const ValueKey('journey_nodes_roadmap'),
                  child: _buildRoadmapView(
                    title: 'Adaptive Learning Path',
                    modules: _convertJourneyNodesToModules(journeyState.nodes),
                    streakDays: streakDays,
                    isYouTube: false,
                  ),
                );
              }

              // Empty state when no roadmap has been generated yet
              return KeyedSubtree(
                key: const ValueKey('journey_empty_state'),
                child: _buildEmptyState(context),
              );
            },
            loading: () => const SkillTwinLoadingView.fullScreen(
              key: ValueKey('journey_loading'),
              message: 'SkillTwin is preparing your next step.',
              subMessage: 'Mapping your learning world...',
            ),
            error: (err, _) => KeyedSubtree(
              key: const ValueKey('journey_error'),
              child: Stack(
                children: [
                  JourneyHeader(
                    title: 'Roadmap Error',
                    streakDays: streakDays,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: ErrorStateView(
                      error: err.toString(),
                      onRetry: () {
                        ref.invalidate(activeLearningPathProvider);
                        ref.invalidate(journeyProvider);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoadmapView({
    required String title,
    required List<RoadmapModuleItem> modules,
    required int streakDays,
    bool isYouTube = false,
    String? channelName,
    bool isStrictMode = false,
  }) {
    // Schedule initial smooth scroll to active node once layout builds
    if (!_hasAutoScrolled) {
      _hasAutoScrolled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initialScrollToCurrent(modules);
      });
    }

    int total = 0;
    int completed = 0;
    for (final m in modules) {
      total += m.topics.length;
      completed += m.topics.where((t) => t.visualState.isCompleted).length;
    }
    final int? progressPct = total > 0 ? ((completed / total) * 100).toInt() : null;

    return Stack(
      children: [
        // Gamified Winding Map Viewport
        GamifiedRoadmapViewport(
          modules: modules,
          scrollController: _scrollController,
          entranceAnimation: _entranceAnimation,
          isYouTube: isYouTube,
          channelName: channelName,
          isStrictMode: isStrictMode,
          onTopicTap: _onTopicTapped,
          onModuleTap: (module) {
            // Smoothly scroll towards selected module
            _scrollToModule(module, modules);
          },
        ),

        // Floating Translucent Gradient Header Bar (Softly blends into roadmap)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: JourneyHeader(
            title: title.isNotEmpty ? title : 'My Learning Journey',
            streakDays: streakDays,
            progressPercentage: progressPct,
          ),
        ),
      ],
    );
  }

  void _initialScrollToCurrent(List<RoadmapModuleItem> modules) {
    if (!mounted) return;
    int targetModuleIndex = 0;
    int targetTopicIndex = 0;
    bool found = false;

    for (int m = 0; m < modules.length; m++) {
      for (int t = 0; t < modules[m].topics.length; t++) {
        if (modules[m].topics[t].visualState.isCurrent) {
          targetModuleIndex = m;
          targetTopicIndex = t;
          found = true;
          break;
        }
      }
      if (found) break;
    }

    if (found && (targetModuleIndex > 0 || targetTopicIndex > 1)) {
      // Calculate approximate Y position and scroll smoothly
      final approxY = (targetModuleIndex * 480.0) + (targetTopicIndex * 110.0);
      _scrollController.animateTo(
        math.max(0.0, approxY - 180.0),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToModule(
      RoadmapModuleItem module, List<RoadmapModuleItem> modules) {
    final idx = modules.indexOf(module);
    if (idx != -1) {
      final approxY = idx * 480.0;
      _scrollController.animateTo(
        math.max(0.0, approxY - 80.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  List<RoadmapModuleItem> _convertLearningPathToModules(LearningPath path) {
    // 1. Identify the single active current topic in the entire curriculum
    String? currentTopicId;
    for (final section in path.sections) {
      for (final topic in section.topics) {
        if (topic.status == TopicStatus.learning) {
          currentTopicId = topic.id;
          break;
        }
      }
      if (currentTopicId != null) break;
    }

    // If no topic is explicitly marked as 'learning', pick the first incomplete topic
    if (currentTopicId == null) {
      for (final section in path.sections) {
        for (final topic in section.topics) {
          if (topic.status != TopicStatus.completed) {
            currentTopicId = topic.id;
            break;
          }
        }
        if (currentTopicId != null) break;
      }
    }

    bool previousTopicCompletedOrCurrent = true;
    final List<RoadmapModuleItem> moduleItems = [];

    final totalTopicsCount = path.totalTopics;
    int overallIndex = 0;

    for (int s = 0; s < path.sections.length; s++) {
      final section = path.sections[s];
      final theme = ModuleRegionTheme.forIndex(s);

      final List<RoadmapTopicItem> topics = [];
      for (int t = 0; t < section.topics.length; t++) {
        final topic = section.topics[t];
        final isCurrent = topic.id == currentTopicId;

        final item = RoadmapTopicItem.fromLearningTopic(
          topic: topic,
          sectionIndex: s,
          topicIndex: t,
          isPathActiveCurrent: isCurrent,
          isPreviousCompletedOrCurrent: previousTopicCompletedOrCurrent,
          isFirstInModule: t == 0,
          isLastOverall: overallIndex == totalTopicsCount - 1,
        );

        topics.add(item);
        overallIndex++;

        // Update sequence tracker
        if (item.visualState.isCompleted || item.visualState.isCurrent) {
          previousTopicCompletedOrCurrent = true;
        } else {
          previousTopicCompletedOrCurrent = false;
        }
      }

      final completedCount =
          section.topics.where((t) => t.status == TopicStatus.completed).length;

      moduleItems.add(
        RoadmapModuleItem(
          id: section.id,
          title: section.title,
          description: section.description,
          orderIndex: s,
          progress: section.progress,
          completedCount: completedCount,
          totalCount: section.topics.length,
          theme: theme,
          topics: topics,
        ),
      );
    }

    return moduleItems;
  }

  List<RoadmapModuleItem> _convertJourneyNodesToModules(
      List<JourneyNode> nodes) {
    // Group JourneyNode items into modules by phase
    final Map<String, List<JourneyNode>> grouped = {};
    for (final node in nodes) {
      final phaseKey = (node.phase != null && node.phase!.isNotEmpty)
          ? node.phase!
          : 'Core Curriculum';
      grouped.putIfAbsent(phaseKey, () => []).add(node);
    }

    final List<RoadmapModuleItem> modules = [];
    int phaseIndex = 0;

    grouped.forEach((phaseTitle, phaseNodes) {
      final theme = ModuleRegionTheme.forIndex(phaseIndex);
      final List<RoadmapTopicItem> topics = [];

      for (int t = 0; t < phaseNodes.length; t++) {
        final node = phaseNodes[t];
        topics.add(
          RoadmapTopicItem.fromJourneyNode(
            node: node,
            sectionIndex: phaseIndex,
            topicIndex: t,
            isLastOverall: (phaseIndex == grouped.length - 1) &&
                (t == phaseNodes.length - 1),
          ),
        );
      }

      final completed = topics.where((t) => t.visualState.isCompleted).length;
      final progress = topics.isNotEmpty ? completed / topics.length : 0.0;

      modules.add(
        RoadmapModuleItem(
          id: 'phase_$phaseIndex',
          title: phaseTitle,
          description: 'Master key milestones in $phaseTitle',
          orderIndex: phaseIndex,
          progress: progress,
          completedCount: completed,
          totalCount: topics.length,
          theme: theme,
          topics: topics,
        ),
      );
      phaseIndex++;
    });

    return modules;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: JourneyHeader(
            title: 'Learning Journey',
          ),
        ),
        Center(
          child: ListView(
            padding: const EdgeInsets.only(top: 140, left: 32, right: 32),
            children: [
              const SizedBox(height: 32),
              Center(
                child: const SkillTwinTwin(
                  asset: TwinAsset.journeyWalk,
                  size: 110,
                  speechBubble: "Ready for your next journey? 🎒",
                  isDecorative: true,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Active Learning Roadmap',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E2238),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Set a target outcome to have your AI mentor sculpt a continuous winding journey world, or import any YouTube playlist to learn sequentially.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.push('/onboarding'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                      label: const Text(
                        'Set Learning Goal',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => YouTubeImportModal.show(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF0000),
                        side: const BorderSide(
                          color: Color(0xFFFF0000),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.play_circle_fill, size: 18),
                      label: const Text(
                        'Import YouTube Playlist',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
