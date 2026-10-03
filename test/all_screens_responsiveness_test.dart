import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilltwin/core/storage/storage_provider.dart';
import 'package:skilltwin/core/models/user.dart';
import 'package:skilltwin/core/models/goal.dart';
import 'package:skilltwin/core/models/home_dashboard.dart';
import 'package:skilltwin/core/models/twin_dashboard.dart';
import 'package:skilltwin/core/models/learning_path.dart';
import 'package:skilltwin/core/models/resource.dart';
import 'package:skilltwin/core/models/topic_detail.dart';
import 'package:skilltwin/core/models/knowledge_maintenance_item.dart';

import 'package:skilltwin/features/auth/presentation/screens/splash_screen.dart';
import 'package:skilltwin/features/auth/presentation/screens/intro_carousel_screen.dart';
import 'package:skilltwin/features/auth/presentation/screens/login_screen.dart';
import 'package:skilltwin/features/auth/presentation/screens/signup_screen.dart';
import 'package:skilltwin/features/auth/domain/repositories/auth_repository.dart';
import 'package:skilltwin/features/auth/data/repositories/auth_repository_provider.dart';

import 'package:skilltwin/features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import 'package:skilltwin/features/home/presentation/screens/home_screen.dart';
import 'package:skilltwin/features/home/presentation/providers/home_provider.dart';
import 'package:skilltwin/features/journey/presentation/screens/journey_screen.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository.dart';
import 'package:skilltwin/features/journey/data/repositories/learning_path_repository_provider.dart';
import 'package:skilltwin/features/library/presentation/screens/library_screen.dart';
import 'package:skilltwin/features/library/domain/repositories/library_repository.dart';
import 'package:skilltwin/features/library/data/repositories/library_repository_provider.dart';
import 'package:skilltwin/features/twin/presentation/screens/twin_screen.dart';
import 'package:skilltwin/features/twin/presentation/providers/twin_provider.dart';
import 'package:skilltwin/features/twin/presentation/screens/knowledge_maintenance_screen.dart';
import 'package:skilltwin/features/twin/presentation/providers/knowledge_maintenance_provider.dart';
import 'package:skilltwin/features/streak/presentation/screens/streak_screen.dart';
import 'package:skilltwin/features/mentor/presentation/screens/mentor_screen.dart';
import 'package:skilltwin/features/profile/presentation/screens/profile_screen.dart';
import 'package:skilltwin/features/sessions/presentation/screens/revision_screen.dart';
import 'package:skilltwin/features/sessions/presentation/screens/revision_retrieval_screen.dart';
import 'package:skilltwin/features/sessions/data/repositories/mock_revision_repository.dart';
import 'package:skilltwin/features/sessions/data/repositories/revision_repository_provider.dart';
import 'package:skilltwin/features/teach_mode/presentation/screens/teach_mode_report_screen.dart';
import 'package:skilltwin/features/teach_mode/presentation/providers/teach_mode_provider.dart';
import 'package:skilltwin/features/teach_mode/domain/repositories/teach_mode_repository.dart';

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<User?> getCurrentUser() async =>
      User(id: 'u1', email: 'test@skilltwin.dev', name: 'Alex Learner');
  @override
  Future<User> login(String e, String p) async =>
      User(id: 'u1', email: e, name: 'Alex');
  @override
  Future<User> signup(
          {required String email,
          required String password,
          required String name}) async =>
      User(id: 'u2', email: email, name: name);
  @override
  Future<void> logout() async {}
  @override
  Stream<User?> get authStateChanges => const Stream.empty();
  @override
  Future<bool> isUserOnboarded() async => true;
}

class _FakeLibraryRepo implements LibraryRepository {
  @override
  Future<List<Resource>> getResources({String? query}) async => [
        Resource(
          id: 'res_1',
          title: 'Deep Learning System Design',
          type: ResourceType.pdf,
          status: ResourceStatus.ready,
          mentorLabel: ResourceLabel.useNow,
          extractedConcepts: ['Backprop', 'Transformers'],
          createdAt: DateTime.now(),
        ),
      ];

  @override
  Future<Resource> addLink(String url, String title) async => Resource(
        id: 'res_link',
        title: title,
        type: ResourceType.link,
        status: ResourceStatus.ready,
        mentorLabel: ResourceLabel.reference,
        extractedConcepts: [],
        createdAt: DateTime.now(),
      );

  @override
  Future<Resource> createNote(String content, String title) async => Resource(
        id: 'res_note',
        title: title,
        type: ResourceType.note,
        status: ResourceStatus.ready,
        mentorLabel: ResourceLabel.useNow,
        extractedConcepts: [],
        createdAt: DateTime.now(),
      );

  @override
  Future<void> deleteResource(String id) async {}

