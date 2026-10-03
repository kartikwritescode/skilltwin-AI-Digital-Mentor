import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skilltwin/core/widgets/mentor_twin_fab.dart';
import 'package:skilltwin/features/main_wrapper.dart';

void main() {
  group('MentorTwinFab Component Tests', () {
    testWidgets('renders properly with default tooltip and semantic label',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: MentorTwinFab(
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Verify Semantics label
      expect(find.bySemanticsLabel('Open Mentor'), findsOneWidget);

      // Verify Tooltip widget
      final tooltipFinder = find.byType(Tooltip);
      expect(tooltipFinder, findsOneWidget);
      final Tooltip tooltip = tester.widget(tooltipFinder);
      expect(tooltip.message, 'Open Mentor');

      // Verify Image.asset exists with the red-panda mentor asset
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final Image image = tester.widget(imageFinder);

      // Image uses cacheWidth so it wraps in ResizeImage
      expect(image.image, isA<ResizeImage>());
      final ResizeImage resizeImage = image.image as ResizeImage;
      expect(resizeImage.imageProvider, isA<AssetImage>());
      final AssetImage assetImage = resizeImage.imageProvider as AssetImage;
      expect(assetImage.assetName, 'assets/images/mascot/twin_mentor.webp');

      // Verify tap triggers the callback
      await tester.tap(find.byType(MentorTwinFab));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('supports custom tooltip and custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: MentorTwinFab(
              tooltip: 'Talk with Twin',
              size: 68.0,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Talk with Twin'), findsOneWidget);
      final tooltipFinder = find.byType(Tooltip);
      final Tooltip tooltip = tester.widget(tooltipFinder);
      expect(tooltip.message, 'Talk with Twin');
    });

    testWidgets('renders cleanly in dark theme without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            floatingActionButton: MentorTwinFab(
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(MentorTwinFab), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow across various screen sizes',
        (tester) async {
      final screenSizes = [
        const Size(320, 480), // small phone
        const Size(390, 844), // normal phone
        const Size(430, 932), // large phone
      ];

      for (final size in screenSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              floatingActionButton: MentorTwinFab(
                onPressed: () {},
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
      }

      // Reset test window
      addTearDown(() => tester.view.resetPhysicalSize());
    });
  });

  group('MainWrapper MentorTwinFab Integration Tests', () {
    testWidgets('MainWrapper shows MentorTwinFab and navigates to /mentor',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainWrapper(child: child),
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) =>
                    const Scaffold(body: Text('Home Screen Content')),
              ),
              GoRoute(
                path: '/journey',
                builder: (context, state) =>
                    const Scaffold(body: Text('Journey Screen Content')),
              ),
              GoRoute(
                path: '/twin',
                builder: (context, state) =>
                    const Scaffold(body: Text('Twin Screen Content')),
              ),
            ],
          ),
          GoRoute(
            path: '/mentor',
            builder: (context, state) =>
                const Scaffold(body: Text('Mentor Destination Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // 1. On Home ('/'), MentorTwinFab is present
      expect(find.byType(MentorTwinFab), findsOneWidget);
      expect(find.text('Home Screen Content'), findsOneWidget);

      // 2. Tapping MentorTwinFab navigates to /mentor
      await tester.tap(find.byType(MentorTwinFab));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Mentor Destination Screen'), findsOneWidget);

      // Pop mentor back to shell
      Navigator.of(tester.element(find.text('Mentor Destination Screen'))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Home Screen Content'), findsOneWidget);

      // 3. Navigate to Journey: FAB is omitted (null)
      router.go('/journey');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Journey Screen Content'), findsOneWidget);
      expect(find.byType(MentorTwinFab), findsNothing);

      // 4. Navigate to Twin: FAB is present again
      router.go('/twin');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Twin Screen Content'), findsOneWidget);
      expect(find.byType(MentorTwinFab), findsOneWidget);
    });
  });
}
