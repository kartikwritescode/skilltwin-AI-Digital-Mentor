import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilltwin/features/teach_mode/domain/repositories/teach_mode_repository.dart';
import 'package:skilltwin/features/teach_mode/presentation/providers/teach_mode_provider.dart';
import 'package:skilltwin/features/teach_mode/presentation/screens/teach_mode_screen.dart';

class _MockTeachRepo implements TeachModeRepository {
  @override
  Future<void> startVoiceSession() async {}

  @override
  Future<void> stopVoiceSession() async {}

  @override
  Future<Map<String, dynamic>> getUnderstandingReport() async => {
        'conceptual_accuracy': 0.88,
        'reasoning': 0.90,
        'completeness': 0.75,
        'transfer': 0.80,
        'misconceptions': [],
        'feedback': 'Great grasp of attention mechanism.',
        'topic_completed': true,
      };

  @override
  Future<String?> transcribeAudio(File audioFile, {String? conceptId}) async =>
      'Transformers utilize multi-head self-attention.';

  @override
  Future<Map<String, dynamic>> evaluateExplanation(
          String conceptId, String explanationText) async =>
      getUnderstandingReport();
}

Widget createHarness({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Teach / Feynman Mode Redesign Tests', () {
    testWidgets('READY state displays curious mascot, badge, and prompt card',
        (tester) async {
      await tester.pumpWidget(
        createHarness(
          child: const TeachModeScreen(conceptId: 'c1'),
          overrides: [
            teachModeProvider.overrideWith((ref) {
              final notifier = TeachModeNotifier(_MockTeachRepo(), ref);
              notifier.state = TeachModeState(
                status: TeachModeStatus.ready,
                conceptId: 'c1',
                conceptTitle: 'Attention Mechanism',
                mentorPrompt: 'Explain Attention Mechanism in your own words.',
              );
              return notifier;
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // State badge
      expect(find.text('READY'), findsOneWidget);

      // Prompt card
      expect(find.text('TEACH ME'), findsOneWidget);
      expect(
        find.text('Explain Attention Mechanism in your own words.'),
        findsOneWidget,
      );

      // Mascot speech
      expect(find.text("I'm listening. Teach me."), findsOneWidget);

      // Record control
      expect(find.text('TAP TO RECORD'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('Voice to Text toggle allows manual explanation submission',
        (tester) async {
      await tester.pumpWidget(
        createHarness(
          child: const TeachModeScreen(conceptId: 'c1'),
          overrides: [
            teachModeProvider.overrideWith((ref) {
              final notifier = TeachModeNotifier(_MockTeachRepo(), ref);
              notifier.state = TeachModeState(
                status: TeachModeStatus.ready,
                conceptId: 'c1',
                conceptTitle: 'Attention Mechanism',
              );
              return notifier;
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Tap TEXT button
      final textBtn = find.text('TEXT');
      expect(textBtn, findsOneWidget);
      await tester.tap(textBtn);
      await tester.pumpAndSettle();

      // Now in text mode
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('SUBMIT EXPLANATION'), findsOneWidget);
    });

    testWidgets('RECORDING state shows timer, visualizer, and stop prompt',
        (tester) async {
      await tester.pumpWidget(
        createHarness(
          child: const TeachModeScreen(conceptId: 'c1'),
          overrides: [
            teachModeProvider.overrideWith((ref) {
              final notifier = TeachModeNotifier(_MockTeachRepo(), ref);
              notifier.state = TeachModeState(
                status: TeachModeStatus.recording,
                conceptId: 'c1',
                conceptTitle: 'Attention Mechanism',
                elapsedSeconds: 42,
              );
              return notifier;
            }),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('RECORDING'), findsOneWidget);
      expect(find.text('00:42'), findsOneWidget);
      expect(find.text('Take your time. I\'m listening.'), findsOneWidget);
      expect(find.text('TAP TO STOP & EVALUATE'), findsOneWidget);
    });

    testWidgets('PROCESSING & EVALUATING states show mascot loading GIF and thinking prompt',
        (tester) async {
      await tester.pumpWidget(
        createHarness(
          child: const TeachModeScreen(conceptId: 'c1'),
          overrides: [
            teachModeProvider.overrideWith((ref) {
              final notifier = TeachModeNotifier(_MockTeachRepo(), ref);
              notifier.state = TeachModeState(
                status: TeachModeStatus.processing,
                conceptId: 'c1',
              );
              return notifier;
            }),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('PROCESSING'), findsOneWidget);
      expect(find.text('Your Twin is thinking...'), findsOneWidget);
      expect(find.text('Processing Explanation'), findsOneWidget);
    });

    testWidgets('RESULT state with misconceptions displays warning callouts and advice',
        (tester) async {
      await tester.pumpWidget(
        createHarness(
          child: const TeachModeScreen(conceptId: 'c1'),
          overrides: [
            teachModeProvider.overrideWith((ref) {
              final notifier = TeachModeNotifier(_MockTeachRepo(), ref);
              notifier.state = TeachModeState(
                status: TeachModeStatus.result,
                conceptId: 'c1',
                conceptTitle: 'Attention Mechanism',
                report: {
                  'conceptual_accuracy': 0.65,
                  'reasoning': 0.70,
                  'completeness': 0.60,
                  'transfer': 0.55,
                  'misconceptions': [
                    'Confused dot-product scaling factor sqrt(d_k)',
                  ],
                  'feedback': 'Good intuition on queries and keys, but review the scale divisor.',
                  'fix_action_id': 'fix_scale_factor',
                },
              );
              return notifier;
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EVALUATION RESULT'), findsOneWidget);
      expect(find.text('65%'), findsOneWidget);
      expect(find.text("You've got the idea. Let's tighten up one part."), findsOneWidget);
      expect(find.text('DETECTED MISCONCEPTIONS'), findsOneWidget);
      expect(find.text('Confused dot-product scaling factor sqrt(d_k)'), findsOneWidget);
      expect(find.text('FIX THIS WEAKNESS'), findsOneWidget);
      expect(find.text('TEACH AGAIN'), findsOneWidget);
      expect(find.text('CONTINUE JOURNEY'), findsOneWidget);
    });

    testWidgets('TOPIC COMPLETE state renders celebrate banner and completion badge',
        (tester) async {
      await tester.pumpWidget(
        createHarness(
          child: const TeachModeScreen(conceptId: 'c1'),
          overrides: [
            teachModeProvider.overrideWith((ref) {
              final notifier = TeachModeNotifier(_MockTeachRepo(), ref);
              notifier.state = TeachModeState(
                status: TeachModeStatus.completed,
                conceptId: 'c1',
                conceptTitle: 'Attention Mechanism',
                isCompleted: true,
                report: {
                  'conceptual_accuracy': 0.92,
                  'reasoning': 0.95,
                  'completeness': 0.88,
                  'transfer': 0.90,
                  'topic_completed': true,
                  'strengths': ['Flawless explanation of Q, K, V matrices.'],
                  'feedback': 'Mastery achieved! Your explanation was clear and intuitive.',
                },
              );
              return notifier;
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TOPIC COMPLETE ✓'), findsWidgets);
      expect(find.text("You've got this concept down."), findsWidgets);
      expect(find.text('92%'), findsOneWidget);
      expect(find.text('KEY STRENGTHS'), findsOneWidget);
      expect(find.text('Flawless explanation of Q, K, V matrices.'), findsOneWidget);
      expect(find.text('CONTINUE JOURNEY'), findsOneWidget);
    });

    testWidgets('TeachModeScreen survives 320x568 compact stress test with zero overflow',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createHarness(
          child: const TeachModeScreen(conceptId: 'c1'),
          overrides: [
            teachModeProvider.overrideWith((ref) {
              final notifier = TeachModeNotifier(_MockTeachRepo(), ref);
              notifier.state = TeachModeState(
                status: TeachModeStatus.result,
                conceptId: 'c1',
                conceptTitle: 'Attention Mechanism',
                report: {
                  'conceptual_accuracy': 0.80,
                  'reasoning': 0.85,
                  'completeness': 0.75,
                  'transfer': 0.80,
                  'misconceptions': [
                    'Needs review of mask tensor calculation',
                  ],
                  'strengths': [
                    'Excellent multi-head explanation',
                  ],
                  'feedback': 'Very well done.',
                },
              );
              return notifier;
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
