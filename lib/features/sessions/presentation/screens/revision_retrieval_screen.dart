import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_twin.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/skilltwin_markdown.dart';
import '../providers/revision_provider.dart';
import '../providers/teachback_conversation_provider.dart';
import '../../../../core/models/revision_item.dart';

/// Redesigned Revision/Retrieval Screen with Feynman Teachback Methodology
///
/// Flow:
/// 1. Present concept & retrieval challenge
/// 2. User explains to AI (voice or text) - Feynman style
/// 3. AI provides conversational feedback on:
///    - Correctness (what's right)
///    - Gaps (what's missing)
///    - Edge cases & deeper understanding
///    - Suggestions for improvement
/// 4. Multi-turn conversation until mastery confirmed
/// 5. Update retention schedule
class RevisionRetrievalScreen extends ConsumerStatefulWidget {
  final String conceptId;
  const RevisionRetrievalScreen({super.key, required this.conceptId});

  @override
  ConsumerState<RevisionRetrievalScreen> createState() =>
      _RevisionRetrievalScreenState();
}

class _RevisionRetrievalScreenState
    extends ConsumerState<RevisionRetrievalScreen>
    with SingleTickerProviderStateMixin {
  bool _isTextMode = false;
  late final TextEditingController _textController;
  late final ScrollController _scrollController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize teachback conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final revisionState = ref.read(revisionProvider);
      final item = _getRevisionItem(revisionState);
      ref.read(teachbackConversationProvider.notifier).initSession(
            conceptId: widget.conceptId,
            conceptTitle: item.title,
            retrievalPrompt: item.mentorPrompt,
          );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  RevisionItem _getRevisionItem(RevisionState revisionState) {
    return revisionState.dueItems.firstWhere(
      (i) =>
          i.conceptId.toLowerCase() == widget.conceptId.toLowerCase() ||
          i.id.toLowerCase() == widget.conceptId.toLowerCase(),
      orElse: () => RevisionItem(
        id: widget.conceptId,
        conceptId: widget.conceptId,
        title: widget.conceptId.replaceAll('_', ' ').toUpperCase(),
        mastery: 0.78,
        risk: RetentionRisk.high,
        lastRetrieval: DateTime.now().subtract(const Duration(days: 9)),
        dueDate: DateTime.now(),
        mentorNote:
            'Give me 4 minutes. I want to check whether the mental model is intact.',
        whyToday:
            'Memory decay threshold reached. Spaced retrieval anchors foundational invariants.',
        mentorPrompt:
            'Explain the core concept as if teaching it to someone new.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final revisionState = ref.watch(revisionProvider);
    final conversationState = ref.watch(teachbackConversationProvider);
    final item = _getRevisionItem(revisionState);

    // Handle pulse animation for recording state
    if (conversationState.isRecording) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    // Auto-scroll to bottom when new messages arrive
    if (conversationState.messages.isNotEmpty) {
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

    // Show completion screen if session is complete
    if (conversationState.isSessionComplete) {
      return _buildCompletionView(context, item, conversationState);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F111D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => _handleExit(context, conversationState),
        ),
        title: _buildStatusBadge(conversationState),
        centerTitle: true,
        actions: [
          if (!conversationState.isProcessing)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _isTextMode = !_isTextMode);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(
                  _isTextMode ? Icons.mic_rounded : Icons.keyboard_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
                label: Text(
                  _isTextMode ? 'VOICE' : 'TEXT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SkillTwinBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Concept Header Card
              _buildConceptHeader(item),

              // Conversation Area
              Expanded(
                child: conversationState.messages.isEmpty
                    ? _buildInitialPrompt(item, conversationState)
                    : _buildConversationView(conversationState),
              ),

              // Input Controls
              _buildInputControls(conversationState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TeachbackConversationState state) {
    String label;
    Color color;

    if (state.isRecording) {
      label = 'LISTENING';
      color = Colors.red.shade400;
    } else if (state.isProcessing) {
      label = 'ANALYZING';
      color = AppTheme.primaryAccent;
    } else if (state.isAwaitingResponse) {
      label = 'YOUR TURN';
      color = Colors.green.shade400;
    } else {
      label = 'READY';
      color = Colors.white70;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConceptHeader(RevisionItem item) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryAccent.withValues(alpha: 0.15),
            AppTheme.primaryAccent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryAccent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRiskColor(item.risk).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getRiskColor(item.risk).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  '${item.risk.name.toUpperCase()} RISK',
                  style: TextStyle(
                    color: _getRiskColor(item.risk),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology_rounded,
                        size: 14, color: Colors.white.withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Text(
                      'Mastery ${(item.mastery * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.whyToday,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialPrompt(
      RevisionItem item, TeachbackConversationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const SkillTwinTwin(
            asset: TwinAsset.focused,
            size: 80,
          ),
          const SizedBox(height: 24),
          SkillTwinCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        color: AppTheme.primaryAccent, size: 20),
                    const SizedBox(width: 10),
                    const Text(
                      'FEYNMAN TEACHBACK',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryAccent,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  item.mentorPrompt,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded,
                              color: AppTheme.primaryAccent, size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'What I\'ll check for:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildChecklistItem('Core concepts & definitions'),
                      _buildChecklistItem('Edge cases & limitations'),
                      _buildChecklistItem('Practical applications'),
                      _buildChecklistItem('Common misconceptions'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isTextMode
                ? 'Type your explanation below or switch to voice'
                : 'Tap the microphone to start explaining',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationView(TeachbackConversationState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: state.messages.length + (state.isProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.messages.length) {
          return _buildTypingIndicator();
        }

        final message = state.messages[index];
        final isUser = message.role == 'user';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                const SkillTwinTwin(asset: TwinAsset.focused, size: 32),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppTheme.primaryAccent.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUser
                          ? AppTheme.primaryAccent.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser && message.feedbackType != null)
                        _buildFeedbackBadge(message.feedbackType!),
                      if (isUser)
                        Text(
                          message.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.95),
                            height: 1.5,
                          ),
                        )
                      else
                        SkillTwinMarkdown(
                          data: message.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.95),
                            height: 1.5,
                          ),
                        ),
                      if (!isUser && message.suggestions != null) ...[
                        const SizedBox(height: 12),
                        _buildSuggestionsSection(message.suggestions!),
                      ],
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryAccent.withValues(alpha: 0.2),
                  child: Icon(Icons.person_rounded,
                      size: 18, color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedbackBadge(String feedbackType) {
    Color badgeColor;
    IconData icon;
    String label;

    switch (feedbackType.toLowerCase()) {
      case 'correct':
        badgeColor = Colors.green;
        icon = Icons.check_circle_outline;
        label = 'WELL EXPLAINED';
        break;
      case 'partial':
        badgeColor = Colors.orange;
        icon = Icons.info_outline;
        label = 'GOOD START - NEEDS MORE';
        break;
      case 'gap':
        badgeColor = Colors.blue;
        icon = Icons.school_outlined;
        label = 'IMPORTANT GAPS';
        break;
      case 'misconception':
        badgeColor = Colors.red;
        icon = Icons.warning_amber_rounded;
        label = 'MISCONCEPTION DETECTED';
        break;
      default:
        badgeColor = AppTheme.primaryAccent;
        icon = Icons.chat_bubble_outline;
        label = 'FEEDBACK';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: badgeColor,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(List<String> suggestions) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_outlined,
                  size: 14, color: AppTheme.primaryAccent),
              const SizedBox(width: 6),
              const Text(
                'Try explaining:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7))),
                    Expanded(
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const SkillTwinTwin(asset: TwinAsset.focused, size: 32),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final opacity = (value + index * 0.33) % 1.0;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3 + opacity * 0.4),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputControls(TeachbackConversationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isTextMode)
            _buildTextInputField(state)
          else
            _buildVoiceControls(state),
          if (state.canComplete) ...[
            const SizedBox(height: 12),
            _buildCompleteButton(state),
          ],
        ],
      ),
    );
  }

  Widget _buildTextInputField(TeachbackConversationState state) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Explain the concept...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              enabled: !state.isProcessing,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          onPressed: state.isProcessing ? null : () => _handleTextSubmit(state),
          backgroundColor: AppTheme.primaryAccent,
          elevation: 0,
          child: Icon(
            state.isProcessing ? Icons.hourglass_empty : Icons.send_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceControls(TeachbackConversationState state) {
    return Column(
      children: [
        // Voice visualizer
        if (state.isRecording) ...[
          _VoiceWaveVisualizer(isRecording: state.isRecording),
          const SizedBox(height: 16),
          Text(
            state.recordingDuration,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Record button
        GestureDetector(
          onTap: state.isProcessing ? null : () => _handleVoiceToggle(state),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: state.isRecording ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: state.isRecording
                          ? [Colors.red.shade600, Colors.red.shade400]
                          : [AppTheme.primaryAccent, Color(0xFF38BDF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (state.isRecording
                                ? Colors.red.shade600
                                : AppTheme.primaryAccent)
                            .withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    state.isRecording
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          state.isRecording ? 'Tap to stop' : 'Tap to explain',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton(TeachbackConversationState state) {
    return ElevatedButton.icon(
      onPressed: () => _handleComplete(state),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
      ),
      icon: const Icon(Icons.check_circle_rounded, size: 24),
      label: const Text(
        'MASTERY CONFIRMED - COMPLETE SESSION',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildCompletionView(BuildContext context, RevisionItem item,
      TeachbackConversationState conversationState) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111D),
      body: SkillTwinBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SkillTwinTwin(
                    asset: TwinAsset.celebrating,
                    size: 90,
                    bounce: true,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Mental Model Reinforced',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You\'ve demonstrated strong understanding of ${item.title}. Your retention curve has been updated.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Summary metrics
                  _buildMetricCard(
                    'Turns Taken',
                    '${conversationState.messages.length ~/ 2}',
                    Icons.chat_bubble_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    'New Mastery Score',
                    '${(conversationState.finalMasteryScore * 100).toInt()}%',
                    Icons.psychology_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    'Next Review',
                    conversationState.nextReviewDate ?? 'In 7 days',
                    Icons.event_available,
                  ),
                  const SizedBox(height: 48),

                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'RETURN TO QUEUE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(RetentionRisk risk) {
    switch (risk) {
      case RetentionRisk.high:
        return Colors.red.shade400;
      case RetentionRisk.medium:
        return Colors.orange.shade400;
      case RetentionRisk.low:
        return Colors.green.shade400;
    }
  }

  void _handleTextSubmit(TeachbackConversationState state) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref
        .read(teachbackConversationProvider.notifier)
        .sendMessage(text, isVoice: false);
    _textController.clear();
  }

  void _handleVoiceToggle(TeachbackConversationState state) {
    if (state.isRecording) {
      ref.read(teachbackConversationProvider.notifier).stopRecording();
    } else {
      ref.read(teachbackConversationProvider.notifier).startRecording();
    }
  }

  void _handleComplete(TeachbackConversationState state) {
    ref.read(teachbackConversationProvider.notifier).completeSession();
  }

  void _handleExit(
      BuildContext context, TeachbackConversationState state) async {
    if (state.messages.isEmpty) {
      context.pop();
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Session?'),
        content: const Text(
          'Your progress in this teachback session won\'t be saved. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CONTINUE'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('EXIT'),
          ),
        ],
      ),
    );

    if (shouldExit == true && context.mounted) {
      context.pop();
    }
  }
}

// Voice Wave Visualizer Widget
class _VoiceWaveVisualizer extends StatefulWidget {
  final bool isRecording;
  const _VoiceWaveVisualizer({required this.isRecording});

  @override
  State<_VoiceWaveVisualizer> createState() => _VoiceWaveVisualizerState();
}

class _VoiceWaveVisualizerState extends State<_VoiceWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRecording) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) {
              final height = 4.0 +
                  (24.0 * _controller.value * (1 - (index - 2).abs() / 3));
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 4,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
