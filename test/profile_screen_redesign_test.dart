import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilltwin/core/models/goal.dart';
import 'package:skilltwin/core/models/home_dashboard.dart';
import 'package:skilltwin/core/models/learning_path.dart';
import 'package:skilltwin/core/models/topic_detail.dart';
import 'package:skilltwin/core/models/user.dart';
import 'package:skilltwin/core/storage/storage_provider.dart';
import 'package:skilltwin/features/auth/domain/repositories/auth_repository.dart';
import 'package:skilltwin/features/auth/data/repositories/auth_repository_provider.dart';
import 'package:skilltwin/features/home/presentation/providers/home_provider.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository_provider.dart';
import 'package:skilltwin/features/profile/domain/repositories/profile_repository.dart';
import 'package:skilltwin/features/profile/data/repositories/profile_repository_provider.dart';
import 'package:skilltwin/features/profile/presentation/screens/profile_screen.dart';

class _FakeAuthRepo implements AuthRepository {
  final User? user;
  _FakeAuthRepo([this.user]);

  @override
  Future<User?> getCurrentUser() async =>
      user ?? User(id: 'u1', email: 'alex@skilltwin.dev', name: 'Alex Learner', displayName: 'Alex Learner', dailyMinutes: 30);
  @override
  Future<User> login(String e, String p) async =>
      user ?? User(id: 'u1', email: e, name: 'Alex');
  @override
  Future<User> signup({required String email, required String password, required String name}) async =>
      User(id: 'u2', email: email, name: name);
  @override
  Future<void> logout() async {}
  @override
  Stream<User?> get authStateChanges => const Stream.empty();
  @override
  Future<bool> isUserOnboarded() async => true;
}

class _FakeLearningPathRepo implements LearningPathRepository {
  final LearningPath? _path;
  _FakeLearningPathRepo([this._path]);

  @override
  Future<LearningPath?> getActiveLearningPath() async => _path;
  @override
  Future<LearningPath> getLearningPathById(String pathId) async => _path!;
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
        sectionTitle: 'Foundations',
        pathId: 'path_1',
        title: 'Topic',
        orderIndex: 0,
        difficulty: 'beginner',
        estimatedMinutes: 20,
        status: 'not_started',
      );
  @override
  Future<TopicStatusUpdateResponse> startTopic(String topicId) async =>
      TopicStatusUpdateResponse(topicId: topicId, status: 'learning', masteryScore: 0.2);
  @override
  Future<TopicStatusUpdateResponse> completeTopic(String topicId) async =>
      TopicStatusUpdateResponse(topicId: topicId, status: 'completed', masteryScore: 1.0);
  @override
  Future<TopicStatusUpdateResponse> markTopicNeedsRevision(String topicId) async =>
      TopicStatusUpdateResponse(topicId: topicId, status: 'needs_revision', masteryScore: 0.5);

  @override
  Future<TopicExplanationData> getTopicExplanation(String topicId) async =>
      TopicExplanationData(topicId: topicId, topicTitle: 'Topic', content: 'Content', sources: []);
  @override
  Future<List<TopicQuestionItem>> getTopicQuestions(String topicId) async => [];
  @override
  Future<QuestionSubmissionResponse> submitAnswers(String topicId, List<AnswerSubmissionItem> answers) async =>
      QuestionSubmissionResponse(topicId: topicId, score: 1.0, masteryScore: 1.0, masteryDelta: 0.1, correctCount: 1, totalCount: 1, overallFeedback: '');
  @override
  Future<ContextualAskResponse> askTopicQuestion(
    String topicId,
    String query, {
    TopicQuestionItem? currentQuestion,
    String? selectedAnswer,
    Map<String, dynamic>? questionContext,
  }) async =>
      ContextualAskResponse(answer: '');
}

class _FakeProfileRepo implements ProfileRepository {
  @override
  Future<User> getUserProfile() async => User(id: 'u1', email: 'alex@skilltwin.dev', name: 'Alex');
  @override
  Future<void> updateProfile(User user) async {}
  @override
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {}
}

