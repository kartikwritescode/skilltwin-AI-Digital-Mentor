import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/revision_provider.dart';
import '../widgets/revision_card.dart';
import '../widgets/mentor_notifications_sheet.dart';
import '../../../../core/widgets/mentor_app_bar_action.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/empty_state_view.dart';

class RevisionScreen extends ConsumerWidget {
  const RevisionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revisionState = ref.watch(revisionProvider);
    final theme = Theme.of(context);
    final unreadCount = revisionState.unreadNotificationCount;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Spaced Revision',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
            ),
            Text(
              'WILL I REMEMBER IT? • Spaced Retrieval Queue',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF6D00),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black87, size: 24),
                tooltip: 'Mentor Notifications',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  MentorNotificationsSheet.show(context);
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6D00),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadCount.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const MentorAppBarAction(),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: revisionState.isLoading
              ? const SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: SkeletonCardGroup(count: 3, height: 120),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedback.lightImpact();
                    await ref.read(revisionProvider.notifier).loadDueItems();
                    await ref.read(revisionProvider.notifier).loadNotifications();
                  },
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      _buildHeader(context, revisionState.header, revisionState.mentorGuidance),
                      const SizedBox(height: 24),
                      if (revisionState.dueItems.isEmpty)
                        _buildEmptyState(context)
                      else ...[
                    _buildQueueSummaryBar(context, revisionState),
                    const SizedBox(height: 16),

                    // Primary review card (highest priority)
                    if (revisionState.primaryItem != null) ...[
                      RevisionCard(
                        item: revisionState.primaryItem!,
                        isPrimary: true,
                        onStart: () => context.push(
                          '/revision/retrieval/${revisionState.primaryItem!.conceptId}',
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Upcoming items (small non-overwhelming list, max 2 items)
                    if (revisionState.upcomingItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'NEXT IN QUEUE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      ...revisionState.upcomingItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: RevisionCard(
                              item: item,
                              isPrimary: false,
                              onStart: () => context.push(
                                '/revision/retrieval/${item.conceptId}',
                              ),
                            ),
                          )),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildHeader(BuildContext context, String header, String guidance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                height: 1.2,
                fontSize: 26,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          guidance,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildQueueSummaryBar(BuildContext context, RevisionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Text(
            'Prioritized Queue (${state.dueItems.length} active)',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            'Focused list',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const EmptyStateView(
      icon: Icons.verified_user_outlined,
      title: 'Retention is optimal',
      message: 'Your mental model is currently stable across all goal-relevant concepts. No immediate decay risk.',
    );
  }
}

