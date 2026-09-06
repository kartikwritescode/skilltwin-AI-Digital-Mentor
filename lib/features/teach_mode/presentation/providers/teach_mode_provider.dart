import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/teach_mode_repository.dart';
import '../../data/repositories/teach_mode_repository_provider.dart';

enum TeachModeStatus { idle, listening, processing, reporting }

class TeachModeState {
  final TeachModeStatus status;
  final String transcript;
  final String? mentorPrompt;
  final String? conceptId;
  final String? conceptTitle;
  final int elapsedSeconds;
  final Map<String, dynamic>? report;
  final String? error;

  TeachModeState({
    this.status = TeachModeStatus.idle,
    this.transcript = '',
    this.mentorPrompt,
    this.conceptId,
    this.conceptTitle,
    this.elapsedSeconds = 0,
    this.report,
    this.error,
  });

  TeachModeState copyWith({
    TeachModeStatus? status,
    String? transcript,
    String? mentorPrompt,
    String? conceptId,
    String? conceptTitle,
    int? elapsedSeconds,
    Map<String, dynamic>? report,
    String? error,
  }) {
    return TeachModeState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      mentorPrompt: mentorPrompt ?? this.mentorPrompt,
      conceptId: conceptId ?? this.conceptId,
      conceptTitle: conceptTitle ?? this.conceptTitle,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      report: report ?? this.report,
      error: error,
    );
  }
}

final teachModeProvider = StateNotifierProvider<TeachModeNotifier, TeachModeState>((ref) {
  final repository = ref.watch(teachModeRepositoryProvider);
  return TeachModeNotifier(repository);
});

class TeachModeNotifier extends StateNotifier<TeachModeState> {
  final TeachModeRepository _repository;
  Timer? _timer;

  TeachModeNotifier(this._repository) : super(TeachModeState());

  void init(String id, String title, String prompt) {
    state = state.copyWith(
      conceptId: id,
      conceptTitle: title,
      mentorPrompt: prompt,
      status: TeachModeStatus.idle,
      transcript: '',
      elapsedSeconds: 0,
      report: null,
      error: null,
    );
  }

  Future<void> startListening() async {
    state = state.copyWith(status: TeachModeStatus.listening, transcript: '', error: null, elapsedSeconds: 0);
    await _repository.startVoiceSession();
    
    _startTimer();
    _simulateTranscript();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.status == TeachModeStatus.listening) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      } else {
        timer.cancel();
      }
    });
  }

  void _simulateTranscript() async {
    const text = "Backpropagation is essentially the chain rule applied to neural networks. We calculate the gradient of the loss function with respect to each weight. We start from the output layer and move backward. By calculating these partial derivatives, we know exactly how to adjust the weights to reduce the overall error...";
    final words = text.split(' ');
    for (var i = 0; i < words.length; i++) {
      if (state.status != TeachModeStatus.listening) break;
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(transcript: '${state.transcript} ${words[i]}'.trim());
    }
  }

  Future<void> stopAndAnalyze() async {
    _timer?.cancel();
    state = state.copyWith(status: TeachModeStatus.processing);
    await _repository.stopVoiceSession();
    
    try {
      final report = await _repository.getUnderstandingReport();
      state = state.copyWith(status: TeachModeStatus.reporting, report: report);
    } catch (e) {
      state = state.copyWith(status: TeachModeStatus.idle, error: "Analysis failed.");
    }
  }

  void updateTranscriptManually(String text) {
    state = state.copyWith(transcript: text);
  }

  void reset() {
    _timer?.cancel();
    state = TeachModeState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
