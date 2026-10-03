import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/topic_detail.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/skilltwin_markdown.dart';
import 'topic_learn_mascot_header.dart';

/// Redesigned Understand / Learn topic content view.
/// Prioritizes clarity, focus, digestible hierarchy, and a friendly guided experience.
class TopicUnderstandContentView extends StatefulWidget {
  final TopicDetailData topic;
  final TopicExplanationData explanation;
  final VoidCallback onUnderstandCompleted;
  final VoidCallback onRefreshExplanation;

  const TopicUnderstandContentView({
    super.key,
    required this.topic,
    required this.explanation,
    required this.onUnderstandCompleted,
    required this.onRefreshExplanation,
  });

  @override
  State<TopicUnderstandContentView> createState() => _TopicUnderstandContentViewState();
}

class _TopicUnderstandContentViewState extends State<TopicUnderstandContentView> {
  TopicDetailData get topic => widget.topic;
  TopicExplanationData get explanation => widget.explanation;
  VoidCallback get onUnderstandCompleted => widget.onUnderstandCompleted;
  VoidCallback get onRefreshExplanation => widget.onRefreshExplanation;

  @override
  Widget build(BuildContext context) {
    // Dynamic bottom inset calculated from:
    // MediaQuery.safeArea + floating navigation height (84.0) + breathing space (20.0)
    final bottomInset = AppSpacing.calculateBottomNavInset(context);
    // Responsive horizontal padding (16-24px depending on screen width)
    final hMargin = AppSpacing.responsiveHorizontalPadding(context);

    final ytUrl = widget.topic.youtubeUrl ??
        (widget.topic.youtubeVideoId != null && widget.topic.youtubeVideoId!.trim().isNotEmpty
            ? 'https://www.youtube.com/watch?v=${widget.topic.youtubeVideoId}'
            : null);
    final hasValidVideo = ytUrl != null && ytUrl.trim().isNotEmpty;

    return ListView(
      key: PageStorageKey<String>('topic_understand_scroll_${widget.topic.id}'),
      padding: EdgeInsets.fromLTRB(hMargin, 16.0, hMargin, bottomInset),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. What am I learning? (Mascot Companion Header) ──
                TopicLearnMascotHeader(
                  topicTitle: widget.topic.title,
                  difficulty: widget.topic.difficulty,
                  estimatedMinutes: widget.topic.estimatedMinutes,
                  masteryScore: widget.topic.masteryScore,
                  status: widget.topic.status,
                ),

                const SizedBox(height: 6),



                if (widget.topic.learningObjectives.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildLearningObjectivesCard(widget.topic.learningObjectives),
                ],

                const SizedBox(height: 16),
                _buildIntuitionCard(),

                const SizedBox(height: 16),
                _buildExplanationSection(),

                const SizedBox(height: 16),
                _buildPitfallCard(),

                // ── 4. Optional: What resource can help me? (Recommended Video) ──
                if (hasValidVideo) ...[
                  const SizedBox(height: 20),
                  _buildIntegratedVideoSection(context),
                ],

                const SizedBox(height: 16),
                _buildKeyTakeawaysBox(),

                if (widget.explanation.sources.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSourcesCard(widget.explanation.sources),
                ],

                const SizedBox(height: 20),
                // ── 7. Practice Action (Safe-area-aware completion button) ──
                _buildCompletionCard(),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Video Duration Formatter & Helper
  // ---------------------------------------------------------------------------
  String _formatVideoDuration(int seconds) {
    if (seconds <= 0) return '';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final remM = m % 60;
      return '${h}h ${remM}m';
    }
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  Widget _buildVideoFallbackCanvas() {
    return Container(
      color: const Color(0xFF0F172A),
      child: const Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          size: 64,
          color: Colors.white54,
        ),
      ),
    );
  }

