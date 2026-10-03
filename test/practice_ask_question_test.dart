import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilltwin/core/models/topic_detail.dart';
import 'package:skilltwin/core/models/learning_path.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository_provider.dart';
import 'package:skilltwin/features/journey/presentation/providers/learning_path_provider.dart';
import 'package:skilltwin/features/journey/presentation/screens/topic_detail_screen.dart';
import 'package:skilltwin/features/journey/presentation/widgets/practice/practice_interactive_view.dart';

class _FakeLearningPathRepository implements LearningPathRepository {
  final TopicDetailData mockDetail;
  final TopicExplanationData mockExplanation;

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
  Future<List<TopicQuestionItem>> getTopicQuestions(String topicId) async {
    return [
      const TopicQuestionItem(
        id: 'q1',
        topicId: 'topic_1',
        questionType: 'multiple_choice',
        prompt: 'What is the primary role of a loss function in training?',
        options: [
          'Measure the prediction error',
          'Increase GPU memory',
          'Speed up disk access',
          'None of the above'
        ],
        correctAnswer: 'Measure the prediction error',
        explanation: 'Loss functions quantify error.',
        difficulty: 'easy',
      ),
    ];
  }

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
        correctCount: 1,
        totalCount: 1,
        overallFeedback: 'Great job!',
      );

  TopicQuestionItem? lastReceivedQuestion;
  String? lastReceivedSelectedAnswer;

  @override
  Future<ContextualAskResponse> askTopicQuestion(
    String topicId,
    String query, {
    TopicQuestionItem? currentQuestion,
    String? selectedAnswer,
    Map<String, dynamic>? questionContext,
  }) async {
    lastReceivedQuestion = currentQuestion;
    lastReceivedSelectedAnswer = selectedAnswer;
    return const ContextualAskResponse(
      answer: 'This is a helpful explanation of the concept.',
      suggestedFollowups: ['Why does it work this way?'],
    );
  }
}

void main() {
  const mockQuestions = [
    TopicQuestionItem(
      id: 'q1',
      topicId: 'topic-1',
      questionType: 'multiple_choice',
      prompt: 'What is the primary role of a loss function in training?',
      options: [
        'Measure the prediction error',
        'Increase GPU memory',
        'Speed up disk access',
        'None of the above'
      ],
      correctAnswer: 'Measure the prediction error',
      explanation:
          'Loss functions quantify how far model predictions are from ground truth.',
      difficulty: 'easy',
    ),
  ];

  Widget createTestWidget({Widget? askSection}) {
    return ProviderScope(
      overrides: [
        topicQuestionsProvider('topic-1').overrideWith(
          (ref) => Future.value(mockQuestions),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: PracticeInteractiveView(
            topicId: 'topic-1',
            askQuestionsSection: askSection ??
                Container(
                  key: const ValueKey('dummy_ask_section'),
                  child: const Text('Dummy Ask Form Field Content'),
                ),
          ),
        ),
      ),
    );
  }

  testWidgets(
      'PracticeInteractiveView renders Ask a question header with AI Mentor badge and collapsed state',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify header title and badge
    expect(find.text('Ask a question'), findsOneWidget);
    expect(find.text('AI MENTOR'), findsOneWidget);
    expect(find.text('Stuck on something? Ask your Twin.'), findsOneWidget);

    // Verify Question 1 is visible on screen
    expect(find.text('QUESTION 1 OF 1'), findsOneWidget);
    expect(
        find.text('What is the primary role of a loss function in training?'),
        findsOneWidget);
  });

  testWidgets(
      'Tapping Ask a question expands container and reveals ask form field section',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap to expand
    await tester.tap(find.text('Ask a question'));
    await tester.pumpAndSettle();

    // Verify expanded subtitle
    expect(
        find.text('Ask for hints, step explanations, or concept breakdowns.'),
        findsOneWidget);

    // Verify ask section is displayed
    expect(find.byKey(const ValueKey('dummy_ask_section')), findsOneWidget);

    // Verify the question prompt is STILL visible and readable
    expect(
        find.text('What is the primary role of a loss function in training?'),
        findsOneWidget);

    // Tap to collapse again
    await tester.tap(find.text('Ask a question'));
    await tester.pumpAndSettle();

    expect(find.text('Stuck on something? Ask your Twin.'), findsOneWidget);
  });

  testWidgets(
      'Full TopicDetailScreen Practice Tab provides enhanced TextField, clear button, quick chips, and dismissible answer',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final testTopic = TopicDetailData(
      id: 'topic_1',
      sectionId: 'sec_1',
      sectionTitle: 'Foundations',
      pathId: 'path_1',
      title: 'Gradient Descent Fundamentals',
      description: 'Understanding gradient descent.',
      orderIndex: 0,
      difficulty: 'beginner',
      estimatedMinutes: 20,
      learningObjectives: ['Objective 1'],
      keyConcepts: ['Concept 1'],
      status: 'ready',
      masteryScore: 0.85,
    );

    final fakeRepo = _FakeLearningPathRepository(
      mockDetail: testTopic,
      mockExplanation: const TopicExplanationData(
        topicId: 'topic_1',
        topicTitle: 'Gradient Descent Fundamentals',
        content: 'Content',
        cached: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learningPathRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: TopicDetailScreen(topicId: 'topic_1'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Switch to Practice tab (tab index 1)
    await tester.tap(find.text('Practice & Q&A'));
    await tester.pumpAndSettle();

    // Verify Ask a question header is present
    expect(find.text('Ask a question'), findsOneWidget);
    expect(find.text('AI MENTOR'), findsOneWidget);

    // Expand the Ask container
    await tester.tap(find.text('Ask a question'));
    await tester.pumpAndSettle();

    // Verify TextField with hint text and mic icon
    expect(find.text('Focusing on Question 1 of 1'), findsOneWidget);
    expect(find.text('Ask anything about Question 1...'), findsOneWidget);
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);

    // Verify quick prompt chips are visible and context-aware
    expect(find.text('Hint for Q1'), findsOneWidget);
    expect(find.text('Explain concept simply'), findsOneWidget);
    expect(find.text('Why is this option correct?'), findsOneWidget);

    // Type text into the TextField
    final textFieldFinder = find.byType(TextField).first;
    await tester.enterText(
        textFieldFinder, 'How does gradient descent update weights?');
    await tester.pumpAndSettle();

    // Verify text is entered and clear button appears
    expect(
        find.text('How does gradient descent update weights?'), findsOneWidget);
    expect(find.byTooltip('Clear'), findsOneWidget);

    // Tap clear button
    await tester.tap(find.byTooltip('Clear'));
    await tester.pumpAndSettle();

    expect(find.text('How does gradient descent update weights?'), findsNothing);

    // Tap the context-aware quick prompt chip
    await tester.tap(find.text('Hint for Q1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify that current question was passed to repo askTopicQuestion
    expect(fakeRepo.lastReceivedQuestion, isNotNull);
    expect(fakeRepo.lastReceivedQuestion!.id, equals('q1'));
    expect(
      fakeRepo.lastReceivedQuestion!.prompt,
      equals('What is the primary role of a loss function in training?'),
    );

    // Verify Twin response card is shown
    expect(find.text('Your Twin'), findsOneWidget);
    expect(find.text('This is a helpful explanation of the concept.'),
        findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);

    // Tap Dismiss to close answer card
    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();

    expect(
        find.text('This is a helpful explanation of the concept.'),
        findsNothing);
  });
}
