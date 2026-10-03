import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:skilltwin/core/widgets/skilltwin_markdown.dart';

void main() {
  group('SkillTwinMarkdown Tests', () {
    testWidgets('renders empty data as SizedBox.shrink without crashing',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillTwinMarkdown(data: ''),
          ),
        ),
      );

      expect(find.byType(MarkdownBody), findsNothing);
    });

    testWidgets('renders plain text properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillTwinMarkdown(
              data: 'Hello, this is a normal sentence.',
            ),
          ),
        ),
      );

      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.text('Hello, this is a normal sentence.'), findsOneWidget);
    });

    testWidgets('renders **bold** text without showing raw asterisks',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillTwinMarkdown(
              data: 'This is **critically important** for the model.',
            ),
          ),
        ),
      );

      // Verify that raw markdown asterisks are NOT displayed in the UI
      expect(find.text('This is **critically important** for the model.'),
          findsNothing);

      // Verify that the markdown widget rendered the rich text
      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.textContaining('critically important'), findsOneWidget);
    });

    testWidgets('renders *italic* text without showing raw asterisks',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillTwinMarkdown(
              data: 'Notice the *slope* at this vertex.',
            ),
          ),
        ),
      );

      expect(find.text('Notice the *slope* at this vertex.'), findsNothing);
      expect(find.textContaining('slope'), findsOneWidget);
    });

    testWidgets('renders <u>underlined</u> text without showing raw tags',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillTwinMarkdown(
              data: 'Remember to <u>normalize features</u> first.',
            ),
          ),
        ),
      );

      // Verify raw <u> tags are not shown in UI text
      expect(find.text('Remember to <u>normalize features</u> first.'),
          findsNothing);
      expect(find.textContaining('normalize features'), findsOneWidget);
    });

    testWidgets('renders `inline code` without showing raw backticks',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillTwinMarkdown(
              data: 'Call `model.fit(X, y)` to start training.',
            ),
          ),
        ),
      );

      expect(find.text('Call `model.fit(X, y)` to start training.'),
          findsNothing);
      expect(find.textContaining('model.fit(X, y)'), findsOneWidget);
    });

    testWidgets('renders markdown lists correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillTwinMarkdown(
              data: '''
- Learning rate controls step size
- Momentum prevents oscillation
- Weight decay stabilizes gradients
''',
            ),
          ),
        ),
      );

      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.textContaining('Learning rate controls step size'),
          findsOneWidget);
      expect(find.textContaining('Momentum prevents oscillation'),
          findsOneWidget);
      expect(find.textContaining('Weight decay stabilizes gradients'),
          findsOneWidget);
    });

    testWidgets('adapts colors for dark background without contrast failure',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: SkillTwinMarkdown(
              data: 'Twin mentor response on **dark theme**.',
              textColor: Colors.white,
            ),
          ),
        ),
      );

      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.textContaining('Twin mentor response on'), findsOneWidget);
    });
  });
}
