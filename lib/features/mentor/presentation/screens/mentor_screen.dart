import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/mentor_provider.dart';
import '../../../../core/models/mentor_message.dart';
import '../../../../core/models/learning_path.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../journey/presentation/providers/learning_path_provider.dart';

class MentorScreen extends ConsumerStatefulWidget {
  const MentorScreen({super.key});

  @override
  ConsumerState<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends ConsumerState<MentorScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Attach listeners to voice service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final voiceService = ref.read(mentorVoiceServiceProvider);

      voiceService.onListeningChanged = (isListening) {
        if (mounted) {
          ref.read(mentorIsListeningProvider.notifier).state = isListening;
        }
      };

      voiceService.onSpeakingChanged = (speakingId) {
        if (mounted) {
          ref.read(mentorSpeakingMessageIdProvider.notifier).state = speakingId;
        }
      };

      voiceService.onError = (errorMsg) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Voice: $errorMsg'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      };
    });
  }

  @override
  void dispose() {
    final voiceService = ref.read(mentorVoiceServiceProvider);
    voiceService.stopListening();
    voiceService.stopSpeaking();
    _messageController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleListening() async {
    HapticFeedback.mediumImpact();
    final voiceService = ref.read(mentorVoiceServiceProvider);
    final isListening = ref.read(mentorIsListeningProvider);

    if (isListening) {
      await voiceService.stopListening();
      ref.read(mentorIsListeningProvider.notifier).state = false;
    } else {
      final started = await voiceService.startListening(
        onResult: (text, isFinal) {
          if (mounted) {
            setState(() {
              _messageController.text = text;
              _messageController.selection = TextSelection.fromPosition(
                TextPosition(offset: text.length),
              );
            });
            if (isFinal && text.trim().isNotEmpty) {
              final isVoiceMode = ref.read(mentorVoiceModeEnabledProvider);
              if (isVoiceMode) {
                _sendMessage(text.trim());
              }
            }
          }
        },
      );
      if (started) {
        ref.read(mentorIsListeningProvider.notifier).state = true;
      }
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    HapticFeedback.lightImpact();

    // Stop speaking if currently playing
    ref.read(mentorVoiceServiceProvider).stopSpeaking();

    ref.read(mentorProvider.notifier).sendMessage(text.trim());
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final mentorState = ref.watch(mentorProvider);
    final isVoiceMode = ref.watch(mentorVoiceModeEnabledProvider);
    final isListening = ref.watch(mentorIsListeningProvider);
    final speakingMessageId = ref.watch(mentorSpeakingMessageIdProvider);

    final pathAsync = ref.watch(activeLearningPathProvider);
    final goalAsync = ref.watch(activeGoalProvider);
    final authState = ref.watch(authProvider);

    final path = pathAsync.asData?.value;
    final goal = goalAsync.asData?.value;
    final userName = authState.user?.displayName.isNotEmpty == true
        ? authState.user!.displayName
        : 'Learner';

    LearningTopic? activeTopic;
    if (path != null && path.sections.isNotEmpty) {
      for (final sec in path.sections) {
        for (final top in sec.topics) {
          if (top.status == TopicStatus.learning ||
              top.status == TopicStatus.needsRevision) {
            activeTopic = top;
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
              break;
            }
          }
          if (activeTopic != null) break;
        }
      }
    }

    // Auto-scroll on new messages or typing state
    ref.listen(mentorProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length || next.isTyping) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Flexible(
                  child: Text(
                    'SkillTwin Mentor',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6D00).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AI PEDAGOGY',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6D00),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              activeTopic != null
                  ? 'Grounded in: ${activeTopic.title}'
                  : (goal != null
                      ? 'Grounded in: ${goal.title}'
                      : 'Rational Cognitive Guidance'),
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          // Voice Mode Toggle
          Tooltip(
            message: isVoiceMode
                ? 'Voice Mode ON (Auto-speak responses)'
                : 'Voice Mode OFF (Tap to speak)',
            child: IconButton(
              icon: Icon(
                isVoiceMode
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: isVoiceMode
                    ? const Color(0xFFFF6D00)
                    : const Color(0xFF9CA3AF),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                final newState = !isVoiceMode;
                ref.read(mentorVoiceModeEnabledProvider.notifier).state = newState;
                if (!newState) {
                  ref.read(mentorVoiceServiceProvider).stopSpeaking();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      newState
                          ? 'Voice Mode On: Mentor replies will be spoken aloud'
                          : 'Voice Mode Off: Muted speech output',
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6B7280)),
            tooltip: 'Refresh briefing',
            onPressed: () {
              ref.read(mentorProvider.notifier).loadInitialState();
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              Expanded(
                child: mentorState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF6D00),
                        ),
                      )
                    : mentorState.messages.isEmpty
                        ? _buildEmptyState(userName, goal?.title, activeTopic)
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            itemCount: mentorState.messages.length +
                                (mentorState.isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == mentorState.messages.length) {
                                return const _TypingIndicator();
                              }
                              final message = mentorState.messages[index];
                              return _MessageBubble(
                                message: message,
                                isSpeaking: speakingMessageId == message.id,
                                onSpeakPressed: () {
                                  final vService =
                                      ref.read(mentorVoiceServiceProvider);
                                  if (speakingMessageId == message.id) {
                                    vService.stopSpeaking();
                                  } else {
                                    vService.speak(
                                      message.text,
                                      messageId: message.id,
                                    );
                                  }
                                },
                              );
                            },
                          ),
              ),
              if (mentorState.error != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 14, color: Colors.red.shade800),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          mentorState.error!,
                          style: TextStyle(
                              color: Colors.red.shade800, fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(mentorProvider.notifier).clearError();
                        },
                        child: const Text('Dismiss',
                            style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              _buildQuickPrompts(activeTopic?.title),
              _buildInputArea(isListening),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    String userName,
    String? goalTitle,
    LearningTopic? activeTopic,
  ) {
    final topicName = activeTopic?.title ?? 'Foundational Primitives';
    final goalName = goalTitle ?? 'Your Learning Path';
    final mastery = activeTopic?.masteryScore.toInt() ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6D00), Color(0xFFFF9E80)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hello $userName 👋',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'I am your deliberate practice AI mentor. Grounded in cognitive science, '
            'I eliminate knowledge debt and keep your momentum high.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF6B7280),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.track_changes_rounded,
                        size: 16, color: Color(0xFFFF6D00)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        goalName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT SCHEDULED MILESTONE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF9CA3AF),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            topicName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$mastery% Mastery',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recommended Discussion Starters:',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildStarterCard(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Explain $topicName simply',
            subtitle: 'Unpack the core mental model and key invariants.',
            onTap: () => _sendMessage('Explain $topicName simply'),
          ),
          _buildStarterCard(
            icon: Icons.psychology_outlined,
            title: 'Why prioritize $topicName today?',
            subtitle: 'Understand prerequisite transfer and retention value.',
            onTap: () => _sendMessage('Why prioritize $topicName today?'),
          ),
          _buildStarterCard(
            icon: Icons.search_rounded,
            title: 'Identify my potential blindspots',
            subtitle: 'Scan common misconceptions and edge cases.',
            onTap: () => _sendMessage('What are common misconceptions in $topicName?'),
          ),
        ],
      ),
    );
  }

  Widget _buildStarterCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFFFF6D00), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPrompts(String? activeTopicTitle) {
    final topic = activeTopicTitle ?? 'active topic';
    final prompts = [
      'Explain $topic',
      'Why this concept now?',
      'Identify my blindspots',
      'Key test invariants',
    ];

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return ActionChip(
            label: Text(
              prompt,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            onPressed: () => _sendMessage(prompt),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(bool isListening) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, -3),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: isListening
                      ? 'Listening... Speak your question'
                      : 'Ask mentor, clarify a doubt, or tap mic...',
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    color: isListening
                        ? const Color(0xFFFF6D00)
                        : const Color(0xFF9CA3AF),
                    fontWeight:
                        isListening ? FontWeight.w600 : FontWeight.normal,
                  ),
                  filled: true,
                  fillColor: isListening
                      ? const Color(0xFFFF6D00).withValues(alpha: 0.06)
                      : const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: isListening
                        ? const BorderSide(color: Color(0xFFFF6D00), width: 1.5)
                        : BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: isListening
                        ? const BorderSide(color: Color(0xFFFF6D00), width: 1.5)
                        : BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                        color: Color(0xFFFF6D00), width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onSubmitted: (value) => _sendMessage(value),
              ),
            ),
            const SizedBox(width: 8),

            // Voice STT Microphone Button
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isListening
                          ? const Color(0xFFFF6D00)
                          : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                      boxShadow: isListening
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF6D00).withValues(
                                  alpha: 0.3 + 0.3 * _pulseController.value,
                                ),
                                blurRadius: 10 + 6 * _pulseController.value,
                                spreadRadius: 2 * _pulseController.value,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: isListening ? Colors.white : const Color(0xFF4B5563),
                      size: 22,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 6),

            // Send Button
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6D00),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => _sendMessage(_messageController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MentorMessage message;
  final bool isSpeaking;
  final VoidCallback onSpeakPressed;

  const _MessageBubble({
    required this.message,
    required this.isSpeaking,
    required this.onSpeakPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isMentor = message.sender == MessageSender.mentor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment:
            isMentor ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment:
                isMentor ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMentor) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6D00),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.smart_toy_rounded,
                        size: 19, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.82,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isMentor ? Colors.white : const Color(0xFFFF6D00),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMentor ? 4 : 18),
                      bottomRight: Radius.circular(isMentor ? 18 : 4),
                    ),
                    border: isMentor
                        ? Border.all(color: const Color(0xFFE5E7EB))
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                            alpha: isMentor ? 0.03 : 0.12),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMentor) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'AI Mentor',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF6D00),
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Speaker Audio Button
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                onSpeakPressed();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSpeaking
                                      ? const Color(0xFFFF6D00)
                                          .withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isSpeaking
                                      ? Icons.stop_circle_rounded
                                      : Icons.volume_up_outlined,
                                  size: 18,
                                  color: isSpeaking
                                      ? const Color(0xFFFF6D00)
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      isMentor
                          ? MarkdownBody(
                              data: message.text,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 14.5,
                                  height: 1.5,
                                ),
                                strong: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.w700,
                                ),
                                h1: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                h2: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.5,
                                ),
                                h3: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                ),
                                code: TextStyle(
                                  backgroundColor: Colors.grey.shade100,
                                  color: const Color(0xFFD84315),
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                                codeblockDecoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                blockquote: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontStyle: FontStyle.italic,
                                ),
                                listBullet: const TextStyle(
                                  color: Color(0xFFFF6D00),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Text(
                              message.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isMentor && message.warningMessage != null)
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 13, color: Colors.amber.shade900),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        message.warningMessage!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isMentor &&
              (message.actionType != null || message.whyContext != null))
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 10),
              child: _MentorActionCard(message: message),
            ),
        ],
      ),
    );
  }
}

