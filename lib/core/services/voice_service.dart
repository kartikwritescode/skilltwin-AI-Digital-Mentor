import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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

// ---------------------------------------------------------------------------
// Mentor Voice Service (Real-Time Speech-to-Text & Natural Text-to-Speech)
// ---------------------------------------------------------------------------

class MentorVoiceService {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  bool _isSttInitialized = false;
  bool _isTtsInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String? _currentlySpeakingId;

  Function(bool isListening)? onListeningChanged;
  Function(String? speakingId)? onSpeakingChanged;
  Function(String error)? onError;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String? get currentlySpeakingId => _currentlySpeakingId;

  MentorVoiceService() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        _isSpeaking = true;
        onSpeakingChanged?.call(_currentlySpeakingId);
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        _currentlySpeakingId = null;
        onSpeakingChanged?.call(null);
      });

      _tts.setCancelHandler(() {
        _isSpeaking = false;
        _currentlySpeakingId = null;
        onSpeakingChanged?.call(null);
      });

      _tts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        _isSpeaking = false;
        _currentlySpeakingId = null;
        onSpeakingChanged?.call(null);
      });

      _isTtsInitialized = true;
    } on MissingPluginException catch (_) {
      debugPrint('TTS native channel not registered yet (requires full app rebuild with flutter run).');
      _isTtsInitialized = false;
    } catch (e) {
      debugPrint('Failed to initialize TTS: $e');
      _isTtsInitialized = false;
    }
  }

  Future<bool> initStt() async {
    if (_isSttInitialized) return true;
    try {
      _isSttInitialized = await _stt.initialize(
        onError: (val) {
          debugPrint('STT error: ${val.errorMsg}');
          _isListening = false;
          onListeningChanged?.call(false);
          onError?.call(val.errorMsg);
        },
        onStatus: (status) {
          debugPrint('STT status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            onListeningChanged?.call(false);
          }
        },
      );
      return _isSttInitialized;
    } on MissingPluginException catch (_) {
      debugPrint('STT native channel not registered yet (requires full app rebuild).');
      _isSttInitialized = false;
      return false;
    } catch (e) {
      debugPrint('Error initializing STT: $e');
      return false;
    }
  }

  Future<bool> startListening({
    required Function(String text, bool isFinal) onResult,
    Function(double level)? onSoundLevel,
  }) async {
    if (_isSpeaking) {
      await stopSpeaking();
    }

    final ready = await initStt();
    if (!ready) {
      onError?.call('Microphone or Speech Recognition unavailable. Please restart app.');
      return false;
    }

    try {
      _isListening = true;
      onListeningChanged?.call(true);
      await _stt.listen(
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
        },
        onSoundLevelChange: onSoundLevel,
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 4),
          cancelOnError: true,
          partialResults: true,
        ),
      );
      return true;
    } on MissingPluginException catch (_) {
      debugPrint('STT native channel not registered yet.');
      _isListening = false;
      onListeningChanged?.call(false);
      onError?.call('Microphone service requires a full app restart.');
      return false;
    } catch (e) {
      debugPrint('Error in startListening: $e');
      _isListening = false;
      onListeningChanged?.call(false);
      return false;
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      try {
        await _stt.stop();
      } catch (_) {}
      _isListening = false;
      onListeningChanged?.call(false);
    }
  }

  Future<void> cancelListening() async {
    if (_isListening) {
      try {
        await _stt.cancel();
      } catch (_) {}
      _isListening = false;
      onListeningChanged?.call(false);
    }
  }

  Future<void> speak(String text, {String? messageId}) async {
    if (!_isTtsInitialized) {
      await _initTts();
    }
    await stopSpeaking();

    final cleanText = stripMarkdownForSpeech(text);
    if (cleanText.isEmpty) return;

    _currentlySpeakingId = messageId;
    _isSpeaking = true;
    onSpeakingChanged?.call(_currentlySpeakingId);

    try {
      await _tts.speak(cleanText);
    } on MissingPluginException catch (_) {
      debugPrint('TTS native channel not registered yet.');
      _isSpeaking = false;
      _currentlySpeakingId = null;
      onSpeakingChanged?.call(null);
    } catch (e) {
      debugPrint('Error in speak: $e');
      _isSpeaking = false;
      _currentlySpeakingId = null;
      onSpeakingChanged?.call(null);
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _isSpeaking = false;
    _currentlySpeakingId = null;
    onSpeakingChanged?.call(null);
  }

  static String stripMarkdownForSpeech(String markdown) {
    var text = markdown;
    // Replace code blocks
    text = text.replaceAll(RegExp(r'```[\s\S]*?```'), ' Code example omitted. ');
    // Replace inline code `code` with code
    text = text.replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m.group(1) ?? '');
    // Replace headers
    text = text.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    // Replace bold & italics
    text = text.replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), (m) => m.group(1) ?? '');
    text = text.replaceAllMapped(RegExp(r'\*([^*]+)\*'), (m) => m.group(1) ?? '');
    text = text.replaceAllMapped(RegExp(r'__([^_]+)__'), (m) => m.group(1) ?? '');
    text = text.replaceAllMapped(RegExp(r'_([^_]+)_'), (m) => m.group(1) ?? '');
    // Replace markdown links [text](url)
    text = text.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m.group(1) ?? '');
    // Replace blockquotes
    text = text.replaceAll(RegExp(r'^>\s+', multiLine: true), '');
    // Replace list markers
    text = text.replaceAll(RegExp(r'^[\s]*[-*+]\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '');
    // Strip HTML/XML tags
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    // Clean multiple newlines and spaces
    text = text.replaceAll(RegExp(r'\n+'), ' ');
    text = text.replaceAll(RegExp(r'\s{2,}'), ' ');
    return text.trim();
  }

  void dispose() {
    stopListening();
    stopSpeaking();
  }
}

final mentorVoiceServiceProvider = Provider<MentorVoiceService>((ref) {
  final service = MentorVoiceService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final mentorVoiceModeEnabledProvider = StateProvider<bool>((ref) => false);
final mentorSpeakingMessageIdProvider = StateProvider<String?>((ref) => null);
final mentorIsListeningProvider = StateProvider<bool>((ref) => false);
