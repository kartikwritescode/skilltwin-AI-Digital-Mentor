import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/learning_path_provider.dart';
import '../../../../core/models/topic_detail.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/completion_celebration_dialog.dart';

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
  final Map<String, String> _userAnswers = {};
  QuestionSubmissionResponse? _submissionResult;
  ContextualAskResponse? _askResult;
  bool _isSubmitting = false;
  bool _isAsking = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _askController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topicAsync = ref.watch(topicDetailProvider(widget.topicId));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: topicAsync.maybeWhen(
          data: (t) => Text(t.title),
          orElse: () => const Text('Topic Details'),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF6D00),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFFFF6D00),
          indicatorWeight: 3,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Understand'),
            Tab(text: 'Revise'),
            Tab(text: 'Practice & Q&A'),
          ],
        ),
      ),
      body: topicAsync.when(
        data: (topic) => TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(topic),
            _buildUnderstandTab(topic),
            _buildReviseTab(topic),
            _buildQuestionsAndAskTab(topic),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6D00)),
          ),
        ),
        error: (err, _) => ErrorStateView(
          error: err.toString(),
          onRetry: () => ref.invalidate(topicDetailProvider(widget.topicId)),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Overview
  // ---------------------------------------------------------------------------
  Widget _buildOverviewTab(TopicDetailData topic) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                      color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(topic.masteryScore * 100).toInt()}% MASTERY',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Color(0xFFFF6D00),
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
              if (topic.description != null && topic.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  topic.description!,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _infoChip(Icons.trending_up, topic.difficulty.toUpperCase()),
                  const SizedBox(width: 10),
                  _infoChip(Icons.schedule, '${topic.estimatedMinutes} mins'),
                  const SizedBox(width: 10),
                  _infoChip(Icons.repeat, '${topic.revisionCount} revisions'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

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
                        backgroundColor: const Color(0xFFFF6D00),
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

        // Learning Objectives
        if (topic.learningObjectives.isNotEmpty) ...[
          SkillTwinCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LEARNING OBJECTIVES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                ...topic.learningObjectives.map((obj) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 16, color: Color(0xFFFF6D00)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              obj,
                              style: const TextStyle(
                                  fontSize: 13.5, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    )),
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
  // Tab 2: Understand (Explanation + TTS)
  // ---------------------------------------------------------------------------
  Widget _buildUnderstandTab(TopicDetailData topic) {
    final explanationAsync = ref.watch(topicExplanationProvider(topic.id));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      children: [
        explanationAsync.when(
          data: (exp) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Audio / Read Aloud Action Banner
              SkillTwinCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.record_voice_over,
                          color: Color(0xFFFF6D00), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Socratic Explanation',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            exp.cached
                                ? 'Retrieved from verified knowledge cache'
                                : 'Tailored to your current knowledge',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.grey),
                      tooltip: 'Refresh explanation',
                      onPressed: () =>
                          ref.invalidate(topicExplanationProvider(topic.id)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Markdown Content Card
              SkillTwinCard(
                padding: const EdgeInsets.all(20),
                child: MarkdownBody(
                  data: exp.content,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 14.5, height: 1.5),
                    h1: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121)),
                    h2: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121)),
                    h3: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121)),
                    code: TextStyle(
                      backgroundColor: Colors.grey.shade100,
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: const Color(0xFF263238),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              if (exp.sources.isNotEmpty) ...[
                const SizedBox(height: 16),
                SkillTwinCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GROUNDED KNOWLEDGE SOURCES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...exp.sources.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.library_books,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    s,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
          loading: () => const SingleChildScrollView(
            child: SkeletonCardGroup(count: 3, height: 140),
          ),
          error: (err, _) => ErrorStateView(
            error: err.toString(),
            onRetry: () => ref.invalidate(topicExplanationProvider(topic.id)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Revise (Spaced Retrieval)
  // ---------------------------------------------------------------------------
  Widget _buildReviseTab(TopicDetailData topic) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                  _tabController.animateTo(3);
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
  // Tab 4: Questions & Practice + Socratic Q&A
  // ---------------------------------------------------------------------------
  Widget _buildQuestionsAndAskTab(TopicDetailData topic) {
    final questionsAsync = ref.watch(topicQuestionsProvider(topic.id));
    final voiceState = ref.watch(voiceConversationProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      children: [
        // Ask Socratic Question / Voice Card
        SkillTwinCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.assistant, color: Color(0xFFFF6D00), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Ask Socratic Question',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const Spacer(),
                  // Voice Mic Button
                  IconButton(
                    icon: Icon(
                      voiceState.state == VoiceState.listening
                          ? Icons.mic
                          : Icons.mic_none,
                      color: voiceState.state == VoiceState.listening
                          ? Colors.red
                          : const Color(0xFFFF6D00),
                    ),
                    tooltip: voiceState.state.label,
                    onPressed: _handleVoiceMic,
                  ),
                ],
              ),
              if (voiceState.state != VoiceState.idle) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    voiceState.state.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: voiceState.state == VoiceState.error
                          ? Colors.red
                          : const Color(0xFFFF6D00),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _askController,
                      decoration: InputDecoration(
                        hintText: "Ask anything about this topic...",
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      onSubmitted: (_) => _handleTextAsk(topic.id),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6D00),
                    ),
                    icon: _isAsking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed:
                        _isAsking ? null : () => _handleTextAsk(topic.id),
                  ),
                ],
              ),
              if (_askResult != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6D00).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF6D00).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _askResult!.answer,
                        style: const TextStyle(
                            fontSize: 13.5, height: 1.4, color: Colors.black87),
                      ),
                      if (_askResult!.suggestedFollowups.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Suggested follow-ups:',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6D00)),
                        ),
                        ..._askResult!.suggestedFollowups.map((q) => InkWell(
                              onTap: () {
                                _askController.text = q;
                                _handleTextAsk(topic.id);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '• $q',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Practice Questions Suite
        const Text(
          'PRACTICE TEST SUITE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        questionsAsync.when(
          data: (questions) {
            if (questions.isEmpty) {
              return const SkillTwinCard(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No practice questions generated yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return Column(
              children: [
                ...questions.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final q = entry.value;
                  return _buildQuestionCard(idx + 1, q);
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => _handleSubmitQuiz(topic.id, questions),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6D00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Submit Practice Answers',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
                if (_submissionResult != null) ...[
                  const SizedBox(height: 20),
                  _buildSubmissionSummaryCard(_submissionResult!),
                ],
              ],
            );
          },
          loading: () => const SkeletonCardGroup(count: 3, height: 120),
          error: (err, _) => ErrorStateView(
            error: err.toString(),
            onRetry: () => ref.invalidate(topicQuestionsProvider(topic.id)),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildQuestionCard(int number, TopicQuestionItem q) {
    final selectedAnswer = _userAnswers[q.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: SkillTwinCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Q$number • ${q.questionType.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6D00),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  q.difficulty.toUpperCase(),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              q.prompt,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 12),
            if (q.options.isNotEmpty)
              ...q.options.map((opt) {
                final isChosen = selectedAnswer == opt;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _userAnswers[q.id] = opt;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isChosen
                          ? const Color(0xFFFF6D00).withValues(alpha: 0.08)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isChosen
                            ? const Color(0xFFFF6D00)
                            : Colors.grey.shade200,
                        width: isChosen ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isChosen
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 18,
                          color: isChosen
                              ? const Color(0xFFFF6D00)
                              : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isChosen
                                  ? const Color(0xFFFF6D00)
                                  : Colors.black87,
                              fontWeight: isChosen
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
            else
              TextField(
                onChanged: (val) {
                  _userAnswers[q.id] = val;
                },
                decoration: InputDecoration(
                  hintText: "Type your answer...",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionSummaryCard(QuestionSubmissionResponse result) {
    return SkillTwinCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.correctCount > 0
                    ? Icons.check_circle
                    : Icons.error_outline,
                color: result.correctCount > 0 ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score: ${result.correctCount} / ${result.totalCount} correct',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Mastery Delta: ${(result.masteryDelta * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: result.masteryDelta >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.overallFeedback,
            style: const TextStyle(fontSize: 13.5, height: 1.4),
          ),
        ],
      ),
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
                    '/journey/topics/${topicData!.nextTopicId}')
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

  Future<void> _handleSubmitQuiz(
      String topicId, List<TopicQuestionItem> questions) async {
    final answers = questions.map((q) {
      return AnswerSubmissionItem(
        questionId: q.id,
        userAnswer: _userAnswers[q.id] ?? '',
      );
    }).toList();

    setState(() => _isSubmitting = true);
    try {
      final notifier = ref.read(topicActionProvider.notifier);
      final res = await notifier.submitAnswers(topicId, answers);
      setState(() {
        _submissionResult = res;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting quiz: $e')),
        );
      }
    }
  }

  Future<void> _handleTextAsk(String topicId) async {
    final query = _askController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isAsking = true);
    try {
      final notifier = ref.read(topicActionProvider.notifier);
      final res = await notifier.askQuestion(topicId, query);
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
      final res = await voiceNotifier.stopAndAsk(topicId: widget.topicId);
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
}
