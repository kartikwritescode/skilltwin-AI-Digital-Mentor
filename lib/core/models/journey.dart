import 'journey_node.dart';

enum JourneyStatus { pending, processing, ready, failed }

class Journey {
  final String id;
  final String goalId;
  final String title;
  final int version;
  final JourneyStatus status;
  final double progress;
  final Map<String, dynamic> metadata;
  final List<JourneyNode> nodes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Journey({
    required this.id,
    required this.goalId,
    this.title = 'Learning Journey',
    this.version = 1,
    this.status = JourneyStatus.ready,
    this.progress = 0.0,
    this.metadata = const {},
    this.nodes = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? 'READY').toString().toUpperCase();
    final statusEnum = JourneyStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == rawStatus,
      orElse: () => JourneyStatus.ready,
    );

    final rawNodes = json['nodes'] as List?;
    final parsedNodes = rawNodes != null
        ? rawNodes.map((e) => JourneyNode.fromJson(e)).toList()
        : <JourneyNode>[];

    return Journey(
      id: json['id']?.toString() ?? '',
      goalId: json['goal_id']?.toString() ?? '',
      title: json['title'] ?? 'Learning Journey',
      version: (json['version'] as num?)?.toInt() ?? 1,
      status: statusEnum,
      progress: ((json['progress'] ?? 0.0) as num).toDouble(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'])
          : {},
      nodes: parsedNodes,
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
        'title': title,
        'version': version,
        'status': status.name.toUpperCase(),
        'progress': progress,
        'metadata': metadata,
        'nodes': nodes.map((e) => e.toJson()).toList(),
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  Journey copyWith({
    String? id,
    String? goalId,
    String? title,
    int? version,
    JourneyStatus? status,
    double? progress,
    Map<String, dynamic>? metadata,
    List<JourneyNode>? nodes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Journey(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      version: version ?? this.version,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      metadata: metadata ?? this.metadata,
      nodes: nodes ?? this.nodes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

