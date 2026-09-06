import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/mentor_repository.dart';
import '../../data/repositories/mentor_repository_provider.dart';
import '../../../../core/models/mentor_message.dart';
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

final mentorProvider = StateNotifierProvider<MentorNotifier, MentorState>((ref) {
  final repository = ref.watch(mentorRepositoryProvider);
  return MentorNotifier(repository);
});

class MentorNotifier extends StateNotifier<MentorState> {
  final MentorRepository _repository;

  MentorNotifier(this._repository) : super(MentorState()) {
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

  Future<void> sendMessage(String text) async {
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

    try {
      final response = await _repository.sendMessage(text);
      state = state.copyWith(
        messages: [...state.messages, response],
        isTyping: false,
      );
    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        error: "Failed to send message. Please try again.",
      );
    }
  }

  Future<void> requestExplanation(String messageId) async {
    // Find the message to show we're loading an explanation if needed
    // For now, we'll just send a "Why?" as a user message or call the specific endpoint
    await sendMessage("Why?");
  }
}
