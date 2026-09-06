import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/api_provider.dart';
import '../../domain/repositories/revision_repository.dart';
import 'revision_repository_impl.dart';

final revisionRepositoryProvider = Provider<RevisionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RevisionRepositoryImpl(apiClient);
});
