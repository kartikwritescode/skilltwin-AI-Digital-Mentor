import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilltwin/core/models/topic_detail.dart';
import 'package:skilltwin/core/models/learning_path.dart';
import 'package:skilltwin/core/models/session_step.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository_provider.dart';
import 'package:skilltwin/features/journey/presentation/screens/topic_detail_screen.dart';
import 'package:skilltwin/features/journey/presentation/widgets/topic_learn_mascot_header.dart';
import 'package:skilltwin/features/journey/presentation/widgets/topic_understand_content_view.dart';
import 'package:skilltwin/features/journey/presentation/widgets/topic_learn_loading_view.dart';
import 'package:skilltwin/features/journey/presentation/widgets/practice/practice_interactive_view.dart';
import 'package:skilltwin/features/sessions/presentation/widgets/step_learn_view.dart';

class _FakeLearningPathRepository implements LearningPathRepository {
  final TopicDetailData mockDetail;
  final TopicExplanationData mockExplanation;
  bool startTopicCalled = false;

  _FakeLearningPathRepository({
    required this.mockDetail,
    required this.mockExplanation,
  });

  @override
  Future<LearningPath?> getActiveLearningPath() async => null;

  @override
  Future<LearningPath> getLearningPathById(String pathId) async =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> generateLearningPath({
    required String learningGoal,
    required String targetLevel,
    String? customTarget,
    int dailyMinutes = 30,
    List<String> currentKnowledge = const [],
    String? learningPreferences,
  }) async =>
      {};

  Future<Map<String, dynamic>> generateAdaptiveCurriculum({
    required String goal,
    required String currentLevel,
    required int targetWeeks,
    int dailyMinutes = 30,
    List<String> currentKnowledge = const [],
    String? learningPreferences,
  }) async =>
      {};

  @override
  Future<TopicDetailData> getTopicDetail(String topicId) async => mockDetail;

  @override
  Future<TopicStatusUpdateResponse> startTopic(String topicId) async {
    startTopicCalled = true;
    return TopicStatusUpdateResponse(
      topicId: topicId,
      status: 'learning',
      masteryScore: 0.15,
    );
  }

  @override
  Future<TopicStatusUpdateResponse> completeTopic(String topicId) async =>
      TopicStatusUpdateResponse(
        topicId: topicId,
        status: 'completed',
        masteryScore: 1.0,
      );

  @override
  Future<TopicStatusUpdateResponse> markTopicNeedsRevision(String topicId) async =>
      TopicStatusUpdateResponse(
        topicId: topicId,
        status: 'needs_revision',
        masteryScore: 0.5,
      );

  @override
  Future<TopicExplanationData> getTopicExplanation(String topicId) async =>
      mockExplanation;

  @override
  Future<List<TopicQuestionItem>> getTopicQuestions(String topicId) async => [];

  @override
  Future<QuestionSubmissionResponse> submitAnswers(
    String topicId,
    List<AnswerSubmissionItem> answers,
  ) async =>
      QuestionSubmissionResponse(
        topicId: topicId,
        score: 1.0,
        masteryScore: 1.0,
        masteryDelta: 0.2,
        correctCount: 0,
        totalCount: 0,
        overallFeedback: 'Great job!',
      );