class _MentorActionCard extends StatelessWidget {
  final MentorMessage message;

  const _MentorActionCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SkillTwinCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.conceptTitle != null) ...[
            Text(
              message.conceptTitle!.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF6D00),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (message.actionType != null)
            Row(
              children: [
                Icon(
                  _getActionIcon(message.actionType!),
                  size: 15,
                  color: const Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
                Text(
                  message.actionType!.name.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (message.whyContext != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _showWhyDialog(context, message.whyContext!),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Why?'),
                  ),
                ),
              if (message.whyContext != null && message.ctaText != null)
                const SizedBox(width: 10),
              if (message.ctaText != null)
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate or launch practice
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6D00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(message.ctaText!),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(MentorAction action) {
    switch (action) {
      case MentorAction.learn:
        return Icons.school_rounded;
      case MentorAction.revise:
        return Icons.history_rounded;
      case MentorAction.practice:
        return Icons.fitness_center_rounded;
      case MentorAction.prove:
        return Icons.verified_rounded;
      case MentorAction.teach:
        return Icons.record_voice_over_rounded;
      case MentorAction.remediate:
        return Icons.build_rounded;
      case MentorAction.skip:
        return Icons.fast_forward_rounded;
      case MentorAction.reflect:
        return Icons.self_improvement_rounded;
    }
  }

  void _showWhyDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology_rounded, color: Color(0xFFFF6D00)),
            SizedBox(width: 8),
            Text('Why this action?'),
          ],
        ),
        content: Text(
          reason,
          style: const TextStyle(fontSize: 14, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood',
                style: TextStyle(color: Color(0xFFFF6D00))),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFFF6D00),
            radius: 16,
            child: Icon(Icons.smart_toy_rounded, size: 18, color: Colors.white),
          ),
          SizedBox(width: 8),
          _AnimatedDots(),
        ],
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 2),
            blurRadius: 4,
          )
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6D00).withValues(
                    alpha: (index == 0 && _controller.value < 0.3) ||
                            (index == 1 &&
                                _controller.value >= 0.3 &&
                                _controller.value < 0.6) ||
                            (index == 2 && _controller.value >= 0.6)
                        ? 1.0
                        : 0.25,
                  ),
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
