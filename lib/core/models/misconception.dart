class Misconception {
  final String id;
  final String userId;
  final String conceptId;
  final String tag;
  final String description;
  final String severity;
  final int occurrences;
  final bool resolved;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Misconception({
    required this.id,
    this.userId = '',
    required this.conceptId,
    required this.tag,
    required this.description,
    this.severity = 'MEDIUM',
    this.occurrences = 1,
    this.resolved = false,
    this.metadata = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  factory Misconception.fromJson(Map<String, dynamic> json) {
    final created = json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now();
    final updated = json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : created;

    return Misconception(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      conceptId: json['concept_id'] ?? '',
      tag: json['tag'] ?? '',
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'MEDIUM',
      occurrences: (json['occurrences'] as num?)?.toInt() ?? 1,
      resolved: json['resolved'] == true,
      metadata: json['metadata'] is Map<String, dynamic> 
          ? Map<String, dynamic>.from(json['metadata']) 
          : {},
      createdAt: created,
      updatedAt: updated,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'concept_id': conceptId,
    'tag': tag,
    'description': description,
    'severity': severity,
    'occurrences': occurrences,
    'resolved': resolved,
    'metadata': metadata,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Misconception copyWith({
    String? id,
    String? userId,
    String? conceptId,
    String? tag,
    String? description,
    String? severity,
    int? occurrences,
    bool? resolved,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Misconception(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      conceptId: conceptId ?? this.conceptId,
      tag: tag ?? this.tag,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      occurrences: occurrences ?? this.occurrences,
      resolved: resolved ?? this.resolved,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
