class AreaMasteryItem {
  final String name;
  final double masteryScore;
  final String status;

  const AreaMasteryItem({
    required this.name,
    required this.masteryScore,
    required this.status,
  });

  factory AreaMasteryItem.fromJson(Map<String, dynamic> json) {
    return AreaMasteryItem(
      name: json['name']?.toString() ?? '',
      masteryScore: ((json['mastery_score'] ?? 0.0) as num).toDouble(),
      status: json['status']?.toString() ?? 'LEARNING',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'mastery_score': masteryScore,
        'status': status,
      };
}

class TwinDashboardData {
  final String userId;
  final bool hasSufficientData;
  final double overallMastery;
  final String learningLevel;
  final List<AreaMasteryItem> strongestAreas;
  final List<AreaMasteryItem> weakestAreas;
  final List<String> conceptsAtRisk;
  final double learningVelocity;
  final int consistencyStreak;
  final double knowledgeCoverage;
  final int verifiedEvidenceCount;
  final List<String> insights;

  const TwinDashboardData({
    required this.userId,
    this.hasSufficientData = false,
    this.overallMastery = 0.0,
    this.learningLevel = 'Beginner',
    this.strongestAreas = const [],
    this.weakestAreas = const [],
    this.conceptsAtRisk = const [],
    this.learningVelocity = 0.0,
    this.consistencyStreak = 0,
    this.knowledgeCoverage = 0.0,
    this.verifiedEvidenceCount = 0,
    this.insights = const [],
  });

  factory TwinDashboardData.fromJson(Map<String, dynamic> json) {
    final strongest = (json['strongest_areas'] as List<dynamic>? ?? [])
        .map((e) => AreaMasteryItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final weakest = (json['weakest_areas'] as List<dynamic>? ?? [])
        .map((e) => AreaMasteryItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return TwinDashboardData(
      userId: json['user_id']?.toString() ?? '',
      hasSufficientData: json['has_sufficient_data'] == true,
      overallMastery: ((json['overall_mastery'] ?? 0.0) as num).toDouble(),
      learningLevel: json['learning_level']?.toString() ?? 'Beginner',
      strongestAreas: strongest,
      weakestAreas: weakest,
      conceptsAtRisk: (json['concepts_at_risk'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      learningVelocity:
          ((json['learning_velocity'] ?? 0.0) as num).toDouble(),
      consistencyStreak: (json['consistency_streak'] as num?)?.toInt() ?? 0,
      knowledgeCoverage:
          ((json['knowledge_coverage'] ?? 0.0) as num).toDouble(),
      verifiedEvidenceCount:
          (json['verified_evidence_count'] as num?)?.toInt() ?? 0,
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  factory TwinDashboardData.fromHomeData(dynamic homeData) {
    // Allows fast synchronous synthesis of baseline Twin state from available Home data
    final isNew = homeData.isNewLearner == true && (homeData.topicsCompleted ?? 0) == 0;
    final int topicsDone = (homeData.topicsCompleted ?? 0) as int;
    final double mastery = ((homeData.overallMastery ?? 0.0) as num).toDouble();
    final double progress = ((homeData.overallProgress ?? 0.0) as num).toDouble();
    final int streak = (homeData.streakDays ?? 0) as int;
    final String level = homeData.targetLevel?.toString() ?? 'Beginner';
    final List<String> weak = (homeData.weakAreas as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [];
    final List<String> ins = (homeData.insights as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [];

    return TwinDashboardData(
      userId: '',
      hasSufficientData: !isNew,
      overallMastery: mastery,
      learningLevel: level,
      strongestAreas: topicsDone > 0
          ? [
              AreaMasteryItem(
                name: homeData.currentModuleName?.toString() ?? 'Current Curriculum',
                masteryScore: (mastery * 100).clamp(0.0, 100.0),
                status: 'In Progress',
              ),
            ]
          : const [],
      weakestAreas: weak
          .map((w) => AreaMasteryItem(name: w, masteryScore: 50.0, status: 'Needs Revision'))
          .toList(),
      conceptsAtRisk: weak,
      learningVelocity: topicsDone > 0 ? (topicsDone / 4.0).clamp(0.5, 5.0) : 0.0,
      consistencyStreak: streak,
      knowledgeCoverage: progress,
      verifiedEvidenceCount: topicsDone,
      insights: ins,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'has_sufficient_data': hasSufficientData,
        'overall_mastery': overallMastery,
        'learning_level': learningLevel,
        'strongest_areas': strongestAreas.map((e) => e.toJson()).toList(),
        'weakest_areas': weakestAreas.map((e) => e.toJson()).toList(),
        'concepts_at_risk': conceptsAtRisk,
        'learning_velocity': learningVelocity,
        'consistency_streak': consistencyStreak,
        'knowledge_coverage': knowledgeCoverage,
        'verified_evidence_count': verifiedEvidenceCount,
        'insights': insights,
      };
}
