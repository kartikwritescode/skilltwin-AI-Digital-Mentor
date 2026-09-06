import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/teach_mode_provider.dart';

class TeachModeScreen extends ConsumerStatefulWidget {
  final String? conceptId;
  const TeachModeScreen({super.key, this.conceptId});

  @override
  ConsumerState<TeachModeScreen> createState() => _TeachModeScreenState();
}

class _TeachModeScreenState extends ConsumerState<TeachModeScreen> {
  bool _isTextMode = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teachModeProvider);
    final notifier = ref.read(teachModeProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Deep black for focus
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => _handleExit(context, state, notifier),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _isTextMode = !_isTextMode),
            icon: Icon(_isTextMode ? Icons.mic : Icons.keyboard, color: Colors.white70, size: 18),
            label: Text(_isTextMode ? 'VOICE' : 'TEXT', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _MentorPromptCard(prompt: state.mentorPrompt ?? "Explain the core concept in your own words."),
              const SizedBox(height: 40),
              
              if (!_isTextMode) ...[
                _buildVoiceUI(state),
              ] else ...[
                _buildTextUI(state, notifier),
              ],

              const Spacer(),
              if (!_isTextMode) 
                _VoiceVisualizer(isListening: state.status == TeachModeStatus.listening),
              const SizedBox(height: 40),
              _buildControls(context, state, notifier),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceUI(TeachModeState state) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.circle, color: Colors.red, size: 8),
              const SizedBox(width: 8),
              Text(
                _formatDuration(state.elapsedSeconds),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                state.transcript.isEmpty ? "Your mentor is listening..." : state.transcript,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: state.transcript.isEmpty ? Colors.white24 : Colors.white,
                  fontSize: 24,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                  fontStyle: state.transcript.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextUI(TeachModeState state, TeachModeNotifier notifier) {
    return Expanded(
      child: TextField(
        controller: _textController,
        maxLines: null,
        autofocus: true,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: const InputDecoration(
          hintText: 'Type your explanation here...',
          hintStyle: TextStyle(color: Colors.white24),
          border: InputBorder.none,
        ),
        onChanged: (val) => notifier.updateTranscriptManually(val),
      ),
    );
  }

  Widget _buildControls(BuildContext context, TeachModeState state, TeachModeNotifier notifier) {
    if (state.status == TeachModeStatus.reporting) {
      return ElevatedButton(
        onPressed: () => context.push('/teach/report'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('VIEW UNDERSTANDING REPORT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
      );
    }

    if (state.status == TeachModeStatus.processing) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text('Analyzing your explanation...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_isTextMode) {
      return ElevatedButton(
        onPressed: state.transcript.length > 10 ? () => notifier.stopAndAnalyze() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('SUBMIT EXPLANATION', style: TextStyle(fontWeight: FontWeight.bold)),
      );
    }

    return GestureDetector(
      onTap: () {
        if (state.status == TeachModeStatus.listening) {
          notifier.stopAndAnalyze();
        } else {
          notifier.startListening();
        }
      },
      child: Center(
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: state.status == TeachModeStatus.listening ? Colors.red : Colors.orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (state.status == TeachModeStatus.listening ? Colors.red : Colors.orange).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Icon(
                state.status == TeachModeStatus.listening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              state.status == TeachModeStatus.listening ? 'TAP TO STOP' : 'TAP TO START TEACHING',
              style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _handleExit(BuildContext context, TeachModeState state, TeachModeNotifier notifier) {
    if (state.status == TeachModeStatus.listening) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('End Session?'),
          content: const Text('Your current explanation will not be analyzed by your mentor.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('RESUME')),
            TextButton(
              onPressed: () {
                notifier.reset();
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('EXIT', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      notifier.reset();
      context.pop();
    }
  }
}

class _MentorPromptCard extends StatelessWidget {
  final String prompt;
  const _MentorPromptCard({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.assistant, color: Colors.orange, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              prompt,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceVisualizer extends StatelessWidget {
  final bool isListening;
  const _VoiceVisualizer({required this.isListening});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(20, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: isListening ? 150 : 500),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 3,
            height: isListening ? (10 + (index % 7) * 15.0) : 4,
            decoration: BoxDecoration(
              color: isListening ? Colors.orange : Colors.white12,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
