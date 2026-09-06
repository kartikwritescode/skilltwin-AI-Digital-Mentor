import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/mentor_provider.dart';
import '../../../../core/models/mentor_message.dart';
import '../../../../core/widgets/skilltwin_card.dart';

class MentorScreen extends ConsumerStatefulWidget {
  const MentorScreen({super.key});

  @override
  ConsumerState<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends ConsumerState<MentorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final mentorState = ref.watch(mentorProvider);
    final notifier = ref.read(mentorProvider.notifier);

    // Auto-scroll when new messages arrive
    ref.listen(mentorProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length || next.isTyping) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Mentor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'WHY SHOULD I DO THIS? • Rational Cognitive Guidance',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF6D00),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Expanded(
                child: mentorState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: mentorState.messages.length + (mentorState.isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == mentorState.messages.length) {
                            return const _TypingIndicator();
                          }
                          final message = mentorState.messages[index];
                          return _MessageBubble(message: message);
                        },
                      ),
              ),
              if (mentorState.error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    mentorState.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              _buildQuickPrompts(notifier),
              _buildInputArea(notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPrompts(MentorNotifier notifier) {
    final prompts = [
      'Why this concept now?',
      'What is my biggest blindspot?',
      'Why 5-min revision?',
      'Analyze knowledge debt',
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 6),
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
              style: const TextStyle(fontSize: 12, color: Color(0xFF424242)),
            ),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () {
              HapticFeedback.lightImpact();
              notifier.sendMessage(prompt);
            },
          );
        },
      ),
    );
  }

  Widget _buildInputArea(MentorNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
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
                decoration: InputDecoration(
                  hintText: 'Ask why, clarify a doubt, or request next step...',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    HapticFeedback.lightImpact();
                    notifier.sendMessage(value.trim());
                    _messageController.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFF6D00),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
                onPressed: () {
                  final text = _messageController.text.trim();
                  if (text.isNotEmpty) {
                    HapticFeedback.lightImpact();
                    notifier.sendMessage(text);
                    _messageController.clear();
                  }
                },
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

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMentor = message.sender == MessageSender.mentor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isMentor ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: isMentor ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMentor) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6D00),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.assistant, size: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isMentor ? Colors.white : const Color(0xFFFF6D00),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMentor ? 4 : 18),
                      bottomRight: Radius.circular(isMentor ? 18 : 4),
                    ),
                    border: isMentor ? Border.all(color: Colors.black.withOpacity(0.06)) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isMentor ? 0.04 : 0.12),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: isMentor
                      ? MarkdownBody(
                          data: message.text,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              height: 1.45,
                            ),
                            strong: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            h1: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            h2: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            h3: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            code: TextStyle(
                              backgroundColor: Colors.grey.shade100,
                              color: const Color(0xFFD84315),
                              fontSize: 13.5,
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
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ),
          if (isMentor && message.warningMessage != null)
            Padding(
              padding: const EdgeInsets.only(left: 42, top: 6),
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
                    Icon(Icons.info_outline, size: 13, color: Colors.amber.shade900),
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
          if (isMentor && (message.actionType != null || message.whyContext != null))
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 12),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.conceptTitle != null) ...[
            Text(
              message.conceptTitle!.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (message.actionType != null)
            Row(
              children: [
                Icon(
                  _getActionIcon(message.actionType!),
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  message.actionType!.name.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (message.whyContext != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showWhyDialog(context, message.whyContext!);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Why?'),
                  ),
                ),
              if (message.whyContext != null && message.ctaText != null)
                const SizedBox(width: 12),
              if (message.ctaText != null)
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // Launch session logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      case MentorAction.learn: return Icons.school;
      case MentorAction.revise: return Icons.history;
      case MentorAction.practice: return Icons.fitness_center;
      case MentorAction.prove: return Icons.verified;
      case MentorAction.teach: return Icons.record_voice_over;
      case MentorAction.remediate: return Icons.build;
      case MentorAction.skip: return Icons.fast_forward;
      case MentorAction.reflect: return Icons.self_improvement;
    }
  }

  void _showWhyDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Why this action?'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange,
            radius: 16,
            child: Icon(Icons.assistant, size: 18, color: Colors.white),
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

class _AnimatedDotsState extends State<_AnimatedDots> with SingleTickerProviderStateMixin {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: Colors.grey.withOpacity(
                    (index == 0 && _controller.value < 0.3) ||
                    (index == 1 && _controller.value >= 0.3 && _controller.value < 0.6) ||
                    (index == 2 && _controller.value >= 0.6)
                        ? 1.0
                        : 0.3,
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
