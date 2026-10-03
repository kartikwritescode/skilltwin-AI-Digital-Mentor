import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:skilltwin/core/models/home_dashboard.dart';
import 'package:skilltwin/core/storage/storage_provider.dart';
import 'package:skilltwin/features/home/presentation/providers/home_provider.dart';
import 'package:skilltwin/features/home/presentation/widgets/todays_task_card.dart';
import 'package:skilltwin/features/home/presentation/widgets/learning_pace_card.dart';
import 'package:skilltwin/features/home/presentation/screens/home_screen.dart';
import 'package:skilltwin/features/home/domain/repositories/home_repository.dart';
import 'package:skilltwin/features/home/data/repositories/home_repository_provider.dart';
import 'package:skilltwin/core/models/goal.dart';
import 'package:skilltwin/core/models/mentor_message.dart';
import 'package:skilltwin/core/models/learning_path.dart';
import 'package:skilltwin/core/models/topic_detail.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository_provider.dart';
import 'package:skilltwin/core/models/learning_session.dart';
import 'package:skilltwin/core/models/session_step.dart';
import 'package:skilltwin/core/models/session_result.dart';
import 'package:skilltwin/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:skilltwin/features/sessions/data/repositories/sessions_repository_provider.dart';
import 'package:skilltwin/features/sessions/presentation/providers/session_state_provider.dart';

class _FakeSessionsRepo implements SessionsRepository {
  @override
  Future<LearningSession> getSession(String sessionId) async {
    return LearningSession(
      id: sessionId,
      conceptId: 'topic_graphs',
      conceptTitle: 'Graph Theory',
      type: SessionType.learn,
      durationMinutes: 20,
      whyStatement: 'Learn graph traversals',
      steps: [
        SessionStep(
          id: 'step_1',
          title: 'Intro',
          type: StepType.learn,
          content: {'title': 'Intro'},
        ),
      ],
    );
  }

  @override
  Future<LearningSession> createSession(String conceptId, SessionType type) async =>
      throw UnimplementedError();

  @override
  Future<SessionResult> completeSession(String sessionId, Map<String, dynamic> evidence) async {
    return SessionResult(
      sessionId: sessionId,
      conceptId: 'topic_graphs',
      conceptTitle: 'Graph Theory',
      masteryDelta: 0.15,
      confidenceDelta: 0.10,
      currentMastery: 0.85,
      currentConfidence: 0.80,
      improvements: ['Solid understanding'],
      focusAreas: [],
      mentorRecommendation: 'Keep going',
      accuracyScore: 0.9,
      completenessScore: 0.9,
      evidenceSummary: {},
    );
  }

  @override
  Future<void> updateStepProgress(String sessionId, String stepId, bool completed) async {}
}

class _FakeHomeRepo implements HomeRepository {
  HomeDashboardData dashboard;
  _FakeHomeRepo(this.dashboard);

  @override
  Future<HomeDashboardData> getHomeDashboard() async => dashboard;

  @override
  Future<Goal?> getActiveGoal() async => null;

  @override
  Future<List<MentorMessage>> getRecentMentorMessages() async => [];
}

