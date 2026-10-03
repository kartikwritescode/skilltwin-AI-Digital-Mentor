import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../domain/repositories/teach_mode_repository.dart';
import '../../data/repositories/teach_mode_repository_provider.dart';
import '../../../journey/presentation/providers/learning_path_provider.dart';

enum TeachModeStatus {
  ready,
  recording,
  processing,
  evaluating,
  result,
  completed;

  // Backward compatibility aliases
  static const TeachModeStatus idle = TeachModeStatus.ready;
  static const TeachModeStatus listening = TeachModeStatus.recording;
  static const TeachModeStatus reporting = TeachModeStatus.result;

  bool get isReady => this == TeachModeStatus.ready;
  bool get isRecording => this == TeachModeStatus.recording;
  bool get isProcessing => this == TeachModeStatus.processing;
  bool get isEvaluating => this == TeachModeStatus.evaluating;
  bool get isResult => this == TeachModeStatus.result;
  bool get isCompleted => this == TeachModeStatus.completed;
  bool get isLoading =>
      this == TeachModeStatus.processing || this == TeachModeStatus.evaluating;
}

class TeachModeState {
  final TeachModeStatus status;
  final String transcript;
  final String? mentorPrompt;
  final String? conceptId;
  final String? conceptTitle;
  final int elapsedSeconds;
  final Map<String, dynamic>? report;
  final String? error;
  final bool isCompleted;

