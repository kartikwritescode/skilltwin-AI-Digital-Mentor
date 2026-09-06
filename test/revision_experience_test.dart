import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilltwin/features/sessions/presentation/screens/revision_screen.dart';
import 'package:skilltwin/features/sessions/presentation/screens/revision_retrieval_screen.dart';
import 'package:skilltwin/features/sessions/presentation/widgets/mentor_notifications_sheet.dart';
import 'package:skilltwin/features/sessions/domain/repositories/revision_repository.dart';
import 'package:skilltwin/features/sessions/data/repositories/mock_revision_repository.dart';
import 'package:skilltwin/features/sessions/data/repositories/revision_repository_provider.dart';

void main() {
  group('Revision Experience Tests', () {
    late RevisionRepository mockRepository;

    setUp(() {
      mockRepository = MockRevisionRepository();
    });

    test('MockRevisionRepository returns prioritized queue with 5 minutes header', () async {
      final queue = await mockRepository.getPrioritizedQueue();
      expect(queue.header, '5 minutes for your future self.');
      expect(queue.primaryItem, isNotNull);
      expect(queue.primaryItem!.conceptId, 'recursion');
      expect(queue.primaryItem!.whyToday, contains('Memory decay threshold reached'));
      expect(queue.upcomingItems.length, lessThanOrEqualTo(2));
    });

    test('MockRevisionRepository handles retrieval submission and reschedules in 3 days', () async {
      final result = await mockRepository.submitRetrieval(
        reviewItemId: 'rev_recursion',
        accuracy: 'correct',
        confidence: 'confident',
      );
      expect(result.nextReviewText, 'Next review in 3 days.');
      expect(result.intervalDays, 3);
    });

    testWidgets('RevisionScreen shows "5 minutes for your future self." and prioritized cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            revisionRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: RevisionScreen(),
          ),
        ),
      );

      // Initial loading
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Header verification
      expect(find.text('5 minutes for your future self.'), findsOneWidget);

      // Card contents verification: Concept, Retention risk, Last reviewed, Why today, Start retrieval
      expect(find.text('Recursion'), findsAtLeastNWidgets(1));
      expect(find.text('HIGH RETENTION RISK'), findsAtLeastNWidgets(1));
      expect(find.text('WHY TODAY'), findsAtLeastNWidgets(1));
      expect(find.text('Last reviewed: '), findsAtLeastNWidgets(1));
      expect(find.textContaining('START', findRichText: false), findsAtLeastNWidgets(1));

      // Notification icon
      expect(find.byTooltip('Mentor Notifications'), findsOneWidget);
    });

    testWidgets('RevisionRetrievalScreen shows options (Correct, Incorrect, Partially correct, Confident, Not confident) and "Next review in 3 days."',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            revisionRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: RevisionRetrievalScreen(conceptId: 'recursion'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Challenge is displayed
      expect(find.text('RETRIEVAL CHALLENGE'), findsOneWidget);
      expect(find.text('REVEAL MODEL & INVARIANTS'), findsOneWidget);

      // Tap reveal
      await tester.tap(find.text('REVEAL MODEL & INVARIANTS'));
      await tester.pump();

      // Verify self-assessment options: Correct, Incorrect, Partially correct, Confident, Not confident
      expect(find.text('AFTER RETRIEVAL SELF-ASSESSMENT'), findsOneWidget);
      expect(find.text('Correct'), findsOneWidget);
      expect(find.text('Partially correct'), findsOneWidget);
      expect(find.text('Incorrect'), findsOneWidget);
      expect(find.text('Confident'), findsOneWidget);
      expect(find.text('Not confident'), findsOneWidget);

      // Tap record result
      await tester.ensureVisible(find.text('RECORD RETRIEVAL RESULT'));
      await tester.tap(find.text('RECORD RETRIEVAL RESULT'));
      await tester.pumpAndSettle();

      // Result screen verification: Then show: "Next review in 3 days."
      expect(find.text('Next review in 3 days.'), findsOneWidget);
      expect(find.text('RETURN TO QUEUE'), findsOneWidget);
    });

    testWidgets('MentorNotificationsSheet renders notifications with action button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            revisionRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MentorNotificationsSheet(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Mentor Advisories'), findsOneWidget);
      expect(find.text('5 minutes for your future self.'), findsOneWidget);
      expect(find.textContaining("Memory retention for 'Recursion' is decaying"), findsOneWidget);
      expect(find.text('START RETRIEVAL NOW'), findsAtLeastNWidgets(1));
    });
  });
}
