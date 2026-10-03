import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../journey/presentation/providers/learning_path_provider.dart';
import '../providers/teach_mode_provider.dart';
import '../widgets/teach_mascot_header.dart';
import '../widgets/teach_state_badge.dart';
import '../widgets/teach_evaluation_report_view.dart';
import '../../../../core/widgets/skilltwin_markdown.dart';

/// Redesigned Teach / Feynman Mode Screen.
/// Provides a focused, intimate learning companion experience where the learner
/// explains a concept to their digital Twin with clear visual states:
/// READY -> RECORDING -> PROCESSING -> EVALUATING -> RESULT / COMPLETED.
class TeachModeScreen extends ConsumerStatefulWidget {
  final String? conceptId;
  const TeachModeScreen({super.key, this.conceptId});

  @override
  ConsumerState<TeachModeScreen> createState() => _TeachModeScreenState();
}

class _TeachModeScreenState extends ConsumerState<TeachModeScreen>
    with SingleTickerProviderStateMixin {
  bool _isTextMode = false;
  late final TextEditingController _textController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize concept context if passed and not already initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cid = widget.conceptId;
      if (cid != null && cid.isNotEmpty) {
        final existingState = ref.read(teachModeProvider);
        if (existingState.conceptId != cid) {
          final detailAsync = ref.read(topicDetailProvider(cid));
          final title = detailAsync.asData?.value.title ?? 'Foundational Concept';
          ref.read(teachModeProvider.notifier).init(
                cid,
                title,
                'Explain $title in your own words.',
              );
        }
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teachModeProvider);
    final notifier = ref.read(teachModeProvider.notifier);

    if (state.status == TeachModeStatus.recording) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F111D), // Deep midnight navy for intense focus
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          tooltip: 'Exit session',
          onPressed: () => _handleExit(context, state, notifier),
        ),
        title: TeachStateBadge(status: state.status),
        centerTitle: true,
        actions: [
          // Voice vs Text Toggle (only relevant during input stages)
          if (!state.status.isLoading && !state.status.isResult && !state.status.isCompleted)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _isTextMode = !_isTextMode);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(
                  _isTextMode ? Icons.mic_rounded : Icons.keyboard_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
                label: Text(
                  _isTextMode ? 'VOICE' : 'TEXT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentStage(state, notifier),
        ),
      ),
    );
  }

  Widget _buildCurrentStage(TeachModeState state, TeachModeNotifier notifier) {
    // ── 1. PROCESSING / EVALUATING STAGE (Loading Mascot GIF) ──
    if (state.status.isLoading) {
      return _buildProcessingStage(state);
    }

    // ── 2. RESULT / COMPLETED STAGE (Information-First Evaluation Report) ──
    if (state.status.isResult || state.status.isCompleted || state.report != null) {
      return _buildResultStage(state, notifier);
    }

    // ── 3. READY / RECORDING STAGE (Focused Input UI) ──
    return _buildInputStage(state, notifier);
  }

  // ---------------------------------------------------------------------------
  // Stage 1: Processing / Evaluating with Mascot Loading GIF
  // ---------------------------------------------------------------------------
  Widget _buildProcessingStage(TeachModeState state) {
    final isEvaluating = state.status == TeachModeStatus.evaluating;

    return Center(
      key: const ValueKey('processing_stage'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TeachMascotHeader(
              status: state.status,
              mascotSize: 110,
              customSpeech: isEvaluating
                  ? 'Evaluating reasoning depth and mental model...'
                  : 'Your Twin is thinking...',
            ),
            const SizedBox(height: 28),
            Text(
              isEvaluating ? 'Evaluating Mental Model' : 'Processing Explanation',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isEvaluating
                  ? 'Analyzing conceptual completeness, analogies, and detecting potential misconceptions.'
                  : 'Synthesizing voice transcription into structured semantic arguments.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stage 2: Result & Topic Completion Evaluation View
  // ---------------------------------------------------------------------------
  Widget _buildResultStage(TeachModeState state, TeachModeNotifier notifier) {
    final report = state.report ?? {};
    final hasMisconceptions = state.misconceptions.isNotEmpty;

    return SingleChildScrollView(
      key: const ValueKey('result_stage'),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          TeachMascotHeader(
            status: state.status,
            isMastered: state.isMastered,
            hasMisconceptions: hasMisconceptions,
            mascotSize: 92,
          ),
          const SizedBox(height: 20),
          TeachEvaluationReportView(
            report: report,
            isDark: true,
            onTeachAgain: () {
              notifier.init(
                widget.conceptId ?? state.conceptId ?? '',
                state.conceptTitle ?? 'Concept',
                state.mentorPrompt ?? 'Explain this concept in your own words.',
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stage 3: Ready & Recording Focused Layout
  // ---------------------------------------------------------------------------
  Widget _buildInputStage(TeachModeState state, TeachModeNotifier notifier) {
    final isRecording = state.status == TeachModeStatus.recording;

    return Padding(
      key: const ValueKey('input_stage'),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // Mascot Header with Listening / Encouraging pose
          TeachMascotHeader(
            status: state.status,
            mascotSize: 84,
          ),
          const SizedBox(height: 16),

          // Prompt Card: "Explain ___ in your own words."
          _PromptCard(
            title: state.conceptTitle ?? 'Concept',
            prompt: state.mentorPrompt ?? 'Explain this concept in your own words.',
          ),
          const SizedBox(height: 20),

          // Core Interactive Area (Voice or Text)
          Expanded(
            child: _isTextMode
                ? _buildTextInput(state, notifier)
                : _buildVoiceInput(state),
          ),

          // Voice Wave Visualizer (Voice mode only)
          if (!_isTextMode) ...[
            _VoiceWaveVisualizer(isRecording: isRecording),
            const SizedBox(height: 16),
          ],

          // Footer Controls (Record Button or Submit Button)
          _buildControls(state, notifier),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildVoiceInput(TeachModeState state) {
    final isRecording = state.status == TeachModeStatus.recording;

    return Column(
      children: [
        // Live Recording Timer (e.g. 00:42)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRecording ? const Color(0xFFEF4444) : Colors.white24,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(state.elapsedSeconds),
              style: TextStyle(
                color: isRecording ? Colors.white : Colors.white38,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Live streaming transcript or prompt preview
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                state.transcript.isEmpty
                    ? (isRecording
                        ? "Listening closely... speak your thoughts freely."
                        : "Tap Record and explain like I'm 5...")
                    : state.transcript,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: state.transcript.isEmpty ? Colors.white38 : Colors.white,
                  fontSize: 16,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  fontStyle: state.transcript.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput(TeachModeState state, TeachModeNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        autofocus: true,
        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.45),
        decoration: const InputDecoration(
          hintText: 'Type your explanation here in your own words...',
          hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
          border: InputBorder.none,
        ),
        onChanged: (val) => notifier.updateTranscriptManually(val),
      ),
    );
  }

  Widget _buildControls(TeachModeState state, TeachModeNotifier notifier) {
    if (_isTextMode) {
      final canSubmit = state.transcript.trim().length >= 10;
      return ElevatedButton(
        onPressed: canSubmit
            ? () {
                HapticFeedback.mediumImpact();
                notifier.stopAndAnalyze();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white12,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          'SUBMIT EXPLANATION',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
      );
    }

    final isRecording = state.status == TeachModeStatus.recording;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              if (isRecording) {
                notifier.stopAndAnalyze();
              } else {
                notifier.startListening();
              }
            },
            child: ScaleTransition(
              scale: isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isRecording
                        ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                        : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isRecording ? const Color(0xFFEF4444) : const Color(0xFF6366F1))
                          .withValues(alpha: 0.45),
                      blurRadius: 22,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isRecording ? 'TAP TO STOP & EVALUATE' : 'TAP TO RECORD',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remSecs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remSecs.toString().padLeft(2, '0')}';
  }

  void _handleExit(BuildContext context, TeachModeState state, TeachModeNotifier notifier) {
    if (state.status == TeachModeStatus.recording) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E2238),
          title: const Text('End Teach Session?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Your current explanation will not be analyzed by your Twin companion.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('RESUME', style: TextStyle(color: Color(0xFF818CF8))),
            ),
            TextButton(
              onPressed: () {
                notifier.reset();
                Navigator.pop(ctx);
                context.pop();
              },
              child: const Text('EXIT', style: TextStyle(color: Color(0xFFEF4444))),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }
}

class _PromptCard extends StatelessWidget {
  final String title;
  final String prompt;

  const _PromptCard({required this.title, required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TEACH ME',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF818CF8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          SkillTwinMarkdown(
            data: prompt,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceWaveVisualizer extends StatelessWidget {
  final bool isRecording;
  const _VoiceWaveVisualizer({required this.isRecording});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(24, (index) {
          final barHeight = isRecording ? (8 + (index % 6) * 6.0) : 4.0;
          return AnimatedContainer(
            duration: Duration(milliseconds: isRecording ? 120 : 400),
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            width: 3.0,
            height: barHeight,
            decoration: BoxDecoration(
              color: isRecording ? const Color(0xFF6366F1) : Colors.white12,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
