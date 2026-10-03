import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';
import '../../../../core/widgets/skilltwin_transition_switcher.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../../../../core/widgets/skilltwin_twin.dart';
import '../../../../core/widgets/skilltwin_markdown.dart';
import '../providers/library_provider.dart';

class PersonalizedNoteScreen extends ConsumerWidget {
  final String resourceId;
  const PersonalizedNoteScreen({super.key, required this.resourceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceAsync = ref.watch(resourceDetailProvider(resourceId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkillTwinBackground(
        child: SkillTwinTransitionSwitcher(
        child: resourceAsync.when(
          data: (resource) => CustomScrollView(
            key: const ValueKey('personalized_note_content'),
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, resource, ref),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSynthesisContext(context, resource),
                      const SizedBox(height: 48),
                      _buildNoteContent(context, resource),
                      const SizedBox(height: 60),
                      _buildNextActionFooter(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          loading: () => const SkillTwinLoadingView.fullScreen(
            key: ValueKey('personalized_note_loading'),
            message: 'SkillTwin is preparing your next step.',
            subMessage: 'Synthesizing personalized notes & takeaways...',
          ),
          error: (err, _) => Center(
            key: const ValueKey('personalized_note_error'),
            child: Text('Error: $err'),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildAppBar(BuildContext context, dynamic resource, WidgetRef ref) {
    final isSaved = ref.watch(libraryProvider).isSaved(resourceId);

    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFFAF9F6),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: const FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 56, bottom: 16),
        title: Text(
          'Mentor Synthesis',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      actions: [
        IconButton(
          tooltip: isSaved ? 'Remove from saved' : 'Save note',
          icon: Icon(
            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: isSaved ? const Color(0xFF6366F1) : Colors.black87,
          ),
          onPressed: () {
            ref.read(libraryProvider.notifier).toggleSave(resourceId);
          },
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSynthesisContext(BuildContext context, dynamic resource) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  SkillTwinTwin(asset: TwinAsset.focused, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'WHY THIS NOTE IS UNIQUE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Instead of a standard summary, I have restructured this information to address your active learning blockers.',
                style: TextStyle(fontSize: 15, height: 1.5, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 20),
              _buildContextTag(Icons.flag, 'Focus: AI Career Goal'),
              const SizedBox(height: 8),
              _buildContextTag(Icons.warning_amber_rounded, 'Fix: Probability Misconception'),
              const SizedBox(height: 8),
              _buildContextTag(Icons.map_outlined, 'Stage: Neural Foundations'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContextTag(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNoteContent(BuildContext context, dynamic resource) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resource.title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const SkillTwinTwin(asset: TwinAsset.reading, size: 24),
            const SizedBox(width: 10),
            Text('Synthesized by SkillTwin Mentor', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 32),
        SkillTwinMarkdown(
          data: resource.generatedNotes ?? '# No notes available',
          selectable: true,
          style: const TextStyle(fontSize: 16.5, height: 1.65, color: Color(0xFF1A1A1A)),
        ),
      ],
    );
  }

  Widget _buildNextActionFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Text(
            'Ready to convert this into mastery?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Your mentor has prepared a validation session based on these notes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push('/session/verify_mastery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('START VALIDATION SESSION', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ),
        ],
      ),
    );
  }
}
