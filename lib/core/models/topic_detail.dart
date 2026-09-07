class TopicDetailData {
  final String id;
  final String sectionId;
  final String sectionTitle;
  final String pathId;
  final String title;
  final String? description;
  final int orderIndex;
  final String difficulty;
  final int estimatedMinutes;
  final List<String> prerequisites;
  final List<String> learningObjectives;
  final String status;
  final double masteryScore;
  final double confidenceScore;
  final int revisionCount;
  final int timeSpentMinutes;
  final int attempts;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? nextRevisionAt;
  final String? previousTopicId;
  final String? nextTopicId;
  final bool hasCachedExplanation;
  final int questionCount;

  const TopicDetailData({
    required this.id,
    required this.sectionId,
    required this.sectionTitle,
    required this.pathId,
    required this.title,
    this.description,
    required this.orderIndex,
    required this.difficulty,
    required this.estimatedMinutes,
    this.prerequisites = const [],
    this.learningObjectives = const [],
    required this.status,
    this.masteryScore = 0.0,
    this.confidenceScore = 0.0,
    this.revisionCount = 0,
    this.timeSpentMinutes = 0,
    this.attempts = 0,
    this.startedAt,
    this.completedAt,
    this.nextRevisionAt,
    this.previousTopicId,
    this.nextTopicId,
    this.hasCachedExplanation = false,
    this.questionCount = 0,
  });

  factory TopicDetailData.fromJson(Map<String, dynamic> json) {
    return TopicDetailData(
      id: json['id']?.toString() ?? '',
      sectionId: json['section_id']?.toString() ?? '',
      sectionTitle: json['section_title']?.toString() ?? '',
      pathId: json['path_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty']?.toString() ?? 'medium',
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 25,
      prerequisites: (json['prerequisites'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      learningObjectives: (json['learning_objectives'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: json['status']?.toString() ?? 'not_started',
      masteryScore: ((json['mastery_score'] ?? 0.0) as num).toDouble(),
      confidenceScore: ((json['confidence_score'] ?? 0.0) as num).toDouble(),
      revisionCount: (json['revision_count'] as num?)?.toInt() ?? 0,
      timeSpentMinutes: (json['time_spent_minutes'] as num?)?.toInt() ?? 0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      nextRevisionAt: json['next_revision_at'] != null
          ? DateTime.tryParse(json['next_revision_at'].toString())
          : null,
      previousTopicId: json['previous_topic_id']?.toString(),
      nextTopicId: json['next_topic_id']?.toString(),
      hasCachedExplanation: json['has_cached_explanation'] == true,
      questionCount: (json['question_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'section_id': sectionId,
        'section_title': sectionTitle,
        'path_id': pathId,
        'title': title,
        'description': description,
        'order_index': orderIndex,
        'difficulty': difficulty,
        'estimated_minutes': estimatedMinutes,
        'prerequisites': prerequisites,
        'learning_objectives': learningObjectives,
        'status': status,
        'mastery_score': masteryScore,
        'confidence_score': confidenceScore,
        'revision_count': revisionCount,
        'time_spent_minutes': timeSpentMinutes,
        'attempts': attempts,
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'next_revision_at': nextRevisionAt?.toIso8601String(),
        'previous_topic_id': previousTopicId,
        'next_topic_id': nextTopicId,
        'has_cached_explanation': hasCachedExplanation,
        'question_count': questionCount,
      };
}

class TopicExplanationData {
  final String topicId;
  final String topicTitle;
  final String content;
  final String promptVersion;
  final bool cached;
  final List<String> sources;

  const TopicExplanationData({
    required this.topicId,
    required this.topicTitle,
    required this.content,
    this.promptVersion = 'v1',
    this.cached = false,
    this.sources = const [],
  });

  factory TopicExplanationData.fromJson(Map<String, dynamic> json) {
    return TopicExplanationData(
      topicId: json['topic_id']?.toString() ?? '',
      topicTitle: json['topic_title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      promptVersion: json['prompt_version']?.toString() ?? 'v1',
      cached: json['cached'] == true,
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'topic_id': topicId,
        'topic_title': topicTitle,
        'content': content,
        'prompt_version': promptVersion,
        'cached': cached,
        'sources': sources,
      };
}

class TopicQuestionItem {
  final String id;
  final String topicId;
  final String questionType;
  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String difficulty;

  const TopicQuestionItem({
    required this.id,
    required this.topicId,
    required this.questionType,
    required this.prompt,
    this.options = const [],
    required this.correctAnswer,
    required this.explanation,
    this.difficulty = 'medium',
  });

  factory TopicQuestionItem.fromJson(Map<String, dynamic> json) {
    return TopicQuestionItem(
      id: json['id']?.toString() ?? '',
      topicId: json['topic_id']?.toString() ?? '',
      questionType: json['question_type']?.toString() ?? 'mcq',
      prompt: json['prompt']?.toString() ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      correctAnswer: json['correct_answer']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic_id': topicId,
        'question_type': questionType,
        'prompt': prompt,
        'options': options,
        'correct_answer': correctAnswer,
        'explanation': explanation,
        'difficulty': difficulty,
      };
}

class AnswerSubmissionItem {
  final String questionId;
  final String userAnswer;

  const AnswerSubmissionItem({
    required this.questionId,
    required this.userAnswer,
  });

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'user_answer': userAnswer,
      };
}

class QuestionAttemptResult {
  final String questionId;
  final bool isCorrect;
  final double score;
  final String feedback;
  final String correctAnswer;

  const QuestionAttemptResult({
    required this.questionId,
    required this.isCorrect,
    required this.score,
    required this.feedback,
    required this.correctAnswer,
  });

  factory QuestionAttemptResult.fromJson(Map<String, dynamic> json) {
    return QuestionAttemptResult(
      questionId: json['question_id']?.toString() ?? '',
      isCorrect: json['is_correct'] == true,
      score: ((json['score'] ?? 0.0) as num).toDouble(),
      feedback: json['feedback']?.toString() ?? '',
      correctAnswer: json['correct_answer']?.toString() ?? '',
    );
  }
}

class QuestionSubmissionResponse {
  final String topicId;
  final double score;
  final double masteryScore;
  final double masteryDelta;
  final int correctCount;
  final int totalCount;
  final String overallFeedback;
  final List<QuestionAttemptResult> attempts;

  const QuestionSubmissionResponse({
    required this.topicId,
    required this.score,
    required this.masteryScore,
    required this.masteryDelta,
    required this.correctCount,
    required this.totalCount,
    required this.overallFeedback,
    this.attempts = const [],
  });

  factory QuestionSubmissionResponse.fromJson(Map<String, dynamic> json) {
    final rawAttempts = (json['attempts'] as List<dynamic>? ?? [])
        .map((a) => QuestionAttemptResult.fromJson(a as Map<String, dynamic>))
        .toList();

    return QuestionSubmissionResponse(
      topicId: json['topic_id']?.toString() ?? '',
      score: ((json['score'] ?? 0.0) as num).toDouble(),
      masteryScore: ((json['mastery_score'] ?? 0.0) as num).toDouble(),
      masteryDelta: ((json['mastery_delta'] ?? 0.0) as num).toDouble(),
      correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      overallFeedback: json['overall_feedback']?.toString() ?? '',
      attempts: rawAttempts,
    );
  }
}

class TopicStatusUpdateResponse {
  final String topicId;
  final String status;
  final double masteryScore;
  final DateTime? completedAt;
  final DateTime? nextRevisionAt;
  final double pathProgress;

  const TopicStatusUpdateResponse({
    required this.topicId,
    required this.status,
    required this.masteryScore,
    this.completedAt,
    this.nextRevisionAt,
    this.pathProgress = 0.0,
  });

  factory TopicStatusUpdateResponse.fromJson(Map<String, dynamic> json) {
    return TopicStatusUpdateResponse(
      topicId: json['topic_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'not_started',
      masteryScore: ((json['mastery_score'] ?? 0.0) as num).toDouble(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      nextRevisionAt: json['next_revision_at'] != null
          ? DateTime.tryParse(json['next_revision_at'].toString())
          : null,
      pathProgress: ((json['path_progress'] ?? 0.0) as num).toDouble(),
    );
  }
}

class ContextualAskResponse {
  final String answer;
  final List<String> sources;
  final List<String> suggestedFollowups;
  final String? audioTtsText;

  const ContextualAskResponse({
    required this.answer,
    this.sources = const [],
    this.suggestedFollowups = const [],
    this.audioTtsText,
  });

  factory ContextualAskResponse.fromJson(Map<String, dynamic> json) {
    return ContextualAskResponse(
      answer: json['answer']?.toString() ?? '',
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      suggestedFollowups: (json['suggested_followups'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      audioTtsText: json['audio_tts_text']?.toString(),
    );
  }
}
