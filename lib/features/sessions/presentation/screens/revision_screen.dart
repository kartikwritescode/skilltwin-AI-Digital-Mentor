import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';
import '../../../../core/widgets/skilltwin_transition_switcher.dart';
import '../../../../core/widgets/skilltwin_refresh_indicator.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/skilltwin_twin.dart';
import '../providers/revision_provider.dart';
import '../widgets/mentor_notifications_sheet.dart';
import '../widgets/revision_card.dart';

class RevisionScreen extends ConsumerWidget {
  const RevisionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revisionState = ref.watch(revisionProvider);
    final theme = Theme.of(context);
    final unreadCount = revisionState.unreadNotificationCount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Daily Spaced Revision',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
            ),
            const Text(
              'WILL I REMEMBER IT? • Spaced Retrieval Queue',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryAccent,
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
                      color: AppTheme.primaryAccent,
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
        ],
      ),
      body: SkillTwinBackground(
        child: Center(
          child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SkillTwinRefreshIndicator(
            message: 'SkillTwin is updating revision queue...',
            onRefresh: () async {
              await ref.read(revisionProvider.notifier).loadDueItems();
              await ref.read(revisionProvider.notifier).loadNotifications();
            },
            child: SkillTwinTransitionSwitcher(
              child: revisionState.isLoading
                  ? const SkillTwinLoadingView.fullScreen(
                      key: ValueKey('revision_loading'),
                      message: 'SkillTwin is preparing your next step.',
                      subMessage: 'Gathering your active recall queue...',
                    )
                  : ListView(
                      key: const ValueKey('revision_content'),
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
            color: Color(0xFF1E2238),
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
        color: AppTheme.primaryAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on, color: AppTheme.primaryAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Prioritized Queue (${state.dueItems.length} active)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Focused list',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const EmptyStateView(
      title: 'Retention is optimal',
      message: 'Your mental model is currently stable across all goal-relevant concepts. No immediate decay risk.',
      mascotAsset: TwinAsset.celebrate,
    );
  }
}
