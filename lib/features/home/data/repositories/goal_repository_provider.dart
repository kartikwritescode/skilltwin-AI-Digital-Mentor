import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/../../core/networking/api_provider.dart';
import '../../domain/repositories/goal_repository.dart';
import 'goal_repository_impl.dart';

// Using the same mock logic as Auth if needed, but for now providing the real implementation
// which will fail gracefully or hit the mock backend if configured.
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GoalRepositoryImpl(apiClient);
});
