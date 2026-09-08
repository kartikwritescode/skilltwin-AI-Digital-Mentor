enum TopicStatus {
  notStarted,
  learning,
  completed,
  needsRevision;

  static TopicStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'learning':
        return TopicStatus.learning;
      case 'completed':
        return TopicStatus.completed;
      case 'needs_revision':
      case 'needsrevision':
        return TopicStatus.needsRevision;
      case 'not_started':
      default:
        return TopicStatus.notStarted;
    }
  }

  String toApiString() {
    switch (this) {
      case TopicStatus.learning:
        return 'learning';
      case TopicStatus.completed:
        return 'completed';
      case TopicStatus.needsRevision:
        return 'needs_revision';
      case TopicStatus.notStarted:
        return 'not_started';
    }
  }
}

class LearningTopic {
  final String id;
  final String sectionId;
  final String title;
  final String? description;
  final int orderIndex;
  final String difficulty;
  final int estimatedMinutes;
  final List<String> prerequisites;
  final List<String> learningObjectives;
  final TopicStatus status;
  final double masteryScore;
  final double confidenceScore;
  final int revisionCount;
  final DateTime? completedAt;
  final DateTime? nextRevisionAt;

  const LearningTopic({
    required this.id,
    required this.sectionId,
    required this.title,
    this.description,
    required this.orderIndex,
    this.difficulty = 'beginner',
    this.estimatedMinutes = 25,
    this.prerequisites = const [],
    this.learningObjectives = const [],
    this.status = TopicStatus.notStarted,
    this.masteryScore = 0.0,
    this.confidenceScore = 0.0,
    this.revisionCount = 0,
    this.completedAt,
    this.nextRevisionAt,
  });

