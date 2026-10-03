import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skilltwin/core/models/home_dashboard.dart';
import 'package:skilltwin/features/streak/presentation/widgets/streak_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Streak Models & Tiers Test', () {
    test('Correct tier resolved for streak counts', () {
      expect(StreakTierConfig.getTierForStreak(0), equals(StreakTier.zero));
      expect(StreakTierConfig.getTierForStreak(-1), equals(StreakTier.zero));
      expect(StreakTierConfig.getTierForStreak(1), equals(StreakTier.shortStreak));
      expect(StreakTierConfig.getTierForStreak(4), equals(StreakTier.shortStreak));
      expect(StreakTierConfig.getTierForStreak(6), equals(StreakTier.shortStreak));
      expect(StreakTierConfig.getTierForStreak(7), equals(StreakTier.active));
      expect(StreakTierConfig.getTierForStreak(74), equals(StreakTier.active));
      expect(StreakTierConfig.getTierForStreak(99), equals(StreakTier.active));
      expect(StreakTierConfig.getTierForStreak(100), equals(StreakTier.legendary));
      expect(StreakTierConfig.getTierForStreak(623), equals(StreakTier.legendary));
    });

    test('Weekly progress generation produces 7 days with valid statuses', () {
      // Create a reference date: Saturday (weekday 6)
      final saturday = DateTime(2026, 9, 26);
      final days = StreakTierConfig.generateWeekProgress(
        streakDays: 5,
        referenceDate: saturday,
      );

      expect(days.length, equals(7));
      expect(days[0].label, equals('Mon'));
      expect(days[5].label, equals('Sat'));
      expect(days[5].status, equals(DayCompletionStatus.current));
      expect(days[6].label, equals('Sun'));
      expect(days[6].status, equals(DayCompletionStatus.future));
    });
  });

  group('Streak Widgets Rendering Test', () {
    testWidgets('HeroStreakCard renders active streak with 74 days', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HeroStreakCard(
                streakDays: 74,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('74 Days'), findsOneWidget);
      expect(find.text('On fire! Keep learning, you got this!'), findsOneWidget);
      expect(find.byType(StreakWeekProgress), findsOneWidget);
    });

    testWidgets('HeroStreakCard renders zero streak with recovery button', (tester) async {
      bool started = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HeroStreakCard(
                streakDays: 0,
                onStartToday: () => started = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('0 Days'), findsOneWidget);
      expect(find.text("Let's get back on track!"), findsOneWidget);
      expect(find.text('🚀 Start Today'), findsOneWidget);

      await tester.tap(find.text('🚀 Start Today'));
      expect(started, isTrue);
    });

    testWidgets('SupportingStreakCard renders short streak and legendary', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SupportingStreakCard(
                  tier: StreakTier.shortStreak,
                  days: 4,
                ),
                SupportingStreakCard(
                  tier: StreakTier.legendary,
                  days: 623,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('4 Days'), findsOneWidget);
      expect(find.text('623 Days'), findsOneWidget);
      expect(find.text("That's legendary!"), findsOneWidget);
    });

    testWidgets('StreakSection renders hero and supporting cards with metrics', (tester) async {
      const mockData = HomeDashboardData(
        streakDays: 74,
        learningMinutes: 45,
        overallMastery: 0.82,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StreakSection(
                dashboardData: mockData,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Learning Momentum'), findsOneWidget);
      expect(find.text('74 Days'), findsOneWidget);
      expect(find.text('45m'), findsOneWidget);
      expect(find.text('82%'), findsOneWidget);
    });
  });
}
