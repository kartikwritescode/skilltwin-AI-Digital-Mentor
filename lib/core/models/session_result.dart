class SessionResult {
  final String sessionId;
  final String conceptId;
  final String conceptTitle;
  
  // Progress Deltas
  final double masteryDelta;
  final double confidenceDelta;
  
  // New Absolute States
  final double currentMastery;
  final double currentConfidence;
  
  final List<String> improvements;
  final List<String> focusAreas;
  final String mentorRecommendation;
  
  // Detailed Evaluation Signals
  final double accuracyScore;
  final double completenessScore;
  final String? reasoningFeedback;
  final List<String> identifiedMisconceptions;
  
  final Map<String, dynamic> evidenceSummary;

  SessionResult({
    required this.sessionId,
    required this.conceptId,
    required this.conceptTitle,
    required this.masteryDelta,
    required this.confidenceDelta,
    required this.currentMastery,
    required this.currentConfidence,
    required this.improvements,
    required this.focusAreas,
    required this.mentorRecommendation,
    required this.accuracyScore,
    required this.completenessScore,
    this.reasoningFeedback,
    this.identifiedMisconceptions = const [],
    required this.evidenceSummary,
  });

  factory SessionResult.fromJson(Map<String, dynamic> json) => SessionResult(
        sessionId: json['session_id'] ?? '',
        conceptId: json['concept_id'] ?? '',
        conceptTitle: json['concept_title'] ?? '',
        masteryDelta: (json['mastery_delta'] ?? 0.0).toDouble(),
        confidenceDelta: (json['confidence_delta'] ?? 0.0).toDouble(),
        currentMastery: (json['current_mastery'] ?? 0.0).toDouble(),
        currentConfidence: (json['current_confidence'] ?? 0.0).toDouble(),
        improvements: List<String>.from(json['improvements'] ?? []),
        focusAreas: List<String>.from(json['focus_areas'] ?? []),
        mentorRecommendation: json['mentor_recommendation'] ?? '',
        accuracyScore: (json['accuracy_score'] ?? 0.0).toDouble(),
        completenessScore: (json['completeness_score'] ?? 0.0).toDouble(),
        reasoningFeedback: json['reasoning_feedback'],
        identifiedMisconceptions: List<String>.from(json['identified_misconceptions'] ?? []),
        evidenceSummary: json['evidence_summary'] ?? {},
      );
}
