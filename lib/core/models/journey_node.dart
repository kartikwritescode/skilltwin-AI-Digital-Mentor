enum NodeStatus { completed, current, needsAttention, upcoming, locked, skipped }

typedef JourneyNodeState = NodeStatus;

class JourneyNode {
  final String id;
  final String journeyId;
  final String? conceptId;
  final String title;
  final String? subtitle;
  final String? phase;
  final int nodeOrder;
  final int estimatedMinutes;
  final NodeStatus status;
  final double progress;
  final Map<String, dynamic> metadata;
  final List<String> prerequisites;
  final String? whyItMatters;
  final String? mentorRecommendation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JourneyNode({
    required this.id,
    this.journeyId = '',
    this.conceptId,
    required this.title,
    this.subtitle,
    this.phase,
    this.nodeOrder = 0,
    this.estimatedMinutes = 0,
    required this.status,
    this.progress = 0.0,
    this.metadata = const {},
    this.prerequisites = const [],
    this.whyItMatters,
    this.mentorRecommendation,
    this.createdAt,
    this.updatedAt,
  });

  NodeStatus get state => status;

  static NodeStatus _parseStatus(dynamic raw) {
    if (raw == null) return NodeStatus.upcoming;
    final str = raw.toString().toUpperCase().replaceAll(' ', '_');
    switch (str) {
      case 'COMPLETED':
        return NodeStatus.completed;
      case 'CURRENT':
        return NodeStatus.current;
      case 'NEEDS_ATTENTION':
      case 'NEEDSATTENTION':
        return NodeStatus.needsAttention;
      case 'UPCOMING':
        return NodeStatus.upcoming;
      case 'LOCKED':
        return NodeStatus.locked;
      case 'SKIPPED':
        return NodeStatus.skipped;
      default:
        return NodeStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == raw.toString().toLowerCase(),
          orElse: () => NodeStatus.upcoming,
        );
    }
  }

  static String _statusToString(NodeStatus s) {
    switch (s) {
      case NodeStatus.completed:
        return 'COMPLETED';
      case NodeStatus.current:
        return 'CURRENT';
      case NodeStatus.needsAttention:
        return 'NEEDS_ATTENTION';
      case NodeStatus.upcoming:
        return 'UPCOMING';
      case NodeStatus.locked:
        return 'LOCKED';
      case NodeStatus.skipped:
        return 'SKIPPED';
    }
  }

  factory JourneyNode.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['metadata'])
        : <String, dynamic>{};

    final prereqs = json['prerequisites'] != null
        ? List<String>.from(json['prerequisites'])
        : (meta['prerequisites'] != null
            ? List<String>.from(meta['prerequisites'])
            : <String>[]);

    return JourneyNode(
      id: json['id']?.toString() ?? '',
      journeyId: json['journey_id']?.toString() ?? '',
      conceptId: json['concept_id']?.toString(),
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      phase: json['phase'],
      nodeOrder: (json['node_order'] as num?)?.toInt() ?? 0,
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 0,
      status: _parseStatus(json['state'] ?? json['status']),
      progress: ((json['progress'] ?? 0.0) as num).toDouble(),
      metadata: meta,
      prerequisites: prereqs,
      whyItMatters: json['why_it_matters'] ?? meta['why_it_matters'],
      mentorRecommendation:
          json['mentor_recommendation'] ?? meta['mentor_recommendation'],
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
        'journey_id': journeyId,
        'concept_id': conceptId,
        'title': title,
        'subtitle': subtitle,
        'phase': phase,
        'node_order': nodeOrder,
        'estimated_minutes': estimatedMinutes,
        'state': _statusToString(status),
        'status': status.name,
        'progress': progress,
        'metadata': {
          ...metadata,
          if (whyItMatters != null) 'why_it_matters': whyItMatters,
          if (mentorRecommendation != null)
            'mentor_recommendation': mentorRecommendation,
          if (prerequisites.isNotEmpty) 'prerequisites': prerequisites,
        },
        'prerequisites': prerequisites,
        'why_it_matters': whyItMatters,
        'mentor_recommendation': mentorRecommendation,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };
}

