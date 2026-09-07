import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../networking/api_client.dart';
import '../networking/api_provider.dart';
import '../models/topic_detail.dart';

enum VoiceState {
  idle,
  listening,
  transcribing,
  thinking,
  speaking,
  error;

  String get label {
    switch (this) {
      case VoiceState.idle:
        return 'Tap to Speak';
      case VoiceState.listening:
        return 'Listening...';
      case VoiceState.transcribing:
        return 'Processing audio...';
      case VoiceState.thinking:
        return 'SkillTwin is thinking...';
      case VoiceState.speaking:
        return 'Speaking response...';
      case VoiceState.error:
        return 'Voice Error';
    }
  }
}

class SpeechService {
  final ApiClient _apiClient;
  final AudioRecorder _recorder = AudioRecorder();

  SpeechService(this._apiClient);

  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      debugPrint('Error checking mic permission: $e');
      return false;
    }
  }

  Future<String?> startRecording() async {
    try {
      final permitted = await hasPermission();
      if (!permitted) return null;

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );
      return filePath;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return null;
    }
  }

  Future<String?> stopRecording() async {
    try {
      return await _recorder.stop();
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  Future<String> transcribeAudioFile(String filePath, {String? topicHint}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Audio file not found: $filePath');
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: 'recording.m4a',
      ),
      if (topicHint != null) 'topic_hint': topicHint,
    });

    final response = await _apiClient.rawDio.post(
      '${_apiClient.rawDio.options.baseUrl}/voice/transcribe',
      data: formData,
    );

    if (response.data is Map<String, dynamic>) {
      return (response.data['transcript'] ?? '').toString();
    }
    return '';
  }

  Future<ContextualAskResponse> askVoiceQuestion(
    String filePath, {
    String? topicId,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Audio file not found: $filePath');
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: 'question.m4a',
      ),
      if (topicId != null) 'topic_id': topicId,
    });

    final response = await _apiClient.rawDio.post(
      '${_apiClient.rawDio.options.baseUrl}/voice/ask',
      data: formData,
    );

    if (response.data is Map<String, dynamic>) {
      return ContextualAskResponse.fromJson(
          response.data as Map<String, dynamic>);
    }
    return const ContextualAskResponse(answer: 'No answer received.');
  }

  void dispose() {
    _recorder.dispose();
  }
}

class VoiceConversationState {
  final VoiceState state;
  final String? transcript;
  final ContextualAskResponse? response;
  final String? errorMessage;

  const VoiceConversationState({
    this.state = VoiceState.idle,
    this.transcript,
    this.response,
    this.errorMessage,
  });

  VoiceConversationState copyWith({
    VoiceState? state,
    String? transcript,
    ContextualAskResponse? response,
    String? errorMessage,
  }) {
    return VoiceConversationState(
      state: state ?? this.state,
      transcript: transcript ?? this.transcript,
      response: response ?? this.response,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class VoiceConversationNotifier
    extends StateNotifier<VoiceConversationState> {
  final SpeechService _speechService;
  String? _currentRecordingPath;

  VoiceConversationNotifier(this._speechService)
      : super(const VoiceConversationState());

  Future<void> startListening() async {
    final permitted = await _speechService.hasPermission();
    if (!permitted) {
      state = state.copyWith(
        state: VoiceState.error,
        errorMessage: 'Microphone permission denied.',
      );
      return;
    }

    _currentRecordingPath = await _speechService.startRecording();
    if (_currentRecordingPath != null) {
      state = state.copyWith(
        state: VoiceState.listening,
        errorMessage: null,
      );
    } else {
      state = state.copyWith(
        state: VoiceState.error,
        errorMessage: 'Failed to start microphone recording.',
      );
    }
  }

  Future<ContextualAskResponse?> stopAndAsk({String? topicId}) async {
    if (state.state != VoiceState.listening) return null;

    state = state.copyWith(state: VoiceState.transcribing);
    final path = await _speechService.stopRecording();
    final actualPath = path ?? _currentRecordingPath;

    if (actualPath == null) {
      state = state.copyWith(
        state: VoiceState.error,
        errorMessage: 'Audio capture was empty.',
      );
      return null;
    }

    try {
      state = state.copyWith(state: VoiceState.thinking);
      final askResult = await _speechService.askVoiceQuestion(
        actualPath,
        topicId: topicId,
      );

      state = state.copyWith(
        state: VoiceState.speaking,
        response: askResult,
      );

      // Transition to idle after a simulated speaking period or immediately
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && state.state == VoiceState.speaking) {
          state = state.copyWith(state: VoiceState.idle);
        }
      });

      return askResult;
    } catch (e) {
      state = state.copyWith(
        state: VoiceState.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const VoiceConversationState();
  }
}

final speechServiceProvider = Provider<SpeechService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SpeechService(apiClient);
});

final voiceConversationProvider = StateNotifierProvider<
    VoiceConversationNotifier, VoiceConversationState>((ref) {
  final speechService = ref.watch(speechServiceProvider);
  return VoiceConversationNotifier(speechService);
});
