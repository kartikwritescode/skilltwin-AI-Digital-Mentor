import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../journey/presentation/providers/learning_path_provider.dart';
import '../providers/home_provider.dart';
import '../providers/today_task_provider.dart';
import '../../../../core/models/home_dashboard.dart';
import '../../../../core/models/learning_path.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/storage_provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';
import '../../../../core/widgets/skilltwin_transition_switcher.dart';
import '../../../../core/widgets/skilltwin_refresh_indicator.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../widgets/home_header.dart';
import '../widgets/weekly_learning_tracker.dart';
import '../widgets/learning_pace_card.dart';
import '../widgets/todays_task_card.dart';
import '../widgets/active_journey_card.dart';
import '../widgets/empty_journey_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _handleStartSession(
    BuildContext context,
    WidgetRef ref,
    HomeDashboardData data, [
    String? currentTopicId,
    String? currentTopicTitle,
  ]) {
    HapticFeedback.lightImpact();
    final targetTopicId = currentTopicId ??
        data.currentActionableTask?.topicId ??
        data.todayTargetTopicId ??
        data.nextActionTopicId ??
        data.currentTopicId;
    if (targetTopicId != null && targetTopicId.isNotEmpty) {
      ref.read(todayTaskStateProvider.notifier).markStarted(
            topicId: targetTopicId,
            topicTitle: currentTopicTitle ??
                data.currentActionableTask?.title ??
                data.todayTargetTopicTitle,
          );
      context.push('/journey/topic/$targetTopicId');
    } else {
      context.push('/journey');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final learningPathAsync = ref.watch(learningPathProvider);
    final authState = ref.watch(authProvider);
    final todayState = ref.watch(todayTaskStateProvider);

    // Auto-schedule daily native reminders when dashboard loads
    ref.listen<AsyncValue<HomeDashboardData>>(
      homeDashboardProvider,
      (previous, next) {
        next.whenData((data) {
          final targetTopic =
              data.todayTargetTopicTitle ?? data.nextActionTitle;
          if (targetTopic.isNotEmpty) {
            NotificationService.instance.scheduleDailyStudyReminders(
              pendingTopicTitle: targetTopic,
              backlogCount: data.backlogCount,
              dailyMinutes: data.dailyCommitmentMinutes,
            );
          }
        });
      },
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkillTwinBackground(
        child: SafeArea(
          top: true,
          bottom: false,
          child: SkillTwinRefreshIndicator(
            message: 'SkillTwin is updating your daily plan...',
            onRefresh: () async {
              ref.invalidate(homeDashboardProvider);
              ref.invalidate(learningPathProvider);
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: SkillTwinTransitionSwitcher(
                  child: dashboardAsync.when(
                    data: (data) {
                      final hasActiveGoal = data.goalId != null &&
                          data.goalId!.isNotEmpty &&
                          data.goalTitle != 'No Active Goal';

                      return ListView(
                        key: const ValueKey('home_dashboard_content'),
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.screenPadding,
                          AppSpacing.sm,
                          AppSpacing.screenPadding,
                          AppSpacing.calculateBottomNavInset(context), // ← WAS: 96-130px bottom padding
                        ),
                        children: [
                          // ── 1. Greeting Header (Name, Dynamic Greeting, Streak, Notifications) ──
                          HomeHeader(
                            user: authState.user,
                            streakDays: data.streakDays,
                            onNotificationTap: () {
                              _showNotificationTestingSheet(context, ref, data);
                            },
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // ── 2. Weekly Learning / Streak Tracker (Sun - Sat) ──
                          WeeklyLearningTracker(
                            streakDays: data.streakDays,
                            learningPath: learningPathAsync.valueOrNull,
                            isTodayCompleted:
                                todayState.completedTopicIds.isNotEmpty ||
                                todayState.isCompleted ||
                                data.isTodayCompleted ||
                                data.todayStatus.toUpperCase() == 'COMPLETED',
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // ── 3. Learning Pace Card (Compact Adaptive Feedback) ──
                          if (hasActiveGoal || !data.isNewLearner) ...[
                            LearningPaceCard(data: data),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          // ── 4. Today's Task — Dominant Main Card ──
                          if (hasActiveGoal || !data.isNewLearner)
                            TodaysTaskCard(
                              data: data,
                              isCompleted: todayState.isCompleted ||
                                  data.isTodayCompleted ||
                                  data.todayStatus.toUpperCase() == 'COMPLETED' ||
                                  (todayState.tasks.isNotEmpty &&
                                      todayState.tasks.every((t) =>
                                          todayState.completedTopicIds.contains(t.topicId))),
                              isLearning: todayState.isLearning ||
                                  (!todayState.isCompleted &&
                                      data.todayStatus.toUpperCase() == 'LEARNING'),
                              currentTopicTitle: todayState.topicTitle,
                              currentTopicId: todayState.topicId,
                              currentTopicMinutes: todayState.estimatedMinutes,
                              taskIndex: todayState.currentTaskIndex + 1,
                              totalTasks: todayState.totalTasks,
                              onStartSession: () => _handleStartSession(
                                context,
                                ref,
                                data,
                                todayState.topicId,
                                todayState.topicTitle,
                              ),
                            )
                          else
                            const EmptyJourneyCard(),

                          const SizedBox(height: AppSpacing.md),

                          // ── 5. Your Active Journey — Compact Summary Card ──
                          if (hasActiveGoal || !data.isNewLearner) ...[
                            ActiveJourneyCard(data: data),
                            const SizedBox(height: AppSpacing.lg), // Final visual balance
                          ],
                        ],
                      );
                    },
                    loading: () => const SkillTwinLoadingView.fullScreen(
                      key: ValueKey('home_loading'),
                      message: "SkillTwin is preparing your next step.",
                      subMessage: "Calibrating study schedule & daily path...",
                    ),
                    error: (err, _) => KeyedSubtree(
                      key: const ValueKey('home_error'),
                      child: ErrorStateView(
                        error: err.toString(),
                        onRetry: () {
                          ref.invalidate(homeDashboardProvider);
                          ref.invalidate(learningPathProvider);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showNotificationTestingSheet(
  BuildContext context,
  WidgetRef ref,
  HomeDashboardData? dashboard,
) {
  final prefs = ref.read(sharedPrefsProvider);
  final fcmToken = prefs.getString('fcm_token');

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E293B),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active, color: Color(0xFF38BDF8)),
                SizedBox(width: 8),
                Text(
                  'Notification Testing Center',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flash_on, color: Colors.amber, size: 20),
              ),
              title: const Text(
                'Send Instant Trolling Roast',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Fires a sarcastic reminder immediately to your device tray.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
              onTap: () async {
                Navigator.pop(ctx);
                await NotificationService.instance.showInstantTrollNotification(
                  topicTitle: dashboard?.todayTargetTopicTitle,
                  backlogCount: dashboard?.backlogCount,
                  dailyMinutes: dashboard?.dailyCommitmentMinutes,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔔 Trolling reminder sent! Check your notification drawer.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            const Divider(color: Color(0xFF334155), height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cloud_done, color: Colors.greenAccent, size: 20),
              ),
              title: const Text(
                'FCM Device Token (Firebase Cloud Push)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                fcmToken ?? 'Token pending (run on real device or Android emulator with Google Play)',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Color(0xFF38BDF8)),
                tooltip: 'Copy Token for Firebase Console',
                onPressed: fcmToken != null
                    ? () {
                        Clipboard.setData(ClipboardData(text: fcmToken));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📋 FCM Token copied! Paste it in Firebase Console to send test push.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    : null,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}
