import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skilltwin/core/widgets/skilltwin_background.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SkillTwinBackground Widget Tests', () {
    testWidgets('renders background image and child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SkillTwinBackground(
            child: Text('SkillTwin Content Here'),
          ),
        ),
      );

      // Verify the child text is present
      expect(find.text('SkillTwin Content Here'), findsOneWidget);

      // Verify Image.asset is rendered
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final Image imageWidget = tester.widget(imageFinder);
      expect(imageWidget.image, isA<AssetImage>());
      final AssetImage assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, SkillTwinBackground.assetPath);
      expect(imageWidget.fit, BoxFit.cover);
      expect(imageWidget.alignment, Alignment.topCenter);
    });

    testWidgets('prevents duplicate background layer when nested', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SkillTwinBackground(
            child: SkillTwinBackground(
              child: Text('Nested Content'),
            ),
          ),
        ),
      );

      // Verify child content is present
      expect(find.text('Nested Content'), findsOneWidget);

      // Verify there is EXACTLY ONE Image widget rendered, not two
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('respects RepaintBoundary to isolate background repainting', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SkillTwinBackground(
            child: Text('Repaint boundary test'),
          ),
        ),
      );

      expect(find.byType(RepaintBoundary), findsWidgets);
    });
  });
}