Widget createProfileHarness({
  required SharedPreferences prefs,
  User? user,
  Goal? activeGoal,
  List<Goal>? allGoals,
  HomeDashboardData? dashboardData,
  LearningPath? learningPath,
  double textScale = 1.0,
}) {
  final defaultActiveGoal = activeGoal ??
      Goal(
        id: 'goal_1',
        title: 'Master Flutter & Riverpod Architecture',
        targetLevel: 'Advanced',
        description: 'Build enterprise-grade resilient flutter applications',
        progress: 0.65,
        deadline: DateTime.now().add(const Duration(days: 45)),
        status: GoalStatus.active,
      );

  final defaultDashboard = dashboardData ??
      const HomeDashboardData(
        goalId: 'goal_1',
        streakDays: 7,
        todayStatus: 'NOT_STARTED',
        goalTitle: 'Master Flutter & Riverpod Architecture',
        todayTargetTopicTitle: 'RenderObject & Custom Layouts',
        topicsCompleted: 14,
        topicsRemaining: 6,
        learningMinutes: 35,
        todayTasks: [],
      );

  final defaultLearningPath = learningPath ??
      LearningPath(
        id: 'path_1',
        goalId: 'goal_1',
        userId: 'u1',
        title: 'Master Flutter & Riverpod Architecture',
        targetLevel: 'Advanced',
        progress: 0.65,
        sections: [
          LearningSection(
            id: 'sec_1',
            pathId: 'path_1',
            title: 'Dart & Flutter Fundamentals',
            orderIndex: 0,
            topics: [
              LearningTopic(
                id: 'top_1',
                sectionId: 'sec_1',
                title: 'Riverpod State Management',
                estimatedMinutes: 25,
                orderIndex: 0,
                status: TopicStatus.completed,
                difficulty: 'Intermediate',
                masteryScore: 0.92,
                completedAt: DateTime.now(),
              ),
              LearningTopic(
                id: 'top_2',
                sectionId: 'sec_1',
                title: 'RenderObject & Custom Layouts',
                estimatedMinutes: 30,
                orderIndex: 1,
                status: TopicStatus.learning,
                difficulty: 'Advanced',
                masteryScore: 0.40,
              ),
            ],
          ),
        ],
      );

  return ProviderScope(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      authRepositoryProvider.overrideWithValue(_FakeAuthRepo(user)),
      learningPathRepositoryProvider.overrideWithValue(_FakeLearningPathRepo(defaultLearningPath)),
      profileRepositoryProvider.overrideWithValue(_FakeProfileRepo()),
      activeGoalProvider.overrideWith((ref) async => defaultActiveGoal),
      allGoalsProvider.overrideWith((ref) async => allGoals ?? [defaultActiveGoal]),
      homeDashboardProvider.overrideWith((ref) async => defaultDashboard),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: const ProfileScreen(),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
  });

  late SharedPreferences prefs;

  setUp(() async {
    FlutterError.onError = (details) {
      debugPrint('=== OVERFLOW DETECTED ===');
      debugPrint(details.exceptionAsString());
      if (details.informationCollector != null) {
        for (final node in details.informationCollector!()) {
          debugPrint(node.toStringDeep());
        }
      }
    };
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('Profile Screen Redesign & Visual Hierarchy Tests', () {
    testWidgets('Renders full visual hierarchy in the required sequence', (tester) async {
      await tester.pumpWidget(createProfileHarness(prefs: prefs));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);

      // Section 1: Who I am
      expect(find.text('Learner Profile'), findsOneWidget);
      expect(find.text('LEARNER'), findsOneWidget);
      expect(find.text('Alex Learner'), findsOneWidget);
      expect(find.text('SkillTwin Companion'), findsOneWidget);
      expect(find.text('Ready to keep your momentum going today?'), findsOneWidget);

      // Section 2: How I'm learning
      expect(find.text('HOW I\'M LEARNING'), findsOneWidget);
      expect(find.text('ACTIVE GOAL'), findsOneWidget);
      expect(find.text('Master Flutter & Riverpod Architecture'), findsOneWidget);
      expect(find.text('65% Completed'), findsOneWidget);
      expect(find.text('Edit Goal'), findsOneWidget);
      expect(find.text('Open Journey Roadmap'), findsOneWidget);

      // Section 3: What I've achieved
      await tester.scrollUntilVisible(find.text('WHAT I\'VE ACHIEVED'), 200);
      expect(find.text('WHAT I\'VE ACHIEVED'), findsOneWidget);
      expect(find.text('Milestones & Mastery'), findsOneWidget);
      expect(find.text('Mastered'), findsOneWidget);
      expect(find.text('Retention'), findsOneWidget);
      expect(find.text('Daily Target'), findsOneWidget);

      // Section 4: My consistency & rhythm
      await tester.scrollUntilVisible(find.text('MY CONSISTENCY & RHYTHM'), 200);
      expect(find.text('MY CONSISTENCY & RHYTHM'), findsOneWidget);
      expect(find.text('Jump to Today'), findsOneWidget);
    });

    testWidgets('Zero RenderFlex overflow on compact screen (320x568) with 1.4x text scale', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createProfileHarness(
        prefs: prefs,
        textScale: 1.4,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final err = tester.takeException();
      expect(err, isNull);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('Long learner name and long goal title handle safely without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final longUser = User(
        id: 'u_long',
        email: 'alexander.bartholomew.montgomery.iv@skilltwin.dev',
        name: 'Alexander Bartholomew Montgomery IV',
        displayName: 'Alexander Bartholomew Montgomery IV',
        dailyMinutes: 45,
      );

      final longGoal = Goal(
        id: 'goal_long',
        title: 'Mastering Enterprise Scalable Microservices with Flutter & Kubernetes Cloud Native Architecture',
        targetLevel: 'Production Ready',
        description: 'Comprehensive curriculum covering distributed systems and reactive architectures.',
        progress: 0.78,
        deadline: DateTime.now().add(const Duration(days: 90)),
        status: GoalStatus.active,
      );

      await tester.pumpWidget(createProfileHarness(
        prefs: prefs,
        user: longUser,
        activeGoal: longGoal,
        textScale: 1.3,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('Empty active goal renders friendly empty state cleanly', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
          learningPathRepositoryProvider.overrideWithValue(_FakeLearningPathRepo()),
          profileRepositoryProvider.overrideWithValue(_FakeProfileRepo()),
          activeGoalProvider.overrideWith((ref) async => null),
          allGoalsProvider.overrideWith((ref) async => []),
          homeDashboardProvider.overrideWith((ref) async => const HomeDashboardData(
                goalId: 'g0',
                streakDays: 0,
                todayStatus: 'NOT_STARTED',
                goalTitle: '',
                topicsCompleted: 0,
                topicsRemaining: 0,
                todayTasks: [],
              )),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('No Active Goal Set'), findsOneWidget);
      expect(find.text('No Other Saved Goals'), findsOneWidget);
    });
  });
}
