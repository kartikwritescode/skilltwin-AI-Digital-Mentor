enum RetentionRisk { low, medium, high }

enum SessionResult {
  mastered,
  progressed,
  needsReview,
  failed,
}

class RevisionItem {
  final String id;
  final String userId;
  final String conceptId;
  final String title;
  final double mastery;
  final RetentionRisk risk;
  final DateTime lastRetrieval;
  final DateTime dueAt;
  final int intervalDays;
  final double easeFactor;
  final int successfulRetrievals;
  final int failedRetrievals;
  final SessionResult? lastResult;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  // UI fields & legacy aliases
  final String mentorNote;
  final String whyToday;
  final String mentorPrompt;
  final int estimatedMinutes;
  final double priorityScore;
  final String? nextReviewText;

  DateTime get dueDate => dueAt;
  int get interval => intervalDays;

  RevisionItem({
    String? id,
    this.userId = '',
    required this.conceptId,
    required this.title,
    required this.mastery,
    required this.risk,
    required this.lastRetrieval,
    DateTime? dueAt,
    DateTime? dueDate,
    required this.mentorNote,
    String? whyToday,
    String? mentorPrompt,
    this.estimatedMinutes = 4,
    this.priorityScore = 0.0,
    int? intervalDays,
    int? interval,
    this.easeFactor = 2.5,
    this.successfulRetrievals = 0,
    this.failedRetrievals = 0,
    this.lastResult,
    this.metadata = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
    this.nextReviewText,
  })  : id = id ?? conceptId,
        dueAt = dueAt ?? dueDate ?? DateTime.now(),
        intervalDays = intervalDays ?? interval ?? 1,
        whyToday = whyToday ?? mentorNote,
        mentorPrompt = mentorPrompt ??
            'Give me $estimatedMinutes minutes. I want to check whether your mental model is intact.',
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  String get lastReviewedFormatted {
    final diff = DateTime.now().difference(lastRetrieval);
    if (diff.inDays <= 0) {
      if (diff.inHours <= 0) {
        return 'Earlier today';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  static SessionResult? _parseSessionResult(dynamic value) {
    if (value == null) return null;
    final str = value.toString().toUpperCase().replaceAll(' ', '_');
    switch (str) {
      case 'MASTERED':
        return SessionResult.mastered;
      case 'PROGRESSED':
        return SessionResult.progressed;
      case 'NEEDS_REVIEW':
        return SessionResult.needsReview;
      case 'FAILED':
        return SessionResult.failed;
      default:
        return null;
    }
  }

  factory RevisionItem.fromJson(Map<String, dynamic> json) {
    final rawRisk = (json['retention_risk'] ?? json['risk'] ?? 'medium').toString().toLowerCase();
    final riskEnum = RetentionRisk.values.firstWhere(
      (e) => e.name.toLowerCase() == rawRisk,
      orElse: () => RetentionRisk.medium,
    );

    final rawLast = json['last_reviewed'] ?? json['last_reviewed_at'] ?? json['last_retrieval'];
    final parsedLast = rawLast != null
        ? DateTime.tryParse(rawLast.toString()) ?? DateTime.now().subtract(const Duration(days: 3))
        : DateTime.now().subtract(const Duration(days: 3));

    final rawDue = json['due_at'] ?? json['next_review'] ?? json['due_date'];
    final parsedDue = rawDue != null
        ? DateTime.tryParse(rawDue.toString()) ?? DateTime.now()
        : DateTime.now();

    final title = json['concept_name'] ?? json['title'] ?? json['concept_id'] ?? 'Concept';
    final why = json['why_today'] ?? json['mentor_note'] ?? 'Memory decay threshold reached. Spaced retrieval anchors foundational invariants.';
    final prompt = json['mentor_prompt'] ?? 'Give me 4 minutes. I want to check whether your mental model is intact.';

    final created = json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now();
    final updated = json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : created;

    return RevisionItem(
      id: json['id']?.toString() ?? json['concept_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      conceptId: json['concept_id']?.toString() ?? '',
      title: title,
      mastery: ((json['retention_score'] ?? json['mastery'] ?? 75.0) as num).toDouble() /
          ((json['retention_score'] != null && (json['retention_score'] as num) > 1.0) ? 100.0 : 1.0),
      risk: riskEnum,
      lastRetrieval: parsedLast,
      dueAt: parsedDue,
      mentorNote: why,
      whyToday: why,
      mentorPrompt: prompt,
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 4,
      priorityScore: ((json['priority_score'] ?? 0.0) as num).toDouble(),
      intervalDays: (json['interval_days'] ?? json['interval'] ?? 1) as int,
      easeFactor: ((json['ease_factor'] ?? 2.5) as num).toDouble(),
      successfulRetrievals: (json['successful_retrievals'] as num?)?.toInt() ?? 0,
      failedRetrievals: (json['failed_retrievals'] as num?)?.toInt() ?? 0,
      lastResult: _parseSessionResult(json['last_result']),
      metadata: json['metadata'] is Map<String, dynamic> 
          ? Map<String, dynamic>.from(json['metadata']) 
          : {},
      createdAt: created,
      updatedAt: updated,
      nextReviewText: json['next_review_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'concept_id': conceptId,
        'due_at': dueAt.toIso8601String(),
        'interval_days': intervalDays,
        'ease_factor': easeFactor,
        'successful_retrievals': successfulRetrievals,
        'failed_retrievals': failedRetrievals,
        'last_result': lastResult != null 
            ? (lastResult == SessionResult.needsReview ? 'NEEDS_REVIEW' : lastResult!.name.toUpperCase())
            : null,
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        // UI & backward compatibility fields
        'title': title,
        'concept_name': title,
        'retention_risk': risk.name,
        'mastery': mastery,
        'last_reviewed': lastRetrieval.toIso8601String(),
        'next_review': dueAt.toIso8601String(),
        'why_today': whyToday,
        'mentor_prompt': mentorPrompt,
        'estimated_minutes': estimatedMinutes,
        'priority_score': priorityScore,
        'interval': intervalDays,
        'next_review_text': nextReviewText,
      };
}

typedef ReviewItem = RevisionItem;


class RevisionQueueData {
  final String header;
  final int totalDueCount;
  final RevisionItem? primaryItem;
  final List<RevisionItem> upcomingItems;
  final String mentorGuidance;

  RevisionQueueData({
    this.header = '5 minutes for your future self.',
    required this.totalDueCount,
    this.primaryItem,
    this.upcomingItems = const [],
    this.mentorGuidance =
        'Consistent 5-minute retrieval is the single highest-yield cognitive investment.',
  });

  List<RevisionItem> get allQueueItems {
    final list = <RevisionItem>[];
    if (primaryItem != null) list.add(primaryItem!);
    list.addAll(upcomingItems);
    return list;
  }

  factory RevisionQueueData.fromJson(Map<String, dynamic> json) {
    RevisionItem? primary;
    if (json['primary_review_item'] != null) {
      primary = RevisionItem.fromJson(json['primary_review_item']);
    }
    final upcoming = (json['upcoming_items'] as List?)
            ?.map((e) => RevisionItem.fromJson(e))
            .toList() ??
        [];

    return RevisionQueueData(
      header: json['header'] ?? '5 minutes for your future self.',
      totalDueCount: (json['total_due_count'] as num?)?.toInt() ?? (primary != null ? 1 + upcoming.length : upcoming.length),
      primaryItem: primary,
      upcomingItems: upcoming,
      mentorGuidance: json['mentor_guidance'] ??
          'Consistent 5-minute retrieval is the single highest-yield cognitive investment.',
    );
  }
}

class RetrievalSubmissionResult {
  final String reviewItemId;
  final String nextReviewText;
  final int intervalDays;
  final RetentionRisk updatedRisk;
  final double updatedRetentionScore;

  RetrievalSubmissionResult({
    required this.reviewItemId,
    required this.nextReviewText,
    required this.intervalDays,
    required this.updatedRisk,
    required this.updatedRetentionScore,
  });

  factory RetrievalSubmissionResult.fromJson(Map<String, dynamic> json) {
    final rawRisk = (json['retention_risk'] ?? 'low').toString().toLowerCase();
    final riskEnum = RetentionRisk.values.firstWhere(
      (e) => e.name.toLowerCase() == rawRisk,
      orElse: () => RetentionRisk.low,
    );
    final interval = (json['interval'] ?? json['interval_days'] ?? 3) as int;
    final text = json['next_review_text'] ?? 'Next review in $interval ${interval == 1 ? "day" : "days"}.';

    return RetrievalSubmissionResult(
      reviewItemId: json['id']?.toString() ?? json['review_item_id']?.toString() ?? '',
      nextReviewText: text,
      intervalDays: interval,
      updatedRisk: riskEnum,
      updatedRetentionScore: ((json['retention_score'] ?? 92.0) as num).toDouble(),
    );
  }
}

