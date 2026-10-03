import 'package:flutter/material.dart';
import '../../../../core/models/home_dashboard.dart';
import '../../../../core/models/twin_dashboard.dart';
import '../../../home/presentation/providers/today_task_provider.dart';

/// Contextual personality model for the SkillTwin companion.
/// Dynamically evaluates real learner state to select appropriate mascot poses,
/// witty companion dialogue, archetype traits, and evolution level.
class TwinCompanionPersona {
  final String mascotAssetPath;
  final String stageTitle;
  final String stageSubtitle;
  final String wittyMessage;
  final String statusTag;
  final Color statusColor;
  final String evolutionStageName;
  final int evolutionStageNumber;
  final String archetypeTitle;
  final String archetypeDescription;
  final IconData archetypeIcon;
  final String conversationalHeadline;
  final String conversationalPrompt;
  final String primaryActionTitle;
  final String primaryActionSubtitle;
  final String? targetTopicId;
  final bool isAtRisk;

  const TwinCompanionPersona({
    required this.mascotAssetPath,
    required this.stageTitle,
    required this.stageSubtitle,
    required this.wittyMessage,
    required this.statusTag,
    required this.statusColor,
    required this.evolutionStageName,
    required this.evolutionStageNumber,
    required this.archetypeTitle,
    required this.archetypeDescription,
    required this.archetypeIcon,
    this.conversationalHeadline = "Here's what I think you should do next:",
    this.conversationalPrompt = "Let's dive into your next milestone to solidify your mastery.",
    this.primaryActionTitle = "Continue Today's Focus",
    this.primaryActionSubtitle = "25 min session target",
    this.targetTopicId,
    this.isAtRisk = false,
  });