class _FakeLearningPathRepo implements LearningPathRepository {
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
  Future<TopicDetailData> getTopicDetail(String topicId) async =>
      throw UnimplementedError();
  @override
  Future<TopicStatusUpdateResponse> startTopic(String topicId) async =>
      throw UnimplementedError();
  @override
  Future<TopicStatusUpdateResponse> completeTopic(String topicId) async =>
      throw UnimplementedError();
  @override
  Future<TopicStatusUpdateResponse> markTopicNeedsRevision(
          String topicId) async =>
      throw UnimplementedError();
  @override
  Future<TopicExplanationData> getTopicExplanation(String topicId) async =>
      throw UnimplementedError();
  @override
  Future<List<TopicQuestionItem>> getTopicQuestions(String topicId) async =>
      [];
  @override
  Future<QuestionSubmissionResponse> submitAnswers(
          String topicId, List<AnswerSubmissionItem> answers) async =>
      throw UnimplementedError();
  @override
  Future<ContextualAskResponse> askTopicQuestion(
    String topicId,
    String query, {
    TopicQuestionItem? currentQuestion,
    String? selectedAnswer,
    Map<String, dynamic>? questionContext,
  }) async =>
      throw UnimplementedError();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TodaysTaskCard Adaptive State Transitions', () {
    testWidgets('shows "Start Today\'s Session" when task is NOT_STARTED',
        (WidgetTester tester) async {
      const dashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'Python Mastery',
        todayTargetTopicTitle: 'List Comprehensions',
        todayKeyConcepts: ['Syntax', 'Filtering'],
        todayStatus: 'NOT_STARTED',
        isTodayCompleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodaysTaskCard(
              data: dashboard,
              isCompleted: false,
              isLearning: false,
              onStartSession: () {},
            ),
          ),
        ),
      );

      expect(find.text("Today's Task"), findsOneWidget);
      expect(find.text("Start Today's Session"), findsOneWidget);
      expect(find.text("Completed"), findsNothing);
    });

    testWidgets('shows "Continue Today\'s Session" and "In Progress" when LEARNING',
        (WidgetTester tester) async {
      const dashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'Python Mastery',
        todayTargetTopicTitle: 'List Comprehensions',
        todayStatus: 'LEARNING',
        isTodayCompleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodaysTaskCard(
              data: dashboard,
              isCompleted: false,
              isLearning: true,
              onStartSession: () {},
            ),
          ),
        ),
      );

      expect(find.text("Continue Today's Session"), findsOneWidget);
      expect(find.text("In Progress"), findsOneWidget);
    });

    testWidgets(
        'shows "✓ Today\'s Session Completed" and "Completed" badge when COMPLETED',
        (WidgetTester tester) async {
      const dashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'Python Mastery',
        todayTargetTopicTitle: 'List Comprehensions',
        todayStatus: 'COMPLETED',
        isTodayCompleted: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodaysTaskCard(
              data: dashboard,
              isCompleted: true,
              isLearning: false,
              onStartSession: () {},
            ),
          ),
        ),
      );

      expect(find.text("✓ Today's Session Completed"), findsOneWidget);
      expect(find.text("Completed"), findsOneWidget);
      expect(find.text("Start Today's Session"), findsNothing);
    });
  });

  group('LearningPaceCard Adaptive States', () {
    testWidgets('renders Ahead of Schedule state correctly',
        (WidgetTester tester) async {
      const dashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'Cloud Architecture',
        scheduleStatus: 'AHEAD_OF_SCHEDULE',
        topicsCompleted: 15,
        topicsRemaining: 5,
        daysRemaining: 18,
        overallProgress: 0.75,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LearningPaceCard(data: dashboard),
          ),
        ),
      );

      expect(find.text("You're ahead of schedule"), findsOneWidget);
      expect(find.text("You're moving faster than your planned pace."),
          findsOneWidget);
      expect(find.textContaining("15 completed"), findsOneWidget);
    });

    testWidgets('renders On Track state correctly',
        (WidgetTester tester) async {
      const dashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'Cloud Architecture',
        scheduleStatus: 'ON_TRACK',
        topicsCompleted: 8,
        topicsRemaining: 12,
        daysRemaining: 25,
        overallProgress: 0.40,
        backlogCount: 0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LearningPaceCard(data: dashboard),
          ),
        ),
      );

      expect(find.text("You're right on track"), findsOneWidget);
      expect(
          find.text("You're progressing at a healthy pace toward your goal."),
          findsOneWidget);
      expect(find.textContaining("40% progress"), findsOneWidget);
    });

    testWidgets('renders Behind / Backlog state with Catch up CTA',
        (WidgetTester tester) async {
      const dashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'Cloud Architecture',
        scheduleStatus: 'BEHIND_SCHEDULE',
        backlogCount: 2,
        topicsCompleted: 4,
        topicsRemaining: 16,
        daysRemaining: 10,
        overallProgress: 0.20,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LearningPaceCard(data: dashboard),
          ),
        ),
      );

      expect(find.text("You have a little catching up to do"), findsOneWidget);
      expect(find.text("You have some unfinished learning from previous days."),
          findsOneWidget);
      expect(find.text("2 tasks waiting for you"), findsOneWidget);
      expect(find.text("Catch up"), findsOneWidget);
    });
  });

  group('TodayTaskStateNotifier & Shared State Persistence', () {
    test('transitions NOT_STARTED -> LEARNING -> COMPLETED and persists',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(todayTaskStateProvider.notifier);
      expect(container.read(todayTaskStateProvider).isNotStarted, isTrue);

      // Start learning
      notifier.markStarted(topicId: 'topic_123', topicTitle: 'Binary Search');
      expect(container.read(todayTaskStateProvider).isLearning, isTrue);
      expect(container.read(todayTaskStateProvider).topicTitle, 'Binary Search');

      // Complete session
      await notifier.recordCompletion(
        topicId: 'topic_123',
        topicTitle: 'Binary Search',
      );
      expect(container.read(todayTaskStateProvider).isCompleted, isTrue);

      // Check SharedPreferences persistence
      final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      expect(prefs.getBool('skilltwin_today_completed_$todayKey'), isTrue);
      expect(prefs.getString('skilltwin_today_topic_id_$todayKey'), 'topic_123');

      // Verify app restart initializes state directly to COMPLETED from storage
      final restartContainer = ProviderContainer(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
      );
      expect(
          restartContainer.read(todayTaskStateProvider).isCompleted, isTrue);
    });

    test('failure rolls back and never falsely marks completion', () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(todayTaskStateProvider.notifier);
      notifier.markStarted(topicId: 'topic_err');
      expect(container.read(todayTaskStateProvider).isLearning, isTrue);

      // API fails
      notifier.recordFailure('Network 500 error');
      expect(container.read(todayTaskStateProvider).isCompleted, isFalse);
      expect(container.read(todayTaskStateProvider).isLearning, isTrue);
      expect(container.read(todayTaskStateProvider).error, 'Network 500 error');

      final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      expect(prefs.getBool('skilltwin_today_completed_$todayKey'), isNull);
    });
  });

  group('Reactive Home Rebuild upon Today Task Completion', () {
    testWidgets(
        'Home screen dynamically updates CTA from Start to Completed upon state change',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      const initialDashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'DSA Java',
        todayTargetTopicTitle: 'Graph Theory',
        todayStatus: 'NOT_STARTED',
        isTodayCompleted: false,
        streakDays: 5,
        topicsCompleted: 10,
        topicsRemaining: 15,
        overallProgress: 0.40,
        isNewLearner: false,
      );

      final container = ProviderContainer(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          homeRepositoryProvider.overrideWithValue(_FakeHomeRepo(initialDashboard)),
          learningPathRepositoryProvider.overrideWithValue(_FakeLearningPathRepo()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially displays Start Today's Session
      expect(find.text("Start Today's Session"), findsOneWidget);
      expect(find.text("✓ Today's Session Completed"), findsNothing);

      // Now simulate session completion through the single source of truth
      await container.read(todayTaskStateProvider.notifier).recordCompletion(
            topicId: 'topic_graphs',
            topicTitle: 'Graph Theory',
          );

      await tester.pumpAndSettle();

      // Automatically transformed to Completed without reload or user interaction!
      expect(find.text("✓ Today's Session Completed"), findsOneWidget);
      expect(find.text("Start Today's Session"), findsNothing);
    });

    testWidgets(
        'SessionNotifier submitSession immediately and reactively transforms Home screen',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      const initialDashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'DSA Java',
        todayTargetTopicId: 'topic_graphs',
        todayTargetTopicTitle: 'Graph Theory',
        todayStatus: 'NOT_STARTED',
        isTodayCompleted: false,
        streakDays: 5,
        topicsCompleted: 10,
        topicsRemaining: 15,
        overallProgress: 0.40,
        isNewLearner: false,
      );

      final fakeSessionsRepo = _FakeSessionsRepo();
      final container = ProviderContainer(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          homeRepositoryProvider.overrideWithValue(_FakeHomeRepo(initialDashboard)),
          learningPathRepositoryProvider.overrideWithValue(_FakeLearningPathRepo()),
          sessionsRepositoryProvider.overrideWithValue(fakeSessionsRepo),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text("Start Today's Session"), findsOneWidget);
      expect(find.text("✓ Today's Session Completed"), findsNothing);

      // User starts and completes learning session with UUID session_uuid_999
      final sessionNotifier = container.read(sessionStateProvider('session_uuid_999').notifier);
      await sessionNotifier.loadSession();
      sessionNotifier.startSession();
      await sessionNotifier.submitSession();

      await tester.pumpAndSettle();

      // Home dynamically reflects the completed state because effective conceptId matched!
      expect(find.text("✓ Today's Session Completed"), findsOneWidget);
      expect(find.text("Start Today's Session"), findsNothing);
    });
  });

  group('Multiple Daily Tasks Queue Handling', () {
    const task1 = DailyTaskItem(
      id: 'task_1',
      topicId: 'topic_1',
      title: 'Learn Flutter BLoC',
      orderIndex: 0,
      estimatedMinutes: 25,
      isCurrent: true,
    );
    const task2 = DailyTaskItem(
      id: 'task_2',
      topicId: 'topic_2',
      title: 'Practice BLoC Architecture',
      orderIndex: 1,
      estimatedMinutes: 20,
      isCurrent: false,
    );
    const task3 = DailyTaskItem(
      id: 'task_3',
      topicId: 'topic_3',
      title: 'BLoC Integration Tests',
      orderIndex: 2,
      estimatedMinutes: 30,
      isCurrent: false,
    );

    test('Two tasks: Task 1 completes -> advances to Task 2 -> Task 2 completes -> all completed',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(todayTaskStateProvider.notifier);

      const dashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'Flutter Expert',
        todayTasks: [task1, task2],
        todayTasksTotal: 2,
        todayTasksCompleted: 0,
      );

      // Step 1: Initial Sync
      notifier.syncWithDashboard(dashboard);
      final state1 = container.read(todayTaskStateProvider);
      expect(state1.topicId, 'topic_1');
      expect(state1.topicTitle, 'Learn Flutter BLoC');
      expect(state1.isCompleted, isFalse);
      expect(state1.totalTasks, 2);
      expect(state1.currentTaskIndex, 0);

      // Step 2: Complete Task 1
      await notifier.recordCompletion(
        topicId: 'topic_1',
        topicTitle: 'Learn Flutter BLoC',
      );

      final state2 = container.read(todayTaskStateProvider);
      // Automatically advances to Task 2!
      expect(state2.topicId, 'topic_2');
      expect(state2.topicTitle, 'Practice BLoC Architecture');
      expect(state2.isCompleted, isFalse);
      expect(state2.completedCount, 1);
      expect(state2.remainingCount, 1);
      expect(state2.currentTaskIndex, 1);

      // Step 3: Complete Task 2
      await notifier.recordCompletion(
        topicId: 'topic_2',
        topicTitle: 'Practice BLoC Architecture',
      );

      final state3 = container.read(todayTaskStateProvider);
      // Now all completed!
      expect(state3.isCompleted, isTrue);
      expect(state3.completedCount, 2);
      expect(state3.remainingCount, 0);
    });

    test('Three tasks sequentially advance 1 -> 2 -> 3 -> all complete',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(todayTaskStateProvider.notifier);

      const dashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'Flutter Expert',
        todayTasks: [task1, task2, task3],
        todayTasksTotal: 3,
        todayTasksCompleted: 0,
      );

      notifier.syncWithDashboard(dashboard);
      expect(container.read(todayTaskStateProvider).topicId, 'topic_1');

      // Complete 1
      await notifier.recordCompletion(topicId: 'topic_1', topicTitle: 'Learn Flutter BLoC');
      expect(container.read(todayTaskStateProvider).topicId, 'topic_2');
      expect(container.read(todayTaskStateProvider).isCompleted, isFalse);

      // Complete 2
      await notifier.recordCompletion(topicId: 'topic_2', topicTitle: 'Practice BLoC Architecture');
      expect(container.read(todayTaskStateProvider).topicId, 'topic_3');
      expect(container.read(todayTaskStateProvider).isCompleted, isFalse);

      // Complete 3
      await notifier.recordCompletion(topicId: 'topic_3', topicTitle: 'BLoC Integration Tests');
      expect(container.read(todayTaskStateProvider).isCompleted, isTrue);
    });

    test('Partial completion persists across app restarts (Task 1 completed -> restart -> Task 2 CURRENT)',
        () async {
      final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      // Simulate persisted state from previous session where Task 1 was completed
      SharedPreferences.setMockInitialValues({
        'skilltwin_today_completed_$todayKey': false,
        'skilltwin_today_completed_topics_$todayKey': ['topic_1'],
        'skilltwin_today_topic_id_$todayKey': 'topic_2',
        'skilltwin_today_topic_title_$todayKey': 'Practice BLoC Architecture',
      });

      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
      );

      // Startup restoration
      final restoredState = container.read(todayTaskStateProvider);
      expect(restoredState.topicId, 'topic_2');
      expect(restoredState.topicTitle, 'Practice BLoC Architecture');
      expect(restoredState.isCompleted, isFalse);
      expect(restoredState.completedTopicIds, contains('topic_1'));

      // Backend sync does not reset back to Task 1
      const dashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'Flutter Expert',
        todayTasks: [
          DailyTaskItem(id: 't1', topicId: 'topic_1', title: 'Task 1', status: 'COMPLETED'),
          DailyTaskItem(id: 't2', topicId: 'topic_2', title: 'Task 2', status: 'NOT_STARTED', isCurrent: true),
        ],
        todayTasksTotal: 2,
        todayTasksCompleted: 1,
      );

      container.read(todayTaskStateProvider.notifier).syncWithDashboard(dashboard);
      final syncedState = container.read(todayTaskStateProvider);
      expect(syncedState.topicId, 'topic_2');
      expect(syncedState.isCompleted, isFalse);
    });

    test('All tasks completed persists across restart', () async {
      final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      SharedPreferences.setMockInitialValues({
        'skilltwin_today_completed_$todayKey': true,
        'skilltwin_today_completed_topics_$todayKey': ['topic_1', 'topic_2'],
      });

      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
      );

      final state = container.read(todayTaskStateProvider);
      expect(state.isCompleted, isTrue);
    });

    test('Completion failure rolls back without advancing to next task',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(todayTaskStateProvider.notifier);
      const dashboard = HomeDashboardData(
        goalId: 'g1',
        todayTasks: [task1, task2],
        todayTasksTotal: 2,
      );

      notifier.syncWithDashboard(dashboard);
      expect(container.read(todayTaskStateProvider).topicId, 'topic_1');

      notifier.markStarted(topicId: 'topic_1');
      expect(container.read(todayTaskStateProvider).isLearning, isTrue);

      // Network error occurred
      notifier.recordFailure('Submission failed');
      final failState = container.read(todayTaskStateProvider);
      expect(failState.topicId, 'topic_1'); // Still on Task 1!
      expect(failState.isCompleted, isFalse);
      expect(failState.error, 'Submission failed');
    });

    testWidgets('TodaysTaskCard renders Task 1 of 2 with "Today\'s Focus", then Task 2 of 2 with "Up Next"',
        (WidgetTester tester) async {
      const dashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'Flutter Mastery',
        todayTasks: [task1, task2],
        todayTasksTotal: 2,
        todayTasksCompleted: 0,
      );

      // Render Task 1
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodaysTaskCard(
              data: dashboard,
              isCompleted: false,
              isLearning: false,
              taskIndex: 1,
              totalTasks: 2,
              currentTopicTitle: 'Learn Flutter BLoC',
              onStartSession: () {},
            ),
          ),
        ),
      );

      expect(find.text("Today's Focus"), findsOneWidget);
      expect(find.text('Task 1 of 2'), findsOneWidget);
      expect(find.text('Learn Flutter BLoC'), findsOneWidget);
      expect(find.text("Start Today's Session"), findsOneWidget);

      // Render Task 2 (after Task 1 completed)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodaysTaskCard(
              data: dashboard,
              isCompleted: false,
              isLearning: false,
              taskIndex: 2,
              totalTasks: 2,
              currentTopicTitle: 'Practice BLoC Architecture',
              onStartSession: () {},
            ),
          ),
        ),
      );

      expect(find.text("Up Next"), findsOneWidget);
      expect(find.text('Task 2 of 2'), findsOneWidget);
      expect(find.text('Practice BLoC Architecture'), findsOneWidget);
      expect(find.text("Start Today's Session"), findsOneWidget);

      // Render All Completed
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodaysTaskCard(
              data: dashboard,
              isCompleted: true,
              isLearning: false,
              taskIndex: 2,
              totalTasks: 2,
              onStartSession: () {},
            ),
          ),
        ),
      );

      expect(find.text("Today's Tasks Completed"), findsOneWidget);
      expect(find.text('All 2 Tasks Done'), findsOneWidget);
      expect(find.text("✓ Today's Session Completed"), findsOneWidget);
    });
  });
}
