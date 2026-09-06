import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/api_provider.dart';
import '../../domain/repositories/sessions_repository.dart';
import 'sessions_repository_impl.dart';

final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SessionsRepositoryImpl(apiClient);
});
