import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilltwin/features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import 'package:skilltwin/features/home/domain/repositories/goal_repository.dart';
import 'package:skilltwin/features/home/data/repositories/goal_repository_provider.dart';
import 'package:skilltwin/core/storage/storage_provider.dart';
import 'package:skilltwin/core/models/goal.dart';

class _FakeGoalRepository implements GoalRepository {
  bool shouldFail = false;
  Goal? lastCreatedGoal;

  @override
  Future<Goal> createGoal(Goal goal) async {
    if (shouldFail) {
      throw Exception('Backend network failure');
    }
    lastCreatedGoal = goal;
    return goal;
  }

  @override
  Future<Goal?> getActiveGoal() async => lastCreatedGoal;

  @override
  Future<List<Goal>> getGoalHistory() async => [];

  @override
  Future<void> updateGoal(String goalId, Map<String, dynamic> updates) async {}

  @override
  Future<void> deleteGoal(String goalId) async {}

  @override
  Future<void> setActiveGoal(String goalId) async {}
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeGoalRepository fakeGoalRepo;

  setUp(() {
    fakeGoalRepo = _FakeGoalRepository();
    SharedPreferences.setMockInitialValues({});
  });

  group('Meet Your Twin Onboarding Experience Tests', () {
    testWidgets(
        'Step 0 renders welcoming intro with Twin and "Let\'s do it →"',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(prefs),
            goalRepositoryProvider.overrideWithValue(fakeGoalRepo),
          ],
          child: const MaterialApp(
            home: OnboardingFlowScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify Opening step copy
      expect(find.text('Before we start...'), findsOneWidget);
      expect(
        find.text(
          "I've got a few quick questions that'll make your journey much better.",
        ),
        findsOneWidget,
      );
      expect(find.text("Let's do it →"), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets(
        'Navigates sequentially through all conversational questions: Goal -> Level -> Time -> Deadline -> Methods -> Videos -> Ready',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(prefs),
            goalRepositoryProvider.overrideWithValue(fakeGoalRepo),
          ],
          child: const MaterialApp(
            home: OnboardingFlowScreen(),
          ),
        ),
      );

      await tester.pump();

      // Step 0: Welcome -> Step 1
      await _tap(tester, find.text("Let's do it →"));
      await tester.pump(const Duration(milliseconds: 350));

      // Step 1: Goal ("What do you want to get really good at?")
      expect(find.text('What do you want to get really good at?'), findsOneWidget);
      await _tap(tester, find.text('Flutter & Mobile Apps'));
      await _tap(tester, find.text('Continue →'));
      await tester.pump(const Duration(milliseconds: 350));

      // Step 2: Level ("How much do you already know?")
      expect(find.text('How much do you already know?'), findsOneWidget);
      await _tap(tester, find.text('I know the basics'));
      await _tap(tester, find.text('Continue →'));
      await tester.pump(const Duration(milliseconds: 350));

      // Step 3: Time ("How much time can we steal from your day?")
      expect(find.text('How much time can we steal from your day?'), findsOneWidget);
      await _tap(tester, find.text('30 min'));
      await _tap(tester, find.text('Continue →'));
      await tester.pump(const Duration(milliseconds: 350));

      // Step 4: Deadline ("Got a deadline?")
      expect(find.text('Got a deadline?'), findsOneWidget);
      await _tap(tester, find.text('Within 90 days'));
      await _tap(tester, find.text('Continue →'));
      await tester.pump(const Duration(milliseconds: 350));

      // Step 5: Learning Methods ("How do you like learning?")
      expect(find.text('How do you like learning?'), findsOneWidget);
      await _tap(tester, find.text('Build projects'));
      await _tap(tester, find.text('Continue →'));
      await tester.pump(const Duration(milliseconds: 350));

      // Step 6: YouTube / Resource Preference ("Want me to bring videos into your learning path?")
      expect(
        find.text('Want me to bring videos into your learning path?'),
        findsOneWidget,
      );
      await _tap(tester, find.text('Only when helpful'));
      await _tap(tester, find.text('Continue →'));
      await tester.pump(const Duration(milliseconds: 350));

      // Step 7: Ready screen ("Your journey is ready.")
      expect(find.text('Your journey is ready.'), findsOneWidget);
      expect(find.text('Start My Journey →'), findsOneWidget);
    });

