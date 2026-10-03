import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';
import '../../../../core/widgets/skilltwin_transition_switcher.dart';
import '../../../../core/widgets/skilltwin_refresh_indicator.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../models/twin_companion_persona.dart';
import '../../../../core/models/home_dashboard.dart';
import '../../../../core/models/twin_dashboard.dart';
import '../../data/repositories/twin_repository_provider.dart';
import '../providers/twin_provider.dart';
import '../widgets/twin_companion_hero.dart';
import '../widgets/twin_personality_card.dart';
import '../widgets/twin_knowledge_card.dart';
import '../widgets/twin_current_state_card.dart';
import '../widgets/twin_empty_state_view.dart';

/// The redesigned Cognitive Twin Screen.
/// Transforms the experience from a generic analytics dashboard into the learner's
/// actual living, evolving digital companion with instant first paint and progressive intelligence.
class TwinScreen extends ConsumerWidget {
  const TwinScreen({super.key});

  void _handlePrimaryAction(
    BuildContext context,
    TwinCompanionPersona persona,
    TodayTaskState? todayState,
    HomeDashboardData? homeData,
  ) {
    HapticFeedback.mediumImpact();
    if (persona.isAtRisk) {
      context.push('/twin/maintenance');
      return;
    }

    final targetId = persona.targetTopicId ??
        todayState?.topicId ??
        homeData?.todayTargetTopicId ??
        homeData?.nextActionTopicId;

    if (targetId != null && targetId.isNotEmpty) {
      context.push('/journey/topic/$targetId');
    } else {
      context.push('/journey');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final twinDashboardAsync = ref.watch(twinDashboardProvider);
    final repo = ref.watch(twinRepositoryProvider);
    final homeData = ref.watch(homeDashboardProvider).valueOrNull;
    final todayState = ref.watch(todayTaskStateProvider);

    // ── Phase 3 & 4: Instant First Render via Cache / SWR ──
    final cachedDashboard = repo.getCachedTwinDashboard();
    final dashboard = twinDashboardAsync.valueOrNull ??
        cachedDashboard ??
        (homeData != null ? TwinDashboardData.fromHomeData(homeData) : null);

    final isBackgroundRefreshing = twinDashboardAsync.isLoading && dashboard != null;
    final isOfflineWithCachedData = twinDashboardAsync.hasError && dashboard != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'My Cognitive Twin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Knowledge Maintenance',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_fix_high_rounded,
                size: 19,
                color: Color(0xFF475569),
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/twin/maintenance');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SkillTwinBackground(
        child: SkillTwinRefreshIndicator(
          message: 'SkillTwin is updating your companion...',
          onRefresh: () async {
            ref.invalidate(twinDashboardProvider);
            ref.invalidate(homeDashboardProvider);
            ref.invalidate(learnerStateProvider);
            ref.invalidate(evidenceHistoryProvider);
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SkillTwinTransitionSwitcher(
                child: _buildBody(
                  context: context,
                  ref: ref,
                  dashboard: dashboard,
                  twinDashboardAsync: twinDashboardAsync,
                  homeData: homeData,
                  todayState: todayState,
                  isBackgroundRefreshing: isBackgroundRefreshing,
                  isOfflineWithCachedData: isOfflineWithCachedData,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required WidgetRef ref,
    required TwinDashboardData? dashboard,
    required AsyncValue<TwinDashboardData> twinDashboardAsync,
    required HomeDashboardData? homeData,
    required TodayTaskState? todayState,
    required bool isBackgroundRefreshing,
    required bool isOfflineWithCachedData,
  }) {
    // 1. If we have resolved dashboard data (from API, Cache, or Home state), render immediately!
    if (dashboard != null) {
      if (!dashboard.hasSufficientData) {
        return const KeyedSubtree(
          key: ValueKey('twin_empty_view'),
          child: TwinEmptyStateView(),
        );
      }

      // Compute real-time companion persona from actual learner state
      final persona = TwinCompanionPersona.fromState(
        twinData: dashboard,
        homeData: homeData,
        todayState: todayState,
      );

      return ListView(
        key: const ValueKey('twin_dashboard_content'),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.calculateBottomNavInset(context),
        ),
        children: [
          // ── Subtle Background Sync Indicator (Non-blocking) ──
          if (isBackgroundRefreshing) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Syncing verified memory synapses...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Offline Mode Notice (Non-blocking) ──
          if (isOfflineWithCachedData) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A), width: 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 14, color: Color(0xFFB45309)),
                  SizedBox(width: 8),
                  Text(
                    'Offline mode • Displaying verified local twin state',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── 1. Hero Mascot & Conversational Speech & Primary Action ──
          TwinCompanionHero(
            persona: persona,
            onActionTap: () => _handlePrimaryAction(context, persona, todayState, homeData),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── 2. Supporting Learner Information Card ──
          TwinCurrentStateCard(
            homeData: homeData,
            twinData: dashboard,
            todayState: todayState,
          ),

          const SizedBox(height: AppSpacing.md),

          // ── 3. Learning Personality (Cognitive Dimensions) ──
          TwinPersonalityCard(
            twinData: dashboard,
            homeData: homeData,
            persona: persona,
          ),

          const SizedBox(height: AppSpacing.md),

          // ── 4. What Your Twin Knows (Knowledge Boundaries) ──
          TwinKnowledgeCard(twinData: dashboard),
        ],
      );
    }

    // 2. Cold Start: No cached or home data exists yet
    if (twinDashboardAsync.isLoading) {
      return const SkillTwinLoadingView.fullScreen(
        key: ValueKey('twin_loading'),
        message: 'SkillTwin is preparing your next step.',
        subMessage: 'Synchronizing verified memory traces & cognitive synapses...',
      );
    }

    // 3. Complete Error with no fallback data
    return KeyedSubtree(
      key: const ValueKey('twin_error'),
      child: ErrorStateView(
        error: twinDashboardAsync.error.toString(),
        onRetry: () {
          ref.invalidate(twinDashboardProvider);
          ref.invalidate(homeDashboardProvider);
        },
      ),
    );
  }
}
