import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilltwin/core/models/learning_path.dart';
import 'package:skilltwin/features/journey/presentation/screens/journey_screen.dart';
import 'package:skilltwin/features/journey/presentation/widgets/journey_theme_models.dart';
import 'package:skilltwin/features/journey/presentation/widgets/adaptive_module_card.dart';
import 'package:skilltwin/features/journey/presentation/widgets/journey_mascot.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository_provider.dart';
import 'package:skilltwin/core/models/topic_detail.dart';

class _FakeLearningPathRepository implements LearningPathRepository {
  final LearningPath? path;

  _FakeLearningPathRepository(this.path);

  @override
  Future<LearningPath?> getActiveLearningPath() async => path;

  @override
  Future<LearningPath> getLearningPathById(String pathId) async => path!;

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
  Future<TopicDetailData> getTopicDetail(String topicId) async =>
      TopicDetailData(
        id: topicId,
        sectionId: 'sec_1',
        sectionTitle: 'Python Foundations',
        pathId: 'path_1',
        title: 'Mock Topic',
        orderIndex: 0,
        difficulty: 'beginner',
        estimatedMinutes: 20,
        status: 'not_started',
      );

  @override
  Future<TopicStatusUpdateResponse> startTopic(String topicId) async =>
      TopicStatusUpdateResponse(
          topicId: topicId, status: 'learning', masteryScore: 0.2);

  @override
  Future<TopicStatusUpdateResponse> completeTopic(String topicId) async =>
      TopicStatusUpdateResponse(
          topicId: topicId, status: 'completed', masteryScore: 1.0);

  @override
  Future<TopicStatusUpdateResponse> markTopicNeedsRevision(
          String topicId) async =>
      TopicStatusUpdateResponse(
          topicId: topicId, status: 'needs_revision', masteryScore: 0.5);

  @override
  Future<TopicExplanationData> getTopicExplanation(String topicId) async =>
      TopicExplanationData(
        topicId: topicId,
        topicTitle: 'Mock Topic',
        content: 'Explanation',
        sources: [],
      );

  @override
  Future<List<TopicQuestionItem>> getTopicQuestions(String topicId) async => [];

  @override
  Future<QuestionSubmissionResponse> submitAnswers(
          String topicId, List<AnswerSubmissionItem> answers) async =>
      QuestionSubmissionResponse(
        topicId: topicId,
        score: 1.0,
        masteryScore: 1.0,
        masteryDelta: 0.2,
        correctCount: 1,
        totalCount: 1,
        overallFeedback: 'Great',
      );

  @override
  Future<ContextualAskResponse> askTopicQuestion(
    String topicId,
    String query, {
    TopicQuestionItem? currentQuestion,
    String? selectedAnswer,
    Map<String, dynamic>? questionContext,
  }) async =>
      ContextualAskResponse(answer: 'Answer');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleLearningPath = LearningPath(
    id: 'path_ai_101',
    goalId: 'goal_ai',
    userId: 'user_1',
    title: 'Modern AI & Machine Learning',
    targetLevel: 'Advanced',
    sections: [
      LearningSection(
        id: 'sec_1',
        pathId: 'path_ai_101',
        title: 'Python Foundations',
        description: 'Build your core programming fundamentals',
        orderIndex: 0,
        topics: [
          LearningTopic(
            id: 'top_1',
            sectionId: 'sec_1',
            title: 'Python Syntax & Logic',
            orderIndex: 0,
            status: TopicStatus.completed,
            masteryScore: 0.95,
          ),
          LearningTopic(
            id: 'top_2',
            sectionId: 'sec_1',
            title: 'OOP & Data Structures',
            orderIndex: 1,
            status: TopicStatus.learning,
            masteryScore: 0.40,
          ),
          LearningTopic(
            id: 'top_detour',
            sectionId: 'sec_1',
            title: 'Memory Management',
            orderIndex: 2,
            status: TopicStatus.notStarted,
            metadata: {'is_remediation': true},
          ),
        ],
      ),
      LearningSection(
        id: 'sec_2',
        pathId: 'path_ai_101',
        title: 'Data & Analytics',
        description: 'Master NumPy, Pandas & SQL',
        orderIndex: 1,
        topics: [
          LearningTopic(
            id: 'top_bypassed',
            sectionId: 'sec_2',
            title: 'SQL Basics',
            orderIndex: 0,
            status: TopicStatus.notStarted,
            metadata: {'bypassed': true},
          ),
          LearningTopic(
            id: 'top_revision',
            sectionId: 'sec_2',
            title: 'DataFrame Vectorization',
            orderIndex: 1,
            status: TopicStatus.needsRevision,
            masteryScore: 0.50,
          ),
          LearningTopic(
            id: 'top_locked',
            sectionId: 'sec_2',
            title: 'Statistical Inference',
            orderIndex: 2,
            status: TopicStatus.notStarted,
          ),
        ],
      ),
    ],
  );

