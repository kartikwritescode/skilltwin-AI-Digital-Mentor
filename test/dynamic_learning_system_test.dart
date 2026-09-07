import 'package:flutter_test/flutter_test.dart';
import 'package:skilltwin/core/models/learning_path.dart';
import 'package:skilltwin/core/models/home_dashboard.dart';
import 'package:skilltwin/core/models/twin_dashboard.dart';
import 'package:skilltwin/core/models/topic_detail.dart';

void main() {
  group('Dynamic Learning Models Test Suite', () {
    test('LearningPath deserialization and hierarchical calculation', () {
      final json = {
        'id': 'path_1',
        'goal_id': 'goal_1',
        'user_id': 'user_1',
        'title': 'Full-Stack Web Development',
        'target_level': 'Intermediate',
        'estimated_duration': '6 weeks',
        'progress': 0.5,
        'sections': [
          {
            'id': 'sec_1',
            'path_id': 'path_1',
            'title': 'Frontend Foundations',
            'order_index': 0,
            'topics': [
              {
                'id': 'top_1',
                'section_id': 'sec_1',
                'title': 'HTML5 Semantics',
                'order_index': 0,
                'difficulty': 'beginner',
                'estimated_minutes': 20,
                'status': 'completed',
                'mastery_score': 0.95,
              },
              {
                'id': 'top_2',
                'section_id': 'sec_1',
                'title': 'CSS Grid & Flexbox',
                'order_index': 1,
                'difficulty': 'intermediate',
                'estimated_minutes': 30,
                'status': 'learning',
                'mastery_score': 0.40,
              },
            ],
          },
        ],
      };

      final path = LearningPath.fromJson(json);

      expect(path.id, 'path_1');
      expect(path.title, 'Full-Stack Web Development');
      expect(path.targetLevel, 'Intermediate');
      expect(path.sections.length, 1);
      expect(path.sections.first.topics.length, 2);
      expect(path.totalTopics, 2);
      expect(path.completedTopics, 1);
      expect(path.sections.first.progress, 0.5);

      final serialized = path.toJson();
      expect(serialized['id'], 'path_1');
      expect(serialized['target_level'], 'Intermediate');
    });

    test('HomeDashboardData default and real metric parsing', () {
      final json = {
        'goal_id': 'goal_100',
        'goal_title': 'Master FastAPI & PostgreSQL',
        'target_level': 'Expert',
        'current_module_name': 'Database Optimization',
        'current_topic_id': 'top_indexing',
        'current_topic_title': 'B-Tree Indexes',
        'overall_progress': 0.65,
        'overall_mastery': 0.72,
        'topics_completed': 12,
        'topics_remaining': 8,
        'streak_days': 7,
        'learning_minutes': 310,
        'weak_areas': ['Query Optimization'],
        'next_action_title': 'Continue Practice: B-Tree Indexes',
        'next_action_reason': 'Reinforce query planner intuition.',
        'next_action_type': 'LEARN',
        'revision_due_count': 2,
        'is_new_learner': false,
        'insights': ['Strong foundational comprehension of relational algebra.'],
      };

      final dashboard = HomeDashboardData.fromJson(json);

      expect(dashboard.goalTitle, 'Master FastAPI & PostgreSQL');
      expect(dashboard.targetLevel, 'Expert');
      expect(dashboard.overallProgress, 0.65);
      expect(dashboard.overallMastery, 0.72);
      expect(dashboard.streakDays, 7);
      expect(dashboard.learningMinutes, 310);
      expect(dashboard.isNewLearner, false);
      expect(dashboard.weakAreas, contains('Query Optimization'));
      expect(dashboard.revisionDueCount, 2);
      expect(dashboard.insights.length, 1);
    });

    test('TwinDashboardData non-fabricated initial state handling', () {
      final emptyJson = {
        'user_id': 'user_new',
        'has_sufficient_data': false,
        'overall_mastery': 0.0,
        'learning_level': 'Beginner',
        'strongest_areas': [],
        'weakest_areas': [],
        'concepts_at_risk': [],
        'learning_velocity': 0.0,
        'consistency_streak': 0,
        'knowledge_coverage': 0.0,
        'verified_evidence_count': 0,
        'insights': [],
      };

      final emptyTwin = TwinDashboardData.fromJson(emptyJson);

      expect(emptyTwin.hasSufficientData, isFalse);
      expect(emptyTwin.overallMastery, 0.0);
      expect(emptyTwin.verifiedEvidenceCount, 0);

      final verifiedJson = {
        'user_id': 'user_active',
        'has_sufficient_data': true,
        'overall_mastery': 0.82,
        'learning_level': 'Intermediate',
        'strongest_areas': [
          {'name': 'Routing', 'mastery_score': 0.95, 'status': 'MASTERED'},
        ],
        'weakest_areas': [
          {'name': 'Async Locks', 'mastery_score': 0.35, 'status': 'NEEDS_REVISION'},
        ],
        'concepts_at_risk': ['Deadlocks'],
        'learning_velocity': 1.4,
        'consistency_streak': 12,
        'knowledge_coverage': 0.65,
        'verified_evidence_count': 28,
        'insights': ['Consistent spaced retrieval execution.'],
      };

      final verifiedTwin = TwinDashboardData.fromJson(verifiedJson);

      expect(verifiedTwin.hasSufficientData, isTrue);
      expect(verifiedTwin.overallMastery, 0.82);
      expect(verifiedTwin.strongestAreas.first.name, 'Routing');
      expect(verifiedTwin.weakestAreas.first.status, 'NEEDS_REVISION');
      expect(verifiedTwin.conceptsAtRisk, contains('Deadlocks'));
      expect(verifiedTwin.verifiedEvidenceCount, 28);
    });

    test('TopicDetailData and Practice Question submission parsing', () {
      final topicJson = {
        'id': 'top_sub',
        'section_id': 'sec_1',
        'section_title': 'Concurrency',
        'path_id': 'path_1',
        'title': 'Event Loops & Coroutines',
        'order_index': 0,
        'difficulty': 'intermediate',
        'estimated_minutes': 30,
        'prerequisites': ['Call Stacks'],
        'learning_objectives': ['Understand asynchronous scheduling'],
        'status': 'learning',
        'mastery_score': 0.55,
        'has_cached_explanation': true,
      };

      final topic = TopicDetailData.fromJson(topicJson);

      expect(topic.id, 'top_sub');
      expect(topic.title, 'Event Loops & Coroutines');
      expect(topic.status, 'learning');
      expect(topic.prerequisites, contains('Call Stacks'));
      expect(topic.hasCachedExplanation, isTrue);

      final submissionJson = {
        'topic_id': 'top_sub',
        'score': 1.0,
        'mastery_score': 0.70,
        'mastery_delta': 0.15,
        'correct_count': 3,
        'total_count': 3,
        'overall_feedback': 'All questions answered accurately.',
        'attempts': [
          {
            'question_id': 'q1',
            'is_correct': true,
            'score': 1.0,
            'feedback': 'Correct understanding of microtasks.',
            'correct_answer': 'Microtask queue',
          }
        ],
      };

      final submission = QuestionSubmissionResponse.fromJson(submissionJson);

      expect(submission.topicId, 'top_sub');
      expect(submission.score, 1.0);
      expect(submission.masteryDelta, 0.15);
      expect(submission.correctCount, 3);
      expect(submission.attempts.first.isCorrect, isTrue);
    });
  });
}
