import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilltwin/app/router/app_router.dart';
import 'package:skilltwin/features/auth/presentation/screens/intro_carousel_screen.dart';
import 'package:skilltwin/features/auth/presentation/providers/intro_provider.dart';
import 'package:skilltwin/features/auth/domain/repositories/auth_repository.dart';
import 'package:skilltwin/features/auth/data/repositories/auth_repository_provider.dart';
import 'package:skilltwin/core/models/user.dart';

class _FakeAuthRepository implements AuthRepository {
  final User? mockUser;

  _FakeAuthRepository({
    this.mockUser,
  });

  @override
  Stream<User?> get authStateChanges => Stream.value(mockUser);

  @override
  Future<User?> getCurrentUser() async => mockUser;

  @override
  Future<bool> isUserOnboarded() async => true;

  @override
  Future<User> login(String email, String password) async =>
      mockUser ?? User(id: '1', email: 'test@example.com', name: 'Test');

  @override
  Future<void> logout() async {}

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String name,
  }) async =>
      mockUser ?? User(id: '1', email: 'test@example.com', name: 'Test');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SkillTwin Introductory Carousel Tests', () {
    testWidgets('Renders Slide 1 with headline, explanation, and progress bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: IntroCarouselScreen(),
          ),
        ),
      );

      // Verify Slide 1 contents
      expect(find.text('Meet your Learning Twin.'), findsOneWidget);
      expect(find.text('WELCOME TO SKILLTWIN'), findsOneWidget);
      expect(
        find.text(
          'SkillTwin creates a living digital twin of your knowledge, adapting your learning journey dynamically around you.',
        ),
        findsOneWidget,
      );
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('Tapping Next navigates sequentially through all 4 slides',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: IntroCarouselScreen(),
          ),
        ),
      );

      // Slide 1
      expect(find.text('Meet your Learning Twin.'), findsOneWidget);

      // Tap Next -> Slide 2
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.text('Your journey changes with you.'), findsOneWidget);
      expect(find.text('ADAPTIVE ROADMAPS'), findsOneWidget);

      // Tap Next -> Slide 3
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.text('Learn it. Practice it. Prove it.'), findsOneWidget);
      expect(find.text('ACTIVE MASTERY'), findsOneWidget);

      // Tap Next -> Slide 4
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      expect(
        find.text('You focus on learning. I\'ll figure out what\'s next.'),
        findsOneWidget,
      );
      expect(find.text('AI COMPANION'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Tapping Skip completes intro and routes to /login',
        (WidgetTester tester) async {
      bool introMarkedCompleted = false;
      final fakeRepo = _FakeAuthRepository(mockUser: null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            splashCompleteProvider.overrideWith((ref) => true),
            authRepositoryProvider.overrideWithValue(fakeRepo),
            introCompletedProvider.overrideWith((ref) {
              final notifier = IntroCompletedNotifier(null);
              notifier.addListener((state) {
                if (state) introMarkedCompleted = true;
              });
              return notifier;
            }),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      // Settle into /intro without triggering 4.5s auto-progression
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(IntroCarouselScreen), findsOneWidget);

      // Tap Skip
      await tester.tap(find.text('Skip'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(introMarkedCompleted, isTrue);
      expect(find.byType(IntroCarouselScreen), findsNothing);
      expect(find.text('Welcome back.'), findsOneWidget);
    });

    testWidgets('Tapping Get Started on Slide 4 completes intro and routes to /login',
        (WidgetTester tester) async {
      bool introMarkedCompleted = false;
      final fakeRepo = _FakeAuthRepository(mockUser: null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            splashCompleteProvider.overrideWith((ref) => true),
            authRepositoryProvider.overrideWithValue(fakeRepo),
            introCompletedProvider.overrideWith((ref) {
              final notifier = IntroCompletedNotifier(null);
              notifier.addListener((state) {
                if (state) introMarkedCompleted = true;
              });
              return notifier;
            }),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      // Settle into /intro without triggering 4.5s auto-progression
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(IntroCarouselScreen), findsOneWidget);

      // Advance to Slide 4
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      // Tap Get Started
      expect(find.text('Get Started'), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(introMarkedCompleted, isTrue);
      expect(find.byType(IntroCarouselScreen), findsNothing);
      expect(find.text('Welcome back.'), findsOneWidget);
    });

    testWidgets('Responsive on small viewports without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 520);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: IntroCarouselScreen(),
          ),
        ),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);

      // Step through all slides on constrained screen
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
      }
    });
  });
}
