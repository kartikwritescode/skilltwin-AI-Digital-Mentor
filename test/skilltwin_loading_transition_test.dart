import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skilltwin/core/navigation/skilltwin_page_transitions.dart';
import 'package:skilltwin/core/widgets/skilltwin_loading_view.dart';
import 'package:skilltwin/core/widgets/skilltwin_refresh_indicator.dart';
import 'package:skilltwin/core/widgets/skilltwin_transition_switcher.dart';

void main() {
  group('SkillTwinLoadingView Unit & Widget Tests', () {
    testWidgets('renders mascot GIF and default cognitive message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillTwinLoadingView(),
          ),
        ),
      );

      // Verify mascot GIF image is present
      expect(find.byType(Image), findsWidgets);

      // Verify default cognitive message is rendered
      expect(find.text('SkillTwin is preparing your next step.'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });

    testWidgets('renders custom message and sub-message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillTwinLoadingView(
              message: 'Synthesizing knowledge graph...',
              subMessage: 'Connecting concepts and active recall cues',
            ),
          ),
        ),
      );

      expect(find.text('Synthesizing knowledge graph...'), findsOneWidget);
      expect(find.text('Connecting concepts and active recall cues'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });

    testWidgets('compact variant renders with constrained mascot and sizing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillTwinLoadingView.compact(
              message: 'Preparing section...',
            ),
          ),
        ),
      );

      expect(find.text('Preparing section...'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });

    testWidgets('fullScreen variant centers content inside the viewport', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillTwinLoadingView.fullScreen(
              message: 'Synchronizing curriculum roadmap...',
            ),
          ),
        ),
      );

      expect(find.text('Synchronizing curriculum roadmap...'), findsOneWidget);
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(Image), findsWidgets);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });
  });

  group('SkillTwinTransitionSwitcher Tests', () {
    testWidgets('smoothly transitions between loading and loaded state', (tester) async {
      Widget buildTest(bool isLoading) {
        return MaterialApp(
          home: Scaffold(
            body: SkillTwinTransitionSwitcher(
              child: isLoading
                  ? const Text('Loading state', key: ValueKey('loading'))
                  : const Text('Loaded content', key: ValueKey('loaded')),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildTest(true));
      expect(find.text('Loading state'), findsOneWidget);
      expect(find.text('Loaded content'), findsNothing);

      // Trigger transition to loaded
      await tester.pumpWidget(buildTest(false));
      await tester.pump(const Duration(milliseconds: 150));

      // During animation both or incoming are rendering smoothly
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.text('Loaded content'), findsOneWidget);
      expect(find.text('Loading state'), findsNothing);
    });
  });

  group('SkillTwinRefreshIndicator Widget Tests', () {
    testWidgets('renders child scrollable cleanly without blocking touch interaction', (tester) async {
      bool refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkillTwinRefreshIndicator(
              onRefresh: () async {
                refreshed = true;
              },
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Item $index'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);
      expect(refreshed, isFalse);

      await tester.pumpAndSettle();
    });

    testWidgets('pull gesture shows mascot and triggers onRefresh when passing threshold', (tester) async {
      int refreshCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkillTwinRefreshIndicator(
              triggerDistance: 60.0,
              onRefresh: () async {
                refreshCount++;
              },
              child: ListView(
                children: const [
                  SizedBox(
                    height: 800,
                    child: Text('Top Scroll Content'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Perform downward drag gesture holding touch
      final gesture = await tester.startGesture(tester.getCenter(find.byType(ListView)));
      await gesture.moveBy(const Offset(0, 160));
      await tester.pump();

      // Verify mascot header threshold reaction while held down
      expect(find.text('Release to refresh'), findsOneWidget);

      // Release finger to enter refreshing state
      await gesture.up();
      await tester.pump();

      expect(find.text('SkillTwin is updating...'), findsOneWidget);

      // Wait for refresh to complete and settle
      await tester.pumpAndSettle();

      expect(refreshCount, equals(1));
    });
  });

  group('Navigation Carousel Transitions Tests', () {
    testWidgets('SkillTwinCarouselPageTransitionsBuilder slides screen from right to left', (tester) async {
      const builder = SkillTwinCarouselPageTransitionsBuilder();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: builder,
                TargetPlatform.iOS: builder,
              },
            ),
          ),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, anim, secAnim) => const Scaffold(
                      body: Text('Second Screen'),
                    ),
                    transitionsBuilder: (context, anim, secAnim, child) =>
                        builder.buildTransitions(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const SizedBox(),
                      ),
                      context,
                      anim,
                      secAnim,
                      child,
                    ),
                  ),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ),
      );

      expect(find.text('Navigate'), findsOneWidget);
      await tester.tap(find.text('Navigate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Screen is transitioning in via SlideTransition
      expect(find.byType(SlideTransition), findsWidgets);

      await tester.pumpAndSettle();
      expect(find.text('Second Screen'), findsOneWidget);
    });
  });
}
