import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../domain/repositories/revision_repository.dart';
import '../../data/repositories/revision_repository_provider.dart';

/// Represents a single message in the teachback conversation
class TeachbackMessage {
  final String role; // 'user' or 'ai'
  final String content;
  final DateTime timestamp;
  final String? feedbackType; // 'correct', 'partial', 'gap', 'misconception'
  final List<String>? suggestions; // Follow-up questions or areas to explore

  TeachbackMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.feedbackType,
    this.suggestions,
  });

  TeachbackMessage copyWith({
    String? role,
    String? content,
    DateTime? timestamp,
    String? feedbackType,
    List<String>? suggestions,
  }) {
    return TeachbackMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      feedbackType: feedbackType ?? this.feedbackType,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

/// State for the Feynman Teachback conversation
class TeachbackConversationState {
  final String? conceptId;
  final String? conceptTitle;
  final String? retrievalPrompt;
  final List<TeachbackMessage> messages;
  final bool isRecording;
  final bool isProcessing;
  final bool isAwaitingResponse;
  final String recordingDuration;
  final bool canComplete; // True when AI confirms mastery
  final bool isSessionComplete;
  final double finalMasteryScore;
  final String? nextReviewDate;
  final String? error;

  TeachbackConversationState({
    this.conceptId,
    this.conceptTitle,
    this.retrievalPrompt,
    this.messages = const [],
    this.isRecording = false,
    this.isProcessing = false,
    this.isAwaitingResponse = true,
    this.recordingDuration = '00:00',
    this.canComplete = false,
    this.isSessionComplete = false,
    this.finalMasteryScore = 0.0,
    this.nextReviewDate,
    this.error,
  });

  TeachbackConversationState copyWith({
    String? conceptId,
    String? conceptTitle,
    String? retrievalPrompt,
    List<TeachbackMessage>? messages,
    bool? isRecording,
    bool? isProcessing,
    bool? isAwaitingResponse,
    String? recordingDuration,
    bool? canComplete,
    bool? isSessionComplete,
    double? finalMasteryScore,
    String? nextReviewDate,
    String? error,
  }) {
    return TeachbackConversationState(
      conceptId: conceptId ?? this.conceptId,
      conceptTitle: conceptTitle ?? this.conceptTitle,
      retrievalPrompt: retrievalPrompt ?? this.retrievalPrompt,
      messages: messages ?? this.messages,
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      isAwaitingResponse: isAwaitingResponse ?? this.isAwaitingResponse,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      canComplete: canComplete ?? this.canComplete,
      isSessionComplete: isSessionComplete ?? this.isSessionComplete,
      finalMasteryScore: finalMasteryScore ?? this.finalMasteryScore,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      error: error ?? this.error,
    );
  }
}

final teachbackConversationProvider =
    StateNotifierProvider<TeachbackConversationNotifier,
        TeachbackConversationState>((ref) {
  final repository = ref.watch(revisionRepositoryProvider);
  return TeachbackConversationNotifier(repository);
});

class TeachbackConversationNotifier
    extends StateNotifier<TeachbackConversationState> {
  final RevisionRepository _repository;
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  bool _isSpeechInitialized = false;

  TeachbackConversationNotifier(this._repository)
      : super(TeachbackConversationState()) {
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void initSession({
    required String conceptId,
    required String conceptTitle,
    required String retrievalPrompt,
  }) {
    state = TeachbackConversationState(
      conceptId: conceptId,
      conceptTitle: conceptTitle,
      retrievalPrompt: retrievalPrompt,
      isAwaitingResponse: true,
    );
  }

  Future<void> startRecording() async {
    if (!_isSpeechInitialized) {
      _isSpeechInitialized = await _speechToText.initialize(
        onError: (error) => _handleSpeechError(error.errorMsg),
        onStatus: (status) => _handleSpeechStatus(status),
      );

      if (!_isSpeechInitialized) {
        state = state.copyWith(
          error: 'Voice recognition not available on this device.',
        );
        return;
      }
    }

    if (_isSpeechInitialized) {
      state = state.copyWith(isRecording: true, error: null);
      _recordingSeconds = 0;
      _startRecordingTimer();

      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _handleVoiceInput(result.recognizedWords);
          }
        },
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: true,
        partialResults: false,
      );
    }
  }

  Future<void> stopRecording() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    _stopRecordingTimer();
    state = state.copyWith(
      isRecording: false,
      recordingDuration: '00:00',
    );
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingSeconds++;
      final minutes = _recordingSeconds ~/ 60;
      final seconds = _recordingSeconds % 60;
      state = state.copyWith(
        recordingDuration:
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      );
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _recordingSeconds = 0;
  }

  void _handleSpeechError(String error) {
    state = state.copyWith(
      isRecording: false,
      error: 'Voice recognition error: $error',
    );
    _stopRecordingTimer();
  }

  void _handleSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      state = state.copyWith(isRecording: false);
      _stopRecordingTimer();
    }
  }

  void _handleVoiceInput(String text) {
    if (text.trim().isNotEmpty) {
      sendMessage(text, isVoice: true);
    }
  }

  Future<void> sendMessage(String content, {required bool isVoice}) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = TeachbackMessage(
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isProcessing: true,
      isAwaitingResponse: false,
      error: null,
    );

    try {
      // Call backend API for AI response
      final response = await _repository.getTeachbackFeedback(
        conceptId: state.conceptId!,
        userExplanation: content,
        conversationHistory: state.messages
            .map((m) => {'role': m.role, 'content': m.content})
            .toList(),
      );

      // Parse AI response
      final aiMessage = TeachbackMessage(
        role: 'ai',
        content: response['content'] as String? ?? 'Continue explaining...',
        timestamp: DateTime.now(),
        feedbackType: response['feedback_type'] as String?,
        suggestions: (response['suggestions'] as List?)?.cast<String>(),
      );

      // Speak AI response if voice mode is enabled
      if (isVoice && response['content'] != null) {
        await _speakResponse(response['content'] as String);
      }

      // Check if mastery is achieved
      final masteryAchieved = response['mastery_achieved'] as bool? ?? false;
      final masteryScore =
          (response['mastery_score'] as num?)?.toDouble() ?? 0.0;

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isProcessing: false,
        isAwaitingResponse: true,
        canComplete: masteryAchieved,
        finalMasteryScore: masteryScore,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        isAwaitingResponse: true,
        error: 'Failed to get AI response: ${e.toString()}',
      );
    }
  }

  Future<void> _speakResponse(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      // Silently fail if TTS is not available
    }
  }

  Future<void> completeSession() async {
    if (!state.canComplete) return;

    state = state.copyWith(isProcessing: true);

    try {
      // Submit final mastery assessment to backend
      final result = await _repository.submitTeachbackSession(
        conceptId: state.conceptId!,
        turnCount: state.messages.length ~/ 2,
        finalMasteryScore: state.finalMasteryScore,
        conversationHistory: state.messages
            .map((m) => {'role': m.role, 'content': m.content})
            .toList(),
      );

      state = state.copyWith(
        isSessionComplete: true,
        nextReviewDate: result['next_review_date'] as String?,
        finalMasteryScore:
            (result['final_mastery'] as num?)?.toDouble() ?? state.finalMasteryScore,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to complete session: ${e.toString()}',
      );
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}