  factory TwinCompanionPersona.fromState({
    required TwinDashboardData twinData,
    HomeDashboardData? homeData,
    TodayTaskState? todayState,
  }) {
    // 1. Calculate Evolution Stage from verified empirical proofs
    final verifiedProofs = twinData.verifiedEvidenceCount > 0
        ? twinData.verifiedEvidenceCount
        : (homeData?.topicsCompleted ?? 0);

    final int stageNum;
    final String stageName;
    if (verifiedProofs >= 25) {
      stageNum = 5;
      stageName = 'Master Twin';
    } else if (verifiedProofs >= 15) {
      stageNum = 4;
      stageName = 'Deep Synthesizer';
    } else if (verifiedProofs >= 8) {
      stageNum = 3;
      stageName = 'Building Twin';
    } else if (verifiedProofs >= 3) {
      stageNum = 2;
      stageName = 'Exploring Twin';
    } else {
      stageNum = 1;
      stageName = 'Calibrating Twin';
    }

    // 2. Resolve Dynamic Topic & Action Context
    final String activeTopicTitle = todayState?.topicTitle ??
        homeData?.todayTargetTopicTitle ??
        homeData?.nextActionTitle ??
        (twinData.strongestAreas.isNotEmpty ? twinData.strongestAreas.first.name : 'Next Curriculum Milestone');
    final String? topicId = todayState?.topicId ?? homeData?.todayTargetTopicId ?? homeData?.nextActionTopicId;
    final int estMins = todayState?.estimatedMinutes ??
        homeData?.todayEstimatedMinutes ??
        homeData?.dailyCommitmentMinutes ??
        25;
    final bool hasRisk = twinData.conceptsAtRisk.isNotEmpty || (homeData?.weakAreas.isNotEmpty ?? false);
    final String? riskConcept = twinData.conceptsAtRisk.isNotEmpty
        ? twinData.conceptsAtRisk.first
        : (homeData?.weakAreas.isNotEmpty == true ? homeData!.weakAreas.first : null);

    // 3. Resolve Pose & Contextual Witty Personality
    final streak = twinData.consistencyStreak > 0
        ? twinData.consistencyStreak
        : (homeData?.streakDays ?? 0);
    final isAhead = homeData?.scheduleStatus == 'AHEAD_OF_SCHEDULE';
    final isBehind = homeData?.scheduleStatus == 'BEHIND_SCHEDULE' ||
        (homeData?.backlogCount ?? 0) > 0 ||
        hasRisk;
    final isTodayDone = todayState?.isCompleted == true ||
        (homeData?.isTodayCompleted == true) ||
        (homeData?.todayStatus.toUpperCase() == 'COMPLETED');
    final isLearningNow = todayState?.isLearning == true ||
        (homeData?.todayStatus.toUpperCase() == 'LEARNING');
    final isMasteryHigh = twinData.overallMastery >= 0.75 ||
        (homeData != null && homeData.overallMastery >= 0.75);

    // State 1: Ahead of Schedule / Burning streak
    if ((isAhead && streak >= 2) || streak >= 5) {
      return TwinCompanionPersona(
        mascotAssetPath: 'assets/mascots/twin_streak_fire.webp',
        stageTitle: 'Your Twin is cooking',
        stageSubtitle:
            'Moving faster than your roadmap schedule with strong retention.',
        wittyMessage: 'Okay, you\'re actually cooking.',
        statusTag: 'AHEAD OF PACE',
        statusColor: const Color(0xFF059669),
        evolutionStageName: stageName,
        evolutionStageNumber: stageNum,
        archetypeTitle: 'The Relentless Sprinter',
        archetypeDescription:
            'Blazing learning velocity coupled with active daily streak momentum.',
        archetypeIcon: Icons.bolt_rounded,
        conversationalHeadline: "Here's what I think you should do next:",
        conversationalPrompt:
            "You're moving faster than scheduled with great retention. Let's tackle '$activeTopicTitle' to push your streak even further.",
        primaryActionTitle: "Dive into '$activeTopicTitle'",
        primaryActionSubtitle: "$estMins min session • Ahead of pace",
        targetTopicId: topicId,
        isAtRisk: false,
      );
    }

    // State 2: Crushed today's session
    if (isTodayDone) {
      return TwinCompanionPersona(
        mascotAssetPath: 'assets/mascots/twin_celebrate.webp',
        stageTitle: 'Your Twin is celebrating',
        stageSubtitle:
            'Daily mission cleared. Synapses consolidated and resting.',
        wittyMessage: 'Daily mission cleared. You showed up and delivered.',
        statusTag: 'TODAY COMPLETE',
        statusColor: const Color(0xFF10B981),
        evolutionStageName: stageName,
        evolutionStageNumber: stageNum,
        archetypeTitle: 'The Consistent Achiever',
        archetypeDescription:
            'Reliable daily follow-through that compounds into effortless mastery.',
        archetypeIcon: Icons.emoji_events_rounded,
        conversationalHeadline: "Here's what I think you should do next:",
        conversationalPrompt:
            "Daily mission cleared! Your synapses have consolidated today's proofs. Feel free to explore ahead or take a well-deserved rest.",
        primaryActionTitle: "Explore Next Milestone",
        primaryActionSubtitle: "Preview upcoming topic",
        targetTopicId: topicId,
        isAtRisk: false,
      );
    }

    // State 3: Actively in learning session
    if (isLearningNow) {
      return TwinCompanionPersona(
        mascotAssetPath: 'assets/mascots/twin_coding.webp',
        stageTitle: 'Your Twin is in the zone',
        stageSubtitle:
            'Actively absorbing concepts and constructing cognitive proofs.',
        wittyMessage: 'Deep in the zone. Let\'s cement this proof.',
        statusTag: 'SESSION ACTIVE',
        statusColor: const Color(0xFF2563EB),
        evolutionStageName: stageName,
        evolutionStageNumber: stageNum,
        archetypeTitle: 'The Focused Deep-Diver',
        archetypeDescription:
            'Prefers immersive problem solving and hands-on conceptual rigor.',
        archetypeIcon: Icons.code_rounded,
        conversationalHeadline: "Here's what I think you should do next:",
        conversationalPrompt:
            "You're deep in the zone on '$activeTopicTitle'. Let's finish the remaining practice questions to lock in mastery.",
        primaryActionTitle: "Resume '$activeTopicTitle'",
        primaryActionSubtitle: "$estMins min session in progress",
        targetTopicId: topicId,
        isAtRisk: false,
      );
    }

    // State 4: Behind Schedule or At-Risk concepts
    if (isBehind) {
      return TwinCompanionPersona(
        mascotAssetPath: 'assets/mascots/twin_streak_warning.webp',
        stageTitle: 'Your Twin needs a quick boost',
        stageSubtitle:
            'A few concepts are due for reinforcement to prevent memory decay.',
        wittyMessage: 'We\'ve got some catching up to do.',
        statusTag: 'CATCH-UP MODE',
        statusColor: const Color(0xFFD97706),
        evolutionStageName: stageName,
        evolutionStageNumber: stageNum,
        archetypeTitle: 'The Comeback Strategist',
        archetypeDescription:
            'Targeting knowledge blindspots and calibrating pace to recover velocity.',
        archetypeIcon: Icons.auto_fix_high_rounded,
        conversationalHeadline: "Here's what I think you should do next:",
        conversationalPrompt:
            "A few concepts like '${riskConcept ?? 'recent topics'}' are decaying in memory. 10 minutes of spaced practice now will protect your hard-earned retention.",
        primaryActionTitle: "Review ${riskConcept ?? 'Weak Concepts'}",
        primaryActionSubtitle: "10 min spaced review",
        targetTopicId: topicId,
        isAtRisk: true,
      );
    }

    // State 5: Developing consistency (streak 2..4)
    if (streak >= 2) {
      return TwinCompanionPersona(
        mascotAssetPath: 'assets/mascots/twin_growing.webp',
        stageTitle: 'Your Twin is evolving',
        stageSubtitle:
            'Strengthening neural pathways through steady daily repetitions.',
        wittyMessage: 'Look who\'s becoming consistent.',
        statusTag: 'HABIT FORMING',
        statusColor: const Color(0xFF6366F1),
        evolutionStageName: stageName,
        evolutionStageNumber: stageNum,
        archetypeTitle: 'The Steady Architect',
        archetypeDescription:
            'Lays solid conceptual bricks day by day with compounding retention.',
        archetypeIcon: Icons.architecture_rounded,
        conversationalHeadline: "Here's what I think you should do next:",
        conversationalPrompt:
            "You're building solid consistency day by day. Let's complete '$activeTopicTitle' to keep your momentum going.",
        primaryActionTitle: "Continue '$activeTopicTitle'",
        primaryActionSubtitle: "$estMins min target • Day $streak streak",
        targetTopicId: topicId,
        isAtRisk: false,
      );
    }

    // State 6: Domain Mastery
    if (isMasteryHigh) {
      return TwinCompanionPersona(
        mascotAssetPath: 'assets/mascots/twin_streak_legend.webp',
        stageTitle: 'Your Twin is mastering the domain',
        stageSubtitle:
            'High proof verification scores across core curriculum topics.',
        wittyMessage: 'Unstoppable velocity. Your cognitive twin is proud.',
        statusTag: 'DOMAIN MASTER',
        statusColor: const Color(0xFF7C3AED),
        evolutionStageName: stageName,
        evolutionStageNumber: stageNum,
        archetypeTitle: 'The Deep Synthesizer',
        archetypeDescription:
            'Effortlessly connects foundational concepts into systemic understanding.',
        archetypeIcon: Icons.psychology_rounded,
        conversationalHeadline: "Here's what I think you should do next:",
        conversationalPrompt:
            "High proof verification across your curriculum! Continue with '$activeTopicTitle' to push into advanced concepts.",
        primaryActionTitle: "Advance '$activeTopicTitle'",
        primaryActionSubtitle: "$estMins min advanced target",
        targetTopicId: topicId,
        isAtRisk: false,
      );
    }

    // State 7: Default / Curious & Ready
    return TwinCompanionPersona(
      mascotAssetPath: 'assets/mascots/twin_curious.webp',
      stageTitle: 'Your Twin is calibrated & ready',
      stageSubtitle:
          'Every completed lesson calibrates your companion\'s memory model.',
      wittyMessage: 'Alright. Let\'s build this thing.',
      statusTag: 'READY TO LEARN',
      statusColor: const Color(0xFF4F46E5),
      evolutionStageName: stageName,
      evolutionStageNumber: stageNum,
      archetypeTitle: 'The Curious Explorer',
      archetypeDescription:
          'Building foundational intuition across new technical horizons.',
      archetypeIcon: Icons.explore_rounded,
      conversationalHeadline: "Here's what I think you should do next:",
      conversationalPrompt:
          "Let's focus on '$activeTopicTitle'. A focused $estMins-minute session today will build verified conceptual proof.",
      primaryActionTitle: "Continue Today's Focus",
      primaryActionSubtitle: "$estMins min session target",
      targetTopicId: topicId,
      isAtRisk: false,
    );
  }
}
