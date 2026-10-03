import 'package:flutter/material.dart';
import '../../../../core/models/learning_path.dart';
import '../../../../core/models/journey_node.dart';

/// The 7 distinct visual states defined by the gamified roadmap architecture.
enum RoadmapVisualState {
  completed,
  current,
  available,
  locked,
  needsRevision,
  remediating,
  bypassed;

  bool get isCompleted => this == RoadmapVisualState.completed;
  bool get isCurrent => this == RoadmapVisualState.current;
  bool get isAvailable => this == RoadmapVisualState.available;
  bool get isLocked => this == RoadmapVisualState.locked;
  bool get isNeedsRevision => this == RoadmapVisualState.needsRevision;
  bool get isRemediating => this == RoadmapVisualState.remediating;
  bool get isBypassed => this == RoadmapVisualState.bypassed;
}

/// Regional environmental themes representing the 5 distinct fantasy biomes.
class ModuleRegionTheme {
  final int index;
  final String regionName;
  final Color primary;
  final Color secondary;
  final Color surfaceTint;
  final Color borderColor;
  final Color glowColor;
  final Color badgeBg;
  final Color badgeText;
  final Gradient cardGradient;

  const ModuleRegionTheme({
    required this.index,
    required this.regionName,
    required this.primary,
    required this.secondary,
    required this.surfaceTint,
    required this.borderColor,
    required this.glowColor,
    required this.badgeBg,
    required this.badgeText,
    required this.cardGradient,
  });

  static const List<ModuleRegionTheme> biomes = [
    // Module 1: Emerald Highlands (Nature / Grasslands)
    ModuleRegionTheme(
      index: 0,
      regionName: 'Emerald Highlands',
      primary: Color(0xFF10B981), // Emerald
      secondary: Color(0xFF059669),
      surfaceTint: Color(0xFFECFDF5),
      borderColor: Color(0xFFA7F3D0),
      glowColor: Color(0x6610B981),
      badgeBg: Color(0xFFD1FAE5),
      badgeText: Color(0xFF065F46),
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
      ),
    ),
    // Module 2: Azure Waters (Waterfall / River Cascades)
    ModuleRegionTheme(
      index: 1,
      regionName: 'Crystal Cascades',
      primary: Color(0xFF0EA5E9), // Sky Blue / Cyan
      secondary: Color(0xFF0284C7),
      surfaceTint: Color(0xFFF0F9FF),
      borderColor: Color(0xFFBAE6FD),
      glowColor: Color(0x660EA5E9),
      badgeBg: Color(0xFFE0F2FE),
      badgeText: Color(0xFF075985),
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
      ),
    ),
    // Module 3: Mystic Peaks (Purple / Crystal Sanctuary)
    ModuleRegionTheme(
      index: 2,
      regionName: 'Mystic Peaks',
      primary: Color(0xFF8B5CF6), // Violet / Purple
      secondary: Color(0xFF7C3AED),
      surfaceTint: Color(0xFFF5F3FF),
      borderColor: Color(0xFFDDD6FE),
      glowColor: Color(0x668B5CF6),
      badgeBg: Color(0xFFEDE9FE),
      badgeText: Color(0xFF5B21B6),
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
      ),
    ),
    // Module 4: Periwinkle Heights (Indigo / Periwinkle Sanctuary)
    ModuleRegionTheme(
      index: 3,
      regionName: 'Periwinkle Heights',
      primary: Color(0xFF6366F1), // Indigo / Periwinkle
      secondary: Color(0xFF4F46E5),
      surfaceTint: Color(0xFFEEF2FF),
      borderColor: Color(0xFFC7D2FE),
      glowColor: Color(0x666366F1),
      badgeBg: Color(0xFFE0E7FF),
      badgeText: Color(0xFF3730A3),
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
      ),
    ),
    // Module 5: Blossom Sanctuary (Pastel Pink Ruins / Project Citadel)
    ModuleRegionTheme(
      index: 4,
      regionName: 'Blossom Citadel',
      primary: Color(0xFFEC4899), // Coral / Pink
      secondary: Color(0xFFDB2777),
      surfaceTint: Color(0xFFFDF2F8),
      borderColor: Color(0xFFFBCFE8),
      glowColor: Color(0x66EC4899),
      badgeBg: Color(0xFFFCE7F3),
      badgeText: Color(0xFF9D174D),
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFDF2F8), Color(0xFFFCE7F3)],
      ),
    ),
  ];

  static ModuleRegionTheme forIndex(int index) {
    return biomes[index % biomes.length];
  }
}

