import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/api_provider.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_repository_impl.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepositoryImpl(apiClient);
});
