import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/mentor_repository.dart';
import '../../data/repositories/mentor_repository_provider.dart';
import '../../../../core/models/mentor_message.dart';
import '../../../../core/models/learning_path.dart';
import '../../../../core/services/voice_service.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../journey/presentation/providers/learning_path_provider.dart';
import 'dart:async';

class MentorState {
  final List<MentorMessage> messages;
  final bool isLoading;
  final bool isTyping;
  final String? error;

  MentorState({
    this.messages = const [],
    this.isLoading = false,
    this.isTyping = false,
    this.error,
  });

  MentorState copyWith({
    List<MentorMessage>? messages,
    bool? isLoading,
    bool? isTyping,
    String? error,
  }) {
    return MentorState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      error: error,
    );
  }
}

final mentorProvider =
    StateNotifierProvider<MentorNotifier, MentorState>((ref) {
  final repository = ref.watch(mentorRepositoryProvider);
  return MentorNotifier(repository, ref);
});

class MentorNotifier extends StateNotifier<MentorState> {
  final MentorRepository _repository;
  final Ref _ref;

  MentorNotifier(this._repository, this._ref) : super(MentorState()) {
    loadInitialState();
  }

  Future<void> loadInitialState() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await _repository.getDailyMentorBriefing();
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String text, {Map<String, dynamic>? extraContext}) async {
    if (text.trim().isEmpty) return;

    final userMessage = MentorMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    // Optimistic update
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
      error: null,
    );

    // Build RAG context payload from active goal and learning path
    Map<String, dynamic> contextPayload = {};
    try {
      final path = _ref.read(activeLearningPathProvider).asData?.value;
      final goal = _ref.read(activeGoalProvider).asData?.value;

      LearningTopic? activeTopic;
      String? moduleTitle;

      if (path != null && path.sections.isNotEmpty) {
        for (final sec in path.sections) {
          for (final top in sec.topics) {
            if (top.status == TopicStatus.learning ||
                top.status == TopicStatus.needsRevision) {
              activeTopic = top;
              moduleTitle = sec.title;
              break;
            }
          }
          if (activeTopic != null) break;
        }

        if (activeTopic == null) {
          for (final sec in path.sections) {
            for (final top in sec.topics) {
              if (top.status != TopicStatus.completed) {
                activeTopic = top;
                moduleTitle = sec.title;
                break;
              }
            }
            if (activeTopic != null) break;
          }
        }
      }

      contextPayload = {
        if (goal?.title != null) 'goal_title': goal!.title,
        if (goal?.currentLevel != null) 'target_level': goal!.currentLevel,
        if (activeTopic?.title != null) 'current_topic': activeTopic!.title,
        if (moduleTitle != null) 'current_module': moduleTitle,
        if (activeTopic != null) 'mastery_score': activeTopic.masteryScore,
        if (activeTopic != null) 'key_concepts': activeTopic.keyConcepts,
        if (extraContext != null) ...extraContext,
      };
    } catch (_) {}

    try {
      final response = await _repository.sendMessage(text, context: contextPayload);
      state = state.copyWith(
        messages: [...state.messages, response],
        isTyping: false,
      );

      // Auto-speak if voice mode is enabled
      final isVoiceMode = _ref.read(mentorVoiceModeEnabledProvider);
      if (isVoiceMode && response.text.isNotEmpty) {
        _ref.read(mentorVoiceServiceProvider).speak(
              response.text,
              messageId: response.id,
            );
      }
    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        error: "Failed to send message. Please try again.",
      );
    }
  }

  Future<void> requestExplanation(String messageId) async {
    await sendMessage("Why is this action prioritized now?");
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
