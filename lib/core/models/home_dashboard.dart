class DailyTaskItem {
  final String id;
  final String topicId;
  final String title;
  final int orderIndex;
  final int estimatedMinutes;
  final String difficulty;
  final String status; // NOT_STARTED, LEARNING, COMPLETED
  final List<String> keyConcepts;
  final bool isCurrent;

  const DailyTaskItem({
    required this.id,
    required this.topicId,
    required this.title,
    this.orderIndex = 0,
    this.estimatedMinutes = 25,
    this.difficulty = 'beginner',
    this.status = 'NOT_STARTED',
    this.keyConcepts = const [],
    this.isCurrent = false,
  });

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isLearning => status.toUpperCase() == 'LEARNING';

  DailyTaskItem copyWith({
    String? id,
    String? topicId,
    String? title,
    int? orderIndex,
    int? estimatedMinutes,
    String? difficulty,
    String? status,
    List<String>? keyConcepts,
    bool? isCurrent,
  }) {
    return DailyTaskItem(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      orderIndex: orderIndex ?? this.orderIndex,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      keyConcepts: keyConcepts ?? this.keyConcepts,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  factory DailyTaskItem.fromJson(Map<String, dynamic> json) {
    return DailyTaskItem(
      id: json['id']?.toString() ?? '',
      topicId: json['topic_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 25,
      difficulty: json['difficulty']?.toString() ?? 'beginner',
      status: json['status']?.toString() ?? 'NOT_STARTED',
      keyConcepts: (json['key_concepts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isCurrent: json['is_current'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic_id': topicId,
        'title': title,
        'order_index': orderIndex,
        'estimated_minutes': estimatedMinutes,
        'difficulty': difficulty,
        'status': status,
        'key_concepts': keyConcepts,
        'is_current': isCurrent,
      };
}

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

  // Dynamic Schedule & Backlog Tracking
  final DateTime? targetDeadline;
  final int daysRemaining;
  final String scheduleStatus; // ON_TRACK, BEHIND_SCHEDULE, AHEAD_OF_SCHEDULE, COMPLETED
  final int backlogCount;
  final String? dailyInstructions;
  final String? todayTargetTopicTitle;
  final String? todayTargetTopicId;
  final List<String> todayKeyConcepts;
  final int todayEstimatedMinutes;
  final int dailyCommitmentMinutes;
  final bool isTodayCompleted;
  final String todayStatus; // NOT_STARTED, LEARNING, COMPLETED
  final List<DailyTaskItem> todayTasks;
  final int todayTasksTotal;
  final int todayTasksCompleted;

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
    this.targetDeadline,
    this.daysRemaining = 0,
    this.scheduleStatus = 'ON_TRACK',
    this.backlogCount = 0,
    this.dailyInstructions,
    this.todayTargetTopicTitle,
    this.todayTargetTopicId,
    this.todayKeyConcepts = const [],
    this.todayEstimatedMinutes = 30,
    this.dailyCommitmentMinutes = 30,
    this.isTodayCompleted = false,
    this.todayStatus = 'NOT_STARTED',
    this.todayTasks = const [],
    this.todayTasksTotal = 1,
    this.todayTasksCompleted = 0,
  });

  DailyTaskItem? get currentActionableTask {
    for (final task in todayTasks) {
      if (task.isCurrent && !task.isCompleted) return task;
    }
    for (final task in todayTasks) {
      if (!task.isCompleted) return task;
    }
    return todayTasks.isNotEmpty ? todayTasks.last : null;
  }

  HomeDashboardData copyWith({
    String? goalId,
    String? goalTitle,
    String? targetLevel,
    String? currentModuleName,
    String? currentTopicId,
    String? currentTopicTitle,
    double? overallProgress,
    double? overallMastery,
    int? topicsCompleted,
    int? topicsRemaining,
    int? streakDays,
    int? learningMinutes,
    List<String>? weakAreas,
    String? nextActionTitle,
    String? nextActionReason,
    String? nextActionType,
    String? nextActionTopicId,
    int? revisionDueCount,
    bool? isNewLearner,
    List<String>? insights,
    DateTime? targetDeadline,
    int? daysRemaining,
    String? scheduleStatus,
    int? backlogCount,
    String? dailyInstructions,
    String? todayTargetTopicTitle,
    String? todayTargetTopicId,
    List<String>? todayKeyConcepts,
    int? todayEstimatedMinutes,
    int? dailyCommitmentMinutes,
    bool? isTodayCompleted,
    String? todayStatus,
    List<DailyTaskItem>? todayTasks,
    int? todayTasksTotal,
    int? todayTasksCompleted,
  }) {
    return HomeDashboardData(
      goalId: goalId ?? this.goalId,
      goalTitle: goalTitle ?? this.goalTitle,
      targetLevel: targetLevel ?? this.targetLevel,
      currentModuleName: currentModuleName ?? this.currentModuleName,
      currentTopicId: currentTopicId ?? this.currentTopicId,
      currentTopicTitle: currentTopicTitle ?? this.currentTopicTitle,
      overallProgress: overallProgress ?? this.overallProgress,
      overallMastery: overallMastery ?? this.overallMastery,
      topicsCompleted: topicsCompleted ?? this.topicsCompleted,
      topicsRemaining: topicsRemaining ?? this.topicsRemaining,
      streakDays: streakDays ?? this.streakDays,
      learningMinutes: learningMinutes ?? this.learningMinutes,
      weakAreas: weakAreas ?? this.weakAreas,
      nextActionTitle: nextActionTitle ?? this.nextActionTitle,
      nextActionReason: nextActionReason ?? this.nextActionReason,
      nextActionType: nextActionType ?? this.nextActionType,
      nextActionTopicId: nextActionTopicId ?? this.nextActionTopicId,
      revisionDueCount: revisionDueCount ?? this.revisionDueCount,
      isNewLearner: isNewLearner ?? this.isNewLearner,
      insights: insights ?? this.insights,
      targetDeadline: targetDeadline ?? this.targetDeadline,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      scheduleStatus: scheduleStatus ?? this.scheduleStatus,
      backlogCount: backlogCount ?? this.backlogCount,
      dailyInstructions: dailyInstructions ?? this.dailyInstructions,
      todayTargetTopicTitle:
          todayTargetTopicTitle ?? this.todayTargetTopicTitle,
      todayTargetTopicId: todayTargetTopicId ?? this.todayTargetTopicId,
      todayKeyConcepts: todayKeyConcepts ?? this.todayKeyConcepts,
      todayEstimatedMinutes:
          todayEstimatedMinutes ?? this.todayEstimatedMinutes,
      dailyCommitmentMinutes:
          dailyCommitmentMinutes ?? this.dailyCommitmentMinutes,
      isTodayCompleted: isTodayCompleted ?? this.isTodayCompleted,
      todayStatus: todayStatus ?? this.todayStatus,
      todayTasks: todayTasks ?? this.todayTasks,
      todayTasksTotal: todayTasksTotal ?? this.todayTasksTotal,
      todayTasksCompleted: todayTasksCompleted ?? this.todayTasksCompleted,
    );
  }

  factory HomeDashboardData.fromJson(Map<String, dynamic> json) {
    final parsedTasks = (json['today_tasks'] as List<dynamic>?)
            ?.map((e) => DailyTaskItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];
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
      targetDeadline: json['target_deadline'] != null
          ? DateTime.tryParse(json['target_deadline'].toString())
          : null,
      daysRemaining: (json['days_remaining'] as num?)?.toInt() ?? 0,
      scheduleStatus: json['schedule_status']?.toString() ?? 'ON_TRACK',
      backlogCount: (json['backlog_count'] as num?)?.toInt() ?? 0,
      dailyInstructions: json['daily_instructions']?.toString(),
      todayTargetTopicTitle: json['today_target_topic_title']?.toString(),
      todayTargetTopicId: json['today_target_topic_id']?.toString(),
      todayKeyConcepts: (json['today_key_concepts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      todayEstimatedMinutes:
          (json['today_estimated_minutes'] as num?)?.toInt() ?? 30,
      dailyCommitmentMinutes:
          (json['daily_commitment_minutes'] as num?)?.toInt() ?? 30,
      isTodayCompleted: json['is_today_completed'] == true,
      todayStatus: json['today_status']?.toString() ??
          (json['is_today_completed'] == true ? 'COMPLETED' : 'NOT_STARTED'),
      todayTasks: parsedTasks,
      todayTasksTotal: (json['today_tasks_total'] as num?)?.toInt() ?? (parsedTasks.isNotEmpty ? parsedTasks.length : 1),
      todayTasksCompleted: (json['today_tasks_completed'] as num?)?.toInt() ?? (parsedTasks.where((t) => t.isCompleted).length),
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
        'target_deadline': targetDeadline?.toIso8601String(),
        'days_remaining': daysRemaining,
        'schedule_status': scheduleStatus,
        'backlog_count': backlogCount,
        'daily_instructions': dailyInstructions,
        'today_target_topic_title': todayTargetTopicTitle,
        'today_target_topic_id': todayTargetTopicId,
        'today_key_concepts': todayKeyConcepts,
        'today_estimated_minutes': todayEstimatedMinutes,
        'daily_commitment_minutes': dailyCommitmentMinutes,
        'is_today_completed': isTodayCompleted,
        'today_status': todayStatus,
        'today_tasks': todayTasks.map((t) => t.toJson()).toList(),
        'today_tasks_total': todayTasksTotal,
        'today_tasks_completed': todayTasksCompleted,
      };
}
