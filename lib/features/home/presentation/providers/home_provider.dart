import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/home_repository_provider.dart';
import '../../data/repositories/goal_repository_provider.dart';
import '../../../../core/models/goal.dart';
import '../../../../core/models/mentor_message.dart';
import '../../../../core/models/home_dashboard.dart';

export '../../data/repositories/goal_repository_provider.dart' show goalRepositoryProvider;
export '../../../mentor/presentation/providers/mentor_recommendation_provider.dart'
    show nextBestActionProvider, currentMentorRecommendationProvider;

final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getHomeDashboard();
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