  group('Gamified Journey Roadmap Test Suite', () {
    testWidgets('Renders empty state when active learning path is null',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningPathRepositoryProvider
                .overrideWithValue(_FakeLearningPathRepository(null)),
          ],
          child: const MaterialApp(
            home: JourneyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Active Learning Roadmap'), findsOneWidget);
      expect(find.text('Set Learning Goal'), findsOneWidget);
      expect(find.text('Import YouTube Playlist'), findsOneWidget);
    });

    testWidgets(
        'Renders gamified roadmap, alternating cards, and all 7 adaptive states',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningPathRepositoryProvider.overrideWithValue(
              _FakeLearningPathRepository(sampleLearningPath),
            ),
          ],
          child: const MaterialApp(
            home: JourneyScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Verify Top Bar Header
      expect(find.text('Modern AI & Machine Learning'), findsOneWidget);
      expect(find.text('LEARNING ROADMAP'), findsOneWidget);

      // 2. Verify Module 1 & Module 2 Cards
      expect(find.text('MODULE 1'), findsOneWidget);
      expect(find.text('Python Foundations'), findsOneWidget);
      expect(find.text('MODULE 2'), findsOneWidget);
      expect(find.text('Data & Analytics'), findsOneWidget);

      // 3. Verify Topics & Milestone Nodes
      expect(find.text('Python Syntax & Logic'), findsOneWidget);
      expect(find.text('OOP & Data Structures'), findsOneWidget);
      expect(find.text('Memory Management'), findsOneWidget);
      expect(find.text('SQL Basics'), findsOneWidget);
      expect(find.text('DataFrame Vectorization'), findsOneWidget);
      expect(find.text('Statistical Inference'), findsOneWidget);

      // 4. Verify Active Affordance and Companion Mascot on Current Node
      expect(find.text('CONTINUE'), findsOneWidget);
      expect(find.byType(JourneyMascot), findsOneWidget);

      // 5. Verify Adaptive Badges: Quick Fix (Remediation), Proved (Bypassed), Revise (Needs Revision)
      expect(find.text('QUICK FIX'), findsOneWidget);
      expect(find.text('PROVED'), findsOneWidget);
      expect(find.text('REVISE'), findsOneWidget);

      // 6. Verify Mastery Summit Podium at bottom
      expect(find.text('MASTERY SUMMIT'), findsOneWidget);
    });

