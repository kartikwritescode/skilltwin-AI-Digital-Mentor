import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/home_repository_provider.dart';
import '../../data/repositories/goal_repository_provider.dart';
import '../../../../core/models/goal.dart';
import '../../../../core/models/mentor_message.dart';
import '../../../../core/models/home_dashboard.dart';
import 'today_task_provider.dart';

export '../../data/repositories/goal_repository_provider.dart' show goalRepositoryProvider;
export '../../../mentor/presentation/providers/mentor_recommendation_provider.dart'
    show nextBestActionProvider, currentMentorRecommendationProvider;
export 'today_task_provider.dart';

final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final data = await repository.getHomeDashboard();
  // Automatically synchronize with the reactive today task queue
  try {
    ref.read(todayTaskStateProvider.notifier).syncWithDashboard(data);
  } catch (_) {}
  return data;
});

final activeGoalProvider = FutureProvider<Goal?>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getActiveGoal();
});

final allGoalsProvider = FutureProvider<List<Goal>>((ref) async {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.getGoalHistory();
});

final recentMentorMessagesProvider = FutureProvider<List<MentorMessage>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getRecentMentorMessages();
});
