import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import '../providers/library_provider.dart';
import '../../../../core/widgets/skilltwin_card.dart';

class PersonalizedNoteScreen extends ConsumerWidget {
  final String resourceId;
  const PersonalizedNoteScreen({super.key, required this.resourceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceAsync = ref.watch(resourceDetailProvider(resourceId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: resourceAsync.when(
        data: (resource) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context, resource),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, dynamic resource) {
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
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: const Text(
          'Mentor Synthesis',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.black87),
          onPressed: () {},
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
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(color: Colors.orange.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.assistant, color: Colors.orange, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'WHY THIS NOTE IS UNIQUE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Instead of a standard summary, I have restructured this information to address your active learning blockers.',
                style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87, fontWeight: FontWeight.w500),
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
            const CircleAvatar(radius: 10, backgroundColor: Colors.orange, child: Icon(Icons.assistant, size: 12, color: Colors.white)),
            const SizedBox(width: 8),
            Text('Synthesized by SkillTwin Mentor', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 40),
        MarkdownBody(
          data: resource.generatedNotes ?? '# No notes available',
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(fontSize: 18, height: 1.7, color: Color(0xFF1A1A1A)),
            h1: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 2.5, color: Colors.black),
            h2: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 2.2, color: Colors.black87),
            h3: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.8, color: Colors.black87),
            listBullet: const TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold),
            blockquote: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
            blockquoteDecoration: BoxDecoration(
              border: const Border(left: BorderSide(color: Colors.orange, width: 4)),
              color: Colors.orange.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextActionFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black,
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
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push('/session/verify_mastery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(60),
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
