import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilltwin/features/sessions/presentation/screens/revision_screen.dart';
import 'package:skilltwin/features/sessions/data/repositories/mock_revision_repository.dart';
import 'package:skilltwin/features/sessions/data/repositories/revision_repository_provider.dart';

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
}