/// Unified view model for a topic/milestone node on the winding roadmap.
class RoadmapTopicItem {
  final String id;
  final String title;
  final String? subtitle;
  final RoadmapVisualState visualState;
  final IconData icon;
  final double masteryScore;
  final String difficulty;
  final bool isRemediation;
  final bool isBypassed;
  final int sectionIndex;
  final int topicIndex;
  final bool isYouTube;
  final int durationSeconds;
  final String? conceptId;
  final Object rawSource;

  const RoadmapTopicItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.visualState,
    required this.icon,
    this.masteryScore = 0.0,
    this.difficulty = 'beginner',
    this.isRemediation = false,
    this.isBypassed = false,
    required this.sectionIndex,
    required this.topicIndex,
    this.isYouTube = false,
    this.durationSeconds = 0,
    this.conceptId,
    required this.rawSource,
  });

  /// Factory adapter for LearningTopic from the existing dynamic learning system.
  factory RoadmapTopicItem.fromLearningTopic({
    required LearningTopic topic,
    required int sectionIndex,
    required int topicIndex,
    required bool isPathActiveCurrent,
    required bool isPreviousCompletedOrCurrent,
    required bool isFirstInModule,
    required bool isLastOverall,
  }) {
    // 1. Check adaptive remediation and fast-track bypasses from metadata
    final isRem = topic.metadata['is_remediation'] == true ||
        topic.metadata['isRemediation'] == true ||
        topic.metadata['detour'] == true;

    final isByp = topic.metadata['bypassed'] == true ||
        topic.metadata['skipped'] == true ||
        topic.metadata['fast_tracked'] == true;

    // 2. Resolve visual state
    RoadmapVisualState state;
    if (isByp) {
      state = RoadmapVisualState.bypassed;
    } else if (isRem) {
      state = RoadmapVisualState.remediating;
    } else if (topic.status == TopicStatus.completed) {
      state = RoadmapVisualState.completed;
    } else if (topic.status == TopicStatus.needsRevision) {
      state = RoadmapVisualState.needsRevision;
    } else if (topic.status == TopicStatus.learning || isPathActiveCurrent) {
      state = RoadmapVisualState.current;
    } else if (isPreviousCompletedOrCurrent) {
      state = RoadmapVisualState.available;
    } else {
      state = RoadmapVisualState.locked;
    }

    // 3. Select meaningful domain-specific icon
    final icon = _deriveTopicIcon(
      topic.title,
      index: topicIndex,
      isFirst: isFirstInModule && sectionIndex == 0,
      isLast: isLastOverall,
    );

    return RoadmapTopicItem(
      id: topic.id,
      title: topic.title,
      subtitle: topic.description,
      visualState: state,
      icon: icon,
      masteryScore: topic.masteryScore,
      difficulty: topic.difficulty,
      isRemediation: isRem,
      isBypassed: isByp,
      sectionIndex: sectionIndex,
      topicIndex: topicIndex,
      isYouTube: topic.isYouTubeVideo,
      durationSeconds: topic.durationSeconds,
      conceptId: topic.metadata['concept_id']?.toString(),
      rawSource: topic,
    );
  }

  /// Factory adapter for JourneyNode.
  factory RoadmapTopicItem.fromJourneyNode({
    required JourneyNode node,
    required int sectionIndex,
    required int topicIndex,
    required bool isLastOverall,
  }) {
    RoadmapVisualState state;
    final isRem = node.isRemediation || node.status == NodeState.remediating;
    final isByp = node.status == NodeState.bypassed || node.status == NodeState.skipped;

    if (isByp) {
      state = RoadmapVisualState.bypassed;
    } else if (isRem) {
      state = RoadmapVisualState.remediating;
    } else {
      switch (node.status) {
        case NodeState.completed:
          state = RoadmapVisualState.completed;
          break;
        case NodeState.current:
          state = RoadmapVisualState.current;
          break;
        case NodeState.needsRevision:
        case NodeState.needsAttention:
          state = RoadmapVisualState.needsRevision;
          break;
        case NodeState.available:
        case NodeState.upcoming:
          state = RoadmapVisualState.available;
          break;
        case NodeState.locked:
        default:
          state = RoadmapVisualState.locked;
          break;
      }
    }

    final icon = _deriveTopicIcon(
      node.title,
      index: topicIndex,
      isFirst: topicIndex == 0 && sectionIndex == 0,
      isLast: isLastOverall,
    );

    return RoadmapTopicItem(
      id: node.id,
      title: node.title,
      subtitle: node.subtitle,
      visualState: state,
      icon: icon,
      masteryScore: node.progress,
      isRemediation: isRem,
      isBypassed: isByp,
      sectionIndex: sectionIndex,
      topicIndex: topicIndex,
      conceptId: node.conceptId,
      rawSource: node,
    );
  }

  static IconData _deriveTopicIcon(
    String title, {
    int index = 0,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final lower = title.toLowerCase();

    if (isFirst && index == 0) return Icons.star_rounded;
    if (isLast) return Icons.emoji_events_rounded;

    if (lower.contains('code') ||
        lower.contains('python') ||
        lower.contains('syntax') ||
        lower.contains('programming') ||
        lower.contains('script') ||
        lower.contains('dart') ||
        lower.contains('java') ||
        lower.contains('c++') ||
        lower.contains('rust') ||
        lower.contains('go') ||
        lower.contains('kotlin') ||
        lower.contains('swift') ||
        lower.contains('typescript') ||
        lower.contains('javascript')) {
      return Icons.code_rounded;
    }
    if (lower.contains('sql') ||
        lower.contains('database') ||
        lower.contains('table') ||
        lower.contains('query') ||
        lower.contains('postgres') ||
        lower.contains('sqlite') ||
        lower.contains('mongo') ||
        lower.contains('redis') ||
        lower.contains('storage') ||
        lower.contains('schema')) {
      return Icons.dns_rounded;
    }
    if (lower.contains('data') ||
        lower.contains('analysis') ||
        lower.contains('pandas') ||
        lower.contains('numpy') ||
        lower.contains('statistics') ||
        lower.contains('metric') ||
        lower.contains('bi') ||
        lower.contains('chart') ||
        lower.contains('dashboard')) {
      return Icons.bar_chart_rounded;
    }
    if (lower.contains('deep learning') ||
        lower.contains('neural') ||
        lower.contains('cnn') ||
        lower.contains('rnn') ||
        lower.contains('transformer') ||
        lower.contains('tensor') ||
        lower.contains('pytorch') ||
        lower.contains('tensorflow')) {
      return Icons.hub_rounded;
    }
    if (lower.contains('machine learning') ||
        lower.contains('ml') ||
        lower.contains('ai') ||
        lower.contains('model') ||
        lower.contains('predict') ||
        lower.contains('classifier') ||
        lower.contains('nlp')) {
      return Icons.psychology_rounded;
    }
    if (lower.contains('agent') ||
        lower.contains('prompt') ||
        lower.contains('llm') ||
        lower.contains('gpt') ||
        lower.contains('genai') ||
        lower.contains('gemini') ||
        lower.contains('bot')) {
      return Icons.smart_toy_rounded;
    }
    if (lower.contains('api') ||
        lower.contains('rest') ||
        lower.contains('cloud') ||
        lower.contains('http') ||
        lower.contains('network') ||
        lower.contains('backend') ||
        lower.contains('server') ||
        lower.contains('endpoint')) {
      return Icons.cloud_rounded;
    }
    if (lower.contains('ui') ||
        lower.contains('ux') ||
        lower.contains('design') ||
        lower.contains('css') ||
        lower.contains('html') ||
        lower.contains('frontend') ||
        lower.contains('style') ||
        lower.contains('layout') ||
        lower.contains('screen')) {
      return Icons.palette_rounded;
    }
    if (lower.contains('mobile') ||
        lower.contains('flutter') ||
        lower.contains('android') ||
        lower.contains('ios') ||
        lower.contains('widget')) {
      return Icons.phone_android_rounded;
    }
    if (lower.contains('git') ||
        lower.contains('github') ||
        lower.contains('version') ||
        lower.contains('branch') ||
        lower.contains('commit')) {
      return Icons.fork_right_rounded;
    }
    if (lower.contains('docker') ||
        lower.contains('container') ||
        lower.contains('kubernetes') ||
        lower.contains('devops') ||
        lower.contains('ci') ||
        lower.contains('cd') ||
        lower.contains('pipeline')) {
      return Icons.inventory_2_rounded;
    }
    if (lower.contains('system') ||
        lower.contains('architecture') ||
        lower.contains('pattern') ||
        lower.contains('microservice')) {
      return Icons.account_tree_rounded;
    }
    if (lower.contains('terminal') ||
        lower.contains('cli') ||
        lower.contains('command') ||
        lower.contains('bash') ||
        lower.contains('shell') ||
        lower.contains('linux')) {
      return Icons.terminal_rounded;
    }
    if (lower.contains('memory') ||
        lower.contains('pointer') ||
        lower.contains('stack') ||
        lower.contains('heap') ||
        lower.contains('alloc')) {
      return Icons.memory_rounded;
    }
    if (lower.contains('project') ||
        lower.contains('build') ||
        lower.contains('deploy') ||
        lower.contains('capstone') ||
        lower.contains('launch') ||
        lower.contains('app') ||
        lower.contains('production')) {
      return Icons.rocket_launch_rounded;
    }
    if (lower.contains('test') ||
        lower.contains('debug') ||
        lower.contains('qa') ||
        lower.contains('lint') ||
        lower.contains('error') ||
        lower.contains('validation')) {
      return Icons.bug_report_rounded;
    }
    if (lower.contains('algorithm') ||
        lower.contains('structure') ||
        lower.contains('tree') ||
        lower.contains('graph') ||
        lower.contains('sort') ||
        lower.contains('recursion')) {
      return Icons.alt_route_rounded;
    }
    if (lower.contains('math') ||
        lower.contains('function') ||
        lower.contains('calculus') ||
        lower.contains('logic') ||
        lower.contains('equation') ||
        lower.contains('vector') ||
        lower.contains('matrix') ||
        lower.contains('algebra')) {
      return Icons.functions_rounded;
    }
    if (lower.contains('security') ||
        lower.contains('auth') ||
        lower.contains('crypto') ||
        lower.contains('token') ||
        lower.contains('jwt') ||
        lower.contains('permission') ||
        lower.contains('privacy')) {
      return Icons.shield_rounded;
    }
    if (lower.contains('video') ||
        lower.contains('watch') ||
        lower.contains('youtube') ||
        lower.contains('tutorial')) {
      return Icons.play_circle_fill_rounded;
    }
    if (lower.contains('chip') ||
        lower.contains('hardware') ||
        lower.contains('gpu') ||
        lower.contains('cpu')) {
      return Icons.developer_board_rounded;
    }
    if (lower.contains('experiment') ||
        lower.contains('science') ||
        lower.contains('research')) {
      return Icons.science_rounded;
    }
    if (lower.contains('practice') ||
        lower.contains('quiz') ||
        lower.contains('drill') ||
        lower.contains('exercise') ||
        lower.contains('challenge')) {
      return Icons.fitness_center_rounded;
    }

    const fallbacks = [
      Icons.auto_stories_rounded,
      Icons.lightbulb_rounded,
      Icons.explore_rounded,
      Icons.widgets_rounded,
      Icons.layers_rounded,
      Icons.extension_rounded,
    ];
    return fallbacks[index % fallbacks.length];
  }
}

/// Unified view model for a module region on the winding roadmap.
class RoadmapModuleItem {
  final String id;
  final String title;
  final String? description;
  final int orderIndex;
  final double progress;
  final int completedCount;
  final int totalCount;
  final ModuleRegionTheme theme;
  final List<RoadmapTopicItem> topics;

  const RoadmapModuleItem({
    required this.id,
    required this.title,
    this.description,
    required this.orderIndex,
    required this.progress,
    required this.completedCount,
    required this.totalCount,
    required this.theme,
    required this.topics,
  });

  /// True if the module card should be positioned on the LEFT, false for RIGHT.
  /// Alternates: Module 0 (LEFT), Module 1 (RIGHT), Module 2 (LEFT), Module 3 (RIGHT)...
  bool get isCardOnLeft => orderIndex % 2 == 0;
}