  factory LearningTopic.fromJson(Map<String, dynamic> json) {
    return LearningTopic(
      id: json['id']?.toString() ?? '',
      sectionId: json['section_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty']?.toString() ?? 'beginner',
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 25,
      prerequisites: (json['prerequisites'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      learningObjectives: (json['learning_objectives'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: TopicStatus.fromString(json['status']?.toString()),
      masteryScore: ((json['mastery_score'] ?? 0.0) as num).toDouble(),
      confidenceScore: ((json['confidence_score'] ?? 0.0) as num).toDouble(),
      revisionCount: (json['revision_count'] as num?)?.toInt() ?? 0,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      nextRevisionAt: json['next_revision_at'] != null
          ? DateTime.tryParse(json['next_revision_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'section_id': sectionId,
        'title': title,
        'description': description,
        'order_index': orderIndex,
        'difficulty': difficulty,
        'estimated_minutes': estimatedMinutes,
        'prerequisites': prerequisites,
        'learning_objectives': learningObjectives,
        'status': status.toApiString(),
        'mastery_score': masteryScore,
        'confidence_score': confidenceScore,
        'revision_count': revisionCount,
        'completed_at': completedAt?.toIso8601String(),
        'next_revision_at': nextRevisionAt?.toIso8601String(),
      };

  LearningTopic copyWith({
    String? id,
    String? sectionId,
    String? title,
    String? description,
    int? orderIndex,
    String? difficulty,
    int? estimatedMinutes,
    List<String>? prerequisites,
    List<String>? learningObjectives,
    TopicStatus? status,
    double? masteryScore,
    double? confidenceScore,
    int? revisionCount,
    DateTime? completedAt,
    DateTime? nextRevisionAt,
  }) {
    return LearningTopic(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      difficulty: difficulty ?? this.difficulty,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      prerequisites: prerequisites ?? this.prerequisites,
      learningObjectives: learningObjectives ?? this.learningObjectives,
      status: status ?? this.status,
      masteryScore: masteryScore ?? this.masteryScore,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      revisionCount: revisionCount ?? this.revisionCount,
      completedAt: completedAt ?? this.completedAt,
      nextRevisionAt: nextRevisionAt ?? this.nextRevisionAt,
    );
  }
}

class LearningSection {
  final String id;
  final String pathId;
  final String title;
  final String? description;
  final int orderIndex;
  final List<LearningTopic> topics;

  const LearningSection({
    required this.id,
    required this.pathId,
    required this.title,
    this.description,
    required this.orderIndex,
    this.topics = const [],
  });

  factory LearningSection.fromJson(Map<String, dynamic> json) {
    final rawTopics = json['topics'] as List<dynamic>? ?? [];
    return LearningSection(
      id: json['id']?.toString() ?? '',
      pathId: json['path_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      topics: rawTopics
          .map((t) => LearningTopic.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'path_id': pathId,
        'title': title,
        'description': description,
        'order_index': orderIndex,
        'topics': topics.map((t) => t.toJson()).toList(),
      };

  double get progress {
    if (topics.isEmpty) return 0.0;
    final completedCount =
        topics.where((t) => t.status == TopicStatus.completed).length;
    return completedCount / topics.length;
  }

  LearningSection copyWith({
    String? id,
    String? pathId,
    String? title,
    String? description,
    int? orderIndex,
    List<LearningTopic>? topics,
  }) {
    return LearningSection(
      id: id ?? this.id,
      pathId: pathId ?? this.pathId,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      topics: topics ?? this.topics,
    );
  }
}

class LearningPath {
  final String id;
  final String goalId;
  final String userId;
  final String title;
  final String? description;
  final String targetLevel;
  final String? estimatedDuration;
  final int version;
  final String status;
  final String generationStatus;
  final String? generationError;
  final double progress;
  final List<LearningSection> sections;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LearningPath({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.title,
    this.description,
    this.targetLevel = 'Intermediate',
    this.estimatedDuration,
    this.version = 1,
    this.status = 'ACTIVE',
    this.generationStatus = 'READY',
    this.generationError,
    this.progress = 0.0,
    this.sections = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory LearningPath.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'] as List<dynamic>? ?? [];
    return LearningPath(
      id: json['id']?.toString() ?? '',
      goalId: json['goal_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      targetLevel: json['target_level']?.toString() ?? 'Intermediate',
      estimatedDuration: json['estimated_duration']?.toString(),
      version: (json['version'] as num?)?.toInt() ?? 1,
      status: json['status']?.toString() ?? 'ACTIVE',
      generationStatus: json['generation_status']?.toString() ?? 'READY',
      generationError: json['generation_error']?.toString(),
      progress: ((json['progress'] ?? 0.0) as num).toDouble(),
      sections: rawSections
          .map((s) => LearningSection.fromJson(s as Map<String, dynamic>))
          .toList(),
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
        'goal_id': goalId,
        'user_id': userId,
        'title': title,
        'description': description,
        'target_level': targetLevel,
        'estimated_duration': estimatedDuration,
        'version': version,
        'status': status,
        'generation_status': generationStatus,
        'generation_error': generationError,
        'progress': progress,
        'sections': sections.map((s) => s.toJson()).toList(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  LearningPath copyWith({
    String? id,
    String? goalId,
    String? userId,
    String? title,
    String? description,
    String? targetLevel,
    String? estimatedDuration,
    int? version,
    String? status,
    String? generationStatus,
    String? generationError,
    double? progress,
    List<LearningSection>? sections,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LearningPath(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetLevel: targetLevel ?? this.targetLevel,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      version: version ?? this.version,
      status: status ?? this.status,
      generationStatus: generationStatus ?? this.generationStatus,
      generationError: generationError ?? this.generationError,
      progress: progress ?? this.progress,
      sections: sections ?? this.sections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get totalTopics =>
      sections.fold(0, (sum, sec) => sum + sec.topics.length);

  int get completedTopics => sections.fold(
        0,
        (sum, sec) =>
            sum +
            sec.topics.where((t) => t.status == TopicStatus.completed).length,
      );
}