    testWidgets(
        'Custom answer field for Level: "Something else" expands input, validates, and sets custom level',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(prefs),
            goalRepositoryProvider.overrideWithValue(fakeGoalRepo),
          ],
          child: const MaterialApp(
            home: OnboardingFlowScreen(),
          ),
        ),
      );

      await tester.pump();

      // Navigate to Level (Step 2)
      await _tap(tester, find.text("Let's do it →"));
      await tester.pump(const Duration(milliseconds: 350));

      await _tap(tester, find.text('Flutter & Mobile Apps'));
      await _tap(tester, find.text('Continue →'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('How much do you already know?'), findsOneWidget);

      // Select "Something else"
      await _tap(tester, find.text('Something else'));

      // Try tapping continue with empty input -> validation error
      await _tap(tester, find.text('Continue →'));
      expect(
        find.text('Please describe your background to continue'),
        findsOneWidget,
      );

      // Enter custom experience
      final inputFinder = find.byType(TextField);
      await tester.ensureVisible(inputFinder);
      await tester.enterText(
        inputFinder,
        '2 years of Java, switching to Flutter',
      );
      await tester.pump();

      // Tap continue -> should successfully proceed to Time step
      await _tap(tester, find.text('Continue →'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(
        find.text('How much time can we steal from your day?'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Specialized custom time selector normalizes "45 minutes", "1 hour", "1 hr 30 min"',
        (WidgetTester tester) async {
      // Test direct parser logic
      expect(OnboardingFlowScreen.normalizeDailyMinutes('45 minutes'), equals(45));
      expect(OnboardingFlowScreen.normalizeDailyMinutes('1 hour'), equals(60));
      expect(OnboardingFlowScreen.normalizeDailyMinutes('1 hr 30 min'), equals(90));
      expect(OnboardingFlowScreen.normalizeDailyMinutes('2 hours'), equals(120));
      expect(OnboardingFlowScreen.normalizeDailyMinutes('1.5 hours'), equals(90));
      expect(OnboardingFlowScreen.normalizeDailyMinutes('invalid'), isNull);
      expect(OnboardingFlowScreen.normalizeDailyMinutes('2 min'), isNull); // < 5 mins
      expect(OnboardingFlowScreen.normalizeDailyMinutes('10 hours'), isNull); // > 480 mins

      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(prefs),
            goalRepositoryProvider.overrideWithValue(fakeGoalRepo),
          ],
          child: const MaterialApp(
            home: OnboardingFlowScreen(),
          ),
        ),
      );

      await tester.pump();

      // Navigate to Time (Step 3)
      await _tap(tester, find.text("Let's do it →"));
      await tester.pump(const Duration(milliseconds: 350));

      await _tap(tester, find.text('Flutter & Mobile Apps'));
      await _tap(tester, find.text('Continue →'));
      await tester.pump(const Duration(milliseconds: 350));

      await _tap(tester, find.text('I know the basics'));
      await _tap(tester, find.text('Continue →'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('How much time can we steal from your day?'), findsOneWidget);

      // Tap Custom option
      await _tap(tester, find.text('Custom'));

      // Type "1 hr 30 min"
      final timeField = find.byType(TextField);
      await tester.ensureVisible(timeField);
      await tester.enterText(timeField, '1 hr 30 min');
      await tester.pump();

      // Check normalized preview badge
      expect(find.text('90 min / day'), findsOneWidget);

      // Tap "+ 15m" stepper
      await _tap(tester, find.byIcon(Icons.add_rounded));
      expect(find.text('105 min / day'), findsOneWidget);
    });

    testWidgets(
        'Draft persistence restores previous step and answers across restarts',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'skilltwin_onboarding_draft_step': 2,
        'skilltwin_onboarding_draft_title': 'Machine Learning & AI',
        'skilltwin_onboarding_draft_current_level': 'Intermediate',
        'skilltwin_onboarding_draft_daily_minutes': 45,
      });

      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(prefs),
            goalRepositoryProvider.overrideWithValue(fakeGoalRepo),
          ],
          child: const MaterialApp(
            home: OnboardingFlowScreen(),
          ),
        ),
      );

      await tester.pump();

      // Should directly restore to step 2 (Level question) with restored answers
      expect(find.text('How much do you already know?'), findsOneWidget);
    });

    testWidgets(
        'Backend submission failure preserves answers and shows friendly retry banner',
        (WidgetTester tester) async {
      fakeGoalRepo.shouldFail = true;
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(prefs),
            goalRepositoryProvider.overrideWithValue(fakeGoalRepo),
          ],
          child: const MaterialApp(
            home: OnboardingFlowScreen(),
          ),
        ),
      );

      await tester.pump();

      // Navigate to Ready step (Step 7)
      for (int i = 0; i < 7; i++) {
        if (i == 1) {
          await _tap(tester, find.text('Flutter & Mobile Apps'));
        }
        await _tap(tester, find.byType(ElevatedButton));
        await tester.pump(const Duration(milliseconds: 350));
      }

      // Tap Start My Journey (triggers failing submission)
      await _tap(tester, find.text('Start My Journey →'));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify error banner is shown with retry
      expect(find.text('Backend network failure'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Verify state was not reset
      expect(find.text('Start My Journey →'), findsOneWidget);
    });

    testWidgets('Responsive on small viewports without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 520);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(prefs),
            goalRepositoryProvider.overrideWithValue(fakeGoalRepo),
          ],
          child: const MaterialApp(
            home: OnboardingFlowScreen(),
          ),
        ),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);

      // Tap next through screens on small viewport
      for (int i = 0; i < 3; i++) {
        if (i == 1) {
          await _tap(tester, find.text('Flutter & Mobile Apps'));
        }
        await _tap(tester, find.byType(ElevatedButton));
        await tester.pump(const Duration(milliseconds: 350));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Accessible text scaling (1.5x) renders cleanly without errors',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(prefs),
            goalRepositoryProvider.overrideWithValue(fakeGoalRepo),
          ],
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
              child: OnboardingFlowScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Before we start...'), findsOneWidget);
    });
  });
}