  @override
  Future<ContextualAskResponse> askTopicQuestion(
    String topicId,
    String query, {
    TopicQuestionItem? currentQuestion,
    String? selectedAnswer,
    Map<String, dynamic>? questionContext,
  }) async =>
      const ContextualAskResponse(
        answer: 'Test answer',
        suggestedFollowups: [],
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testTopic = TopicDetailData(
    id: 'topic_gradient_descent',
    sectionId: 'sec_ml_foundations',
    sectionTitle: 'Machine Learning Foundations',
    pathId: 'path_1',
    title: 'Gradient Descent & Loss Optimization',
    description: 'This is the old generic description that must NEVER be shown.',
    orderIndex: 0,
    difficulty: 'beginner',
    estimatedMinutes: 20,
    learningObjectives: [
      'Understand the loss surface intuition',
      'Compute numerical parameter updates with learning rate alpha',
    ],
    keyConcepts: [
      'Loss Surface',
      'Learning Rate',
      'Convexity',
    ],
    status: 'not_started',
    masteryScore: 0.0,
  );

  const testExplanation = TopicExplanationData(
    topicId: 'topic_gradient_descent',
    topicTitle: 'Gradient Descent & Loss Optimization',
    content: '''
## The Core Intuition

Imagine you are standing on a foggy hillside trying to reach the lowest valley floor without being able to see more than a few feet in front of you. What do you do?

You feel the slope of the ground under your feet and take a step downhill in the steepest direction.

```python
# Gradient update step
theta = theta - alpha * gradient
```

## Key Formula

The parameter update rule is expressed as:
`W = W - alpha * dL/dW`
''',
    cached: true,
    sources: [
      'Deep Learning (Goodfellow, Bengio, Courville) Chapter 4',
      'Stanford CS229: Supervised Learning Lecture Notes',
    ],
  );

  group('Understand / Learn Topic Screen Unit & Widget Tests', () {
    testWidgets('TopicLearnMascotHeader renders teaching mascot, copy and metadata',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopicLearnMascotHeader(
              topicTitle: testTopic.title,
              difficulty: testTopic.difficulty,
              estimatedMinutes: testTopic.estimatedMinutes,
              masteryScore: testTopic.masteryScore,
              status: testTopic.status,
            ),
          ),
        ),
      );

      // Verify Teaching mascot presence
      expect(find.byType(Image), findsWidgets);

      // Verify "Let's make this click." microcopy badge
      expect(find.text("Let's make this click."), findsOneWidget);

      // Verify Topic Title
      expect(find.text(testTopic.title), findsOneWidget);

      // Verify metadata chips
      expect(find.text('BEGINNER'), findsOneWidget);
      expect(find.text('~20 MIN'), findsOneWidget);
      expect(find.text('READY TO LEARN'), findsOneWidget);
    });

    testWidgets('TopicUnderstandContentView renders structured hierarchy and completion CTA',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool completedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopicUnderstandContentView(
              topic: testTopic,
              explanation: testExplanation,
              onUnderstandCompleted: () => completedCalled = true,
              onRefreshExplanation: () {},
            ),
          ),
        ),
      );

      // Verify Mascot Header
      expect(find.text("Let's make this click."), findsOneWidget);

      // Verify Learning Objectives
      expect(find.text('LEARNING OBJECTIVES'), findsOneWidget);
      expect(find.text('Understand the loss surface intuition'), findsOneWidget);

      // Verify removed boxes are absent
      expect(find.text('Think of it this way...'), findsNothing);
      expect(find.text('CONCEPT GUIDE'), findsNothing);
      expect(find.text("Here's the part that usually trips people up."), findsNothing);

      // Verify Key Takeaways
      expect(find.text('KEY TAKEAWAYS'), findsOneWidget);
      expect(find.text('Loss Surface'), findsOneWidget);

      // Verify Grounded Sources
      expect(find.text('GROUNDED KNOWLEDGE SOURCES'), findsOneWidget);
      expect(
        find.textContaining('Deep Learning (Goodfellow, Bengio, Courville)'),
        findsOneWidget,
      );

      // Verify Completion CTA
      expect(
        find.text('I understand this — Continue to Practice'),
        findsOneWidget,
      );

      // Tap completion CTA
      await tester.tap(find.text('I understand this — Continue to Practice'));
      await tester.pump();
      expect(completedCalled, isTrue);
    });

    testWidgets('TopicLearnLoadingView renders loading GIF and friendly text after delay',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TopicLearnLoadingView(),
          ),
        ),
      );

      // Initially suppressed by 150ms anti-flicker delay
      expect(find.text('Synthesizing your concept guide...'), findsNothing);

      // Advance past anti-flicker timer
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Synthesizing your concept guide...'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('TopicDetailScreen starts on Understand tab and never shows old description',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeRepo = _FakeLearningPathRepository(
        mockDetail: testTopic,
        mockExplanation: testExplanation,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningPathRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: TopicDetailScreen(topicId: 'topic_gradient_descent'),
          ),
        ),
      );

      // Advance through loading
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Verify screen title
      expect(find.text(testTopic.title), findsWidgets);

      // Verify Tab 0 is Understand
      expect(find.text("Let's make this click."), findsOneWidget);

      // CRITICAL REQUIREMENT: Verify old generic description is NOT shown!
      expect(
        find.text('This is the old generic description that must NEVER be shown.'),
        findsNothing,
      );

      // Tap completion CTA
      await tester.tap(find.text('I understand this — Continue to Practice'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Verify startTopic was triggered in repository
      expect(fakeRepo.startTopicCalled, isTrue);

      // Verify tab switched to Practice & Q&A
      expect(find.byType(PracticeInteractiveView), findsOneWidget);
    });

    testWidgets('StepLearnView in sessions displays companion header and takeaways',
        (WidgetTester tester) async {
      final step = SessionStep(
        id: 'step_1',
        title: 'Neural Networks 101',
        type: StepType.learn,
        content: {
          'text': 'A neuron takes inputs, weights them, and applies an activation function.',
          'key_points': [
            'Weights determine input importance',
            'Activation introduces non-linearity',
          ],
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StepLearnView(step: step),
            ),
          ),
        ),
      );

      // Verify mascot companion header
      expect(find.text("Let's make this click."), findsOneWidget);
      expect(find.text('Focus on the core intuition below.'), findsOneWidget);

      // Verify content text
      expect(find.textContaining('A neuron takes inputs'), findsOneWidget);

      // Verify key takeaways
      expect(find.text('KEY TAKEAWAYS'), findsOneWidget);
      expect(find.text('Weights determine input importance'), findsOneWidget);
      expect(find.text('Activation introduces non-linearity'), findsOneWidget);
    });

    testWidgets('Responsive rendering on narrow 320px screen without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      FlutterErrorDetails? caught;
      final originalHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        caught = details;
      };
      addTearDown(() => FlutterError.onError = originalHandler);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopicUnderstandContentView(
              topic: testTopic,
              explanation: testExplanation,
              onUnderstandCompleted: () {},
              onRefreshExplanation: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      FlutterError.onError = originalHandler;
      if (caught != null) {
        // ignore: avoid_print
        print('CAUGHT CONTEXT: ${caught?.context?.toDescription()}');
        // ignore: avoid_print
        print('CAUGHT SUMMARY: ${caught?.summary.toDescription()}');
        final info = caught?.informationCollector?.call();
        if (info != null) {
          for (final d in info) {
            // ignore: avoid_print
            print('  INFO: $d');
          }
        }
      }
      expect(caught, isNull);
    });
  });
}