  @override
  Future<Resource> getResourceDetails(String id) async => Resource(
        id: id,
        title: 'Deep Learning System Design',
        type: ResourceType.pdf,
        status: ResourceStatus.ready,
        mentorLabel: ResourceLabel.useNow,
        extractedConcepts: ['Backprop', 'Transformers'],
        createdAt: DateTime.now(),
      );

  @override
  Future<Resource> uploadPdf(File file, String title) async => Resource(
        id: 'res_pdf',
        title: title,
        type: ResourceType.pdf,
        status: ResourceStatus.ready,
        mentorLabel: ResourceLabel.useNow,
        extractedConcepts: [],
        createdAt: DateTime.now(),
      );
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
        title: 'Gradient Descent',
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
        topicTitle: 'Gradient Descent',
        content: 'Optimization algorithm',
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
      ContextualAskResponse(answer: 'Answer');
}

class _FakeTeachModeRepo implements TeachModeRepository {
  @override
  Future<void> startVoiceSession() async {}
  @override
  Future<void> stopVoiceSession() async {}
  @override
  Future<Map<String, dynamic>> getUnderstandingReport() async => {};
  @override
  Future<String?> transcribeAudio(File audioFile, {String? conceptId}) async =>
      'Transcription';
  @override
  Future<Map<String, dynamic>> evaluateExplanation(
          String conceptId, String explanationText) async =>
      {};
}

