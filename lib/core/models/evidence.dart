enum EvidenceType {
  recall,
  practice,
  explanation,
  teachBack,
  project,
  assessment,
  delayedRetrieval,
}

class Evidence {
  final String id;
  final String userId;
  final String conceptId;
  final String? sessionId;
  final EvidenceType type;
  final double? score;
  final double? confidence;
  final Map<String, dynamic> details;
  final String description;
  final DateTime createdAt;

  Evidence({
    required this.id,
    this.userId = '',
    required this.conceptId,
    this.sessionId,
    this.type = EvidenceType.practice,
    this.score,
    this.confidence,
    this.details = const {},
    String? description,
    DateTime? createdAt,
    DateTime? timestamp,
  })  : createdAt = createdAt ?? timestamp ?? DateTime.now(),
        description = description ?? details['description']?.toString() ?? '';

  DateTime get timestamp => createdAt;

  static EvidenceType _parseType(dynamic raw) {
    if (raw == null) return EvidenceType.practice;
    final str = raw.toString().toUpperCase().replaceAll(' ', '_');
    switch (str) {
      case 'RECALL':
        return EvidenceType.recall;
      case 'PRACTICE':
        return EvidenceType.practice;
      case 'EXPLANATION':
        return EvidenceType.explanation;
      case 'TEACH_BACK':
      case 'TEACHBACK':
        return EvidenceType.teachBack;
      case 'PROJECT':
        return EvidenceType.project;
      case 'ASSESSMENT':
        return EvidenceType.assessment;
      case 'DELAYED_RETRIEVAL':
      case 'DELAYEDRETRIEVAL':
        return EvidenceType.delayedRetrieval;
      default:
        return EvidenceType.values.firstWhere(
          (e) => e.name.toLowerCase() == raw.toString().toLowerCase(),
          orElse: () => EvidenceType.practice,
        );
    }
  }

  static String _typeToString(EvidenceType t) {
    switch (t) {
      case EvidenceType.recall:
        return 'RECALL';
      case EvidenceType.practice:
        return 'PRACTICE';
      case EvidenceType.explanation:
        return 'EXPLANATION';
      case EvidenceType.teachBack:
        return 'TEACH_BACK';
      case EvidenceType.project:
        return 'PROJECT';
      case EvidenceType.assessment:
        return 'ASSESSMENT';
      case EvidenceType.delayedRetrieval:
        return 'DELAYED_RETRIEVAL';
    }
  }

  factory Evidence.fromJson(Map<String, dynamic> json) {
    final detailsMap = json['details'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['details'])
        : <String, dynamic>{};

    final rawDate = json['created_at'] ?? json['timestamp'];
    final parsedDate = rawDate != null
        ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
        : DateTime.now();

    final desc = json['description'] ?? detailsMap['description'] ?? '';

    return Evidence(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      conceptId: json['concept_id']?.toString() ?? '',
      sessionId: json['session_id']?.toString(),
      type: _parseType(json['type']),
      score: (json['score'] as num?)?.toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble(),
      details: detailsMap,
      description: desc.toString(),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'concept_id': conceptId,
        'session_id': sessionId,
        'type': _typeToString(type),
        'score': score,
        'confidence': confidence,
        'details': {
          ...details,
          if (description.isNotEmpty) 'description': description,
        },
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'timestamp': createdAt.toIso8601String(),
      };
}

