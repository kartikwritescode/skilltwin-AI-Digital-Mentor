import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/api_provider.dart';
import '../../domain/repositories/teach_mode_repository.dart';
import 'teach_mode_repository_impl.dart';

final teachModeRepositoryProvider = Provider<TeachModeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TeachModeRepositoryImpl(apiClient);
});
