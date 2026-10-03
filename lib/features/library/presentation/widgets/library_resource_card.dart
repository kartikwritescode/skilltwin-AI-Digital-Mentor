import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/resource.dart';

class LibraryResourceCard extends StatelessWidget {
  final Resource resource;
  final bool isSaved;
  final VoidCallback onToggleSave;
  final VoidCallback onDelete;

  const LibraryResourceCard({
    super.key,
    required this.resource,
    required this.isSaved,
    required this.onToggleSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color iconColor;
    final Color iconBgColor;
    final String typeBadgeLabel;

    switch (resource.type) {
      case ResourceType.pdf:
        icon = Icons.picture_as_pdf_rounded;
        iconColor = const Color(0xFFE11D48);
        iconBgColor = const Color(0xFFFFF1F2);
        typeBadgeLabel = 'PDF';
        break;
      case ResourceType.link:
      case ResourceType.url:
        icon = Icons.link_rounded;
        iconColor = const Color(0xFF0284C7);
        iconBgColor = const Color(0xFFF0F9FF);
        typeBadgeLabel = 'LINK';
        break;
      case ResourceType.text:
      case ResourceType.note:
        icon = Icons.description_rounded;
        iconColor = const Color(0xFFD97706);
        iconBgColor = const Color(0xFFFFFBEB);
        typeBadgeLabel = 'NOTE';
        break;
      case ResourceType.video:
        icon = Icons.play_circle_fill_rounded;
        iconColor = const Color(0xFF7C3AED);
        iconBgColor = const Color(0xFFF5F3FF);
        typeBadgeLabel = 'VIDEO';
        break;
    }

    final isProcessing = resource.status != ResourceStatus.ready &&
        resource.status != ResourceStatus.failed;

    return Semantics(
      label: '${resource.title}. $typeBadgeLabel. ${isSaved ? "Saved" : "Not saved"}.',
      button: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/library/resource/${resource.id}');
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Format Icon Container ──
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: iconColor.withValues(alpha: 0.18),
                                width: 1,
                              ),
                            ),
                            child: Icon(icon, color: iconColor, size: 22),
                          ),
                          if (isProcessing)
                            Positioned.fill(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(iconColor),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(width: 14),

                      // ── Title & Meta ──
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resource.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Type badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    typeBadgeLabel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF475569),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),

                                // Mentor Label badge
                                if (resource.mentorLabel != null)
                                  _MentorBadge(label: resource.mentorLabel!),

                                // Processing Status badge
                                if (resource.status != ResourceStatus.ready)
                                  _StatusBadge(status: resource.status),

                                // Date added
                                Text(
                                  DateFormat('MMM d').format(resource.createdAt),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Bookmark Save / Unsave Action Button ──
                      IconButton(
                        tooltip: isSaved ? 'Remove from saved' : 'Save resource',
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isSaved
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF94A3B8),
                          size: 22,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onToggleSave();
                        },
                      ),

                      // ── Overflow Popup Menu ──
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (val) {
                          if (val == 'save') {
                            onToggleSave();
                          } else if (val == 'delete') {
                            onDelete();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'save',
                            child: Row(
                              children: [
                                Icon(
                                  isSaved
                                      ? Icons.bookmark_remove_rounded
                                      : Icons.bookmark_add_rounded,
                                  size: 18,
                                  color: const Color(0xFF475569),
                                ),
                                const SizedBox(width: 8),
                                Text(isSaved ? 'Unsave' : 'Save'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded,
                                    size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ── Extracted Concepts Chips Preview ──
                  if (resource.extractedConcepts.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: resource.extractedConcepts.take(3).map((concept) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            concept,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MentorBadge extends StatelessWidget {
  final ResourceLabel label;
  const _MentorBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;

    switch (label) {
      case ResourceLabel.useNow:
        color = const Color(0xFF059669);
        text = 'USE NOW';
        break;
      case ResourceLabel.keep:
        color = const Color(0xFF2563EB);
        text = 'KEEP';
        break;
      case ResourceLabel.reference:
        color = const Color(0xFF7C3AED);
        text = 'REF';
        break;
      case ResourceLabel.ignore:
        color = const Color(0xFF64748B);
        text = 'IGNORE';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
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

    final Color color = status == ResourceStatus.failed
        ? Colors.red
        : AppTheme.primaryAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
