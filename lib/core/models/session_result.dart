class StepEvaluation {
  final String stepId;
  final String question;
  final String userAnswer;
  final bool isCorrect;
  final String correctAnswer;
  final String explanation;

  StepEvaluation({
    required this.stepId,
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
  });

  factory StepEvaluation.fromJson(Map<String, dynamic> json) => StepEvaluation(
        stepId: json['step_id']?.toString() ?? '',
        question: json['question']?.toString() ?? '',
        userAnswer: json['user_answer']?.toString() ?? '',
        isCorrect: json['is_correct'] == true,
        correctAnswer: json['correct_answer']?.toString() ?? '',
        explanation: json['explanation']?.toString() ?? '',
      );
}

class SessionResult {
  final String sessionId;
  final String conceptId;
  final String conceptTitle;
  
  // Progress Deltas
  final double masteryDelta;
  final double confidenceDelta;
  
  // New Absolute States (0.0 - 1.0)
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
  final List<StepEvaluation> stepEvaluations;
  
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
    this.stepEvaluations = const [],
    required this.evidenceSummary,
  });

  static double _normalizePercent(dynamic raw) {
    if (raw == null) return 0.0;
    final val = (raw as num).toDouble();
    return val > 1.0 ? val / 100.0 : val;
  }

  static double _normalizeDelta(dynamic raw) {
    if (raw == null) return 0.0;
    final val = (raw as num).toDouble();
    return val.abs() > 1.0 ? val / 100.0 : val;
  }

  factory SessionResult.fromJson(Map<String, dynamic> json) {
    final rawStepEvals = json['step_evaluations'] as List?;
    final stepEvals = rawStepEvals != null
        ? rawStepEvals.map((e) => StepEvaluation.fromJson(e as Map<String, dynamic>)).toList()
        : <StepEvaluation>[];

    final scoreVal = _normalizePercent(json['accuracy_score'] ?? json['score']);

    return SessionResult(
      sessionId: json['session_id'] ?? json['id'] ?? '',
      conceptId: json['concept_id'] ?? '',
      conceptTitle: json['concept_title'] ?? '',
      masteryDelta: _normalizeDelta(json['mastery_delta']),
      confidenceDelta: _normalizeDelta(json['confidence_delta']),
      currentMastery: _normalizePercent(json['current_mastery']),
      currentConfidence: _normalizePercent(json['current_confidence']),
      improvements: List<String>.from(json['improvements'] ?? []),
      focusAreas: List<String>.from(json['focus_areas'] ?? []),
      mentorRecommendation: json['mentor_recommendation'] ??
          (json['next_recommendation'] is Map
              ? json['next_recommendation']['reason'] ?? ''
              : json['reasoning_feedback'] ?? ''),
      accuracyScore: scoreVal,
      completenessScore: _normalizePercent(json['completeness_score']),
      reasoningFeedback: json['reasoning_feedback'],
      identifiedMisconceptions: List<String>.from(json['identified_misconceptions'] ?? []),
      stepEvaluations: stepEvals,
      evidenceSummary: json['evidence_summary'] is Map<String, dynamic>
          ? json['evidence_summary']
          : {'score': scoreVal},
    );
  }
}