  Future<void> _launchVideo(BuildContext context, String? ytUrl) async {
    HapticFeedback.lightImpact();
    if (ytUrl == null || ytUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video link is currently unavailable')),
      );
      return;
    }
    final uri = Uri.parse(ytUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: ytUrl));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video URL copied to clipboard')),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: ytUrl));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video URL copied to clipboard')),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Integrated 16:9 Video Section (Avoids heavy card containers)
  // ---------------------------------------------------------------------------
  Widget _buildIntegratedVideoSection(BuildContext context) {
    final hasThumbnail =
        topic.thumbnailUrl != null && topic.thumbnailUrl!.trim().isNotEmpty;
    final ytUrl = topic.youtubeUrl ??
        (topic.youtubeVideoId != null
            ? 'https://www.youtube.com/watch?v=${topic.youtubeVideoId}'
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: const [
              Icon(Icons.video_library_rounded, size: 15, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'RECOMMENDED RESOURCE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Video Preview Frame (Guaranteed 16:9 Aspect Ratio, Never Stretched) ──
          GestureDetector(
            onTap: () => _launchVideo(context, ytUrl),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasThumbnail)
                    Image.network(
                      topic.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildVideoFallbackCanvas(),
                    )
                  else
                    _buildVideoFallbackCanvas(),

                  // Scrim overlay for comfortable text/icon contrast
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.60),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),

                  // Top-Left: Playlist Position Badge
                  if (topic.position != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.playlist_play_rounded,
                                color: Colors.white, size: 15),
                            const SizedBox(width: 4),
                            Text(
                              'Video #${(topic.position ?? 0) + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Bottom-Right: Duration Badge
                  if (topic.durationSeconds > 0)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatVideoDuration(topic.durationSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Center: High-Contrast Play Button
                  Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000).withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Clean Integrated Info & Action Strip ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0000).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.smart_display_rounded,
                    color: Color(0xFFFF0000),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.channelName != null
                            ? topic.channelName!
                            : 'Recommended Video Resource',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        topic.durationSeconds > 0
                            ? '${_formatVideoDuration(topic.durationSeconds)} • Watch if helpful'
                            : 'Recommended video resource • Watch if helpful',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _launchVideo(context, ytUrl),
                  icon: const Icon(Icons.open_in_new_rounded, size: 14),
                  label: const Text(
                    'Watch',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFF0000).withValues(alpha: 0.08),
                    foregroundColor: const Color(0xFFCC0000),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Learning Objectives
  // ---------------------------------------------------------------------------
  Widget _buildLearningObjectivesCard(List<String> objectives) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.20),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  size: 16,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'LEARNING OBJECTIVES',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...objectives.map(
            (obj) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      obj,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }







  // ---------------------------------------------------------------------------
  // 3. Intuition Callout Card
  // ---------------------------------------------------------------------------
  Widget _buildIntuitionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryAccent.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  size: 16,
                  color: AppTheme.primaryAccent,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Think of it this way...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Mastering ${widget.topic.title} builds the mental scaffolding for real-world application.',
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Topic Explanation Markdown Section
  // ---------------------------------------------------------------------------
  Widget _buildExplanationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_stories_rounded,
                      size: 16, color: AppTheme.primaryAccent),
                  SizedBox(width: 8),
                  Text(
                    'CONCEPT GUIDE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppTheme.primaryAccent,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                tooltip: 'Regenerate explanation',
                onPressed: widget.onRefreshExplanation,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SkillTwinMarkdown(
            data: widget.explanation.content,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.6,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Pitfall Callout Card
  // ---------------------------------------------------------------------------
  Widget _buildPitfallCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1.5,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: Color(0xFFD97706),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Here's the part that usually trips people up.",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Keep an eye on edge cases and common misconceptions as you progress into practice questions.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Color(0xFF78350F),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildKeyTakeawaysBox() {
    final takeaways = topic.keyConcepts.isNotEmpty
        ? topic.keyConcepts
        : [
            'Core mental models anchor long-term retention better than rote memorization.',
            'Apply this concept immediately in practice to cement neural pathways.',
          ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Soft emerald tint
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF86EFAC),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.verified_rounded,
                size: 20,
                color: Color(0xFF16A34A),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'KEY TAKEAWAYS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...takeaways.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF14532D),
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. Grounded Knowledge Sources
  // ---------------------------------------------------------------------------
  Widget _buildSourcesCard(List<String> sources) {
    return SkillTwinCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.library_books_rounded, size: 16, color: AppTheme.textSecondary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'GROUNDED KNOWLEDGE SOURCES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...sources.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  const Text('• ', style: TextStyle(color: AppTheme.textSecondary)),
                  Expanded(
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 9. Completion Action Card: I understand this -> Continue to Practice
  // ---------------------------------------------------------------------------
  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.primaryAccent.withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryAccent.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to test your retention?',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Prove your understanding through targeted practice questions.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onUnderstandCompleted();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I understand this — Continue to Practice',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

