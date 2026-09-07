enum GoalStatus { active, paused, completed, archived }

class Goal {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? desiredOutcome;
  final DateTime? deadline;
  final String? currentLevel;
  final String? targetLevel;
  final String? customTarget;
  final String? activePathId;
  final int dailyMinutes;
  final String? dailyTime;
  final List<String> existingKnowledge;
  final List<String> preferredResources;
  final dynamic constraints;
  final String? targetBenchmark;
  final double progress;
  final GoalStatus status;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Goal({
    required this.id,
    this.userId = '',
    required this.title,
    String? description,
    String? desiredOutcome,
    this.deadline,
    this.currentLevel,
    this.targetLevel,
    this.customTarget,
    this.activePathId,
    int? dailyMinutes,
    String? dailyTime,
    this.existingKnowledge = const [],
    this.preferredResources = const [],
    this.constraints,
    this.targetBenchmark,
    this.progress = 0.0,
    GoalStatus? status,
    bool isCompleted = false,
    this.createdAt,
    this.updatedAt,
  })  : description = description ?? desiredOutcome,
        desiredOutcome = desiredOutcome ?? description,
        dailyMinutes = dailyMinutes ?? _parseDailyMinutes(dailyTime),
        dailyTime = dailyTime ?? '${dailyMinutes ?? 30} mins/day',
        status = status ?? (isCompleted ? GoalStatus.completed : GoalStatus.active),
        isCompleted = isCompleted || status == GoalStatus.completed;

  static int _parseDailyMinutes(String? text) {
    if (text == null) return 30;
    final match = RegExp(r'\d+').firstMatch(text);
    return match != null ? int.tryParse(match.group(0)!) ?? 30 : 30;
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? 'ACTIVE').toString().toUpperCase();
    final statusEnum = GoalStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == rawStatus,
      orElse: () => GoalStatus.active,
    );

    final desc = json['description'] ?? json['desired_outcome'];
    final rawKnowledge = json['existing_knowledge'];
    List<String> parsedKnowledge = [];
    if (rawKnowledge is List) {
      parsedKnowledge = rawKnowledge.map((e) => e.toString()).toList();
    } else if (rawKnowledge is String && rawKnowledge.isNotEmpty) {
      parsedKnowledge = [rawKnowledge];
    }

    final dMinutes = (json['daily_minutes'] as num?)?.toInt() ??
        _parseDailyMinutes(json['daily_time']?.toString());

    final completedBool = json['is_completed'] == true || statusEnum == GoalStatus.completed;

    return Goal(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: desc,
      desiredOutcome: desc,
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'].toString())
          : null,
      currentLevel: json['current_level'] ?? json['target_level'],
      targetLevel: json['target_level'] ?? json['current_level'] ?? 'Intermediate',
      customTarget: json['custom_target'],
      activePathId: json['active_journey_id'] ?? json['active_path_id'],
      dailyMinutes: dMinutes,
      dailyTime: json['daily_time'] ?? '$dMinutes mins/day',
      existingKnowledge: parsedKnowledge,
      preferredResources: List<String>.from(json['preferred_resources'] ?? []),
      constraints: json['constraints'],
      targetBenchmark: json['target_benchmark'] ?? json['custom_target'],
      progress: ((json['progress'] ?? 0.0) as num).toDouble(),
      status: statusEnum,
      isCompleted: completedBool,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'learning_goal': title,
        'description': description,
        'desired_outcome': desiredOutcome,
        'deadline': deadline?.toIso8601String().split('T').first,
        'current_level': currentLevel,
        'target_level': targetLevel ?? currentLevel ?? 'Intermediate',
        'custom_target': customTarget,
        'active_path_id': activePathId,
        'daily_minutes': dailyMinutes,
        'daily_time': dailyTime,
        'existing_knowledge': existingKnowledge.isNotEmpty
            ? existingKnowledge.join(', ')
            : null,
        'preferred_resources': preferredResources,
        'constraints': constraints is List ? constraints : (constraints != null ? [constraints] : []),
        'target_benchmark': targetBenchmark,
        'progress': progress,
        'status': status.name.toUpperCase(),
        'is_completed': isCompleted,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? desiredOutcome,
    DateTime? deadline,
    String? currentLevel,
    String? targetLevel,
    String? customTarget,
    String? activePathId,
    int? dailyMinutes,
    String? dailyTime,
    List<String>? existingKnowledge,
    List<String>? preferredResources,
    dynamic constraints,
    String? targetBenchmark,
    double? progress,
    GoalStatus? status,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      desiredOutcome: desiredOutcome ?? this.desiredOutcome,
      deadline: deadline ?? this.deadline,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      customTarget: customTarget ?? this.customTarget,
      activePathId: activePathId ?? this.activePathId,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      dailyTime: dailyTime ?? this.dailyTime,
      existingKnowledge: existingKnowledge ?? this.existingKnowledge,
      preferredResources: preferredResources ?? this.preferredResources,
      constraints: constraints ?? this.constraints,
      targetBenchmark: targetBenchmark ?? this.targetBenchmark,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get progressPercent => progress > 1.0 ? progress : progress * 100.0;
}

