import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilltwin/core/models/home_dashboard.dart';
import 'package:skilltwin/core/models/twin_dashboard.dart';
import 'package:skilltwin/core/storage/storage_provider.dart';
import 'package:skilltwin/features/home/presentation/providers/home_provider.dart';
import 'package:skilltwin/features/twin/presentation/models/twin_companion_persona.dart';
import 'package:skilltwin/features/twin/presentation/providers/twin_provider.dart';
import 'package:skilltwin/features/twin/presentation/screens/twin_screen.dart';
import 'package:skilltwin/features/twin/presentation/widgets/twin_companion_hero.dart';
import 'package:skilltwin/features/twin/presentation/widgets/twin_current_state_card.dart';
import 'package:skilltwin/features/twin/presentation/widgets/twin_empty_state_view.dart';
import 'package:skilltwin/features/twin/presentation/widgets/twin_knowledge_card.dart';
import 'package:skilltwin/features/twin/presentation/widgets/twin_personality_card.dart';

void main() {
  late SharedPreferences mockPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
  });

  group('TwinCompanionPersona State Resolution', () {
    test('resolves fire mascot and cooking dialogue on high streak / ahead of schedule', () {
      const twinData = TwinDashboardData(
        userId: 'u1',
        hasSufficientData: true,
        consistencyStreak: 7,
        overallMastery: 0.82,
        verifiedEvidenceCount: 16,
      );

      final persona = TwinCompanionPersona.fromState(twinData: twinData);

      expect(persona.mascotAssetPath, 'assets/mascots/twin_streak_fire.webp');
      expect(persona.wittyMessage, "Okay, you're actually cooking.");
      expect(persona.evolutionStageNumber, 4);
      expect(persona.evolutionStageName, 'Deep Synthesizer');
    });

    test('resolves celebrating mascot when today session is completed', () {
      const twinData = TwinDashboardData(
        userId: 'u1',
        hasSufficientData: true,
        consistencyStreak: 2,
        overallMastery: 0.50,
        verifiedEvidenceCount: 5,
      );
      const homeData = HomeDashboardData(
        streakDays: 2,
        isTodayCompleted: true,
        todayStatus: 'COMPLETED',
      );

      final persona = TwinCompanionPersona.fromState(
        twinData: twinData,
        homeData: homeData,
      );

      expect(persona.mascotAssetPath, 'assets/mascots/twin_celebrate.webp');
      expect(persona.wittyMessage, 'Daily mission cleared. You showed up and delivered.');
      expect(persona.evolutionStageNumber, 2);
      expect(persona.evolutionStageName, 'Exploring Twin');
    });

    test('resolves supportive mascot when concepts are at risk or behind schedule', () {
      const twinData = TwinDashboardData(
        userId: 'u1',
        hasSufficientData: true,
        consistencyStreak: 1,
        conceptsAtRisk: ['Dynamic Programming', 'Graph Dijkstra'],
        verifiedEvidenceCount: 9,
      );

      final persona = TwinCompanionPersona.fromState(twinData: twinData);

      expect(persona.mascotAssetPath, 'assets/mascots/twin_streak_warning.webp');
      expect(persona.wittyMessage, "We've got some catching up to do.");
      expect(persona.evolutionStageNumber, 3);
      expect(persona.evolutionStageName, 'Building Twin');
    });

    test('resolves focused mascot when learner is actively in a session', () {
      const twinData = TwinDashboardData(
        userId: 'u1',
        hasSufficientData: true,
        consistencyStreak: 2,
        verifiedEvidenceCount: 3,
      );
      const todayState = TodayTaskState(
        status: TodayTaskStatus.learning,
        dateKey: '2026-09-26',
      );

      final persona = TwinCompanionPersona.fromState(
        twinData: twinData,
        todayState: todayState,
      );

      expect(persona.mascotAssetPath, 'assets/mascots/twin_coding.webp');
      expect(persona.wittyMessage, "Deep in the zone. Let's cement this proof.");
    });

    test('resolves welcoming waving mascot by default for fresh learners', () {
      const twinData = TwinDashboardData(
        userId: 'u1',
        hasSufficientData: true,
        consistencyStreak: 1,
        overallMastery: 0.40,
        verifiedEvidenceCount: 1,
      );

      final persona = TwinCompanionPersona.fromState(twinData: twinData);

      expect(persona.mascotAssetPath, 'assets/mascots/twin_curious.webp');
      expect(persona.wittyMessage, "Alright. Let's build this thing.");
      expect(persona.evolutionStageNumber, 1);
      expect(persona.evolutionStageName, 'Calibrating Twin');
    });

    test('evolution stage accurately progresses to Master Twin at 25+ proofs', () {
      const twinData = TwinDashboardData(
        userId: 'u1',
        hasSufficientData: true,
        consistencyStreak: 10,
        overallMastery: 0.95,
        verifiedEvidenceCount: 30,
      );

      final persona = TwinCompanionPersona.fromState(twinData: twinData);

      expect(persona.evolutionStageNumber, 5);
      expect(persona.evolutionStageName, 'Master Twin');
    });
  });

  group('Twin Sub-Widgets Rendering', () {
    testWidgets('TwinEmptyStateView renders calibrating message and CTA', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TwinEmptyStateView(),
          ),
        ),
      );

      expect(find.text('Your Cognitive Twin is Calibrating'), findsOneWidget);
      expect(find.text('Start Practicing in Journey'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('TwinCompanionHero renders mascot, dialogue bubble, and stage badge', (tester) async {
      const persona = TwinCompanionPersona(
        mascotAssetPath: 'assets/mascots/twin_streak_fire.webp',
        stageTitle: 'Your Twin is cooking',
        stageSubtitle: 'Moving faster than scheduled.',
        wittyMessage: "Okay, you're actually cooking.",
        statusTag: 'AHEAD OF PACE',
        statusColor: Color(0xFF059669),
        evolutionStageName: 'Master Twin',
        evolutionStageNumber: 5,
        archetypeTitle: 'The Relentless Sprinter',
        archetypeDescription: 'Blazing velocity and streak momentum.',
        archetypeIcon: Icons.bolt_rounded,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TwinCompanionHero(persona: persona),
          ),
        ),
      );

      expect(find.text("Okay, you're actually cooking."), findsOneWidget);
      expect(find.textContaining('Stage 5'), findsOneWidget);
      expect(find.textContaining('Master Twin'), findsOneWidget);
      expect(find.text('Your Twin is cooking'), findsOneWidget);
      expect(find.text('AHEAD OF PACE'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('TwinPersonalityCard renders 4 cognitive dimensions with normalized values', (tester) async {
      const twinData = TwinDashboardData(
        userId: 'u1',
        hasSufficientData: true,
        learningVelocity: 1.5,
        consistencyStreak: 12,
        overallMastery: 0.88,
        knowledgeCoverage: 0.76,
      );

      final persona = TwinCompanionPersona.fromState(twinData: twinData);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TwinPersonalityCard(
                twinData: twinData,
                persona: persona,
              ),
            ),
          ),
        ),
      );

      expect(find.text('LEARNING PERSONALITY'), findsOneWidget);
      expect(find.text('1.5 /wk'), findsOneWidget);
      expect(find.text('12 days'), findsOneWidget);
      expect(find.text('88%'), findsOneWidget);
      expect(find.text('76%'), findsOneWidget);
    });

    testWidgets('TwinKnowledgeCard renders strengths, insights, and maintenance CTA', (tester) async {
      const twinData = TwinDashboardData(
        userId: 'u1',
        hasSufficientData: true,
        strongestAreas: [
          AreaMasteryItem(name: 'System Design', masteryScore: 0.92, status: 'MASTERED'),
          AreaMasteryItem(name: 'Data Structures', masteryScore: 0.85, status: 'MASTERED'),
        ],
        conceptsAtRisk: ['Graph Theory', 'Dynamic Programming'],
        insights: [
          'High retention when practicing spaced repetition in the morning.',
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TwinKnowledgeCard(twinData: twinData),
            ),
          ),
        ),
      );

      expect(find.text('WHAT YOUR TWIN KNOWS'), findsOneWidget);
      expect(find.text('System Design'), findsOneWidget);
      expect(find.text('92%'), findsOneWidget);
      expect(find.text('Data Structures'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('LEARNING PATTERNS & INSIGHTS'), findsOneWidget);
      expect(find.textContaining('High retention when practicing'), findsOneWidget);
      expect(find.textContaining('Graph Theory'), findsOneWidget);
      expect(find.text('Reinforce Blindspots in Maintenance'), findsOneWidget);
    });

    testWidgets('TwinCurrentStateCard renders active curriculum, topic, and continue CTA', (tester) async {
      const homeData = HomeDashboardData(
        goalTitle: 'Master Flutter Architecture',
        targetLevel: 'Senior Engineer',
        todayTargetTopicTitle: 'State Management with Riverpod',
        todayEstimatedMinutes: 25,
        todayStatus: 'NOT_STARTED',
        topicsCompleted: 14,
        topicsRemaining: 6,
      );
      const twinData = TwinDashboardData(
        userId: 'u1',
        hasSufficientData: true,
        learningLevel: 'Senior Engineer',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TwinCurrentStateCard(
                homeData: homeData,
                twinData: twinData,
              ),
            ),
          ),
        ),
      );

      expect(find.text('CURRENT LEARNING STATE'), findsOneWidget);
      expect(find.text('Master Flutter Architecture'), findsOneWidget);
      expect(find.textContaining('Senior Engineer'), findsOneWidget);
      expect(find.text('State Management with Riverpod'), findsOneWidget);
      expect(find.text('25 min session target'), findsOneWidget);
      expect(find.text('14 completed • 6 left'), findsOneWidget);
      expect(find.text('Continue Today\'s Focus'), findsOneWidget);
    });
  });

  group('TwinScreen Full Integration & Reactivity', () {
    testWidgets('renders loading state initially then renders full companion screen', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const twinData = TwinDashboardData(
        userId: 'u1',
        hasSufficientData: true,
        learningVelocity: 1.2,
        consistencyStreak: 5,
        overallMastery: 0.78,
        knowledgeCoverage: 0.65,
        verifiedEvidenceCount: 10,
        strongestAreas: [
          AreaMasteryItem(name: 'Algorithms', masteryScore: 0.90, status: 'MASTERED'),
        ],
        insights: ['Consistent pace maintained over 5 days.'],
      );

      const homeData = HomeDashboardData(
        goalTitle: 'Fullstack Mastery',
        todayTargetTopicTitle: 'Async Programming',
        todayEstimatedMinutes: 20,
        todayStatus: 'NOT_STARTED',
        topicsCompleted: 10,
        topicsRemaining: 15,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(mockPrefs),
            twinDashboardProvider.overrideWith((ref) => Future.value(twinData)),
            homeDashboardProvider.overrideWith((ref) => Future.value(homeData)),
          ],
          child: const MaterialApp(
            home: TwinScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // App bar title
      expect(find.text('My Cognitive Twin'), findsOneWidget);

      // Cards rendered
      expect(find.byType(TwinCompanionHero), findsOneWidget);
      expect(find.byType(TwinPersonalityCard), findsOneWidget);
      expect(find.byType(TwinKnowledgeCard), findsOneWidget);
      expect(find.byType(TwinCurrentStateCard), findsOneWidget);

      // Verify specific content
      expect(find.textContaining('Stage 3'), findsOneWidget);
      expect(find.textContaining('Building Twin'), findsOneWidget);
      expect(find.text('Algorithms'), findsOneWidget);
      expect(find.text('Fullstack Mastery'), findsOneWidget);
      expect(find.text('Async Programming'), findsOneWidget);
    });

    testWidgets('renders TwinEmptyStateView when hasSufficientData is false', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const twinData = TwinDashboardData(
        userId: 'u1',
        hasSufficientData: false,
      );

      const homeData = HomeDashboardData();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(mockPrefs),
            twinDashboardProvider.overrideWith((ref) => Future.value(twinData)),
            homeDashboardProvider.overrideWith((ref) => Future.value(homeData)),
          ],
          child: const MaterialApp(
            home: TwinScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TwinEmptyStateView), findsOneWidget);
      expect(find.text('Your Cognitive Twin is Calibrating'), findsOneWidget);
    });

    testWidgets('responsive layout renders without overflow on narrow 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const twinData = TwinDashboardData(
        userId: 'u1',
        hasSufficientData: true,
        learningVelocity: 1.0,
        consistencyStreak: 4,
        overallMastery: 0.70,
        knowledgeCoverage: 0.60,
        verifiedEvidenceCount: 8,
        strongestAreas: [
          AreaMasteryItem(name: 'Data Structures', masteryScore: 0.85, status: 'MASTERED'),
        ],
        conceptsAtRisk: ['Dynamic Programming'],
      );

      const homeData = HomeDashboardData(
        goalTitle: 'Core Algorithms',
        todayTargetTopicTitle: 'Recursion and Trees',
        todayEstimatedMinutes: 15,
        todayStatus: 'NOT_STARTED',
        topicsCompleted: 8,
        topicsRemaining: 12,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(mockPrefs),
            twinDashboardProvider.overrideWith((ref) => Future.value(twinData)),
            homeDashboardProvider.overrideWith((ref) => Future.value(homeData)),
          ],
          child: const MaterialApp(
            home: TwinScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure no overflow exception occurred and widgets are mounted
      expect(tester.takeException(), isNull);
      expect(find.byType(TwinCompanionHero), findsOneWidget);
      expect(find.byType(TwinPersonalityCard), findsOneWidget);
    });
  });
}
