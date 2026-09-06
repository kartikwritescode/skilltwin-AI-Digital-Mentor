import 'session_step.dart';

enum SessionType { learn, revise, practice, prove, teach, remediate, reflect }

enum SessionStatus { created, inProgress, completed, abandoned }

class LearningSession {
  final String id;
  final String userId;
  final String? goalId;
  final String? journeyNodeId;
  final String conceptId;
  final String conceptTitle;
  final String? recommendationId;
  final SessionType type;
  final SessionStatus status;
  final int durationMinutes;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? score;
  final double? confidence;
  final Map<String, dynamic> result;
  final String whyStatement;
  final List<SessionStep> steps;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LearningSession({
    required this.id,
    this.userId = '',
    this.goalId,
    this.journeyNodeId,
    required this.conceptId,
    required this.conceptTitle,
    this.recommendationId,
    required this.type,
    this.status = SessionStatus.created,
    required this.durationMinutes,
    this.startedAt,
    this.completedAt,
    this.score,
    this.confidence,
    this.result = const {},
    required this.whyStatement,
    required this.steps,
    this.createdAt,
    this.updatedAt,
  });

  static SessionType _parseType(dynamic raw) {
    if (raw == null) return SessionType.learn;
    final str = raw.toString().toUpperCase().replaceAll(' ', '_');
    switch (str) {
      case 'LEARN':
        return SessionType.learn;
      case 'REVISE':
        return SessionType.revise;
      case 'PRACTICE':
        return SessionType.practice;
      case 'PROVE':
        return SessionType.prove;
      case 'TEACH':
        return SessionType.teach;
      case 'REMEDIATE':
        return SessionType.remediate;
      case 'REFLECT':
        return SessionType.reflect;
      default:
        return SessionType.values.firstWhere(
          (e) => e.name.toLowerCase() == raw.toString().toLowerCase(),
          orElse: () => SessionType.learn,
        );
    }
  }

  static SessionStatus _parseStatus(dynamic raw) {
    if (raw == null) return SessionStatus.created;
    final str = raw.toString().toUpperCase().replaceAll(' ', '_');
    switch (str) {
      case 'CREATED':
        return SessionStatus.created;
      case 'IN_PROGRESS':
      case 'INPROGRESS':
        return SessionStatus.inProgress;
      case 'COMPLETED':
        return SessionStatus.completed;
      case 'ABANDONED':
        return SessionStatus.abandoned;
      default:
        return SessionStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == raw.toString().toLowerCase(),
          orElse: () => SessionStatus.created,
        );
    }
  }

  factory LearningSession.fromJson(Map<String, dynamic> json) => LearningSession(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        goalId: json['goal_id']?.toString(),
        journeyNodeId: json['journey_node_id']?.toString(),
        conceptId: json['concept_id']?.toString() ?? '',
        conceptTitle: json['concept_title'] ?? json['concept_name'] ?? '',
        recommendationId: json['recommendation_id']?.toString(),
        type: _parseType(json['type']),
        status: _parseStatus(json['status']),
        durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
        startedAt: json['started_at'] != null
            ? DateTime.tryParse(json['started_at'].toString())
            : null,
        completedAt: json['completed_at'] != null
            ? DateTime.tryParse(json['completed_at'].toString())
            : null,
        score: (json['score'] as num?)?.toDouble(),
        confidence: (json['confidence'] as num?)?.toDouble(),
        result: json['result'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['result'])
            : {},
        whyStatement: json['why_statement'] ?? '',
        steps: (json['steps'] as List?)
                ?.map((e) => SessionStep.fromJson(e))
                .toList() ??
            [],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'goal_id': goalId,
        'journey_node_id': journeyNodeId,
        'concept_id': conceptId,
        'concept_title': conceptTitle,
        'recommendation_id': recommendationId,
        'type': type.name.toUpperCase(),
        'status': status == SessionStatus.inProgress
            ? 'IN_PROGRESS'
            : status.name.toUpperCase(),
        'duration_minutes': durationMinutes,
        if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
        if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
        'score': score,
        'confidence': confidence,
        'result': result,
        'why_statement': whyStatement,
        'steps': steps.map((e) => e.toJson()).toList(),
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };
}

