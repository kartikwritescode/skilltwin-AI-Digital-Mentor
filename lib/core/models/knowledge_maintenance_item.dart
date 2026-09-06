enum MaintenanceStatus { keep, revise, fix, learnNext, deprioritize }

class KnowledgeMaintenanceItem {
  final String id;
  final String conceptId;
  final String conceptTitle;
  final MaintenanceStatus status;
  final String reason;
  final String mentorRecommendation;
  final String? ctaAction;
  final String? ctaLabel;

  KnowledgeMaintenanceItem({
    required this.id,
    required this.conceptId,
    required this.conceptTitle,
    required this.status,
    required this.reason,
    required this.mentorRecommendation,
    this.ctaAction,
    this.ctaLabel,
  });

  factory KnowledgeMaintenanceItem.fromJson(Map<String, dynamic> json) => KnowledgeMaintenanceItem(
    id: json['id'] ?? '',
    conceptId: json['concept_id'] ?? '',
    conceptTitle: json['concept_title'] ?? '',
    status: MaintenanceStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == json['status'].toString().toLowerCase(),
      orElse: () => MaintenanceStatus.keep,
    ),
    reason: json['reason'] ?? '',
    mentorRecommendation: json['mentor_recommendation'] ?? '',
    ctaAction: json['cta_action'],
    ctaLabel: json['cta_label'],
  );
}
