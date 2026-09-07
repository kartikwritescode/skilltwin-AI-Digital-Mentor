import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/api_provider.dart';
import 'learning_path_repository.dart';

final learningPathRepositoryProvider = Provider<LearningPathRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LearningPathRepositoryImpl(apiClient);
});
