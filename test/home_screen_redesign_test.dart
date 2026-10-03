import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skilltwin/core/models/user.dart';
import 'package:skilltwin/core/models/home_dashboard.dart';
import 'package:skilltwin/features/home/presentation/widgets/home_header.dart';
import 'package:skilltwin/features/home/presentation/widgets/weekly_learning_tracker.dart';
import 'package:skilltwin/features/home/presentation/widgets/todays_task_card.dart';
import 'package:skilltwin/features/home/presentation/widgets/active_journey_card.dart';

void main() {
  group('HomeHeader First Name Extraction & Dynamic Greeting', () {
    test('extracts first name from multi-word name', () {
      final user = User(
        id: 'u1',
        email: 'user@example.com',
        name: 'Kartik Kumar',
      );
      expect(HomeHeader.extractFirstName(user), 'Kartik');
    });

    test('extracts single name', () {
      final user = User(
        id: 'u1',
        email: 'user@example.com',
        name: 'Kartik',
      );
      expect(HomeHeader.extractFirstName(user), 'Kartik');
    });

    test('never exposes email as display name', () {
      final user = User(
        id: 'u1',
        email: 'kartik@gmail.com',
        name: 'kartik@gmail.com',
      );
      expect(HomeHeader.extractFirstName(user), isNull);
    });

    test('never exposes email prefix as display name', () {
      final user = User(
        id: 'u1',
        email: 'kartik123@gmail.com',
        name: 'kartik123',
      );
      expect(HomeHeader.extractFirstName(user), isNull);
    });

    test('handles null or empty name safely', () {
      final user = User(
        id: 'u1',
        email: 'kartik@gmail.com',
        name: '',
      );
      expect(HomeHeader.extractFirstName(user), isNull);
      expect(HomeHeader.extractFirstName(null), isNull);
    });

    test('dynamic greeting returns correct salutation based on local time', () {
      final morning = DateTime(2026, 9, 26, 9, 30);
      final afternoon = DateTime(2026, 9, 26, 14, 0);
      final evening = DateTime(2026, 9, 26, 19, 0);

      expect(HomeHeader.getDynamicGreeting(now: morning), 'Good Morning');
      expect(HomeHeader.getDynamicGreeting(now: afternoon), 'Good Afternoon');
      expect(HomeHeader.getDynamicGreeting(now: evening), 'Good Evening');
    });
  });

  group('Home Screen Widgets Rendering', () {
    testWidgets('HomeHeader renders greeting, name, streak and notification button',
        (WidgetTester tester) async {
      final user = User(
        id: 'u1',
        email: 'test@example.com',
        name: 'Kartik Kumar',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeHeader(
              user: user,
              streakDays: 12,
              onNotificationTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Kartik'), findsOneWidget);
      expect(find.text('👋'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });

    testWidgets('WeeklyLearningTracker renders all 7 days with Sunday start',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeeklyLearningTracker(
              streakDays: 4,
            ),
          ),
        ),
      );

      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
    });

    testWidgets('TodaysTaskCard renders topic, breakdown items, and CTA button',
        (WidgetTester tester) async {
      bool sessionStarted = false;
      const dashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'DSA in Java',
        todayTargetTopicTitle: 'Arrays & Hashing',
        todayKeyConcepts: ['HashMap', 'Prefix Sums'],
        todayEstimatedMinutes: 25,
        streakDays: 12,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodaysTaskCard(
              data: dashboard,
              onStartSession: () => sessionStarted = true,
            ),
          ),
        ),
      );

      expect(find.text("Today's Task"), findsOneWidget);
      expect(find.text('Arrays & Hashing'), findsOneWidget);
      expect(find.text("Start Today's Session"), findsOneWidget);

      await tester.tap(find.text("Start Today's Session"));
      expect(sessionStarted, isTrue);
    });

    testWidgets('ActiveJourneyCard renders goal title, progress and metrics',
        (WidgetTester tester) async {
      const dashboard = HomeDashboardData(
        goalId: 'g1',
        goalTitle: 'DSA in Java',
        currentModuleName: 'Data Structures & Algorithms',
        overallProgress: 0.42,
        topicsCompleted: 18,
        topicsRemaining: 24,
        learningMinutes: 120,
        scheduleStatus: 'ON_TRACK',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ActiveJourneyCard(
              data: dashboard,
            ),
          ),
        ),
      );

      expect(find.text('Your Active Journey'), findsOneWidget);
      expect(find.text('DSA in Java'), findsOneWidget);
      expect(find.text('42%'), findsOneWidget);
      expect(find.text('18/42 Topics'), findsOneWidget);
      expect(find.text('On Track'), findsOneWidget);
    });
  });
}
