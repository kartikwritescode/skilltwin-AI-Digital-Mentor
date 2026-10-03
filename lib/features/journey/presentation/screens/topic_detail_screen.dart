import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/learning_path_provider.dart';
import '../providers/practice_session_provider.dart';
import '../../../../core/models/topic_detail.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/completion_celebration_dialog.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/mastery_format.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/topic_understand_content_view.dart';
import '../widgets/practice/practice_interactive_view.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';
import '../../../../core/widgets/skilltwin_transition_switcher.dart';
import '../../../../core/widgets/skilltwin_refresh_indicator.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../../../../core/widgets/skilltwin_markdown.dart';

class TopicDetailScreen extends ConsumerStatefulWidget {
  final String topicId;

  const TopicDetailScreen({super.key, required this.topicId});

  @override
  ConsumerState<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends ConsumerState<TopicDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _askController = TextEditingController();
  final FocusNode _askFocusNode = FocusNode();
  ContextualAskResponse? _askResult;
  bool _isAsking = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _askFocusNode.addListener(_onAskStateChanged);
    _askController.addListener(_onAskStateChanged);
  }

  void _onAskStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _askFocusNode.removeListener(_onAskStateChanged);
    _askController.removeListener(_onAskStateChanged);
    _askFocusNode.dispose();
    _askController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topicAsync = ref.watch(topicDetailProvider(widget.topicId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: topicAsync.maybeWhen(
          data: (t) => Text(
            t.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          orElse: () => const Text('Topic Details'),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryAccent,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryAccent,
          indicatorWeight: 3,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Understand'),
            Tab(text: 'Practice & Q&A'),
            Tab(text: 'Revise'),
            Tab(text: 'Resources'),
          ],
        ),
      ),
      body: SkillTwinBackground(
        child: SkillTwinRefreshIndicator(
        message: 'SkillTwin is updating topic knowledge...',
        onRefresh: () async {
          ref.invalidate(topicDetailProvider(widget.topicId));
          ref.invalidate(topicExplanationProvider(widget.topicId));
        },
        child: SkillTwinTransitionSwitcher(
          child: topicAsync.when(
            data: (topic) => TabBarView(
              key: const ValueKey('topic_tab_content'),
              controller: _tabController,
              children: [
                _buildUnderstandTab(topic),
                _buildQuestionsAndAskTab(topic),
                _buildReviseTab(topic),
                _buildResourcesTab(topic),
              ],
            ),
            loading: () => const SkillTwinLoadingView.fullScreen(
              key: ValueKey('topic_loading'),
              message: 'SkillTwin is preparing your next step.',
              subMessage: 'Synthesizing concepts, intuition & deliberate practice...',
            ),
            error: (err, _) => KeyedSubtree(
              key: const ValueKey('topic_error'),
              child: ErrorStateView(
                error: err.toString(),
                onRetry: () => ref.invalidate(topicDetailProvider(widget.topicId)),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  // ---------------------------------------------------------------------------
  // Tab 4: Resources (Curriculum Video & Grounded Sources)
  // ---------------------------------------------------------------------------
  Widget _buildResourcesTab(TopicDetailData topic) {
    final bottomInset = AppSpacing.calculateBottomNavInset(context);
    final hMargin = AppSpacing.responsiveHorizontalPadding(context);
    final ytUrl = topic.youtubeUrl ??
        (topic.youtubeVideoId != null && topic.youtubeVideoId!.isNotEmpty
            ? 'https://www.youtube.com/watch?v=${topic.youtubeVideoId}'
            : null);
    final hasValidVideo = ytUrl != null && ytUrl.isNotEmpty;

    return ListView(
      padding: EdgeInsets.fromLTRB(hMargin, 16.0, hMargin, bottomInset),
      children: [
        // Status and Mastery Header Card
        SkillTwinCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusBadge(topic.status),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${topic.masteryScore.toMasteryPercentage}% MASTERY',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppTheme.primaryAccent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                topic.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _infoChip(Icons.trending_up, topic.difficulty.toUpperCase()),
                  _infoChip(Icons.repeat, '${topic.revisionCount} revisions'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (hasValidVideo) ...[
          SkillTwinCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      if (topic.thumbnailUrl != null && topic.thumbnailUrl!.isNotEmpty)
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            topic.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF0F172A),
                              child: const Center(
                                child: Icon(Icons.play_circle_outline, size: 60, color: Colors.white54),
                              ),
                            ),
                          ),
                        )
                      else
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            color: const Color(0xFF0F172A),
                            child: const Center(
                              child: Icon(Icons.play_circle_outline, size: 60, color: Colors.white54),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.playlist_play, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                topic.metadata['source_type'] == 'youtube_playlist'
                                    ? 'Video #${(topic.position ?? 0) + 1}'
                                    : 'Recommended Video',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (topic.durationSeconds > 0)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _formatVideoDuration(topic.durationSeconds),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.smart_display, color: Color(0xFFFF0000), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                topic.channelName != null
                                    ? 'Creator: ${topic.channelName}'
                                    : 'Recommended Video Resource',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse(ytUrl!);
                              try {
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  await Clipboard.setData(ClipboardData(text: ytUrl!));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Video URL copied to clipboard')),
                                    );
                                  }
                                }
                              } catch (_) {
                                await Clipboard.setData(ClipboardData(text: ytUrl!));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Video URL copied to clipboard')),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text(
                              'Watch on YouTube',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0000),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ] else ...[
          SkillTwinCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Color(0xFF6366F1), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Self-Contained Topic',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Everything you need is organized in the Understand and Practice tabs. External videos are optional.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Action Buttons: Start, Complete, Needs Revision
        SkillTwinCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOPIC ACTIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: topic.status == 'learning'
                          ? null
                          : () => _handleStatusAction('start'),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: Text(topic.status == 'learning'
                          ? 'In Progress'
                          : 'Start Topic'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleStatusAction('complete'),
                      icon: const Icon(Icons.check, size: 16, color: Colors.green),
                      label: const Text(
                        'Complete',
                        style: TextStyle(color: Colors.green),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _handleStatusAction('revision'),
                  icon: Icon(Icons.history_edu,
                      size: 16, color: Colors.amber.shade800),
                  label: Text(
                    'Mark for Spaced Revision',
                    style: TextStyle(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.amber.shade50,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Learning Objectives - Enhanced with better structure
        if (topic.learningObjectives.isNotEmpty) ...[
          SkillTwinCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.flag_rounded,
                        size: 18,
                        color: Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'LEARNING OBJECTIVES',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'What you\'ll master in this topic:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 12),
                ...topic.learningObjectives.asMap().entries.map((entry) {
                  final index = entry.key;
                  final obj = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            obj,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Prerequisites
        if (topic.prerequisites.isNotEmpty) ...[
          SkillTwinCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PREREQUISITES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: topic.prerequisites
                      .map((p) => Chip(
                            label: Text(p, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.grey.shade100,
                            side: BorderSide.none,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Understand (Redesigned with Mascot & Digestible Hierarchy)
  // ---------------------------------------------------------------------------
  Widget _buildUnderstandTab(TopicDetailData topic) {
    final explanationAsync = ref.watch(topicExplanationProvider(topic.id));

    return SkillTwinTransitionSwitcher(
      child: explanationAsync.when(
        data: (exp) => KeyedSubtree(
          key: const ValueKey('understand_content'),
          child: TopicUnderstandContentView(
            topic: topic,
            explanation: exp,
            onUnderstandCompleted: () => _handleUnderstandCompleted(topic),
            onRefreshExplanation: () =>
                ref.invalidate(topicExplanationProvider(topic.id)),
          ),
        ),
        loading: () => const SkillTwinLoadingView(
          key: ValueKey('understand_loading'),
          message: 'SkillTwin is preparing your next step.',
          subMessage: 'Your Twin is organizing intuition, examples, and key rules...',
        ),
        error: (err, _) => KeyedSubtree(
          key: const ValueKey('understand_error'),
          child: ErrorStateView(
            error: err.toString(),
            onRetry: () => ref.invalidate(topicExplanationProvider(topic.id)),
          ),
        ),
      ),
    );
  }

  Future<void> _handleUnderstandCompleted(TopicDetailData topic) async {
    HapticFeedback.lightImpact();
    // Persist topic start in background if not already started
    if (topic.status == 'not_started') {
      ref.read(topicActionProvider.notifier).startTopic(topic.id);
    }
    // Transition smoothly to Practice & Q&A tab (index 1)
    _tabController.animateTo(1);
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Revise (Spaced Retrieval)
  // ---------------------------------------------------------------------------
  Widget _buildReviseTab(TopicDetailData topic) {
    final bottomInset = AppSpacing.calculateBottomNavInset(context);
    final hMargin = AppSpacing.responsiveHorizontalPadding(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(hMargin, 16.0, hMargin, bottomInset),
      children: [
        SkillTwinCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.history_edu,
                        color: Colors.amber.shade800, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Recall & Retention',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          'Revision Count: ${topic.revisionCount}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (topic.nextRevisionAt != null) ...[
                Text(
                  'Next scheduled revision: ${topic.nextRevisionAt!.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
              ],
              const Text(
                'To cement this concept in long-term memory, summarize what you learned without looking at your notes, or attempt a quick practice quiz in the Practice tab.',
                style: TextStyle(
                    fontSize: 13.5, height: 1.45, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6D00),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.quiz, size: 16),
                label: const Text('Start Active Recall Quiz'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Practice & Assessment + Ask Questions Companion
  // ---------------------------------------------------------------------------
  Widget _buildQuestionsAndAskTab(TopicDetailData topic) {
    return PracticeInteractiveView(
      topicId: topic.id,
      askQuestionsSection: _buildAskQuestionsSection(topic),
      onContinueLearning: topic.nextTopicId != null
          ? () => context.push('/topics/${topic.nextTopicId}')
          : null,
    );
  }


  Widget _buildQuickPromptChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E7FF)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: const Color(0xFF6366F1)),
              const SizedBox(width: 4.5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4338CA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAskQuestionsSection(TopicDetailData topic) {
    final voiceState = ref.watch(voiceConversationProvider);
    final sessionState = ref.watch(practiceSessionProvider(topic.id));
    final activeQuestion = sessionState.currentQuestion;
    final isFocused = _askFocusNode.hasFocus;
    final hasText = _askController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (voiceState.state != VoiceState.idle) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: voiceState.state == VoiceState.error
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: voiceState.state == VoiceState.error
                      ? const Color(0xFFFECACA)
                      : const Color(0xFFC7D2FE),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        voiceState.state == VoiceState.error
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    voiceState.state.label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: voiceState.state == VoiceState.error
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF4338CA),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        // Active Question Context Pill (shows current question being targeted)
        if (activeQuestion != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.help_outline_rounded,
                      size: 13, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Focusing on Question ${sessionState.currentIndex + 1} of ${sessionState.totalQuestions}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4338CA),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (sessionState.currentSelectedAnswer != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFA5B4FC)),
                      ),
                      child: Text(
                        'Selected: ${sessionState.currentSelectedAnswer}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        // Clean, direct TextField row without inner container
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _askController,
                focusNode: _askFocusNode,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                  height: 1.35,
                ),
                decoration: InputDecoration(
                  hintText: activeQuestion != null
                      ? 'Ask anything about Question ${sessionState.currentIndex + 1}...'
                      : 'Ask anything about this concept...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: isFocused ? Colors.white : const Color(0xFFF8FAFC),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  prefixIcon: Icon(
                    Icons.auto_awesome_rounded,
                    color: isFocused
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF94A3B8),
                    size: 17,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  suffixIcon: hasText
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          tooltip: 'Clear',
                          splashRadius: 16,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: () => _askController.clear(),
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6366F1),
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (_) => _handleTextAsk(topic.id),
              ),
            ),
            const SizedBox(width: 8),
            // Voice Mic Button
            Tooltip(
              message: voiceState.state.label,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleVoiceMic,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: voiceState.state == VoiceState.listening
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: voiceState.state == VoiceState.listening
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Icon(
                      voiceState.state == VoiceState.listening
                          ? Icons.mic_rounded
                          : Icons.mic_none_rounded,
                      color: voiceState.state == VoiceState.listening
                          ? Colors.red
                          : (isFocused
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF64748B)),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Send Action Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isAsking || !hasText
                    ? null
                    : () => _handleTextAsk(topic.id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: hasText && !_isAsking
                        ? const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: hasText && !_isAsking
                        ? null
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasText && !_isAsking
                          ? Colors.transparent
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: hasText && !_isAsking
                        ? [
                            BoxShadow(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: _isAsking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            Icons.arrow_upward_rounded,
                            color: hasText
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                            size: 18,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Smart quick prompt chips to ask with 1-tap without typing
        if (_askResult == null && !_isAsking) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildQuickPromptChip(
                  icon: Icons.lightbulb_outline_rounded,
                  label: activeQuestion != null
                      ? 'Hint for Q${sessionState.currentIndex + 1}'
                      : 'Give me a hint',
                  onTap: () {
                    _askController.text = activeQuestion != null
                        ? 'Can you give me a subtle hint to solve Question ${sessionState.currentIndex + 1} without giving away the full answer?'
                        : 'Can you give me a subtle hint to solve this?';
                    _handleTextAsk(topic.id);
                  },
                ),
                const SizedBox(width: 6),
                _buildQuickPromptChip(
                  icon: Icons.auto_stories_outlined,
                  label: 'Explain concept simply',
                  onTap: () {
                    _askController.text =
                        'Explain this concept in simple, intuitive terms.';
                    _handleTextAsk(topic.id);
                  },
                ),
                const SizedBox(width: 6),
                _buildQuickPromptChip(
                  icon: Icons.psychology_outlined,
                  label: activeQuestion != null
                      ? 'Why is this option correct?'
                      : 'Why is this used?',
                  onTap: () {
                    _askController.text = activeQuestion != null
                        ? 'Why is the correct answer correct for this question, and where might learners get confused?'
                        : 'Why do we use this approach and what is the intuition?';
                    _handleTextAsk(topic.id);
                  },
                ),
              ],
            ),
          ),
        ],
        if (_askResult != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0E7FF)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.04),
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
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          size: 13, color: Color(0xFF6366F1)),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'Your Twin',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4338CA),
                        letterSpacing: -0.1,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => setState(() => _askResult = null),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close_rounded,
                                size: 14, color: Color(0xFF94A3B8)),
                            SizedBox(width: 2),
                            Text(
                              'Dismiss',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SkillTwinMarkdown(
                  data: _askResult!.answer,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (_askResult!.suggestedFollowups.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Try asking:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _askResult!.suggestedFollowups.map((q) {
                      return InkWell(
                        onTap: () {
                          _askController.text = q;
                          _handleTextAsk(topic.id);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.help_outline_rounded,
                                  size: 11, color: Color(0xFF6366F1)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  q,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF334155),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Action Handlers
  // ---------------------------------------------------------------------------
  Future<void> _handleStatusAction(String action) async {
    HapticFeedback.lightImpact();
    final notifier = ref.read(topicActionProvider.notifier);

    if (action == 'complete') {
      final pathState = ref.read(activeLearningPathProvider).asData?.value;
      final topicData = ref.read(topicDetailProvider(widget.topicId)).asData?.value;

      final total = pathState?.totalTopics ?? 1;
      // Optimistically +1 since this topic is now completed
      final completed = (pathState?.completedTopics ?? 0) +
          (topicData?.status == 'completed' ? 0 : 1);
      final isAllCompleted = pathState != null && completed >= total;

      // Show immediate celebration dialog
      if (mounted) {
        if (isAllCompleted) {
          CourseCompletionDialog.show(
            context,
            courseTitle: pathState.title,
            totalTopics: total,
            onExploreNext: () => context.push('/onboarding'),
          );
        } else {
          TopicCelebrationDialog.show(
            context,
            topicTitle: topicData?.title ?? 'Topic',
            totalCompleted: completed,
            totalTopics: total,
            hasNextTopic: topicData?.nextTopicId != null,
            onContinueNext: topicData?.nextTopicId != null
                ? () => context.pushReplacement(
                    '/journey/topic/${topicData!.nextTopicId}')
                : null,
          );
        }
      }

      await notifier.completeTopic(widget.topicId);
    } else if (action == 'start') {
      final res = await notifier.startTopic(widget.topicId);
      if (mounted && res != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Topic started! Dive into the concepts below.'),
            backgroundColor: Color(0xFFFF6D00),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else if (action == 'revision') {
      final res = await notifier.markNeedsRevision(widget.topicId);
      if (mounted && res != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Marked for spaced revision. Cognitive twin scheduled review.'),
            backgroundColor: Colors.amber.shade800,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleTextAsk(String topicId) async {
    final query = _askController.text.trim();
    if (query.isEmpty) return;

    final sessionState = ref.read(practiceSessionProvider(topicId));
    final currentQ = sessionState.currentQuestion;
    final selectedAns = sessionState.currentSelectedAnswer;

    setState(() => _isAsking = true);
    try {
      final notifier = ref.read(topicActionProvider.notifier);
      final res = await notifier.askQuestion(
        topicId,
        query,
        currentQuestion: currentQ,
        selectedAnswer: selectedAns,
      );
      setState(() {
        _askResult = res;
        _isAsking = false;
      });
    } catch (e) {
      setState(() => _isAsking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error asking question: $e')),
        );
      }
    }
  }

  Future<void> _handleVoiceMic() async {
    final voiceNotifier = ref.read(voiceConversationProvider.notifier);
    final voiceState = ref.read(voiceConversationProvider);

    if (voiceState.state == VoiceState.listening) {
      final sessionState = ref.read(practiceSessionProvider(widget.topicId));
      final currentQ = sessionState.currentQuestion;
      final selectedAns = sessionState.currentSelectedAnswer;

      final res = await voiceNotifier.stopAndAsk(
        topicId: widget.topicId,
        currentQuestion: currentQ,
        selectedAnswer: selectedAns,
      );
      if (res != null) {
        setState(() => _askResult = res);
      }
    } else {
      await voiceNotifier.startListening();
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        label = 'COMPLETED';
        break;
      case 'learning':
        bg = const Color(0xFFFF6D00).withValues(alpha: 0.12);
        fg = const Color(0xFFFF6D00);
        label = 'IN PROGRESS';
        break;
      case 'needs_revision':
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade800;
        label = 'NEEDS REVISION';
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
        label = 'NOT STARTED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 10.5,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  String _formatVideoDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final remM = m % 60;
      return '${h}h ${remM}m';
    }
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}
