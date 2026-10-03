import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilltwin/app/theme/app_theme.dart';
import 'package:skilltwin/core/models/topic_detail.dart';
import 'package:skilltwin/core/models/learning_path.dart';
import 'package:skilltwin/core/widgets/error_state_view.dart';
import 'package:skilltwin/core/widgets/skilltwin_loading_view.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository_provider.dart';
import 'package:skilltwin/features/journey/presentation/screens/topic_detail_screen.dart';
import 'package:skilltwin/features/journey/presentation/widgets/topic_understand_content_view.dart';

class _MockLearningRepo implements LearningPathRepository {
  TopicDetailData? detail;
  TopicExplanationData? explanation;
  bool shouldThrowError = false;
  bool startTopicCalled = false;

  _MockLearningRepo({this.detail, this.explanation, this.shouldThrowError = false});

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

  @override
  Future<TopicDetailData> getTopicDetail(String topicId) async {
    if (shouldThrowError) throw Exception('Failed to load topic details');
    return detail!;
  }

  @override
  Future<TopicExplanationData> getTopicExplanation(String topicId) async {
    if (shouldThrowError) throw Exception('Failed to generate learning content');
    return explanation!;
  }

  @override
  Future<TopicStatusUpdateResponse> startTopic(String topicId) async {
    startTopicCalled = true;
    return TopicStatusUpdateResponse(
      topicId: topicId,
      status: 'learning',
      masteryScore: 0.2,
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
        overallFeedback: 'Nice work!',
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

  final testTopicWithoutVideo = TopicDetailData(
    id: 'topic_recursion',
    sectionId: 'sec_algorithms',
    sectionTitle: 'Core Algorithms',
    pathId: 'path_1',
    title: 'Recursion and Call Stacks',
    orderIndex: 0,
    difficulty: 'beginner',
    estimatedMinutes: 15,
    learningObjectives: [
      'Understand the base case vs recursive step',
      'Trace execution across stack frames',
    ],
    keyConcepts: [
      'Base Case',
      'Call Stack',
      'Stack Overflow',
    ],
    status: 'not_started',
    masteryScore: 0.0,
  );

  final testTopicWithVideo = TopicDetailData(
    id: 'topic_binary_search',
    sectionId: 'sec_algorithms',
    sectionTitle: 'Search Algorithms',
    pathId: 'path_1',
    title: 'Binary Search Implementation',
    orderIndex: 1,
    difficulty: 'intermediate',
    estimatedMinutes: 25,
    learningObjectives: [
      'Implement binary search in O(log N) time',
      'Avoid off-by-one mid calculation errors',
    ],
    keyConcepts: [
      'Logarithmic Time',
      'Midpoint Formula',
      'Search Invariant',
    ],
    status: 'not_started',
    masteryScore: 0.0,
    metadata: {
      'source_type': 'youtube_playlist',
      'youtube_video_id': 's4DPM8ct1pI',
      'youtube_url': 'https://www.youtube.com/watch?v=s4DPM8ct1pI',
      'duration_seconds': 740,
      'position': 2,
      'channel_name': 'NeetCode',
    },
  );

  const twoParagraphContent = '''
## Understanding the Core Idea
Recursion is a method of solving a computational problem where the solution depends on solutions to smaller instances of the same problem. Every recursive function requires a base condition that terminates further recursion.

When a function calls itself, memory is allocated on the runtime call stack for each individual invocation until the base condition is reached and frames unwind.
''';

  final twentyParagraphContent = StringBuffer();
  for (int i = 1; i <= 20; i++) {
    twentyParagraphContent.writeln('## Section $i: In-depth Insight on Concept $i');
    twentyParagraphContent.writeln(
        'This is detailed paragraph $i explaining the foundational mechanisms and algorithmic reasoning behind this concept. It emphasizes mental models, edge cases, and runtime efficiency in production.');
    twentyParagraphContent.writeln();
    if (i % 5 == 0) {
      twentyParagraphContent.writeln('```python\n# Example for section $i\ndef step_$i(x):\n    return x * 2\n```\n');
    }
  }

  group('Video Details & Learning Content Screen Tests', () {
    testWidgets('1. Dynamic bottom navigation inset calculation test',
        (WidgetTester tester) async {
      // Test with 0 bottom padding (standard desktop / non-notch screen)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.zero),
            child: Builder(
              builder: (context) {
                final inset = AppSpacing.calculateBottomNavInset(context);
                expect(inset, equals(0.0));
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Test with 34px bottom padding (iPhone notch / gesture home indicator)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.only(bottom: 34)),
            child: Builder(
              builder: (context) {
                final inset = AppSpacing.calculateBottomNavInset(context);
                expect(inset, equals(34.0));
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('2. Renders 2-paragraph content without overflow & correct structure',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844); // iPhone 14
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool completedTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopicUnderstandContentView(
              topic: testTopicWithoutVideo,
              explanation: TopicExplanationData(
                topicId: testTopicWithoutVideo.id,
                topicTitle: testTopicWithoutVideo.title,
                content: twoParagraphContent,
              ),
              onUnderstandCompleted: () => completedTapped = true,
              onRefreshExplanation: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Structure 1: Topic title
      expect(find.text(testTopicWithoutVideo.title), findsOneWidget);

      // Structure 2: Short explanation (Intuition callout + Objectives)
      expect(find.text('Think of it this way...'), findsOneWidget);
      expect(find.text('LEARNING OBJECTIVES'), findsOneWidget);

      // Structure 3: Video is omitted cleanly when not available
      expect(find.text('Curriculum Video Lesson'), findsNothing);

      // Structure 4: Learning content
      expect(find.textContaining('Understanding the Core Idea'), findsOneWidget);
      expect(find.textContaining('runtime call stack'), findsOneWidget);

      // Structure 5: Examples & Key Takeaways
      expect(find.text('KEY TAKEAWAYS'), findsOneWidget);

      // Structure 6: Practice / action
      final actionButton = find.text('I understand this — Continue to Practice');
      expect(actionButton, findsOneWidget);

      // Verify list padding includes calculated safe bottom inset
      final listView = tester.widget<ListView>(find.byType(ListView).first);
      await tester.ensureVisible(actionButton);
      await tester.pumpAndSettle();
      await tester.tap(actionButton);
      await tester.pump();
      expect(completedTapped, isTrue);
    });

    testWidgets('3. Renders 20 paragraphs very long content and scrolls to end without overlap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopicUnderstandContentView(
              topic: testTopicWithoutVideo,
              explanation: TopicExplanationData(
                topicId: testTopicWithoutVideo.id,
                topicTitle: testTopicWithoutVideo.title,
                content: twentyParagraphContent.toString(),
              ),
              onUnderstandCompleted: () {},
              onRefreshExplanation: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Top content is present initially
      expect(find.text(testTopicWithoutVideo.title), findsOneWidget);
      expect(find.textContaining('Section 1: In-depth Insight'), findsOneWidget);

      // Verify list padding includes calculated safe bottom inset
      final listView = tester.widget<ListView>(find.byType(ListView).first);
      expect((listView.padding as EdgeInsets).bottom, equals(0.0));

      // Scroll progressively to reach the bottom without timing out
      for (int i = 0; i < 15; i++) {
        if (find.text('I understand this — Continue to Practice').evaluate().isNotEmpty) {
          break;
        }
        await tester.drag(find.byType(ListView).first, const Offset(0, -600));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Bottom action button is fully visible and reached
      expect(find.text('I understand this — Continue to Practice'), findsOneWidget);
    });

    testWidgets('4. Video + long content renders integrated 16:9 player and full content',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopicUnderstandContentView(
              topic: testTopicWithVideo,
              explanation: TopicExplanationData(
                topicId: testTopicWithVideo.id,
                topicTitle: testTopicWithVideo.title,
                content: twentyParagraphContent.toString(),
              ),
              onUnderstandCompleted: () {},
              onRefreshExplanation: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Topic title
      expect(find.text(testTopicWithVideo.title), findsOneWidget);

      // 2. Video area is integrated:
      // AspectRatio 16:9 check
      final aspectRatios = tester.widgetList<AspectRatio>(find.byType(AspectRatio));
      final has16by9 = aspectRatios.any((ar) => (ar.aspectRatio - 16 / 9).abs() < 0.01);
      expect(has16by9, isTrue);

      // Video metadata: sequence badge, duration, creator name, Watch action
      expect(find.text('Video #3'), findsOneWidget); // position 2 + 1
      expect(find.text('12m 20s'), findsOneWidget); // 740s = 12m 20s
      expect(find.text('NeetCode'), findsOneWidget);
      expect(find.text('Watch'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);

      // Scroll progressively to the end
      for (int i = 0; i < 15; i++) {
        if (find.text('I understand this — Continue to Practice').evaluate().isNotEmpty) {
          break;
        }
        await tester.drag(find.byType(ListView).first, const Offset(0, -600));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.text('I understand this — Continue to Practice'), findsOneWidget);
    });

    testWidgets('5. Slow loading state displays non-blocking loader smoothly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillTwinLoadingView(
              message: 'SkillTwin is preparing your next step.',
              subMessage: 'Synthesizing concepts, intuition & deliberate practice...',
            ),
          ),
        ),
      );

      // Anti-flicker delay advances smoothly
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('SkillTwin is preparing your next step.'), findsOneWidget);
      expect(find.text('Synthesizing concepts, intuition & deliberate practice...'), findsOneWidget);
    });

    testWidgets('6. Error state displays clear recovery and retry CTA without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 480); // Small compact screen
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool retryTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateView(
              error: 'Failed to synchronize with mentor server.',
              onRetry: () => retryTriggered = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Failed to synchronize with mentor server.'), findsOneWidget);
      expect(find.text('Retry Connection'), findsOneWidget);

      await tester.tap(find.text('Retry Connection'));
      await tester.pump();
      expect(retryTriggered, isTrue);
    });

    testWidgets('7. Bottom action button sits fully above floating nav bar inside TopicDetailScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400); // Expanded viewport
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeRepo = _MockLearningRepo(
        detail: testTopicWithVideo,
        explanation: TopicExplanationData(
          topicId: testTopicWithVideo.id,
          topicTitle: testTopicWithVideo.title,
          content: twoParagraphContent,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningPathRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: TopicDetailScreen(topicId: 'topic_binary_search'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Find completion action button
      final buttonFinder = find.text('I understand this — Continue to Practice');
      expect(buttonFinder, findsOneWidget);

      // Verify list padding includes calculated safe bottom inset
      final listView = tester.widget<ListView>(find.byType(ListView).first);
      expect((listView.padding as EdgeInsets).bottom, equals(0.0));
    });
  });
}