  TeachModeState({
    this.status = TeachModeStatus.ready,
    this.transcript = '',
    this.mentorPrompt,
    this.conceptId,
    this.conceptTitle,
    this.elapsedSeconds = 0,
    this.report,
    this.error,
    this.isCompleted = false,
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
    bool? isCompleted,
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
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // ── Helper Getters for Evaluated Metrics ──

  double get conceptualAccuracy {
    if (report == null) return 0.0;
    final val = report!['conceptual_accuracy'] ?? report!['accuracy'];
    if (val is num) return val.toDouble().clamp(0.0, 1.0);
    return 0.0;
  }

  double get reasoningDepth {
    if (report == null) return 0.0;
    final val = report!['reasoning'] ??
        report!['depth'] ??
        report!['reasoning_depth'] ??
        report!['clarity'];
    if (val is num) return val.toDouble().clamp(0.0, 1.0);
    return 0.0;
  }

  double get completeness {
    if (report == null) return 0.0;
    final val = report!['completeness'];
    if (val is num) return val.toDouble().clamp(0.0, 1.0);
    return 0.0;
  }

  double get transfer {
    if (report == null) return 0.0;
    final val = report!['transfer'] ?? report!['transfer_analogy'] ?? report!['confidence'];
    if (val is num) return val.toDouble().clamp(0.0, 1.0);
    return 0.0;
  }

  List<String> get misconceptions {
    if (report == null) return const [];
    final raw = report!['misconceptions'];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    return const [];
  }

  List<String> get strengths {
    if (report == null) return const [];
    final raw = report!['strengths'];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    return const [];
  }

  String get mentorFeedback {
    if (report == null) return '';
    return (report!['feedback'] ?? report!['mentor_feedback'] ?? '').toString();
  }

  String? get mentorRecommendation {
    if (report == null) return null;
    final val = report!['recommendation'] ?? report!['mentor_recommendation'];
    final str = val?.toString();
    return (str != null && str.isNotEmpty) ? str : null;
  }

  String? get fixActionId {
    if (report == null) return null;
    final val = report!['fix_action_id'];
    return val?.toString();
  }

  bool get isMastered {
    if (isCompleted) return true;
    if (report == null) return false;
    final completedFlag =
        report!['topic_completed'] == true || report!['is_mastered'] == true;
    if (completedFlag) return true;
    // Mastery threshold: 75% accuracy and no severe misconceptions, or 85%+ accuracy
    return (conceptualAccuracy >= 0.75 && misconceptions.isEmpty) ||
        conceptualAccuracy >= 0.85;
  }
}

final teachModeProvider =
    StateNotifierProvider<TeachModeNotifier, TeachModeState>((ref) {
  final repository = ref.watch(teachModeRepositoryProvider);
  return TeachModeNotifier(repository, ref);
});

class TeachModeNotifier extends StateNotifier<TeachModeState> {
  final TeachModeRepository _repository;
  final Ref? _ref;
  AudioRecorder? _audioRecorder;
  String? _currentRecordingPath;
  Timer? _timer;

  TeachModeNotifier(this._repository, [this._ref]) : super(TeachModeState());

  void init(String id, String title, String prompt) {
    // Preserve completed report when re-entering the same concept
    if (state.conceptId == id && state.report != null) {
      state = state.copyWith(
        conceptTitle: title.isNotEmpty ? title : state.conceptTitle,
        mentorPrompt: prompt.isNotEmpty ? prompt : state.mentorPrompt,
      );
      return;
    }

    state = state.copyWith(
      conceptId: id,
      conceptTitle: title,
      mentorPrompt: prompt,
      status: TeachModeStatus.ready,
      transcript: '',
      elapsedSeconds: 0,
      report: null,
      error: null,
      isCompleted: false,
    );
  }

  Future<void> startListening() async {
    state = state.copyWith(
      status: TeachModeStatus.recording,
      transcript: '',
      error: null,
      elapsedSeconds: 0,
    );

    try {
      _audioRecorder ??= AudioRecorder();
      final hasPermission = await _audioRecorder!.hasPermission();

      if (hasPermission) {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _currentRecordingPath = '${tempDir.path}/teach_rec_$timestamp.m4a';

        await _audioRecorder!.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _currentRecordingPath!,
        );
      } else {
        // Fallback gracefully without throwing
        _simulateTranscript();
      }
    } catch (_) {
      // Audio hardware not available (e.g. headless desktop / test runner), fall back to guided simulation
      _simulateTranscript();
    }

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.status == TeachModeStatus.recording) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      } else {
        timer.cancel();
      }
    });
  }

  void _simulateTranscript() async {
    const text =
        "Backpropagation calculates gradients through the chain rule to minimize error loss across neural network weights.";
    final words = text.split(' ');
    for (var i = 0; i < words.length; i++) {
      if (state.status != TeachModeStatus.recording) break;
      await Future.delayed(const Duration(milliseconds: 350));
      if (state.status == TeachModeStatus.recording) {
        state =
            state.copyWith(transcript: '${state.transcript} ${words[i]}'.trim());
      }
    }
  }

  Future<void> stopAndAnalyze() async {
    _timer?.cancel();
    state = state.copyWith(status: TeachModeStatus.processing);

    String? recordedAudioPath;
    try {
      if (_audioRecorder != null && await _audioRecorder!.isRecording()) {
        recordedAudioPath = await _audioRecorder!.stop();
      }
    } catch (_) {}

    await _repository.stopVoiceSession();

    try {
      // If we captured audio file, transcribe via STT service
      if (recordedAudioPath != null && File(recordedAudioPath).existsSync()) {
        final transcribed = await _repository.transcribeAudio(
          File(recordedAudioPath),
          conceptId: state.conceptId,
        );
        if (transcribed != null && transcribed.trim().isNotEmpty) {
          state = state.copyWith(transcript: transcribed.trim());
        }
      }

      state = state.copyWith(status: TeachModeStatus.evaluating);

      final conceptId = state.conceptId ?? 'default_concept';
      final explanation = state.transcript.isNotEmpty
          ? state.transcript
          : "Understanding of foundational concepts and relations.";

      final report =
          await _repository.evaluateExplanation(conceptId, explanation);

      final accuracy = report['conceptual_accuracy'] is num
          ? (report['conceptual_accuracy'] as num).toDouble()
          : 0.0;
      final misconceptions = report['misconceptions'] is List
          ? (report['misconceptions'] as List)
          : [];
      final isMasteredNow = (report['topic_completed'] == true) ||
          (report['is_mastered'] == true) ||
          (accuracy >= 0.75 && misconceptions.isEmpty) ||
          accuracy >= 0.85;

      state = state.copyWith(
        status: isMasteredNow ? TeachModeStatus.completed : TeachModeStatus.result,
        report: report,
        isCompleted: isMasteredNow,
      );

      // Reactive propagation: if mastered and topicId is valid, complete topic
      if (isMasteredNow &&
          state.conceptId != null &&
          state.conceptId!.isNotEmpty &&
          _ref != null) {
        try {
          _ref!.read(topicActionProvider.notifier).completeTopic(state.conceptId!);
        } catch (_) {}
      }
    } catch (e) {
      // Fallback to cached or structured report
      try {
        final fallbackReport = await _repository.getUnderstandingReport();
        state = state.copyWith(
          status: TeachModeStatus.result,
          report: fallbackReport,
        );
      } catch (_) {
        state = state.copyWith(
          status: TeachModeStatus.ready,
          error: "Analysis failed. Please check network connection.",
        );
      }
    }
  }

  Future<void> confirmTopicCompletion() async {
    if (state.conceptId != null &&
        state.conceptId!.isNotEmpty &&
        _ref != null) {
      try {
        await _ref!.read(topicActionProvider.notifier).completeTopic(state.conceptId!);
      } catch (_) {}
    }
    state = state.copyWith(
      status: TeachModeStatus.completed,
      isCompleted: true,
    );
  }

  void updateTranscriptManually(String text) {
    state = state.copyWith(transcript: text);
  }

  void reset() {
    _timer?.cancel();
    try {
      _audioRecorder?.stop();
    } catch (_) {}
    state = TeachModeState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    try {
      _audioRecorder?.dispose();
    } catch (_) {}
    super.dispose();
  }
}
