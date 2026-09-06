class Concept {
  final String id;
  final String name;
  final String title;
  final String description;
  final String? domain;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;

  Concept({
    required this.id,
    String? name,
    String? title,
    String? description,
    this.domain,
    this.metadata = const {},
    this.createdAt,
  })  : name = name ?? title ?? '',
        title = title ?? name ?? '',
        description = description ?? '';

  factory Concept.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] ?? json['title'] ?? '';
    return Concept(
      id: json['id']?.toString() ?? '',
      name: rawName,
      title: rawName,
      description: json['description'] ?? '',
      domain: json['domain'],
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'])
          : {},
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'description': description,
        'domain': domain,
        'metadata': metadata,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}

class ConceptEdge {
  final String id;
  final String sourceConceptId;
  final String targetConceptId;
  final String relationshipType;
  final double weight;
  final Map<String, dynamic> metadata;

  ConceptEdge({
    required this.id,
    required this.sourceConceptId,
    required this.targetConceptId,
    required this.relationshipType,
    this.weight = 1.0,
    this.metadata = const {},
  });

  factory ConceptEdge.fromJson(Map<String, dynamic> json) => ConceptEdge(
        id: json['id']?.toString() ?? '',
        sourceConceptId: json['source_concept_id']?.toString() ?? '',
        targetConceptId: json['target_concept_id']?.toString() ?? '',
        relationshipType: json['relationship_type'] ?? 'prerequisite',
        weight: ((json['weight'] ?? 1.0) as num).toDouble(),
        metadata: json['metadata'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['metadata'])
            : {},
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'source_concept_id': sourceConceptId,
        'target_concept_id': targetConceptId,
        'relationship_type': relationshipType,
        'weight': weight,
        'metadata': metadata,
      };
}

