import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilltwin/app/router/app_router.dart';
import 'package:skilltwin/features/auth/presentation/screens/splash_screen.dart';
import 'package:skilltwin/features/auth/presentation/providers/intro_provider.dart';
import 'package:skilltwin/features/auth/domain/repositories/auth_repository.dart';
import 'package:skilltwin/features/auth/data/repositories/auth_repository_provider.dart';
import 'package:skilltwin/core/models/user.dart';

class _FakeAuthRepository implements AuthRepository {
  final User? mockUser;
  final bool mockOnboarded;

  _FakeAuthRepository({
    this.mockUser,
    this.mockOnboarded = true,
  });

  @override
  Stream<User?> get authStateChanges => Stream.value(mockUser);

  @override
  Future<User?> getCurrentUser() async {
    return mockUser;
  }

  @override
  Future<bool> isUserOnboarded() async {
    return mockOnboarded;
  }

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

  group('SkillTwin Splash Screen Tests', () {
    testWidgets('Renders mascot, SkillTwin title, and tagline with native transitions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Verify composition elements are present
      expect(find.text('SkillTwin'), findsOneWidget);
      expect(find.text('Your learning. Evolved.'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      // Verify lightweight Flutter transitions are used
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(ScaleTransition), findsWidgets);
      expect(find.byType(SlideTransition), findsWidgets);

      // Advance through animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('New unauthenticated user transitions to /intro after splash completes',
        (WidgetTester tester) async {
      final fakeRepo = _FakeAuthRepository(mockUser: null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
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

      // Initially on splash
      expect(find.byType(SplashScreen), findsOneWidget);

      // Advance past entrance animation and transition delay
      await tester.pump(const Duration(milliseconds: 950));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 500));

      // New user should be at intro carousel
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('Meet your Learning Twin.'), findsOneWidget);
    });

    testWidgets('Returning unauthenticated user transitions to /login after splash completes',
        (WidgetTester tester) async {
      final fakeRepo = _FakeAuthRepository(mockUser: null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
            introCompletedProvider.overrideWith((ref) => IntroCompletedNotifier(null)..completeIntro()),
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

      // Initially on splash
      expect(find.byType(SplashScreen), findsOneWidget);

      // Advance past entrance animation and transition delay
      await tester.pump(const Duration(milliseconds: 950));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 500));

      // Returning user should be directly at login screen
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('Welcome back.'), findsOneWidget);
    });

    testWidgets('Authenticated user transitions to Home after splash completes',
        (WidgetTester tester) async {
      final mockUser = User(id: 'u123', email: 'user@skilltwin.com', name: 'Learner');
      final fakeRepo = _FakeAuthRepository(mockUser: mockUser, mockOnboarded: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
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

      // Initially on splash
      expect(find.byType(SplashScreen), findsOneWidget);

      // Advance past entrance animation and transition delay
      await tester.pump(const Duration(milliseconds: 950));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 500));

      // Should have transitioned to Home screen (MainWrapper)
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('New user needing onboarding transitions to Onboarding',
        (WidgetTester tester) async {
      final mockUser = User(id: 'u456', email: 'new@skilltwin.com', name: 'Newbie');
      final fakeRepo = _FakeAuthRepository(mockUser: mockUser, mockOnboarded: false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
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

      // Initially on splash
      expect(find.byType(SplashScreen), findsOneWidget);

      // Advance past entrance animation and transition delay
      await tester.pump(const Duration(milliseconds: 950));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 500));

      // Should have transitioned away from splash
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('Responsive in constrained height without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    });
  });
}
