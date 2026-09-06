import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/api_provider.dart';
import '../../domain/repositories/twin_repository.dart';
import 'twin_repository_impl.dart';

final twinRepositoryProvider = Provider<TwinRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TwinRepositoryImpl(apiClient);
});
