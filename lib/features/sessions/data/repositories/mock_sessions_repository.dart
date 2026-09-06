import '../../domain/repositories/sessions_repository.dart';
import '../../../../core/models/learning_session.dart';
import '../../../../core/models/session_step.dart';
import '../../../../core/models/session_result.dart';

class MockSessionsRepository implements SessionsRepository {
  @override
  Future<LearningSession> getSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockSession(sessionId);
  }

  @override
  Future<LearningSession> createSession(String conceptId, SessionType type) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockSession('new-session-id', conceptId: conceptId, type: type);
  }

  @override
  Future<SessionResult> completeSession(String sessionId, Map<String, dynamic> evidence) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return SessionResult(
      sessionId: sessionId,
      conceptId: 'probability_basics',
      conceptTitle: 'Probability Basics',
      masteryDelta: 0.12,
      confidenceDelta: 0.08,
      currentMastery: 0.85,
      currentConfidence: 0.80,
      accuracyScore: 0.88,
      completenessScore: 0.92,
      improvements: [
        'Solidified understanding of Bayes Theorem.',
        'Successfully applied prior probability in a diagnostic context.'
      ],
      focusAreas: [
        'Marginal likelihood calculations.',
        'Distinguishing between independent and disjoint events.'
      ],
      mentorRecommendation: 'Prerequisite unlocked: You can now proceed to "Introduction to Naive Bayes". I have added a 4-minute retrieval session for Friday to ensure retention.',
      evidenceSummary: {
        'accuracy': 0.85,
        'completion_time': '11m 20s',
      },
    );
  }

  @override
  Future<void> updateStepProgress(String sessionId, String stepId, bool completed) async {
    // Mock network lag
    await Future.delayed(const Duration(milliseconds: 200));
  }

  LearningSession _mockSession(String id, {String? conceptId, SessionType? type}) {
    return LearningSession(
      id: id,
      conceptId: conceptId ?? 'probability_basics',
      conceptTitle: 'Bayesian Probability',
      type: type ?? SessionType.learn,
      durationMinutes: 12,
      whyStatement: 'This prerequisite is essential for understanding how your AI mentor updates its belief about your knowledge state.',
      steps: [
        SessionStep(
          id: 'step_1',
          title: 'Recall',
          type: StepType.recall,
          instructions: 'What do you already know?',
          content: {
            'question': 'In simple terms, what does "Prior Probability" represent before we see new evidence?',
            'hint': 'Think about your initial belief.',
          },
        ),
        SessionStep(
          id: 'step_2',
          title: 'Learn',
          type: StepType.learn,
          instructions: 'Updating Beliefs',
          content: {
            'text': 'Bayes Theorem describes the probability of an event, based on prior knowledge of conditions that might be related to the event...',
            'key_points': [
              'Posterior probability is what we want to find.',
              'Likelihood is the evidence provided by new data.',
              'Prior is our initial state of knowledge.'
            ],
          },
        ),
        SessionStep(
          id: 'step_3',
          title: 'Practice',
          type: StepType.question,
          instructions: 'Diagnostic Test',
          content: {
            'question': 'If a test for a disease is 99% accurate, and 1% of the population has the disease, what is the probability that a person who tests positive actually has the disease?',
            'options': ['99%', '50%', '1%', '85%'],
            'hint': 'Don\'t forget to account for the false positives in the healthy 99% of the population.',
          },
        ),
        SessionStep(
          id: 'step_4',
          title: 'Teach Back',
          type: StepType.explanation,
          instructions: 'Explain to Mentor',
          content: {
            'question': 'Explain how the result of the previous question changes your intuition about "99% accuracy".',
          },
        ),
      ],
    );
  }
}
