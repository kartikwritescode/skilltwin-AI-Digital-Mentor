import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilltwin/core/models/topic_detail.dart';
import 'package:skilltwin/core/models/session_step.dart';
import 'package:skilltwin/features/journey/presentation/providers/practice_session_provider.dart';
import 'package:skilltwin/features/journey/presentation/widgets/practice/practice_mascot_header.dart';
import 'package:skilltwin/features/journey/presentation/widgets/practice/practice_question_card.dart';
import 'package:skilltwin/features/journey/presentation/widgets/practice/practice_completion_view.dart';
import 'package:skilltwin/features/sessions/presentation/widgets/step_question_view.dart';

void main() {
  const mockQuestions = [
    TopicQuestionItem(
      id: 'q1',
      topicId: 'topic-1',
      questionType: 'multiple_choice',
      prompt: 'What is the main benefit of Flutter widgets?',
      options: ['Reusability', 'Larger APK', 'Slow compilation', 'None'],
      correctAnswer: 'Reusability',
      explanation: 'Flutter widgets are composable and highly reusable UI blocks.',
      difficulty: 'easy',
    ),
    TopicQuestionItem(
      id: 'q2',
      topicId: 'topic-1',
      questionType: 'multiple_choice',
      prompt: 'Which state management library uses Providers?',
      options: ['Redux', 'Riverpod', 'MobX', 'BLoC'],
      correctAnswer: 'Riverpod',
      explanation: 'Riverpod is a reactive caching and data-binding framework.',
      difficulty: 'medium',
    ),
  ];

  group('PracticeMascotHeader Tests', () {
    testWidgets('renders correct expressions and text for each mood',
        (tester) async {
      for (final mood in PracticeMascotMood.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PracticeMascotHeader(mood: mood),
            ),
          ),
        );
        await tester.pump();

        switch (mood) {
          case PracticeMascotMood.start:
            expect(find.text("Let's see what stuck."), findsOneWidget);
            break;
          case PracticeMascotMood.thinking:
            expect(find.text("Take your time. Think through the logic."),
                findsOneWidget);
            break;
          case PracticeMascotMood.correct:
            expect(find.text("Yep. You got that one."), findsOneWidget);
            break;
          case PracticeMascotMood.incorrect:
            expect(find.text("Not quite. Let's figure out why."), findsOneWidget);
            break;
          case PracticeMascotMood.completion:
            expect(find.text("Nice. That's another piece locked in."),
                findsOneWidget);
            break;
        }
      }
    });

    testWidgets('supports custom message override', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PracticeMascotHeader(
              mood: PracticeMascotMood.start,
              customMessage: 'Custom mascot pep talk!',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Custom mascot pep talk!'), findsOneWidget);
    });
  });

  group('PracticeQuestionCard Tests', () {
    testWidgets('renders question prompt, letter badges, and check button',
        (tester) async {
      String? selected;
      var checked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return PracticeQuestionCard(
                  question: mockQuestions[0],
                  currentIndex: 0,
                  totalQuestions: 2,
                  selectedAnswer: selected,
                  isChecked: checked,
                  isCorrect: selected == mockQuestions[0].correctAnswer,
                  isLastQuestion: false,
                  isSubmitting: false,
                  isReviewMode: false,
                  onSelectOption: (opt) {
                    setState(() => selected = opt);
                  },
                  onCheckAnswer: () {
                    setState(() => checked = true);
                  },
                  onNextQuestion: () {},
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header info
      expect(find.text('QUESTION 1 OF 2'), findsOneWidget);
      expect(find.text('EASY'), findsOneWidget);
      expect(find.text('What is the main benefit of Flutter widgets?'),
          findsOneWidget);

      // Check letter badges
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);

      // Check option labels
      expect(find.text('Reusability'), findsOneWidget);
      expect(find.text('Larger APK'), findsOneWidget);

      // Check Answer button is initially disabled
      final checkBtn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(checkBtn.onPressed, isNull);

      // Tap on option 'Reusability'
      await tester.tap(find.text('Reusability'));
      await tester.pumpAndSettle();

      // Now Check Answer is enabled
      final checkBtnEnabled =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(checkBtnEnabled.onPressed, isNotNull);

      // Tap Check Answer
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Explanation should now be visible
      expect(find.text('Why this is correct:'), findsOneWidget);
      expect(
          find.text(
              'Flutter widgets are composable and highly reusable UI blocks.'),
          findsOneWidget);
      expect(find.text("Yep. You got that one."), findsOneWidget);
      expect(find.text('Next Question'), findsOneWidget);
    });

    testWidgets('shows incorrect feedback and correct answer on wrong pick',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PracticeQuestionCard(
              question: mockQuestions[0],
              currentIndex: 0,
              totalQuestions: 2,
              selectedAnswer: 'Larger APK',
              isChecked: true,
              isCorrect: false,
              isLastQuestion: false,
              isSubmitting: false,
              isReviewMode: false,
              onSelectOption: (_) {},
              onCheckAnswer: () {},
              onNextQuestion: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Not quite. Let's figure out why."), findsOneWidget);
      expect(find.text("Twin's Explanation:"), findsOneWidget);
      expect(find.text('Correct Answer: Reusability'), findsOneWidget);
    });

    testWidgets('renders on narrow 320px viewport without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });


      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PracticeQuestionCard(
              question: mockQuestions[0],
              currentIndex: 0,
              totalQuestions: 2,
              selectedAnswer: 'Reusability',
              isChecked: true,
              isCorrect: true,
              isLastQuestion: false,
              isSubmitting: false,
              isReviewMode: false,
              onSelectOption: (_) {},
              onCheckAnswer: () {},
              onNextQuestion: () {},
            ),
          ),
        ),
      );
      final err = tester.takeException();
      expect(err, isNull);
      expect(find.text('Next Question'), findsOneWidget);
    });
  });

  group('PracticeCompletionView Tests', () {
    const mockResult = QuestionSubmissionResponse(
      topicId: 'topic-1',
      score: 1.0,
      masteryScore: 85.0,
      masteryDelta: 15.0,
      correctCount: 2,
      totalCount: 2,
      overallFeedback: 'Outstanding grasp of reactive widget fundamentals!',
    );

    testWidgets('displays score, mastery delta, feedback, and action buttons',
        (tester) async {
      var reviewed = false;
      var continued = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PracticeCompletionView(
              result: mockResult,
              onReviewQuestions: () => reviewed = true,
              onContinue: () => continued = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Nice. That's another piece locked in."), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text(' / 2'), findsOneWidget);
      expect(find.text('100% Accuracy'), findsOneWidget);
      expect(find.text('+15%'), findsOneWidget);
      expect(find.text('Mastery Delta'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('Total Mastery'), findsOneWidget);
      expect(find.text('Outstanding grasp of reactive widget fundamentals!'),
          findsOneWidget);

      await tester.ensureVisible(find.text('Review Quiz'));
      await tester.tap(find.text('Review Quiz'));
      expect(reviewed, isTrue);

      await tester.ensureVisible(find.text('Continue Learning'));
      await tester.tap(find.text('Continue Learning'));
      expect(continued, isTrue);
    });

    testWidgets('renders completion view on narrow 320px screen without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PracticeCompletionView(
              result: mockResult,
              onReviewQuestions: () {},
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('PracticeSessionNotifier Unit Tests', () {
    test('manages question answers, immediate check, and transitions', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(practiceSessionProvider('topic-1').notifier);
      notifier.initQuestions(mockQuestions);

      var state = container.read(practiceSessionProvider('topic-1'));
      expect(state.totalQuestions, 2);
      expect(state.currentIndex, 0);
      expect(state.currentQuestion?.id, 'q1');

      // Select wrong answer
      notifier.selectAnswer('Larger APK');
      state = container.read(practiceSessionProvider('topic-1'));
      expect(state.currentSelectedAnswer, 'Larger APK');
      expect(state.isChecked, false);

      // Check answer
      notifier.checkAnswer();
      state = container.read(practiceSessionProvider('topic-1'));
      expect(state.isChecked, true);
      expect(state.isCurrentAnswerCorrect, false);

      // Next question
      notifier.nextQuestion();
      state = container.read(practiceSessionProvider('topic-1'));
      expect(state.currentIndex, 1);
      expect(state.currentQuestion?.id, 'q2');
      expect(state.isChecked, false);

      // Select correct answer for Q2
      notifier.selectAnswer('Riverpod');
      notifier.checkAnswer();
      state = container.read(practiceSessionProvider('topic-1'));
      expect(state.isCurrentAnswerCorrect, true);
      expect(state.isLastQuestion, true);

      // Review mode
      notifier.enterReviewMode();
      state = container.read(practiceSessionProvider('topic-1'));
      expect(state.isReviewMode, true);
      expect(state.currentIndex, 0);

      notifier.exitReviewMode();
      state = container.read(practiceSessionProvider('topic-1'));
      expect(state.isReviewMode, false);
    });
  });

  group('StepQuestionView Tests', () {
    testWidgets('renders companion mascot and letter badge options',
        (tester) async {
      final step = SessionStep(
        id: 'step-q1',
        type: StepType.question,
        title: 'Check Your Understanding',
        content: {
          'question': 'Which widget is immutable in Flutter?',
          'options': ['StatelessWidget', 'StatefulWidget', 'Both', 'Neither'],
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StepQuestionView(step: step, sessionId: 'session-123'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Take your time. Think through the logic."),
          findsOneWidget);
      expect(find.text('Which widget is immutable in Flutter?'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      expect(find.text('StatelessWidget'), findsOneWidget);
    });
  });
}
