import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilltwin/features/auth/domain/repositories/auth_repository.dart';
import 'package:skilltwin/features/auth/data/repositories/auth_repository_provider.dart';
import 'package:skilltwin/features/auth/presentation/screens/login_screen.dart';
import 'package:skilltwin/features/auth/presentation/screens/signup_screen.dart';
import 'package:skilltwin/core/models/user.dart';

class FakeAuthRepository implements AuthRepository {
  bool loginCalled = false;
  String? lastLoginEmail;
  String? lastLoginPassword;

  bool signupCalled = false;
  String? lastSignupEmail;
  String? lastSignupPassword;
  String? lastSignupName;

  bool shouldThrow = false;

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> login(String email, String password) async {
    if (shouldThrow) {
      throw Exception('Invalid credentials');
    }
    loginCalled = true;
    lastLoginEmail = email;
    lastLoginPassword = password;
    return User(id: 'user_1', email: email, name: 'Test User');
  }

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    if (shouldThrow) {
      throw Exception('Signup failed');
    }
    signupCalled = true;
    lastSignupEmail = email;
    lastSignupPassword = password;
    lastSignupName = name;
    return User(id: 'user_2', email: email, name: name);
  }

  @override
  Future<void> logout() async {}

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  Future<bool> isUserOnboarded() async => true;
}

void main() {
  late FakeAuthRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeAuthRepository();
  });

  void setDeviceSize(WidgetTester tester, {double width = 390, double height = 844}) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> pumpFrames(WidgetTester tester, [Duration duration = const Duration(milliseconds: 150)]) async {
    await tester.pump();
    await tester.pump(duration);
  }

  Widget buildLoginScreen() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  Widget buildSignupScreen() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: const MaterialApp(
        home: SignupScreen(),
      ),
    );
  }

  group('LoginScreen Tests', () {
    testWidgets('renders mascot, headline, fields and buttons',
        (tester) async {
      setDeviceSize(tester);
      await tester.pumpWidget(buildLoginScreen());
      await pumpFrames(tester);

      expect(find.text('Welcome back.'), findsOneWidget);
      expect(
        find.text('Sign in to continue your personalized learning journey.'),
        findsOneWidget,
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.textContaining("Don't have an account?"), findsOneWidget);
      expect(find.textContaining('Sign up'), findsOneWidget);
    });

    testWidgets('toggles password obscurity', (tester) async {
      setDeviceSize(tester);
      await tester.pumpWidget(buildLoginScreen());
      await pumpFrames(tester);

      final visibilityBtn = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityBtn, findsOneWidget);

      await tester.tap(visibilityBtn);
      await pumpFrames(tester);

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('validates required email and password fields', (tester) async {
      setDeviceSize(tester);
      await tester.pumpWidget(buildLoginScreen());
      await pumpFrames(tester);

      final continueBtn = find.text('Continue');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await pumpFrames(tester);

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      expect(fakeRepo.loginCalled, isFalse);
    });

    testWidgets('successful submission calls login repository', (tester) async {
      setDeviceSize(tester);
      await tester.pumpWidget(buildLoginScreen());
      await pumpFrames(tester);

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'student@skilltwin.dev');
      await tester.enterText(textFields.last, 'secret123');
      await pumpFrames(tester);

      final continueBtn = find.text('Continue');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await pumpFrames(tester);

      expect(fakeRepo.loginCalled, isTrue);
      expect(fakeRepo.lastLoginEmail, 'student@skilltwin.dev');
      expect(fakeRepo.lastLoginPassword, 'secret123');
    });

    testWidgets('forgot password opens recovery bottom sheet', (tester) async {
      setDeviceSize(tester);
      await tester.pumpWidget(buildLoginScreen());
      await pumpFrames(tester);

      final forgotPasswordBtn = find.text('Forgot password?');
      await tester.ensureVisible(forgotPasswordBtn);
      await tester.tap(forgotPasswordBtn);
      await pumpFrames(tester, const Duration(milliseconds: 350));

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('responsive on compact 320x640 screen without overflow',
        (tester) async {
      setDeviceSize(tester, width: 320, height: 640);
      await tester.pumpWidget(buildLoginScreen());
      await pumpFrames(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Continue'), findsOneWidget);
    });
  });

  group('SignupScreen Tests', () {
    testWidgets('renders mascot, headline, fields and buttons',
        (tester) async {
      setDeviceSize(tester);
      await tester.pumpWidget(buildSignupScreen());
      await pumpFrames(tester);

      expect(find.text("Let's build your Twin."), findsOneWidget);
      expect(
        find.text('Create your companion for daily focus and deep mastery.'),
        findsOneWidget,
      );
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create my Twin'), findsOneWidget);
      expect(find.textContaining('Already have an account?'), findsOneWidget);
      expect(find.textContaining('Log in'), findsOneWidget);
    });

    testWidgets('validates required fields on signup', (tester) async {
      setDeviceSize(tester);
      await tester.pumpWidget(buildSignupScreen());
      await pumpFrames(tester);

      final createBtn = find.text('Create my Twin');
      await tester.ensureVisible(createBtn);
      await tester.tap(createBtn);
      await pumpFrames(tester);

      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
      expect(fakeRepo.signupCalled, isFalse);
    });

    testWidgets('validates password mismatch on signup', (tester) async {
      setDeviceSize(tester);
      await tester.pumpWidget(buildSignupScreen());
      await pumpFrames(tester);

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Ada Lovelace');
      await tester.enterText(textFields.at(1), 'ada@skilltwin.dev');
      await tester.enterText(textFields.at(2), 'password123');
      await tester.enterText(textFields.at(3), 'mismatch456');
      await pumpFrames(tester);

      final createBtn = find.text('Create my Twin');
      await tester.ensureVisible(createBtn);
      await tester.tap(createBtn);
      await pumpFrames(tester);

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(fakeRepo.signupCalled, isFalse);
    });

    testWidgets('successful signup calls signup repository', (tester) async {
      setDeviceSize(tester);
      await tester.pumpWidget(buildSignupScreen());
      await pumpFrames(tester);

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Ada Lovelace');
      await tester.enterText(textFields.at(1), 'ada@skilltwin.dev');
      await tester.enterText(textFields.at(2), 'password123');
      await tester.enterText(textFields.at(3), 'password123');
      await pumpFrames(tester);

      final createBtn = find.text('Create my Twin');
      await tester.ensureVisible(createBtn);
      await tester.tap(createBtn);
      await pumpFrames(tester);

      expect(fakeRepo.signupCalled, isTrue);
      expect(fakeRepo.lastSignupName, 'Ada Lovelace');
      expect(fakeRepo.lastSignupEmail, 'ada@skilltwin.dev');
      expect(fakeRepo.lastSignupPassword, 'password123');
    });

    testWidgets('responsive on compact 320x640 screen without overflow',
        (tester) async {
      setDeviceSize(tester, width: 320, height: 640);
      await tester.pumpWidget(buildSignupScreen());
      await pumpFrames(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Create my Twin'), findsOneWidget);
    });
  });
}
