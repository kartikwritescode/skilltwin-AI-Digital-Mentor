enum RecommendationType {
  practice,
  revision,
  newConcept,
  remediation,
  assessment,
}

class MentorRecommendation {
  final String id;
  final String userId;
  final String goalId;
  final String? conceptId;
  final String? journeyNodeId;
  final RecommendationType type;
  final String title;
  final String? description;
  final int priority;
  final int? estimatedMinutes;
  final bool accepted;
  final bool completed;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  // Backward compatibility getters
  String get reason => description ?? '';
  String get actionTitle => title;
  String get actionType => type.name;
  Map<String, dynamic> get actionData => metadata;

  MentorRecommendation({
    required this.id,
    this.userId = '',
    this.goalId = '',
    this.conceptId,
    this.journeyNodeId,
    RecommendationType? type,
    String? title,
    String? description,
    this.priority = 0,
    this.estimatedMinutes,
    this.accepted = false,
    this.completed = false,
    this.metadata = const {},
    DateTime? createdAt,
    // Legacy compatibility arguments
    String? reason,
    String? actionTitle,
    String? actionType,
    Map<String, dynamic>? actionData,
  })  : type = type ?? _parseType(actionType),
        title = title ?? actionTitle ?? 'Recommendation',
        description = description ?? reason,
        createdAt = createdAt ?? DateTime.now();

  static RecommendationType _parseType(dynamic value) {
    if (value == null) return RecommendationType.practice;
    final str = value.toString().toUpperCase().replaceAll(' ', '_');
    switch (str) {
      case 'PRACTICE':
        return RecommendationType.practice;
      case 'REVISION':
        return RecommendationType.revision;
      case 'NEW_CONCEPT':
        return RecommendationType.newConcept;
      case 'REMEDIATION':
        return RecommendationType.remediation;
      case 'ASSESSMENT':
        return RecommendationType.assessment;
      default:
        return RecommendationType.values.firstWhere(
          (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
          orElse: () => RecommendationType.practice,
        );
    }
  }

  factory MentorRecommendation.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['metadata'])
        : (json['action_data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['action_data'])
            : <String, dynamic>{});

    return MentorRecommendation(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      goalId: json['goal_id'] ?? '',
      conceptId: json['concept_id'],
      journeyNodeId: json['journey_node_id'],
      type: _parseType(json['type'] ?? json['action_type']),
      title: json['title'] ?? json['action_title'] ?? 'Recommendation',
      description: json['description'] ?? json['reason'],
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt(),
      accepted: json['accepted'] == true,
      completed: json['completed'] == true,
      metadata: meta,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'goal_id': goalId,
    'concept_id': conceptId,
    'journey_node_id': journeyNodeId,
    'type': type == RecommendationType.newConcept ? 'NEW_CONCEPT' : type.name.toUpperCase(),
    'title': title,
    'description': description,
    'priority': priority,
    'estimated_minutes': estimatedMinutes,
    'accepted': accepted,
    'completed': completed,
    'metadata': metadata,
    'created_at': createdAt.toIso8601String(),
    // Legacy fields
    'reason': reason,
    'action_title': actionTitle,
    'action_type': actionType,
    'action_data': metadata,
  };

  MentorRecommendation copyWith({
    String? id,
    String? userId,
    String? goalId,
    String? conceptId,
    String? journeyNodeId,
    RecommendationType? type,
    String? title,
    String? description,
    int? priority,
    int? estimatedMinutes,
    bool? accepted,
    bool? completed,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return MentorRecommendation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalId: goalId ?? this.goalId,
      conceptId: conceptId ?? this.conceptId,
      journeyNodeId: journeyNodeId ?? this.journeyNodeId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      accepted: accepted ?? this.accepted,
      completed: completed ?? this.completed,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

typedef Recommendation = MentorRecommendation;

