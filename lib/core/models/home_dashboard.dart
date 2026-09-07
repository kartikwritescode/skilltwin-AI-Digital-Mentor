class HomeDashboardData {
  final String? goalId;
  final String goalTitle;
  final String targetLevel;
  final String? currentModuleName;
  final String? currentTopicId;
  final String? currentTopicTitle;
  final double overallProgress;
  final double overallMastery;
  final int topicsCompleted;
  final int topicsRemaining;
  final int streakDays;
  final int learningMinutes;
  final List<String> weakAreas;
  final String nextActionTitle;
  final String nextActionReason;
  final String nextActionType;
  final String? nextActionTopicId;
  final int revisionDueCount;
  final bool isNewLearner;
  final List<String> insights;

  const HomeDashboardData({
    this.goalId,
    this.goalTitle = 'No Active Goal',
    this.targetLevel = 'Beginner',
    this.currentModuleName,
    this.currentTopicId,
    this.currentTopicTitle,
    this.overallProgress = 0.0,
    this.overallMastery = 0.0,
    this.topicsCompleted = 0,
    this.topicsRemaining = 0,
    this.streakDays = 0,
    this.learningMinutes = 0,
    this.weakAreas = const [],
    this.nextActionTitle = 'Start your journey',
    this.nextActionReason =
        'Begin your first foundational topic to establish baseline mastery.',
    this.nextActionType = 'LEARN',
    this.nextActionTopicId,
    this.revisionDueCount = 0,
    this.isNewLearner = true,
    this.insights = const [],
  });

  factory HomeDashboardData.fromJson(Map<String, dynamic> json) {
    return HomeDashboardData(
      goalId: json['goal_id']?.toString(),
      goalTitle: json['goal_title']?.toString() ?? 'No Active Goal',
      targetLevel: json['target_level']?.toString() ?? 'Beginner',
      currentModuleName: json['current_module_name']?.toString(),
      currentTopicId: json['current_topic_id']?.toString(),
      currentTopicTitle: json['current_topic_title']?.toString(),
      overallProgress: ((json['overall_progress'] ?? 0.0) as num).toDouble(),
      overallMastery: ((json['overall_mastery'] ?? 0.0) as num).toDouble(),
      topicsCompleted: (json['topics_completed'] as num?)?.toInt() ?? 0,
      topicsRemaining: (json['topics_remaining'] as num?)?.toInt() ?? 0,
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      learningMinutes: (json['learning_minutes'] as num?)?.toInt() ?? 0,
      weakAreas: (json['weak_areas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      nextActionTitle: json['next_action_title']?.toString() ?? 'Start your journey',
      nextActionReason: json['next_action_reason']?.toString() ??
          'Begin your first foundational topic to establish baseline mastery.',
      nextActionType: json['next_action_type']?.toString() ?? 'LEARN',
      nextActionTopicId: json['next_action_topic_id']?.toString(),
      revisionDueCount: (json['revision_due_count'] as num?)?.toInt() ?? 0,
      isNewLearner: json['is_new_learner'] == true,
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'goal_id': goalId,
        'goal_title': goalTitle,
        'target_level': targetLevel,
        'current_module_name': currentModuleName,
        'current_topic_id': currentTopicId,
        'current_topic_title': currentTopicTitle,
        'overall_progress': overallProgress,
        'overall_mastery': overallMastery,
        'topics_completed': topicsCompleted,
        'topics_remaining': topicsRemaining,
        'streak_days': streakDays,
        'learning_minutes': learningMinutes,
        'weak_areas': weakAreas,
        'next_action_title': nextActionTitle,
        'next_action_reason': nextActionReason,
        'next_action_type': nextActionType,
        'next_action_topic_id': nextActionTopicId,
        'revision_due_count': revisionDueCount,
        'is_new_learner': isNewLearner,
        'insights': insights,
      };
}
