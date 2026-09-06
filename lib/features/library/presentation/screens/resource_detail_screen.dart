import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import '../providers/library_provider.dart';
import '../../../../core/models/resource.dart';
import '../../../../core/widgets/skilltwin_card.dart';

class ResourceDetailScreen extends ConsumerWidget {
  final String resourceId;
  const ResourceDetailScreen({super.key, required this.resourceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceAsync = ref.watch(resourceDetailProvider(resourceId));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Resource Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: resourceAsync.when(
        data: (resource) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _HeaderSection(resource: resource),
            const SizedBox(height: 32),
            if (resource.status != ResourceStatus.ready && resource.status != ResourceStatus.failed)
              _ProcessingStatusCard(status: resource.status),
            
            if (resource.status == ResourceStatus.ready) ...[
              _buildSection(
                context,
                title: 'Extracted Concepts',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: resource.extractedConcepts
                      .map((c) => ActionChip(
                            label: Text(c, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.orange.withOpacity(0.05),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            onPressed: () => context.push('/journey/concept/$c'),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSection(
                context,
                title: 'Mentor Synthesis',
                child: SkillTwinCard(
                  padding: const EdgeInsets.all(20),
                  onTap: () => context.push('/library/note/${resource.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.orange, size: 18),
                          const SizedBox(width: 10),
                          const Text(
                            'Personalized Study Note',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Your mentor has synthesized this document based on your active goals and current knowledge gaps.',
                        style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'READ PERSONALIZED NOTE',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSection(
                context,
                title: 'Mapped to Roadmap',
                child: resource.usedByJourneyNodes.isEmpty
                    ? const Text('This resource hasn\'t been mapped to your roadmap yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 14))
                    : Column(
                        children: resource.usedByJourneyNodes
                            .map((node) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.map_outlined, color: Colors.orange),
                                  title: Text(node, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                  onTap: () => context.go('/journey'),
                                ))
                            .toList(),
                      ),
              ),
            ],
            
            if (resource.status == ResourceStatus.failed)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text('Processing failed. Please try re-uploading.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(resourceDetailProvider(resourceId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
            if (resource.url != null)
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Original Resource'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  elevation: 0,
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resource?'),
        content: const Text('This will remove the resource and all generated notes from your library.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              ref.read(libraryProvider.notifier).deleteResource(resourceId);
              Navigator.pop(context); // Dialog
              context.pop(); // Detail Screen
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Resource resource;
  const _HeaderSection({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            resource.type == ResourceType.pdf ? Icons.picture_as_pdf : Icons.link,
            color: Colors.orange,
            size: 32,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resource.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text(
                'Added on ${_formatDate(resource.createdAt)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)} ${date.year}';
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _ProcessingStatusCard extends StatelessWidget {
  final ResourceStatus status;
  const _ProcessingStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return SkillTwinCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Colors.orange)),
          ),
          const SizedBox(height: 20),
          Text(
            _getStatusLabel(status),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your AI mentor is analyzing the document structure and extracting key learning concepts.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(ResourceStatus status) {
    switch (status) {
      case ResourceStatus.uploading: return 'Uploading Document...';
      case ResourceStatus.processing: return 'Analyzing Content...';
      case ResourceStatus.extracting: return 'Extracting Concepts...';
      case ResourceStatus.indexing: return 'Mapping to Knowledge Graph...';
      case ResourceStatus.synthesizing: return 'Synthesizing Personalized Notes...';
      default: return 'Processing...';
    }
  }
}
