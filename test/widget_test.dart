import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilltwin/features/sessions/presentation/screens/revision_screen.dart';
import 'package:skilltwin/features/sessions/data/repositories/mock_revision_repository.dart';
import 'package:skilltwin/features/sessions/data/repositories/revision_repository_provider.dart';
import 'package:skilltwin/core/widgets/direction_aware_navigation.dart';
import 'package:skilltwin/core/utils/mastery_format.dart';

void main() {
  testWidgets('App revision smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          revisionRepositoryProvider.overrideWithValue(MockRevisionRepository()),
        ],
        child: const MaterialApp(
          home: RevisionScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('5 minutes for your future self.'), findsOneWidget);
  });

  testWidgets('DirectionAwareNavigation switches tabs with direction-aware transitions',
      (WidgetTester tester) async {
    int currentIndex = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: DirectionAwareNavigation(
                currentIndex: currentIndex,
                child: Text('Tab $currentIndex Content'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    currentIndex = currentIndex == 1 ? 2 : 1;
                  });
                },
                child: const Icon(Icons.swap_horiz),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Tab 1 Content'), findsOneWidget);

    // Tap to switch forward: 1 -> 2 (should slide from right)
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(SlideTransition), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('Tab 2 Content'), findsOneWidget);

    // Tap to switch backward: 2 -> 1 (should slide from left)
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(SlideTransition), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('Tab 1 Content'), findsOneWidget);
  });

  test('MasteryScoreFormat correctly handles backend scale and avoids 7000%', () {
    // 70.0 from backend should be 70% not 7000%
    expect(70.0.toMasteryPercentage, 70);
    expect(93.2.toMasteryPercentage, 93);
    expect(100.0.toMasteryPercentage, 100);

    // Decimal 0.70 should also be 70%
    expect(0.70.toMasteryPercentage, 70);
    expect(0.25.toMasteryPercentage, 25);

    // Clamping protects against erroneous high numbers
    expect(7000.0.toMasteryPercentage, 100);
    expect((-5.0).toMasteryPercentage, 0);

    // Fractions for progress indicators
    expect(70.0.toMasteryFraction, 0.7);
    expect(0.7.toMasteryFraction, 0.7);
    expect(100.0.toMasteryFraction, 1.0);

    // Delta formatting
    expect(7.5.toMasteryDeltaString, '+7.5%');
    expect((-3.0).toMasteryDeltaString, '-3%');
    expect(0.12.toMasteryDeltaString, '+12%');
  });

  test('TabNavigationTracker tracks forward and backward navigation', () {
    TabNavigationTracker.reset();
    expect(TabNavigationTracker.previousIndex, 0);
    expect(TabNavigationTracker.currentIndex, 0);

    // Move to Tab 1 (Journey)
    TabNavigationTracker.updateIndex(1);
    expect(TabNavigationTracker.isForward, true);
    expect(TabNavigationTracker.previousIndex, 0);
    expect(TabNavigationTracker.currentIndex, 1);

    // Move to Tab 2 (Twin)
    TabNavigationTracker.updateIndex(2);
    expect(TabNavigationTracker.isForward, true);
    expect(TabNavigationTracker.previousIndex, 1);
    expect(TabNavigationTracker.currentIndex, 2);

    // Move backward to Tab 1 (Journey)
    TabNavigationTracker.updateIndex(1);
    expect(TabNavigationTracker.isForward, false);
    expect(TabNavigationTracker.previousIndex, 2);
    expect(TabNavigationTracker.currentIndex, 1);

    // Move backward to Tab 0 (Home)
    TabNavigationTracker.updateIndex(0);
    expect(TabNavigationTracker.isForward, false);
    expect(TabNavigationTracker.previousIndex, 1);
    expect(TabNavigationTracker.currentIndex, 0);
  });
}

