import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_state_provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../../../../core/widgets/skilltwin_twin.dart';
import '../widgets/session_intro_screen.dart';
import 'session_content_screen.dart';
import 'session_result_screen.dart';

class SessionScreen extends ConsumerWidget {
  final String sessionId;

  const SessionScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionStateProvider(sessionId));

    if (state.isLoading) {
      return const Scaffold(
        body: SkillTwinLoadingView.fullScreen(
          message: 'SkillTwin is preparing your next step.',
          subMessage: 'Personalizing your interactive practice session...',
        ),
      );
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(sessionStateProvider(sessionId).notifier).loadSession(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.session == null) {
      return const Scaffold(
        body: Center(child: Text('Session not found')),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (state.isFinished) return true;
        return await _showExitConfirmation(context) ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () async {
              if (state.isFinished) {
                context.pop();
              } else if (await _showExitConfirmation(context) == true) {
                context.pop();
              }
            },
          ),
          title: state.isIntro || state.isFinished || state.isSubmitting
              ? Text(
                  state.isIntro ? 'Session Intro' : 'Session Evaluation',
                  style: AppTypography.supporting.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (state.currentStepIndex + 1) / state.session!.steps.length,
                    minHeight: 6,
                    backgroundColor: AppTheme.primaryAccent.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryAccent),
                  ),
                ),
        ),
        body: SkillTwinBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _buildCurrentView(state, sessionId),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView(SessionState state, String sessionId) {
    if (state.isSubmitting) {
      return const _EvaluationLoadingView();
    }

    if (state.isIntro) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SessionIntroScreen(session: state.session!, sessionId: sessionId),
      );
    }
    
    if (state.isFinished) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SessionResultScreen(result: state.result!, sessionId: sessionId),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SessionContentScreen(
        session: state.session!,
        sessionId: sessionId,
        currentStep: state.currentStep!,
      ),
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Exit Session?'),
        content: const Text('Your current progress will not be saved. Your mentor recommends finishing to update your twin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('RESUME'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('EXIT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _EvaluationLoadingView extends StatelessWidget {
  const _EvaluationLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: const SkillTwinLoadingView(
        message: 'SkillTwin is preparing your next step.',
        subMessage: 'Analyzing evidence to update your mental model and mastery state...',
      ),
    );
  }
}
