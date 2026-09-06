import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/library_provider.dart';
import '../../../../core/models/resource.dart';
import '../../../../core/widgets/skilltwin_card.dart';
import '../../../../core/widgets/mentor_app_bar_action.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../mentor/presentation/providers/mentor_recommendation_provider.dart';
import 'package:intl/intl.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryProvider);
    final notifier = ref.read(libraryProvider.notifier);
    final libraryMentorGuidance = ref.watch(libraryMentorGuidanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Knowledge Library'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF6D00), size: 24),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAddResourceSheet(context, notifier);
            },
          ),
          const MentorAppBarAction(),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WHAT RESOURCES DO I HAVE?',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFFF6D00),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Grounded learning materials synthesized to address your specific cognitive gaps.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _buildMentorResourceBanner(context, libraryMentorGuidance),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: _buildSearchBox(notifier),
              ),
              const _CategoryTabs(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedback.lightImpact();
                    await notifier.loadResources();
                  },
                  child: libraryState.isLoading && libraryState.resources.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SkeletonCardGroup(count: 3, height: 110),
                        )
                      : _buildResourceList(libraryState.resources, notifier, context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMentorResourceBanner(BuildContext context, String guidance) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6D00).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFF6D00).withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFFFF6D00), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRIORITIZED READING',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: Color(0xFFFF6D00),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guidance,
                  style: const TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xFF37474F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox(LibraryNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) => notifier.setSearchQuery(val),
        decoration: const InputDecoration(
          hintText: 'Search resources, concepts, notes...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildResourceList(List<Resource> resources, LibraryNotifier notifier, BuildContext context) {
    if (resources.isEmpty) {
      return EmptyStateView(
        icon: Icons.library_books_outlined,
        title: 'No resources found',
        message: 'Add a PDF, documentation link, or personal note to ground your cognitive model.',
        actionLabel: 'Add First Resource',
        onAction: () => _showAddResourceSheet(context, notifier),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        return _ResourceCard(
          resource: resources[index],
          onDelete: () {
            HapticFeedback.lightImpact();
            notifier.deleteResource(resources[index].id);
          },
        );
      },
    );
  }

  void _showAddResourceSheet(BuildContext context, LibraryNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => _AddResourceSheet(notifier: notifier),
    );
  }
}

class _AddResourceSheet extends StatelessWidget {
  final LibraryNotifier notifier;
  const _AddResourceSheet({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add to Library',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _ActionTile(
              icon: Icons.upload_file,
              title: 'Upload PDF',
              subtitle: 'Extract concepts and generate notes',
              onTap: () async {
                Navigator.pop(context);
                final result = await FilePicker.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                if (result != null && result.files.single.path != null) {
                  final file = File(result.files.single.path!);
                  await notifier.uploadPdf(file, result.files.single.name);
                }
              },
            ),
            _ActionTile(
              icon: Icons.link,
              title: 'Add Web Link',
              subtitle: 'Articles, documentation, or blog posts',
              onTap: () => Navigator.pop(context),
            ),
            _ActionTile(
              icon: Icons.note_add_outlined,
              title: 'Create Personal Note',
              subtitle: 'Type or paste your own study notes',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.orange),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: onTap,
    );
  }
}

class _CategoryTabs extends ConsumerWidget {
  const _CategoryTabs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryProvider);
    final notifier = ref.read(libraryProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ['All', 'PDFs', 'Links', 'Notes'].map((tab) {
          final isSelected = (tab == 'All' && state.typeFilter == null) ||
              (tab == 'PDFs' && state.typeFilter == ResourceType.pdf) ||
              (tab == 'Links' && state.typeFilter == ResourceType.link) ||
              (tab == 'Notes' && state.typeFilter == ResourceType.note);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(tab),
              selected: isSelected,
              onSelected: (_) {
                if (tab == 'All') notifier.setTypeFilter(null);
                if (tab == 'PDFs') notifier.setTypeFilter(ResourceType.pdf);
                if (tab == 'Links') notifier.setTypeFilter(ResourceType.link);
                if (tab == 'Notes') notifier.setTypeFilter(ResourceType.note);
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.orange.shade100,
              labelStyle: TextStyle(
                color: isSelected ? Colors.orange.shade900 : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: isSelected ? Colors.orange : Colors.grey.shade200),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback onDelete;

  const _ResourceCard({required this.resource, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (resource.type) {
      case ResourceType.pdf:
        icon = Icons.picture_as_pdf;
        iconColor = Colors.red.shade400;
        break;
      case ResourceType.link:
      case ResourceType.url:
        icon = Icons.link;
        iconColor = Colors.blue.shade400;
        break;
      case ResourceType.text:
      case ResourceType.note:
        icon = Icons.description;
        iconColor = Colors.amber.shade800;
        break;
      case ResourceType.video:
        icon = Icons.play_circle_fill;
        iconColor = Colors.red;
        break;
    }

    final isProcessing = resource.status != ResourceStatus.ready && resource.status != ResourceStatus.failed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SkillTwinCard(
        onTap: () => context.push('/library/resource/${resource.id}'),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                if (isProcessing)
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.orange)),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (resource.mentorLabel != null) ...[
                         _MentorLabelBadge(label: resource.mentorLabel!),
                         const SizedBox(width: 8),
                      ],
                      _StatusBadge(status: resource.status),
                      if (resource.status != ResourceStatus.ready) const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d').format(resource.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (val) {
                if (val == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ResourceStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == ResourceStatus.ready) return const SizedBox();
    
    Color color;
    String label = status.name.toUpperCase();

    switch (status) {
      case ResourceStatus.failed:
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MentorLabelBadge extends StatelessWidget {
  final ResourceLabel label;
  const _MentorLabelBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    
    switch (label) {
      case ResourceLabel.keep:
        color = Colors.blue;
        text = 'KEEP';
        break;
      case ResourceLabel.useNow:
        color = Colors.green;
        text = 'USE NOW';
        break;
      case ResourceLabel.reference:
        color = Colors.purple;
        text = 'REF';
        break;
      case ResourceLabel.ignore:
        color = Colors.grey;
        text = 'IGNORE';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }
}
