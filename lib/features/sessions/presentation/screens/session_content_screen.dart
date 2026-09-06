import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/learning_session.dart';
import '../../../../core/models/session_step.dart';
import '../providers/session_state_provider.dart';
import '../widgets/step_recall_view.dart';
import '../widgets/step_learn_view.dart';
import '../widgets/step_question_view.dart';
import '../widgets/step_explanation_view.dart';

class SessionContentScreen extends ConsumerWidget {
  final LearningSession session;
  final String sessionId;
  final SessionStep currentStep;

  const SessionContentScreen({
    super.key,
    required this.session,
    required this.sessionId,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(sessionStateProvider(sessionId).notifier);
    final state = ref.watch(sessionStateProvider(sessionId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentStep.title.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '${state.currentStepIndex + 1} of ${session.steps.length}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (currentStep.instructions != null)
          Text(
            currentStep.instructions!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: _buildStepContent(context, ref),
          ),
        ),
        const SizedBox(height: 16),
        _buildNavigation(context, notifier, state),
      ],
    );
  }

  Widget _buildStepContent(BuildContext context, WidgetRef ref) {
    switch (currentStep.type) {
      case StepType.recall:
        return StepRecallView(step: currentStep, sessionId: sessionId);
      case StepType.learn:
        return StepLearnView(step: currentStep);
      case StepType.practice:
      case StepType.question:
        return StepQuestionView(step: currentStep, sessionId: sessionId);
      case StepType.prove:
      case StepType.explanation:
        return StepExplanationView(step: currentStep, sessionId: sessionId);
      default:
        return const Center(child: Text('Step content coming soon...'));
    }
  }

  Widget _buildNavigation(BuildContext context, SessionNotifier notifier, SessionState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        onPressed: state.isSubmitting ? null : () => notifier.nextStep(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: state.isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                state.isLastStep ? 'FINISH SESSION' : 'NEXT STEP',
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
      ),
    );
  }
}
