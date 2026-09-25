enum NodeState {
  locked,
  available,
  current,
  completed,
  needsRevision,
  remediating,
  bypassed,
  // Backwards compatibility aliases
  upcoming,
  needsAttention,
  skipped,
}

typedef NodeStatus = NodeState;
typedef JourneyNodeState = NodeState;

class JourneyNode {
  final String id;
  final String journeyId;
  final String? conceptId;
  final String title;
  final String? subtitle;
  final String? phase;
  final int nodeOrder;
  final int estimatedMinutes;
  final NodeState status;
  final double progress;
  final Map<String, dynamic> metadata;
  final List<String> prerequisites;
  final String? whyItMatters;
  final String? mentorRecommendation;
  final bool isRemediation;
  final String? splicedAfterNodeId;
  final bool isElaborated;
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
    this.isRemediation = false,
    this.splicedAfterNodeId,
    this.isElaborated = false,
    this.createdAt,
    this.updatedAt,
  });

  NodeState get state => status;

  static NodeState _parseStatus(dynamic raw) {
    if (raw == null) return NodeState.available;
    final str = raw.toString().toUpperCase().replaceAll(' ', '_');
    switch (str) {
      case 'COMPLETED':
        return NodeState.completed;
      case 'CURRENT':
        return NodeState.current;
      case 'NEEDS_REVISION':
      case 'NEEDSREVISION':
      case 'NEEDS_ATTENTION':
      case 'NEEDSATTENTION':
        return NodeState.needsRevision;
      case 'AVAILABLE':
      case 'UPCOMING':
        return NodeState.available;
      case 'LOCKED':
        return NodeState.locked;
      case 'REMEDIATING':
        return NodeState.remediating;
      case 'BYPASSED':
      case 'SKIPPED':
        return NodeState.bypassed;
      default:
        return NodeState.values.firstWhere(
          (e) => e.name.toLowerCase() == raw.toString().toLowerCase(),
          orElse: () => NodeState.available,
        );
    }
  }

  static String _statusToString(NodeState s) {
    switch (s) {
      case NodeState.completed:
        return 'COMPLETED';
      case NodeState.current:
        return 'CURRENT';
      case NodeState.needsRevision:
      case NodeState.needsAttention:
        return 'NEEDS_REVISION';
      case NodeState.available:
      case NodeState.upcoming:
        return 'AVAILABLE';
      case NodeState.locked:
        return 'LOCKED';
      case NodeState.remediating:
        return 'REMEDIATING';
      case NodeState.bypassed:
      case NodeState.skipped:
        return 'BYPASSED';
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

    final bool isRem = json['is_remediation'] == true ||
        meta['is_remediation'] == true ||
        (json['state']?.toString().toUpperCase() == 'REMEDIATING');

    final String? splicedAfter = json['spliced_after_node_id']?.toString() ??
        meta['spliced_after_node_id']?.toString();

    final bool isElab = json['is_elaborated'] == true ||
        meta['is_elaborated'] == true ||
        json['content'] != null ||
        meta['content'] != null;

    return JourneyNode(
      id: json['id']?.toString() ?? '',
      journeyId: json['journey_id']?.toString() ?? json['path_id']?.toString() ?? '',
      conceptId: json['concept_id']?.toString(),
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      phase: json['phase'],
      nodeOrder: (json['order_index'] as num?)?.toInt() ??
          (json['node_order'] as num?)?.toInt() ??
          0,
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ??
          (meta['estimated_minutes'] as num?)?.toInt() ??
          0,
      status: _parseStatus(json['state'] ?? json['status']),
      progress: ((json['progress'] ?? json['mastery_score'] ?? 0.0) as num).toDouble(),
      metadata: meta,
      prerequisites: prereqs,
      whyItMatters: json['why_it_matters'] ?? meta['why_it_matters'],
      mentorRecommendation:
          json['mentor_recommendation'] ?? meta['mentor_recommendation'],
      isRemediation: isRem,
      splicedAfterNodeId: splicedAfter,
      isElaborated: isElab,
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
        'is_remediation': isRemediation,
        if (splicedAfterNodeId != null) 'spliced_after_node_id': splicedAfterNodeId,
        'is_elaborated': isElaborated,
        'metadata': {
          ...metadata,
          'is_remediation': isRemediation,
          if (splicedAfterNodeId != null)
            'spliced_after_node_id': splicedAfterNodeId,
          'is_elaborated': isElaborated,
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

typedef PathNode = JourneyNode;