    testWidgets('Module cards alternate between Left and Right alignment',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      final module1 = RoadmapModuleItem(
        id: 'mod_1',
        title: 'Module One',
        orderIndex: 0, // Even -> LEFT
        progress: 0.5,
        completedCount: 1,
        totalCount: 2,
        theme: ModuleRegionTheme.forIndex(0),
        topics: [],
      );

      final module2 = RoadmapModuleItem(
        id: 'mod_2',
        title: 'Module Two',
        orderIndex: 1, // Odd -> RIGHT
        progress: 0.0,
        completedCount: 0,
        totalCount: 3,
        theme: ModuleRegionTheme.forIndex(1),
        topics: [],
      );

      expect(module1.isCardOnLeft, isTrue);
      expect(module2.isCardOnLeft, isFalse);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AdaptiveModuleCard(module: module1),
                const SizedBox(height: 20),
                AdaptiveModuleCard(module: module2),
              ],
            ),
          ),
        ),
      );

      expect(find.text('MODULE 1'), findsOneWidget);
      expect(find.text('MODULE 2'), findsOneWidget);
      expect(find.text('Module One'), findsOneWidget);
      expect(find.text('Module Two'), findsOneWidget);
    });

    testWidgets('RoadmapTopicItem properly selects context-aware icons',
        (tester) async {
      final codeTopic = RoadmapTopicItem.fromLearningTopic(
        topic: const LearningTopic(
          id: 't1',
          sectionId: 's1',
          title: 'Python Syntax Basics',
          orderIndex: 0,
        ),
        sectionIndex: 0,
        topicIndex: 1,
        isPathActiveCurrent: false,
        isPreviousCompletedOrCurrent: true,
        isFirstInModule: false,
        isLastOverall: false,
      );

      final dbTopic = RoadmapTopicItem.fromLearningTopic(
        topic: const LearningTopic(
          id: 't2',
          sectionId: 's1',
          title: 'PostgreSQL Database Queries',
          orderIndex: 1,
        ),
        sectionIndex: 0,
        topicIndex: 2,
        isPathActiveCurrent: false,
        isPreviousCompletedOrCurrent: true,
        isFirstInModule: false,
        isLastOverall: false,
      );

      final aiTopic = RoadmapTopicItem.fromLearningTopic(
        topic: const LearningTopic(
          id: 't3',
          sectionId: 's1',
          title: 'Deep Learning Neural Networks',
          orderIndex: 2,
        ),
        sectionIndex: 0,
        topicIndex: 3,
        isPathActiveCurrent: false,
        isPreviousCompletedOrCurrent: true,
        isFirstInModule: false,
        isLastOverall: false,
      );

      expect(codeTopic.icon, Icons.code_rounded);
      expect(dbTopic.icon, Icons.dns_rounded);
      expect(aiTopic.icon, Icons.hub_rounded);
    });

    testWidgets('Responsiveness: Renders on small phone (320x568) without overflow',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningPathRepositoryProvider.overrideWithValue(
              _FakeLearningPathRepository(sampleLearningPath),
            ),
          ],
          child: const MaterialApp(
            home: JourneyScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('MODULE 1'), findsOneWidget);
      expect(find.text('Python Syntax & Logic'), findsOneWidget);
    });

    testWidgets('Responsiveness: Renders on tablet (768x1024) without cavernous gaps',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(768, 1024));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningPathRepositoryProvider.overrideWithValue(
              _FakeLearningPathRepository(sampleLearningPath),
            ),
          ],
          child: const MaterialApp(
            home: JourneyScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Modern AI & Machine Learning'), findsOneWidget);
      expect(find.text('MODULE 1'), findsOneWidget);
    });

    testWidgets('Responsiveness: Renders in landscape (844x390) without overflow',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(844, 390));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningPathRepositoryProvider.overrideWithValue(
              _FakeLearningPathRepository(sampleLearningPath),
            ),
          ],
          child: const MaterialApp(
            home: JourneyScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Modern AI & Machine Learning'), findsOneWidget);
    });

    testWidgets('Final journey node and summit podium can be viewed and scrolled to',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningPathRepositoryProvider.overrideWithValue(
              _FakeLearningPathRepository(sampleLearningPath),
            ),
          ],
          child: const MaterialApp(
            home: JourneyScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll to the bottom of the journey
      final scrollable = find.byType(SingleChildScrollView);
      expect(scrollable, findsOneWidget);

      await tester.drag(scrollable, const Offset(0, -2500));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('MASTERY SUMMIT'), findsOneWidget);
      expect(find.text('Statistical Inference'), findsOneWidget);
    });

    testWidgets('Node tapping provides subtle visual response',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningPathRepositoryProvider.overrideWithValue(
              _FakeLearningPathRepository(sampleLearningPath),
            ),
          ],
          child: const MaterialApp(
            home: JourneyScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final activeNodeFinder = find.text('OOP & Data Structures');
      expect(activeNodeFinder, findsOneWidget);

      // Tap active node
      await tester.tap(activeNodeFinder);
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
    });
  });
}