void main() {
  late SharedPreferences mockPrefs;

  setUp(() async {
    FlutterError.onError = FlutterError.dumpErrorToConsole;
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
  });

  void setDevice(WidgetTester tester,
      {required double width, required double height}) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  final mockLearningPath = LearningPath(
    id: 'path_1',
    goalId: 'g1',
    userId: 'u1',
    title: 'Fullstack AI Mastery',
    targetLevel: 'Intermediate',
    progress: 0.35,
    sections: [
      LearningSection(
        id: 'sec_1',
        pathId: 'path_1',
        title: '1. Foundations',
        orderIndex: 0,
        topics: [
          LearningTopic(
            id: 'top_1',
            sectionId: 'sec_1',
            title: 'Linear Algebra for ML',
            estimatedMinutes: 20,
            status: TopicStatus.completed,
            orderIndex: 0,
            masteryScore: 1.0,
          ),
          LearningTopic(
            id: 'top_2',
            sectionId: 'sec_1',
            title: 'Calculus & Gradients',
            estimatedMinutes: 30,
            status: TopicStatus.learning,
            orderIndex: 1,
            masteryScore: 0.4,
          ),
          LearningTopic(
            id: 'top_3',
            sectionId: 'sec_1',
            title: 'Loss Functions',
            estimatedMinutes: 25,
            status: TopicStatus.notStarted,
            orderIndex: 2,
            masteryScore: 0.0,
          ),
        ],
      ),
    ],
  );

  Widget createHarness({
    required Widget child,
    List<dynamic> overrides = const [],
    double textScale = 1.0,
  }) {
    return ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(mockPrefs),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
        libraryRepositoryProvider.overrideWithValue(_FakeLibraryRepo()),
        learningPathRepositoryProvider
            .overrideWithValue(_FakeLearningPathRepo(mockLearningPath)),
        revisionRepositoryProvider.overrideWithValue(MockRevisionRepository()),
        homeDashboardProvider.overrideWith((ref) => Future.value(
              const HomeDashboardData(
                goalId: 'g1',
                streakDays: 5,
                todayStatus: 'NOT_STARTED',
                goalTitle: 'Master Machine Learning',
                todayTargetTopicTitle: 'Gradient Descent Optimization',
                topicsCompleted: 12,
                topicsRemaining: 24,
                todayTasks: [
                  DailyTaskItem(
                    id: 't1',
                    topicId: 'top_1',
                    title: 'Gradient Descent Math',
                    status: 'NOT_STARTED',
                    orderIndex: 1,
                  ),
                  DailyTaskItem(
                    id: 't2',
                    topicId: 'top_2',
                    title: 'Backpropagation Code',
                    status: 'NOT_STARTED',
                    orderIndex: 2,
                  ),
                ],
              ),
            )),
        twinDashboardProvider.overrideWith((ref) => Future.value(
              const TwinDashboardData(
                userId: 'u1',
                hasSufficientData: true,
                consistencyStreak: 5,
                overallMastery: 0.76,
                verifiedEvidenceCount: 14,
                strongestAreas: [
                  AreaMasteryItem(
                      name: 'Neural Nets',
                      masteryScore: 0.88,
                      status: 'MASTERED')
                ],
                conceptsAtRisk: ['Attention Heads'],
              ),
            )),
        activeGoalProvider.overrideWith((ref) => Future.value(
              Goal(
                id: 'g1',
                title: 'Fullstack AI Engineer',
                currentLevel: 'Intermediate',
                dailyMinutes: 30,
                deadline: DateTime.now().add(const Duration(days: 90)),
              ),
            )),
        ...overrides,
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        builder: (context, widget) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: widget!,
          );
        },
        home: child,
      ),
    );
  }

  group('Screen Responsiveness & Overflow Stress Tests', () {
    testWidgets('SplashScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester.pumpWidget(
          createHarness(child: const SplashScreen(), textScale: 1.4));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('SkillTwin'), findsOneWidget);
    });

    testWidgets('IntroCarouselScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester.pumpWidget(
          createHarness(child: const IntroCarouselScreen(), textScale: 1.4));
      await tester.pumpAndSettle();

      final err = tester.takeException();
      if (err is FlutterError) {
        FlutterError.dumpErrorToConsole(FlutterErrorDetails(exception: err));
      }
      expect(err, isNull);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('LoginScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester
          .pumpWidget(createHarness(child: const LoginScreen(), textScale: 1.4));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Welcome back.'), findsOneWidget);
    });

    testWidgets('SignupScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester.pumpWidget(
          createHarness(child: const SignupScreen(), textScale: 1.4));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text("Let's build your Twin."), findsOneWidget);
    });

    testWidgets('OnboardingFlowScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester.pumpWidget(
          createHarness(child: const OnboardingFlowScreen(), textScale: 1.3));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text("Before we start..."), findsOneWidget);
    });

    testWidgets('HomeScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester
          .pumpWidget(createHarness(child: const HomeScreen(), textScale: 1.2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('JourneyScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester.pumpWidget(
          createHarness(child: const JourneyScreen(), textScale: 1.2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final err = tester.takeException();
      expect(err, isNull);
      expect(find.byType(JourneyScreen), findsOneWidget);
    });

    testWidgets('TwinScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester
          .pumpWidget(createHarness(child: const TwinScreen(), textScale: 1.2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('My Cognitive Twin'), findsOneWidget);
    });

    testWidgets('StreakScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester.pumpWidget(
          createHarness(child: const StreakScreen(), textScale: 1.3));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Your Learning Streak'), findsOneWidget);
    });

    testWidgets('LibraryScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester.pumpWidget(
          createHarness(child: const LibraryScreen(), textScale: 1.2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Knowledge Library'), findsOneWidget);
    });

    testWidgets('ProfileScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester.pumpWidget(
          createHarness(child: const ProfileScreen(), textScale: 1.2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Learner Profile'), findsOneWidget);
    });

    testWidgets('RevisionScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester.pumpWidget(createHarness(
        child: const RevisionScreen(),
        textScale: 1.2,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('5 minutes for your future self.'), findsOneWidget);
    });

    testWidgets('RevisionRetrievalScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester.pumpWidget(createHarness(
        child: const RevisionRetrievalScreen(conceptId: 'recursion'),
        textScale: 1.2,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Recursion'), findsAtLeastNWidgets(1));
    });

    testWidgets(
        'KnowledgeMaintenanceScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester.pumpWidget(createHarness(
        child: const KnowledgeMaintenanceScreen(),
        overrides: [
          knowledgeMaintenanceProvider.overrideWith((ref) => Future.value([
                KnowledgeMaintenanceItem(
                  id: 'm1',
                  conceptId: 'c1',
                  conceptTitle: 'Convolution Kernels',
                  status: MaintenanceStatus.revise,
                  reason: 'Memory decay threshold reached',
                  mentorRecommendation: '5-minute retrieval session recommended',
                ),
              ])),
        ],
        textScale: 1.2,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Knowledge Maintenance'), findsOneWidget);
    });

    testWidgets('TeachModeReportScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester.pumpWidget(createHarness(
        child: const TeachModeReportScreen(),
        overrides: [
          teachModeProvider.overrideWith((ref) {
            final notifier = TeachModeNotifier(_FakeTeachModeRepo());
            notifier.state = TeachModeState(
              status: TeachModeStatus.reporting,
              report: {
                'concept_name': 'Attention Mechanism',
                'conceptual_accuracy': 0.88,
                'clarity': 0.9,
                'depth': 0.85,
                'strengths': ['Clear intuition of query-key matching'],
                'misconceptions': ['Overlooked scale factor calculation'],
                'mentor_feedback': 'Great grasp of attention basics.',
              },
            );
            return notifier;
          }),
        ],
        textScale: 1.2,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Understanding Report'), findsOneWidget);
    });

    testWidgets('MentorScreen on compact 320x568 and scaled font',
        (tester) async {
      setDevice(tester, width: 320, height: 568);
      await tester.pumpWidget(
          createHarness(child: const MentorScreen(), textScale: 1.2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.byType(MentorScreen), findsOneWidget);
    });
  });
}
