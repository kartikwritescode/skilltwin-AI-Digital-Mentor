enum ConceptStatus { notLearned, learning, uncertain, mastered, needsReview }

class LearnerConcept {
  final String id;
  final String userId;
  final String conceptId;
  final double mastery;
  final double confidence;
  final double retention;
  final double risk;
  final ConceptStatus status;
  final int evidenceCount;
  final DateTime? lastSeenAt;
  final DateTime? lastRetrievedAt;
  final DateTime? nextReviewAt;
  final Map<String, dynamic> metadata;
  final List<String> misconceptionTags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LearnerConcept({
    this.id = '',
    this.userId = '',
    required this.conceptId,
    required this.mastery,
    required this.confidence,
    required this.retention,
    required this.risk,
    required this.status,
    this.evidenceCount = 0,
    this.lastSeenAt,
    this.lastRetrievedAt,
    this.nextReviewAt,
    this.metadata = const {},
    this.misconceptionTags = const [],
    this.createdAt,
    this.updatedAt,
  });

  double get masteryScore => mastery;
  double get confidenceScore => confidence;
  double get retentionScore => retention;
  double get riskScore => risk;

  static ConceptStatus _parseStatus(dynamic raw) {
    if (raw == null) return ConceptStatus.notLearned;
    final str = raw.toString().toUpperCase().replaceAll(' ', '_');
    switch (str) {
      case 'NOT_LEARNED':
        return ConceptStatus.notLearned;
      case 'LEARNING':
        return ConceptStatus.learning;
      case 'UNCERTAIN':
        return ConceptStatus.uncertain;
      case 'MASTERED':
        return ConceptStatus.mastered;
      case 'NEEDS_REVIEW':
        return ConceptStatus.needsReview;
      default:
        return ConceptStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == raw.toString().toLowerCase(),
          orElse: () => ConceptStatus.notLearned,
        );
    }
  }

  static String _statusToString(ConceptStatus s) {
    switch (s) {
      case ConceptStatus.notLearned:
        return 'NOT_LEARNED';
      case ConceptStatus.learning:
        return 'LEARNING';
      case ConceptStatus.uncertain:
        return 'UNCERTAIN';
      case ConceptStatus.mastered:
        return 'MASTERED';
      case ConceptStatus.needsReview:
        return 'NEEDS_REVIEW';
    }
  }

  factory LearnerConcept.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['metadata'])
        : <String, dynamic>{};

    final rawTags = json['misconception_tags'] ?? meta['misconceptions'] ?? [];
    final tags = rawTags is List ? rawTags.map((e) => e.toString()).toList() : <String>[];

    return LearnerConcept(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      conceptId: json['concept_id']?.toString() ?? '',
      mastery: ((json['mastery_score'] ?? json['mastery'] ?? 0.0) as num).toDouble(),
      confidence: ((json['confidence_score'] ?? json['confidence'] ?? 0.0) as num).toDouble(),
      retention: ((json['retention_score'] ?? json['retention'] ?? 0.0) as num).toDouble(),
      risk: ((json['risk_score'] ?? json['risk'] ?? 0.0) as num).toDouble(),
      status: _parseStatus(json['status']),
      evidenceCount: (json['evidence_count'] as num?)?.toInt() ?? 0,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.tryParse(json['last_seen_at'].toString())
          : null,
      lastRetrievedAt: json['last_retrieved_at'] != null
          ? DateTime.tryParse(json['last_retrieved_at'].toString())
          : null,
      nextReviewAt: json['next_review_at'] != null
          ? DateTime.tryParse(json['next_review_at'].toString())
          : null,
      metadata: meta,
      misconceptionTags: tags,
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
        'concept_id': conceptId,
        'mastery_score': mastery,
        'mastery': mastery,
        'confidence_score': confidence,
        'confidence': confidence,
        'retention_score': retention,
        'retention': retention,
        'risk_score': risk,
        'risk': risk,
        'status': _statusToString(status),
        'evidence_count': evidenceCount,
        if (lastSeenAt != null) 'last_seen_at': lastSeenAt!.toIso8601String(),
        if (lastRetrievedAt != null)
          'last_retrieved_at': lastRetrievedAt!.toIso8601String(),
        if (nextReviewAt != null)
          'next_review_at': nextReviewAt!.toIso8601String(),
        'metadata': {
          ...metadata,
          if (misconceptionTags.isNotEmpty) 'misconceptions': misconceptionTags,
        },
        'misconception_tags': misconceptionTags,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };
}

